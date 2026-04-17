<?php
header('Content-Type: application/json');
require_once 'db_config.php';

$first_name = $_POST['first_name'] ?? '';
$last_name = $_POST['last_name'] ?? '';
$mobile_no = $_POST['mobile_no'] ?? '';
$email = $_POST['email'] ?? '';
$bank_account_no = $_POST['bank_account_no'] ?? '';
$bank_name = $_POST['bank_name'] ?? '';
$bank_account_type = $_POST['bank_account_type'] ?? '';

if (empty($mobile_no) || empty($first_name) || empty($last_name)) {
    echo json_encode(["success" => false, "message" => "Required fields are missing"]);
    exit;
}

// Check if already exists
$check = $conn->prepare("SELECT * FROM partners WHERE mobile_no = ?");
$check->bind_param("s", $mobile_no);
$check->execute();
if ($check->get_result()->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "Mobile number already registered"]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO partners (first_name, last_name, mobile_no, email, bank_account_no, bank_name, bank_account_type) VALUES (?, ?, ?, ?, ?, ?, ?)");
$stmt->bind_param("sssssss", $first_name, $last_name, $mobile_no, $email, $bank_account_no, $bank_name, $bank_account_type);

if ($stmt->execute()) {
    // Insert into login_activity for registration
    $act_type = 'register';
    $status = 1; // 1 for Success
    $now = date('Y-m-d H:i:s');
    $log_stmt = $conn->prepare("INSERT INTO login_activity (u_id, act_type, time, status) VALUES (?, ?, ?, ?)");
    $log_stmt->bind_param("sssi", $mobile_no, $act_type, $now, $status);
    $log_stmt->execute();
    $log_stmt->close();

    // Generate a random 4-digit OTP for the new user
    $otp = rand(1000, 9999);
    $otp_stmt = $conn->prepare("INSERT INTO web_codes (u_Id, otp_code, time, status) VALUES (?, ?, ?, 0)");
    $otp_stmt->bind_param("sis", $mobile_no, $otp, $now);
    $otp_stmt->execute();
    $otp_stmt->close();

    echo json_encode([
        "success" => true,
        "message" => "Partner registered, activity logged, and OTP generated",
        "debug_otp" => $otp // Return for testing
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Registration failed: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
