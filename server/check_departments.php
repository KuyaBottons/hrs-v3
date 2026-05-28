<?php
require_once 'api/db.php';

$conn = getConnection();

// Get all departments
$stmt = $conn->query("SELECT * FROM departments ORDER BY name");
$departments = $stmt->fetch_all(MYSQLI_ASSOC);

echo "Current departments in database:\n";
echo "================================\n";
foreach ($departments as $dept) {
    echo "- {$dept['name']} (Code: {$dept['code']})\n";
}

echo "\nDepartments without KP or GEAMH prefix:\n";
echo "========================================\n";
$nonKpGeamh = [];
foreach ($departments as $dept) {
    if (strpos($dept['name'], 'KP-') !== 0 && strpos($dept['name'], 'GEAMH-') !== 0) {
        $nonKpGeamh[] = $dept;
        echo "- {$dept['name']} (Code: {$dept['code']})\n";
    }
}

echo "\nTotal departments: " . count($departments) . "\n";
echo "Departments without KP/GEAMH: " . count($nonKpGeamh) . "\n";

$conn->close();
?>
