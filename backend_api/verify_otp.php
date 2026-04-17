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

    // Mark OTP as used
    $update_stmt = $conn->prepare("UPDATE web_codes SET status = 1 WHERE ID = ?");
    $update_stmt->bind_param("i", $id);
    $update_stmt->execute();

    // Insert into login_activity
    $act_type = 'login'; // Changed to String
    $status = 1; // 1 for Success
    $now = date('Y-m-d H:i:s');
    $log_stmt = $conn->prepare("INSERT INTO login_activity (u_id, act_type, time, status) VALUES (?, ?, ?, ?)");
    $log_stmt->bind_param("issi", $mobile_no, $act_type, $now, $status);
    $log_stmt->execute();
    $log_stmt->close();

    echo json_encode(["success" => true, "message" => "OTP verified and activity logged"]);
} else {
    // Log failed attempt
    $act_type = 'login';
    $status = 0; // 0 for Failure
    $now = date('Y-m-d H:i:s');
    $log_stmt = $conn->prepare("INSERT INTO login_activity (u_id, act_type, time, status) VALUES (?, ?, ?, ?)");
    $log_stmt->bind_param("issi", $mobile_no, $act_type, $now, $status);
    $log_stmt->execute();
    $log_stmt->close();

    echo json_encode(["success" => false, "message" => "Invalid or expired OTP"]);
}

$stmt->close();
$conn->close();
?>
