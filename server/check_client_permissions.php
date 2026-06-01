<?php
require_once 'api/db.php';

$conn = getConnection();

// Check Client permissions
$sql = "SELECT module, action, granted FROM module_permissions WHERE role = 'Client' ORDER BY module, action";
$result = $conn->query($sql);

echo "Client permissions:\n";
while ($row = $result->fetch_assoc()) {
    echo "Module: " . $row['module'] . ", Action: " . $row['action'] . ", Granted: " . $row['granted'] . "\n";
}

$conn->close();
