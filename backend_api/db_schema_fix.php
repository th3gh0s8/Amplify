<?php
// GLOBAL SCHEMA ALIGNMENT - FINAL VERSION
ini_set('display_errors', 1);
error_reporting(E_ALL);

require_once 'cors_headers.php';
if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

echo "<h2>XPower Database Schema Alignment</h2>";

$conn->query("SET FOREIGN_KEY_CHECKS = 0");

echo "<h3>1. Adding Missing Columns to 'partners' Table...</h3>";

$columns = [
    "partner_type"   => "ENUM('freelancer', 'business') DEFAULT 'freelancer' AFTER remarks",
    "nic_number"     => "VARCHAR(20) NULL AFTER partner_type",
    "business_name"  => "VARCHAR(100) NULL AFTER nic_number",
    "business_type"  => "VARCHAR(50) NULL AFTER business_name",
    "address_line1"  => "VARCHAR(255) NULL AFTER business_type",
    "city"           => "VARCHAR(50) NULL AFTER address_line1",
    "tax_id"         => "VARCHAR(50) NULL AFTER city",
    "website"        => "VARCHAR(100) NULL AFTER tax_id"
];

foreach ($columns as $col => $definition) {
    $check = $conn->query("SHOW COLUMNS FROM partners LIKE '$col'");
    if ($check->num_rows == 0) {
        $conn->query("ALTER TABLE partners ADD $col $definition");
        echo "ADDED: $col<br>";
    } else {
        echo "EXISTS: $col<br>";
    }
}

$conn->query("SET FOREIGN_KEY_CHECKS = 1");

echo "<hr><h2 style='color:green'>SCHEMA ALIGNED!</h2>";
echo "<p>Please delete this file and update your PHP scripts.</p>";

$conn->close();
?>
