<?php
header('Content-Type: application/json');
require_once 'db_config.php';

$mobile_no = $_GET['mobile_no'] ?? '';

if (empty($mobile_no)) {
    echo json_encode(["success" => false, "message" => "Mobile number is required"]);
    exit;
}

$stmt = $conn->prepare("SELECT * FROM partners WHERE mobile_no = ?");
$stmt->bind_param("i", $mobile_no);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $partner = $result->fetch_assoc();
    // Generate a dummy OTP for testing and save it to web_codes
    $otp = 1234;
    $u_id = $partner['mobile_no'];
    $now = date('Y-m-d H:i:s');

    $otp_stmt = $conn->prepare("INSERT INTO web_codes (u_Id, otp_code, time, status) VALUES (?, ?, ?, 0)");
    $otp_stmt->bind_param("iis", $u_id, $otp, $now);
    $otp_stmt->execute();

    echo json_encode(["success" => true, "data" => $partner]);
} else {
    echo json_encode(["success" => false, "message" => "Partner not found"]);
}

$stmt->close();
$conn->close();
?>
