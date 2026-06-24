<?php
require_once 'db/db_config.php';
$mobile_no = 'TEST_NUMBER';
$otp = 1234;
$now = date('Y-m-d H:i:s');

$stmt = $conn->prepare("INSERT INTO web_codes (u_Id, otp_code, time, status) VALUES (?, ?, ?, 0)");
if (!$stmt) {
    echo "Prepare failed: " . $conn->error;
} else {
    $stmt->bind_param("sis", $mobile_no, $otp, $now);
    if ($stmt->execute()) {
        echo "Insert successful";
    } else {
        echo "Execute failed: " . $stmt->error;
    }
    $stmt->close();
}
$conn->close();
?>