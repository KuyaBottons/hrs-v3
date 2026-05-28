<?php
require_once 'api/db.php';

$conn = getConnection();

// Check current permissions for AI Scanning Tools
echo "Checking current permissions for 'AI Scanning Tools':\n";
echo "========================================================\n";

$result = $conn->query("SELECT * FROM module_permissions WHERE module = 'AI Scanning Tools'");
if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        echo "Role: {$row['role']}, Action: {$row['action']}, Granted: " . ($row['granted'] ? 'YES' : 'NO') . "\n";
    }
} else {
    echo "No permissions found for 'AI Scanning Tools'\n";
}

echo "\n";

// Check what roles exist in the system
echo "Checking user roles:\n";
echo "====================\n";
$roles = $conn->query("SELECT DISTINCT role FROM users WHERE active = 1");
if ($roles) {
    while ($row = $roles->fetch_assoc()) {
        echo "- {$row['role']}\n";
    }
}

$conn->close();
