<?php
/**
 * Debug: shows current module_permissions and users in the DB
 * Access: http://localhost/hrs-v3/server/check_permissions_debug.php
 * DELETE THIS FILE after debugging.
 */
require_once 'api/db.php';
header('Content-Type: application/json');

$conn = getConnection();

$users = $conn->query('SELECT id, username, name, role, active FROM users ORDER BY id')->fetch_all(MYSQLI_ASSOC);
$perms = $conn->query('SELECT module, role, action, granted FROM module_permissions ORDER BY module, role, action')->fetch_all(MYSQLI_ASSOC);

echo json_encode([
    'users' => $users,
    'module_permissions_count' => count($perms),
    'module_permissions' => $perms,
], JSON_PRETTY_PRINT);
$conn->close();
