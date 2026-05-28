<?php
require_once 'api/db.php';
$conn = getConnection();

$result = $conn->query('SHOW TABLES LIKE "password_reset_requests"');
if ($result->num_rows > 0) {
    echo "Table exists\n";
    $desc = $conn->query('DESCRIBE password_reset_requests');
    while ($row = $desc->fetch_assoc()) {
        print_r($row);
    }
} else {
    echo "Table does not exist\n";
}
