<?php
require_once 'cors_headers.php';
header('Content-Type: text/plain');

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

echo "=== XPOWER DATABASE DOCTOR ===\n";

function check_table($conn, $table) {
    echo "\n[Table: $table]\n";
    $res = $conn->query("DESCRIBE $table");
    if ($res) {
        while($row = $res->fetch_assoc()) {
            echo "Field: " . str_pad($row['Field'], 20) . " | Type: " . $row['Type'] . "\n";
        }
    } else {
        echo "ERROR: Table not found or access denied.\n";
    }
}

check_table($conn, 'partners');
check_table($conn, 'new_clients');
check_table($conn, 'payout_request');
check_table($conn, 'web_codes');

$conn->close();
?>
