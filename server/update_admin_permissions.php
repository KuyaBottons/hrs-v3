<?php
require_once 'api/db.php';

$conn = getConnection();

// Remove Edit permissions for Admin role (make all modules view-only)
$sql = "UPDATE module_permissions SET granted = 0 WHERE role = 'Admin' AND action = 'Edit'";
$conn->query($sql);

echo "Removed Edit permissions for Admin role. All modules are now view-only for Admin.\n";

// Verify the changes
$result = $conn->query("SELECT module, action, granted FROM module_permissions WHERE role = 'Admin' ORDER BY module, action");
echo "\nCurrent Admin permissions:\n";
while ($row = $result->fetch_assoc()) {
    echo "Module: " . $row['module'] . ", Action: " . $row['action'] . ", Granted: " . $row['granted'] . "\n";
}

$conn->close();
