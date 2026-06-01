<?php
require_once 'api/db.php';

$conn = getConnection();

// Check Admin permissions for Leave Management
$sql = "SELECT module, action, granted FROM module_permissions WHERE role = 'Admin' AND module = 'Leave Management'";
$result = $conn->query($sql);

echo "Admin permissions for Leave Management:\n";
while ($row = $result->fetch_assoc()) {
    echo "Module: " . $row['module'] . ", Action: " . $row['action'] . ", Granted: " . $row['granted'] . "\n";
}

// If View permission is missing or not granted, add it
$checkView = $conn->query("SELECT granted FROM module_permissions WHERE role = 'Admin' AND module = 'Leave Management' AND action = 'View'");
$viewRow = $checkView->fetch_assoc();

if (!$viewRow || $viewRow['granted'] == 0) {
    echo "\nAdding View permission for Admin role on Leave Management...\n";
    
    // Delete existing if any
    $conn->query("DELETE FROM module_permissions WHERE role = 'Admin' AND module = 'Leave Management' AND action = 'View'");
    
    // Insert new permission
    $stmt = $conn->prepare("INSERT INTO module_permissions (role, module, action, granted) VALUES ('Admin', 'Leave Management', 'View', 1)");
    $stmt->execute();
    echo "View permission added successfully.\n";
} else {
    echo "\nView permission already exists and is granted.\n";
}

$conn->close();
