<?php
$host = "localhost";
$user = "root";
$pass = "";
$dbname = "xpartner";

// Check if we are on production
if ($_SERVER['HTTP_HOST'] === 'powersoftt.com') {
    $user = "stcloudb_xPartners";
    $pass = "xPartner-2026-05-05";
    $dbname = "stcloudb_xpower_partners";
}

$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]));
}
?>
