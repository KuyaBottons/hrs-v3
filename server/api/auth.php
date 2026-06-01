<?php
/**
 * Auth API — login, signup, profile update, user management
 */
ini_set('display_errors', 0);
error_reporting(0);
require_once 'cors.php';
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];
$conn   = getConnection();
$action = $_GET['action'] ?? '';

switch ($action) {

    // POST /auth.php?action=login
    case 'login':
        if ($method !== 'POST') sendError('POST required', 405);
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$data) sendError('Invalid JSON body');

        $biometricsNumber = trim($data['biometrics_number'] ?? '');
        $password = trim($data['password'] ?? '');
        if (!$biometricsNumber || !$password) sendError('Biometrics number and password required');

        // Validate biometrics number - must be 1-4 digits
        if (!preg_match('/^\d{1,4}$/', $biometricsNumber)) {
            sendError('Biometrics number must be 1-4 digits');
        }

        $stmt = $conn->prepare(
            'SELECT id, biometrics_number, name, role, department, position
             FROM users WHERE biometrics_number = ? AND password = SHA2(?, 256) AND active = 1'
        );
        $stmt->bind_param('ss', $biometricsNumber, $password);
        $stmt->execute();
        $user = $stmt->get_result()->fetch_assoc();

        if ($user) {
            // Audit log
            $logStmt = $conn->prepare(
                'INSERT INTO audit_logs (user_id, user_name, action, action_type, module, details, status)
                 VALUES (?,?,?,?,?,?,?)'
            );
            $act    = 'Login';
            $atype  = 'LOGIN';
            $mod    = 'Auth';
            $det    = $user['name'] . ' logged in.';
            $status = 'OK';
            $logStmt->bind_param('issssss', $user['id'], $user['name'], $act, $atype, $mod, $det, $status);
            $logStmt->execute();

            sendJson(['user' => $user, 'message' => 'Login successful']);
        } else {
            sendError('Invalid biometrics number or password.', 401);
        }
        break;

    // POST /auth.php?action=signup
    case 'signup':
        if ($method !== 'POST') sendError('POST required', 405);
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$data) sendError('Invalid JSON body');

        // Check permission for Account Management module
        $userId = (int)($_SERVER['HTTP_X_USER_ID'] ?? 0);
        if (!checkPermission($conn, $userId, 'Account Management', 'Add')) {
            denyAccess('Account Management', 'Add');
        }

        $username         = trim($data['username']         ?? '');
        $biometricsNumber = trim($data['password']          ?? ''); // password field = biometrics number
        $name             = trim($data['name']              ?? '');
        $role             = trim($data['role']              ?? 'Admin');
        $dept             = trim($data['department']        ?? 'Human Resources');
        $position         = trim($data['position']          ?? '');

        if (!$username || !$biometricsNumber || !$name) sendError('Username, biometrics number, and name are required');
        if (!preg_match('/^\d{1,4}$/', $biometricsNumber)) sendError('Biometrics number must be 1–4 digits only');

        $allowed_roles = ['Super Admin', 'Admin', 'DIOS', 'Section Admin', 'IT'];
        if (!in_array($role, $allowed_roles)) sendError('Invalid role');

        // Check duplicate username (case-insensitive)
        $chk = $conn->prepare('SELECT id FROM users WHERE LOWER(username) = LOWER(?)');
        $chk->bind_param('s', $username);
        $chk->execute();
        if ($chk->get_result()->num_rows > 0) {
            $chk->close();
            sendError('Username already exists.', 409);
        }
        $chk->close();

        // Check duplicate biometrics number
        $chk2 = $conn->prepare('SELECT id FROM users WHERE biometrics_number = ?');
        $chk2->bind_param('s', $biometricsNumber);
        $chk2->execute();
        if ($chk2->get_result()->num_rows > 0) {
            $chk2->close();
            sendError('Biometrics number already in use.', 409);
        }
        $chk2->close();

        // Use transaction to prevent race conditions
        $conn->begin_transaction();

        try {
            $stmt = $conn->prepare(
                'INSERT INTO users (username, biometrics_number, password, name, role, department, position)
                 VALUES (?, ?, SHA2(?, 256), ?, ?, ?, ?)'
            );
            $stmt->bind_param('sssssss', $username, $biometricsNumber, $biometricsNumber, $name, $role, $dept, $position);

            if (!$stmt->execute()) {
                throw new Exception('Failed to create account: ' . $stmt->error);
            }

            $insertId = $conn->insert_id;
            $stmt->close();

            $conn->commit();
            sendJson(['id' => $insertId, 'message' => 'Account created'], 201);

        } catch (Exception $e) {
            $conn->rollback();
            sendError($e->getMessage(), 500);
        }
        break;

    // GET /auth.php?action=users
    case 'users':
        if ($method !== 'GET') sendError('GET required', 405);

        // Check permission for Account Management module
        $userId = (int)($_SERVER['HTTP_X_USER_ID'] ?? 0);
        if (!checkPermission($conn, $userId, 'Account Management', 'View')) {
            denyAccess('Account Management', 'View');
        }

        $rows = $conn->query(
            'SELECT id, username, biometrics_number, name, role, department, position, active, created_at FROM users ORDER BY name'
        )->fetch_all(MYSQLI_ASSOC);
        // Mark whether biometrics is set but still expose the value for Account Management
        foreach ($rows as &$row) {
            $row['has_biometrics'] = !empty($row['biometrics_number']);
            // biometrics_number is exposed — only DIOS/Admin can reach this endpoint
        }
        sendJson(['users' => $rows]);
        break;

    // PUT /auth.php?action=update_profile&id=X
    case 'update_profile':
        if ($method !== 'PUT') sendError('PUT required', 405);
        $id   = (int)($_GET['id'] ?? 0);
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$id || !$data) sendError('Invalid request');

        // Check permission for Account Management module
        $userId = (int)($_SERVER['HTTP_X_USER_ID'] ?? 0);
        if (!checkPermission($conn, $userId, 'Account Management', 'Edit')) {
            denyAccess('Account Management', 'Edit');
        }

        $name = trim($data['name'] ?? '');
        $biometricsNumber = trim($data['biometrics_number'] ?? '');
        $role = trim($data['role'] ?? '');
        $dept = trim($data['department'] ?? '');
        $position = trim($data['position'] ?? '');
        $avatar = trim($data['avatar'] ?? '');

        if (!$name) sendError('Name is required');
        if ($biometricsNumber && !preg_match('/^\d{1,4}$/', $biometricsNumber)) {
            sendError('Biometrics number must be 1-4 digits');
        }

        // Build dynamic update query based on provided fields
        $updateFields = ['name = ?'];
        $params = [$name];
        $types = 's';

        if ($biometricsNumber) {
            $updateFields[] = 'biometrics_number = ?';
            $params[] = $biometricsNumber;
            $types .= 's';
        }
        if ($role) {
            $updateFields[] = 'role = ?';
            $params[] = $role;
            $types .= 's';
        }
        if ($dept) {
            $updateFields[] = 'department = ?';
            $params[] = $dept;
            $types .= 's';
        }
        if ($position) {
            $updateFields[] = 'position = ?';
            $params[] = $position;
            $types .= 's';
        }
        if ($avatar) {
            $updateFields[] = 'avatar = ?';
            $params[] = $avatar;
            $types .= 's';
        }

        $params[] = $id;
        $types .= 'i';

        $sql = 'UPDATE users SET ' . implode(', ', $updateFields) . ' WHERE id = ?';
        $stmt = $conn->prepare($sql);
        $stmt->bind_param($types, ...$params);
        $stmt->execute();
        sendJson(['message' => 'Profile updated']);
        break;

    // PUT /auth.php?action=change_password&id=X
    case 'change_password':
        if ($method !== 'PUT') sendError('PUT required', 405);
        $id   = (int)($_GET['id'] ?? 0);
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$id || !$data) sendError('Invalid request');

        // Check permission for Account Management module
        $userId = (int)($_SERVER['HTTP_X_USER_ID'] ?? 0);
        if (!checkPermission($conn, $userId, 'Account Management', 'Edit')) {
            denyAccess('Account Management', 'Edit');
        }

        $newPass = trim($data['password'] ?? '');
        if (strlen($newPass) < 6) sendError('Password must be at least 6 characters');

        $stmt = $conn->prepare('UPDATE users SET password = SHA2(?, 256) WHERE id = ?');
        $stmt->bind_param('si', $newPass, $id);
        $stmt->execute();
        sendJson(['message' => 'Password updated']);
        break;

    // DELETE /auth.php?action=delete_user&id=X
    case 'delete_user':
        if ($method !== 'DELETE') sendError('DELETE required', 405);
        $id = (int)($_GET['id'] ?? 0);
        if (!$id) sendError('ID required');

        // Check permission for Account Management module
        $userId = (int)($_SERVER['HTTP_X_USER_ID'] ?? 0);
        if (!checkPermission($conn, $userId, 'Account Management', 'Delete')) {
            denyAccess('Account Management', 'Delete');
        }

        // Prevent deleting the last Super Admin
        $check = $conn->query("SELECT COUNT(*) as cnt FROM users WHERE role='Super Admin' AND active=1")->fetch_assoc();
        $stmt = $conn->prepare("SELECT role FROM users WHERE id=?");
        $stmt->bind_param('i', $id);
        $stmt->execute();
        $target = $stmt->get_result()->fetch_assoc();
        if ($target && $target['role'] === 'Super Admin' && (int)$check['cnt'] <= 1) {
            sendError('Cannot delete the last Super Admin account', 403);
        }

        // Permanently delete the user from database
        $stmt = $conn->prepare('DELETE FROM users WHERE id = ?');
        $stmt->bind_param('i', $id);
        $stmt->execute();
        sendJson(['message' => 'User permanently deleted']);
        break;

    // PUT /auth.php?action=reactivate_user&id=X
    case 'reactivate_user':
        if ($method !== 'PUT') sendError('PUT required', 405);
        $id = (int)($_GET['id'] ?? 0);
        if (!$id) sendError('ID required');

        // Check permission for Account Management module
        $userId = (int)($_SERVER['HTTP_X_USER_ID'] ?? 0);
        if (!checkPermission($conn, $userId, 'Account Management', 'Edit')) {
            denyAccess('Account Management', 'Edit');
        }

        $stmt = $conn->prepare('UPDATE users SET active = 1 WHERE id = ?');
        $stmt->bind_param('i', $id);
        $stmt->execute();
        sendJson(['message' => 'User reactivated']);
        break;

    // POST /auth.php?action=request_password_reset
    case 'request_password_reset':
        if ($method !== 'POST') sendError('POST required', 405);
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$data) sendError('Invalid JSON body');

        $biometricsNumber = trim($data['biometrics_number'] ?? '');
        if (!$biometricsNumber) sendError('Biometrics number is required');

        // Check if user exists
        $stmt = $conn->prepare('SELECT id, name FROM users WHERE biometrics_number = ? AND active = 1');
        $stmt->bind_param('s', $biometricsNumber);
        $stmt->execute();
        $user = $stmt->get_result()->fetch_assoc();

        if (!$user) {
            sendError('Biometrics number not found or account is inactive', 404);
        }

        // Check if there's already a pending request
        $chk = $conn->prepare('SELECT id FROM password_reset_requests WHERE user_id = ? AND status = ?');
        $status = 'pending';
        $chk->bind_param('is', $user['id'], $status);
        $chk->execute();
        if ($chk->get_result()->num_rows > 0) {
            $chk->close();
            sendError('You already have a pending password reset request. Please contact your administrator.', 409);
        }
        $chk->close();

        // Create password reset request
        $stmt = $conn->prepare(
            'INSERT INTO password_reset_requests (user_id, username, user_name, status)
             VALUES (?, ?, ?, ?)'
        );
        $status = 'pending';
        $stmt->bind_param('isss', $user['id'], $biometricsNumber, $user['name'], $status);

        if (!$stmt->execute()) {
            sendError('Failed to create password reset request: ' . $stmt->error, 500);
        }

        $requestId = $conn->insert_id;

        // Create notification for DIOS users
        require_once 'notification_helpers.php';
        notifyPasswordResetRequest($conn, $biometricsNumber, $user['name'], $requestId);

        sendJson(['message' => 'Password reset request submitted successfully'], 201);
        break;

    // GET /auth.php?action=get_password_reset_requests
    case 'get_password_reset_requests':
        if ($method !== 'GET') sendError('GET required', 405);
        
        // Only DIOS can view password reset requests
        $userId = (int)($_SERVER['HTTP_X_USER_ID'] ?? 0);
        $role = getUserRole($conn, $userId);
        if ($role !== 'DIOS') {
            sendError('Access denied. Only DIOS can view password reset requests.', 403);
        }
        
        $result = $conn->query(
            'SELECT * FROM password_reset_requests ORDER BY requested_at DESC'
        );
        $rows = $result->fetch_all(MYSQLI_ASSOC);
        sendJson(['requests' => $rows]);
        break;

    // POST /auth.php?action=process_password_reset
    case 'process_password_reset':
        if ($method !== 'POST') sendError('POST required', 405);
        
        // Only DIOS can process password reset requests
        $userId = (int)($_SERVER['HTTP_X_USER_ID'] ?? 0);
        $role = getUserRole($conn, $userId);
        if ($role !== 'DIOS') {
            sendError('Access denied. Only DIOS can process password reset requests.', 403);
        }
        
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$data) sendError('Invalid JSON body');

        $requestId = (int)($data['request_id'] ?? 0);
        $targetUserId = (int)($data['user_id'] ?? 0);
        $action = $data['action'] ?? ''; // 'approve' or 'reject'
        $newPassword = $data['new_password'] ?? '';

        if (!$requestId || !$targetUserId || !$action) {
            sendError('Missing required fields');
        }

        if (!in_array($action, ['approve', 'reject'])) {
            sendError('Invalid action. Must be approve or reject');
        }

        // Get current user name
        $stmt = $conn->prepare('SELECT name FROM users WHERE id = ?');
        $stmt->bind_param('i', $userId);
        $stmt->execute();
        $currentUser = $stmt->get_result()->fetch_assoc();
        $processedBy = $currentUser['name'] ?? 'DIOS';

        $conn->begin_transaction();
        
        try {
            if ($action === 'approve') {
                if (!$newPassword || strlen($newPassword) < 6) {
                    throw new Exception('New password must be at least 6 characters');
                }

                // Update user password
                $stmt = $conn->prepare('UPDATE users SET password = SHA2(?, 256) WHERE id = ?');
                $stmt->bind_param('si', $newPassword, $targetUserId);
                if (!$stmt->execute()) {
                    throw new Exception('Failed to update password');
                }

                // Update request status
                $stmt = $conn->prepare(
                    'UPDATE password_reset_requests 
                     SET status = ?, processed_at = NOW(), processed_by = ?
                     WHERE id = ?'
                );
                $status = 'approved';
                $stmt->bind_param('ssi', $status, $processedBy, $requestId);
                $stmt->execute();

                $conn->commit();
                sendJson(['message' => 'Password reset successful']);
                
            } else { // reject
                $stmt = $conn->prepare(
                    'UPDATE password_reset_requests 
                     SET status = ?, processed_at = NOW(), processed_by = ?
                     WHERE id = ?'
                );
                $status = 'rejected';
                $stmt->bind_param('ssi', $status, $processedBy, $requestId);
                $stmt->execute();

                $conn->commit();
                sendJson(['message' => 'Request rejected']);
            }
            
        } catch (Exception $e) {
            $conn->rollback();
            sendError($e->getMessage(), 500);
        }
        break;

    default:
        sendError('Unknown action', 400);
}

$conn->close();
