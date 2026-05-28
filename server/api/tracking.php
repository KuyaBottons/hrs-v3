<?php
require_once 'db.php';

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
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `direction` ENUM('incoming','outgoing') NOT NULL DEFAULT 'incoming'");
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `route` VARCHAR(255) DEFAULT NULL");
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `linked_outgoing_id` INT DEFAULT NULL");
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `cancelled` TINYINT(1) DEFAULT 0");
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `cancel_reason` TEXT DEFAULT NULL");
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `cancel_pulled_by` VARCHAR(255) DEFAULT NULL");
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `cancel_care_off` VARCHAR(255) DEFAULT NULL");
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `classification` VARCHAR(50) DEFAULT 'Specific'");

        $stmt = $conn->prepare(
            'INSERT INTO document_tracking
             (doc_type, doc_no, from_office, to_office, route, direction,
              date_forwarded, date_received, received_by, status, remarks, linked_outgoing_id, classification)
             VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)'
        );
        $stmt->bind_param(
            'ssssssssssis',
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
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `direction` ENUM('incoming','outgoing') NOT NULL DEFAULT 'incoming'");
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `route` VARCHAR(255) DEFAULT NULL");
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `linked_outgoing_id` INT DEFAULT NULL");
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `cancelled` TINYINT(1) DEFAULT 0");
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `cancel_reason` TEXT DEFAULT NULL");
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `cancel_pulled_by` VARCHAR(255) DEFAULT NULL");
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `cancel_care_off` VARCHAR(255) DEFAULT NULL");
        $conn->query("ALTER TABLE document_tracking ADD COLUMN IF NOT EXISTS `classification` VARCHAR(50) DEFAULT 'Specific'");

        $stmt = $conn->prepare(
            'UPDATE document_tracking SET
             doc_type=?, doc_no=?, from_office=?, to_office=?, route=?, direction=?,
             date_forwarded=?, date_received=?, received_by=?, status=?, remarks=?, linked_outgoing_id=?, classification=?
             WHERE id=?'
        );
        $stmt->bind_param(
            'ssssssssssis',
            $doc_type, $doc_no, $from_office, $to_office, $route, $direction,
            $date_forwarded, $date_received, $received_by, $status, $remarks, $linked_outgoing_id, $classification,
            $id
        );

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
