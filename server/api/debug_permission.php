<?php
require_once __DIR__.'/db.php';
$userId = (int)($_SERVER['HTTP_X_USER_ID'] ?? 0);
$role = getUserRole(getConnection(), $userId);
$module = 'AI Scanning Tools';
$action = 'View';
$allowed = checkPermission(getConnection(), $userId, $module, $action);
header('Content-Type: application/json');
echo json_encode([
    'userId' => $userId,
    'role' => $role,
    'allowed' => $allowed,
]);
?>
