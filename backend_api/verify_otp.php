<?php
header('Content-Type: application/json');
require_once 'db_config.php';

$mobile_no = $_POST['mobile_no'] ?? '';
$otp_code = $_POST['otp_code'] ?? '';

if (empty($mobile_no) || empty($otp_code)) {
    echo json_encode(["success" => false, "message" => "Mobile number and OTP are required"]);
    exit;
}

$stmt = $conn->prepare("SELECT * FROM web_codes WHERE u_Id = ? AND otp_code = ? AND status = 0 ORDER BY time DESC LIMIT 1");
$stmt->bind_param("ii", $mobile_no, $otp_code);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $id = $row['ID'];

    $update_stmt = $conn->prepare("UPDATE web_codes SET status = 1 WHERE ID = ?");
    $update_stmt->bind_param("i", $id);
    $update_stmt->execute();

    echo json_encode(["success" => true, "message" => "OTP verified"]);
} else {
    echo json_encode(["success" => false, "message" => "Invalid or expired OTP"]);
}

$stmt->close();
$conn->close();
?>
