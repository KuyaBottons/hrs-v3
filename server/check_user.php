<?php
require_once 'api/db.php';

$conn = getConnection();

// Check if user exists
$biometricsNumber = '1234';
$stmt = $conn->prepare('SELECT id, biometrics_number, name, role, active FROM users WHERE biometrics_number = ?');
$stmt->bind_param('s', $biometricsNumber);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

if ($user) {
    echo "Found user:\n";
    echo "ID: " . $user['id'] . "\n";
    echo "Biometrics Number: " . $user['biometrics_number'] . "\n";
    echo "Name: " . $user['name'] . "\n";
    echo "Role: " . $user['role'] . "\n";
    echo "Active: " . $user['active'] . "\n";
    
    // Update password to 567890
    $password = '567890';
    $updateStmt = $conn->prepare('UPDATE users SET password = SHA2(?, 256) WHERE biometrics_number = ?');
    $updateStmt->bind_param('ss', $password, $biometricsNumber);
    $updateStmt->execute();
    echo "\nPassword updated to: 567890\n";
} else {
    echo "User not found with biometrics number: " . $biometricsNumber . "\n";
    
    // Show all users
    echo "\nAll users in database:\n";
    $result = $conn->query('SELECT id, biometrics_number, name, role, active FROM users');
    while ($row = $result->fetch_assoc()) {
        echo "ID: " . $row['id'] . ", Biometrics: " . $row['biometrics_number'] . ", Name: " . $row['name'] . ", Role: " . $row['role'] . ", Active: " . $row['active'] . "\n";
    }
}

$conn->close();
