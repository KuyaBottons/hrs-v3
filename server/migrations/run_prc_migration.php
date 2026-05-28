<?php
/**
 * PRC Licenses Migration Runner
 */

// Database connection
$host = 'localhost';
$user = 'root';
$pass = '';
$db = 'geamh_hris';

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error . "\n");
}

echo "Starting PRC Licenses migration...\n\n";

// Read and execute the table creation SQL
$sql = file_get_contents(__DIR__ . '/add_prc_licenses_table.sql');
if ($conn->multi_query($sql)) {
    echo "✓ PRC Licenses table created\n";
    while ($conn->more_results() && $conn->next_result()) {
        if ($result = $conn->store_result()) {
            $result->free();
        }
    }
} else {
    echo "⚠ " . $conn->error . "\n";
}

// Read and execute the permissions SQL
$sql = file_get_contents(__DIR__ . '/add_prc_licenses_permissions.sql');
if ($conn->multi_query($sql)) {
    echo "✓ PRC Licenses permissions added\n";
    while ($conn->more_results() && $conn->next_result()) {
        if ($result = $conn->store_result()) {
            $result->free();
        }
    }
} else {
    echo "⚠ " . $conn->error . "\n";
}

// Verification
echo "\n" . str_repeat('=', 60) . "\n";
echo "Verification:\n";

$result = $conn->query("SELECT COUNT(*) as count FROM prc_licenses");
if ($result) {
    $row = $result->fetch_assoc();
    echo "✓ prc_licenses: {$row['count']} records\n";
}

$result = $conn->query("SELECT COUNT(*) as count FROM module_permissions WHERE module = 'PRC Licenses'");
if ($result) {
    $row = $result->fetch_assoc();
    echo "✓ PRC Licenses permissions: {$row['count']} permissions\n";
}

echo str_repeat('=', 60) . "\n";
echo "\n✓ PRC Licenses migration completed successfully!\n";

$conn->close();
