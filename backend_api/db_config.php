<?php
$host = "localhost";
$user = "root";
$pass = "";
$dbname = "xpartner";

$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]));
}
?>
