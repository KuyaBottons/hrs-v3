<?php
error_reporting(0);
ini_set('display_errors', 0);
require_once 'db.php';
require_once 'cors.php';

$method = $_SERVER['REQUEST_METHOD'];
$conn   = getConnection();
$userId = (int)($_SERVER['HTTP_X_USER_ID'] ?? 0);

// Map HTTP methods to actions
$actionMap = [
    'GET'    => 'View',
    'POST'   => 'Add',
    'PUT'    => 'Edit',
    'DELETE' => 'Delete',
];
$action = $actionMap[$method] ?? 'View';

// Check permission before processing request
if (!checkPermission($conn, $userId, 'Tracking / Receiving', $action)) {
    denyAccess('Tracking / Receiving', $action);
}

switch ($method) {

    case 'GET':
        if (isset($_GET['id'])) {
            $id   = (int) $_GET['id'];
            $stmt = $conn->prepare('SELECT * FROM document_tracking WHERE id = ?');
            $stmt->bind_param('i', $id);
            $stmt->execute();
            $row = $stmt->get_result()->fetch_assoc();
            $row ? sendJson($row) : sendError('Record not found', 404);
        } else {
            $result = $conn->query('SELECT * FROM document_tracking ORDER BY created_at DESC');
            sendJson($result->fetch_all(MYSQLI_ASSOC));
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$data) sendError('Invalid JSON body');

        $doc_type      = trim($data['doc_type']      ?? '');
        $doc_no        = trim($data['doc_no']        ?? '');
        $from_office   = trim($data['from_office']   ?? '');
        $to_office     = trim($data['to_office']     ?? '');
        $route         = trim($data['route']         ?? '');
        $direction     = trim($data['direction']     ?? 'incoming'); // incoming | outgoing
        $date_forwarded = ($data['date_forwarded'] ?? '') ?: null;
        $date_received  = ($data['date_received']  ?? '') ?: null;
        $received_by   = trim($data['received_by']  ?? '');
        $status        = trim($data['status']        ?? 'Pending');
        $remarks       = trim($data['remarks']       ?? '');
        $linked_outgoing_id = isset($data['linked_outgoing_id']) ? (int) $data['linked_outgoing_id'] : null;
        $classification = trim($data['classification'] ?? 'Specific');

        // Auto-generate document number if not provided
        if (!$doc_no) {
            $result = $conn->query("SELECT MAX(CAST(SUBSTRING(doc_no, 4) AS UNSIGNED)) as max_no FROM document_tracking WHERE doc_no LIKE 'DOC-%'");
            $row = $result->fetch_assoc();
            $next_no = ($row['max_no'] ?? 0) + 1;
            $doc_no = 'DOC-' . str_pad($next_no, 3, '0', STR_PAD_LEFT); // DOC-001, DOC-002, etc.
        }

        if (!$doc_type) sendError('Document type is required');

        // Add columns if they don't exist yet (safe migration)
        $columns = [
            'direction' => "ALTER TABLE document_tracking ADD COLUMN `direction` ENUM('incoming','outgoing') NOT NULL DEFAULT 'incoming'",
            'route' => "ALTER TABLE document_tracking ADD COLUMN `route` VARCHAR(255) DEFAULT NULL",
            'linked_outgoing_id' => "ALTER TABLE document_tracking ADD COLUMN `linked_outgoing_id` INT DEFAULT NULL",
            'cancelled' => "ALTER TABLE document_tracking ADD COLUMN `cancelled` TINYINT(1) DEFAULT 0",
            'cancel_reason' => "ALTER TABLE document_tracking ADD COLUMN `cancel_reason` TEXT DEFAULT NULL",
            'cancel_pulled_by' => "ALTER TABLE document_tracking ADD COLUMN `cancel_pulled_by` VARCHAR(255) DEFAULT NULL",
            'cancel_care_off' => "ALTER TABLE document_tracking ADD COLUMN `cancel_care_off` VARCHAR(255) DEFAULT NULL",
            'classification' => "ALTER TABLE document_tracking ADD COLUMN `classification` VARCHAR(50) DEFAULT 'Specific'"
        ];
        foreach ($columns as $col => $sql) {
            $result = @$conn->query("SHOW COLUMNS FROM document_tracking LIKE '$col'");
            if ($result && $result->num_rows == 0) {
                @$conn->query($sql);
            }
        }

        $stmt = $conn->prepare(
            'INSERT INTO document_tracking
             (doc_type, doc_no, from_office, to_office, route, direction,
              date_forwarded, date_received, received_by, status, remarks, linked_outgoing_id, classification)
             VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)'
        );
        $stmt->bind_param(
            'sssssssssssis',
            $doc_type, $doc_no, $from_office, $to_office, $route, $direction,
            $date_forwarded, $date_received, $received_by, $status, $remarks, $linked_outgoing_id, $classification
        );

        if (!$stmt->execute()) sendError('Insert failed: ' . $stmt->error, 500);
        sendJson(['id' => $conn->insert_id, 'doc_no' => $doc_no, 'message' => 'Tracking record created'], 201);
        break;

    case 'PUT':
        // Handle mark as cancelled
        if (isset($_GET['action']) && $_GET['action'] === 'cancel') {
            $id = (int) ($_GET['id'] ?? 0);
            $data = json_decode(file_get_contents('php://input'), true);
            if (!$id || !$data) sendError('Invalid request');

            $cancel_reason = trim($data['cancel_reason'] ?? '');
            $cancel_pulled_by = trim($data['cancel_pulled_by'] ?? '');
            $cancel_care_off = trim($data['cancel_care_off'] ?? '');

            if (!$cancel_reason) sendError('Cancellation reason is required');

            $stmt = $conn->prepare(
                'UPDATE document_tracking SET cancelled=1, cancel_reason=?, cancel_pulled_by=?, cancel_care_off=? WHERE id=?'
            );
            $stmt->bind_param('sssi', $cancel_reason, $cancel_pulled_by, $cancel_care_off, $id);

            if (!$stmt->execute()) sendError('Cancel failed: ' . $stmt->error, 500);
            sendJson(['message' => 'Tracking record marked as cancelled']);
            break;
        }

        $id   = (int) ($_GET['id'] ?? 0);
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$id || !$data) sendError('Invalid request');

        $doc_type      = trim($data['doc_type']      ?? '');
        $doc_no        = trim($data['doc_no']        ?? '');
        $from_office   = trim($data['from_office']   ?? '');
        $to_office     = trim($data['to_office']     ?? '');
        $route         = trim($data['route']         ?? '');
        $direction     = trim($data['direction']     ?? 'incoming');
        $date_forwarded = ($data['date_forwarded'] ?? '') ?: null;
        $date_received  = ($data['date_received']  ?? '') ?: null;
        $received_by   = trim($data['received_by']  ?? '');
        $status        = trim($data['status']        ?? 'Pending');
        $remarks       = trim($data['remarks']       ?? '');
        $linked_outgoing_id = isset($data['linked_outgoing_id']) ? (int) $data['linked_outgoing_id'] : null;
        $classification = trim($data['classification'] ?? 'Specific');

        // Add columns if they don't exist yet (safe migration)
        $columns = [
            'direction' => "ALTER TABLE document_tracking ADD COLUMN `direction` ENUM('incoming','outgoing') NOT NULL DEFAULT 'incoming'",
            'route' => "ALTER TABLE document_tracking ADD COLUMN `route` VARCHAR(255) DEFAULT NULL",
            'linked_outgoing_id' => "ALTER TABLE document_tracking ADD COLUMN `linked_outgoing_id` INT DEFAULT NULL",
            'cancelled' => "ALTER TABLE document_tracking ADD COLUMN `cancelled` TINYINT(1) DEFAULT 0",
            'cancel_reason' => "ALTER TABLE document_tracking ADD COLUMN `cancel_reason` TEXT DEFAULT NULL",
            'cancel_pulled_by' => "ALTER TABLE document_tracking ADD COLUMN `cancel_pulled_by` VARCHAR(255) DEFAULT NULL",
            'cancel_care_off' => "ALTER TABLE document_tracking ADD COLUMN `cancel_care_off` VARCHAR(255) DEFAULT NULL",
            'classification' => "ALTER TABLE document_tracking ADD COLUMN `classification` VARCHAR(50) DEFAULT 'Specific'"
        ];
        foreach ($columns as $col => $sql) {
            $result = @$conn->query("SHOW COLUMNS FROM document_tracking LIKE '$col'");
            if ($result && $result->num_rows == 0) {
                @$conn->query($sql);
            }
        }

        // Build dynamic UPDATE query to handle NULL values
        $updateFields = [];
        $updateValues = [];
        $types = '';

        $fields = [
            'doc_type' => ['value' => $doc_type, 'type' => 's'],
            'doc_no' => ['value' => $doc_no, 'type' => 's'],
            'from_office' => ['value' => $from_office, 'type' => 's'],
            'to_office' => ['value' => $to_office, 'type' => 's'],
            'route' => ['value' => $route, 'type' => 's'],
            'direction' => ['value' => $direction, 'type' => 's'],
            'date_forwarded' => ['value' => $date_forwarded, 'type' => 's'],
            'date_received' => ['value' => $date_received, 'type' => 's'],
            'received_by' => ['value' => $received_by, 'type' => 's'],
            'status' => ['value' => $status, 'type' => 's'],
            'remarks' => ['value' => $remarks, 'type' => 's'],
            'linked_outgoing_id' => ['value' => $linked_outgoing_id, 'type' => 'i'],
            'classification' => ['value' => $classification, 'type' => 's'],
        ];

        foreach ($fields as $field => $info) {
            $updateFields[] = "$field = ?";
            $updateValues[] = $info['value'];
            $types .= $info['type'];
        }

        $sql = 'UPDATE document_tracking SET ' . implode(', ', $updateFields) . ' WHERE id = ?';
        $updateValues[] = $id;
        $types .= 'i';

        $stmt = $conn->prepare($sql);
        $stmt->bind_param($types, ...$updateValues);

        if (!$stmt->execute()) sendError('Update failed: ' . $stmt->error, 500);
        sendJson(['message' => 'Tracking record updated']);
        break;

    case 'DELETE':
        $id = (int) ($_GET['id'] ?? 0);
        if (!$id) sendError('ID required');

        // Check if user is DIOS account
        $stmt = $conn->prepare('SELECT username FROM users WHERE id = ?');
        $stmt->bind_param('i', $userId);
        $stmt->execute();
        $user = $stmt->get_result()->fetch_assoc();
        
        if (!$user || strtolower($user['username']) !== 'dios') {
            sendError('Only DIOS account can delete tracking records', 403);
        }

        // Check for signature/pin in request
        $data = json_decode(file_get_contents('php://input'), true);
        $pin = trim($data['pin'] ?? '');
        
        if (!$pin || !preg_match('/^\d{4}$/', $pin)) {
            sendError('4-digit PIN is required for deletion');
        }

        // Verify PIN (you may need to add a pin column to users table or use another authentication method)
        // For now, we'll just check if it's a 4-digit number
        // In production, you should verify against a stored PIN
        
        $stmt = $conn->prepare('DELETE FROM document_tracking WHERE id = ?');
        $stmt->bind_param('i', $id);
        $stmt->execute();
        sendJson(['message' => 'Tracking record deleted']);
        break;

    default:
        sendError('Method not allowed', 405);
}

$conn->close();
