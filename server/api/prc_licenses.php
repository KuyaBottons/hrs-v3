<?php
require_once 'db.php';
require_once 'cors.php';

// Wrap everything in try-catch to ensure JSON response
try {
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
if (!checkPermission($conn, $userId, 'PRC Licenses', $action)) {
    denyAccess('PRC Licenses', $action);
}

switch ($method) {

    // GET /prc_licenses.php -> all PRC licenses
    // GET /prc_licenses.php?id=1 -> specific license
    // GET /prc_licenses.php?employee_id=1 -> licenses for specific employee
    case 'GET':
        if (isset($_GET['id'])) {
            $id   = (int) $_GET['id'];
            $stmt = $conn->prepare('SELECT pl.*, e.first_name, e.last_name, e.position, e.department FROM prc_licenses pl JOIN employees e ON pl.employee_id = e.id WHERE pl.id = ?');
            $stmt->bind_param('i', $id);
            $stmt->execute();
            $row = $stmt->get_result()->fetch_assoc();
            $row ? sendJson($row) : sendError('PRC license not found', 404);
        } elseif (isset($_GET['employee_id'])) {
            $employeeId = (int) $_GET['employee_id'];
            $stmt = $conn->prepare('SELECT pl.*, e.first_name, e.last_name, e.position, e.department FROM prc_licenses pl JOIN employees e ON pl.employee_id = e.id WHERE pl.employee_id = ? ORDER BY pl.expiry_date DESC');
            $stmt->bind_param('i', $employeeId);
            $stmt->execute();
            $rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
            sendJson($rows);
        } else {
            $sql = 'SELECT pl.*, e.first_name, e.last_name, e.position, e.department FROM prc_licenses pl JOIN employees e ON pl.employee_id = e.id ORDER BY pl.expiry_date DESC';
            $rows = $conn->query($sql)->fetch_all(MYSQLI_ASSOC);
            sendJson($rows);
        }
        break;

    // POST /prc_licenses.php -> create
    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (!$data || empty($data['employee_id']) || empty($data['license_number']) || empty($data['expiry_date'])) {
            sendError('Employee ID, license number, and expiry date are required');
        }

        $employeeId   = (int) $data['employee_id'];
        $licenseNumber = trim($data['license_number']);
        $expiryDate   = $data['expiry_date'];
        $remarks       = trim($data['remarks'] ?? '');

        // Verify employee exists
        $checkStmt = $conn->prepare('SELECT id FROM employees WHERE id = ?');
        $checkStmt->bind_param('i', $employeeId);
        $checkStmt->execute();
        if (!$checkStmt->get_result()->fetch_assoc()) {
            sendError('Employee not found', 404);
        }

        $stmt = $conn->prepare(
            'INSERT INTO prc_licenses (employee_id, license_number, expiry_date, remarks) VALUES (?,?,?,?)'
        );
        $stmt->bind_param('isss', $employeeId, $licenseNumber, $expiryDate, $remarks);

        if (!$stmt->execute()) {
            if ($conn->errno === 1062) {
                sendError('License already exists for this employee', 409);
            }
            sendError('Insert failed: ' . $stmt->error, 500);
        }
        
        sendJson(['id' => $conn->insert_id, 'message' => 'PRC license created'], 201);
        break;

    // PUT /prc_licenses.php?id=1 -> update
    case 'PUT':
        $id   = (int) ($_GET['id'] ?? 0);
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$id || !$data) sendError('Invalid request');

        $licenseNumber = trim($data['license_number'] ?? '');
        $expiryDate   = $data['expiry_date'] ?? '';
        $remarks       = trim($data['remarks'] ?? '');

        if (!$licenseNumber || !$expiryDate) sendError('License number and expiry date are required');

        $stmt = $conn->prepare(
            'UPDATE prc_licenses SET license_number=?, expiry_date=?, remarks=? WHERE id=?'
        );
        $stmt->bind_param('sssi', $licenseNumber, $expiryDate, $remarks, $id);

        if (!$stmt->execute()) {
            if ($conn->errno === 1062) sendError('License already exists for this employee', 409);
            sendError('Update failed: ' . $stmt->error, 500);
        }
        sendJson(['message' => 'PRC license updated']);
        break;

    // DELETE /prc_licenses.php?id=1 -> delete
    case 'DELETE':
        $id = (int) ($_GET['id'] ?? 0);
        if (!$id) sendError('ID required');
        $stmt = $conn->prepare('DELETE FROM prc_licenses WHERE id = ?');
        $stmt->bind_param('i', $id);
        $stmt->execute();
        sendJson(['message' => 'PRC license deleted']);
        break;

    default:
        sendError('Method not allowed', 405);
}

$conn->close();

} catch (Exception $e) {
    // Ensure we always return JSON even on error
    http_response_code(500);
    header('Content-Type: application/json');
    echo json_encode([
        'error' => 'Server error: ' . $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
}
