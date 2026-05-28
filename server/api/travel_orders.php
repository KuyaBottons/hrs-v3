<?php
require_once 'db.php';
require_once 'notification_helpers.php';

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
if (!checkPermission($conn, $userId, 'Travel Orders', $action)) {
    denyAccess('Travel Orders', $action);
}

switch ($method) {

    case 'GET':
        if (isset($_GET['id'])) {
            $id   = (int) $_GET['id'];
            $stmt = $conn->prepare('SELECT * FROM travel_orders WHERE id = ?');
            $stmt->bind_param('i', $id);
            $stmt->execute();
            $row = $stmt->get_result()->fetch_assoc();
            $row ? sendJson($row) : sendError('Record not found', 404);
        } else {
            $result = $conn->query('SELECT * FROM travel_orders ORDER BY date_from DESC');
            sendJson($result->fetch_all(MYSQLI_ASSOC));
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$data) sendError('Invalid JSON body');

        // Add columns if they don't exist yet (safe migration)
        $conn->query("ALTER TABLE travel_orders ADD COLUMN IF NOT EXISTS `ca_passed` TINYINT(1) DEFAULT 0");
        $conn->query("ALTER TABLE travel_orders ADD COLUMN IF NOT EXISTS `ca_date` DATE DEFAULT NULL");
        $conn->query("ALTER TABLE travel_orders ADD COLUMN IF NOT EXISTS `ca_received_by` VARCHAR(255) DEFAULT NULL");
        $conn->query("ALTER TABLE travel_orders ADD COLUMN IF NOT EXISTS `accomplishment_report` TEXT DEFAULT NULL");

        $stmt = $conn->prepare(
            'INSERT INTO travel_orders
             (employee_id, employee_no, employee_name, department, destination,
              purpose, date_from, date_to, days, transport, approved_by, status, remarks,
              ca_passed, ca_date, ca_received_by, accomplishment_report)
             VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
        );
        $stmt->bind_param(
            'isssssssdssssiss',
            $data['employee_id'],
            $data['employee_no'],
            $data['employee_name'],
            $data['department'],
            $data['destination'],
            $data['purpose'],
            $data['date_from'],
            $data['date_to'],
            $data['days'],
            $data['transport'],
            $data['approved_by'],
            $data['status'],
            $data['remarks'],
            isset($data['ca_passed']) ? (int)$data['ca_passed'] : 0,
            $data['ca_date'] ?? null,
            $data['ca_received_by'] ?? null,
            $data['accomplishment_report'] ?? null
        );
        $stmt->execute();
        
        $toId = $conn->insert_id;
        $employeeName = $data['employee_name'];
        $destination = $data['destination'];
        notifyTravelOrder($conn, $employeeName, $destination, $toId);
        
        sendJson(['id' => $toId, 'message' => 'Travel order created'], 201);
        break;

    case 'PUT':
        $id   = (int) ($_GET['id'] ?? 0);
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$id || !$data) sendError('Invalid request');

        // Add columns if they don't exist yet (safe migration)
        $conn->query("ALTER TABLE travel_orders ADD COLUMN IF NOT EXISTS `ca_passed` TINYINT(1) DEFAULT 0");
        $conn->query("ALTER TABLE travel_orders ADD COLUMN IF NOT EXISTS `ca_date` DATE DEFAULT NULL");
        $conn->query("ALTER TABLE travel_orders ADD COLUMN IF NOT EXISTS `ca_received_by` VARCHAR(255) DEFAULT NULL");
        $conn->query("ALTER TABLE travel_orders ADD COLUMN IF NOT EXISTS `accomplishment_report` TEXT DEFAULT NULL");

        $stmt = $conn->prepare(
            'UPDATE travel_orders SET
             employee_id=?, employee_no=?, employee_name=?, department=?, destination=?,
             purpose=?, date_from=?, date_to=?, days=?, transport=?,
             approved_by=?, status=?, remarks=?,
             ca_passed=?, ca_date=?, ca_received_by=?, accomplishment_report=?
             WHERE id=?'
        );
        $stmt->bind_param(
            'isssssssdssssissi',
            $data['employee_id'],
            $data['employee_no'],
            $data['employee_name'],
            $data['department'],
            $data['destination'],
            $data['purpose'],
            $data['date_from'],
            $data['date_to'],
            $data['days'],
            $data['transport'],
            $data['approved_by'],
            $data['status'],
            $data['remarks'],
            isset($data['ca_passed']) ? (int)$data['ca_passed'] : 0,
            $data['ca_date'] ?? null,
            $data['ca_received_by'] ?? null,
            $data['accomplishment_report'] ?? null,
            $id
        );
        $stmt->execute();
        sendJson(['message' => 'Travel order updated']);
        break;

    case 'DELETE':
        $id = (int) ($_GET['id'] ?? 0);
        if (!$id) sendError('ID required');
        $stmt = $conn->prepare('DELETE FROM travel_orders WHERE id = ?');
        $stmt->bind_param('i', $id);
        $stmt->execute();
        sendJson(['message' => 'Travel order deleted']);
        break;

    default:
        sendError('Method not allowed', 405);
}

$conn->close();
