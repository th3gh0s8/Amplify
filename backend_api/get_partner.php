<?php
header('Content-Type: application/json');
require_once 'db_config.php';

$mobile_no = $_GET['mobile_no'] ?? '';

if (empty($mobile_no)) {
    echo json_encode(["success" => false, "message" => "Mobile number is required"]);
    exit;
}

$stmt = $conn->prepare("SELECT * FROM partners WHERE mobile_no = ?");
$stmt->bind_param("s", $mobile_no);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $partner = $result->fetch_assoc();

    // Generate a random 4-digit OTP
    $otp = rand(1000, 9999);

    $u_id = $partner['mobile_no'];
    $now = date('Y-m-d H:i:s');

    // EXPIRE PREVIOUS CODES: Mark all existing OTPs for this user as expired (status = 1)
    $expire_stmt = $conn->prepare("UPDATE web_codes SET status = 1 WHERE u_Id = ? AND status = 0");
    $expire_stmt->bind_param("s", $u_id);
    $expire_stmt->execute();
    $expire_stmt->close();

    // Insert the new active OTP (status = 0)
    $otp_stmt = $conn->prepare("INSERT INTO web_codes (u_Id, otp_code, time, status) VALUES (?, ?, ?, 0)");
    $otp_stmt->bind_param("sis", $u_id, $otp, $now);
    $otp_stmt->execute();
    $otp_stmt->close();

    // In a real app, you would send this OTP via SMS here
    // For now, we will return it in the response so you can see it while testing
    echo json_encode([
        "success" => true,
        "data" => $partner,
        "debug_otp" => $otp // REMOVE THIS IN PRODUCTION
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Partner not found"]);
}

$stmt->close();
$conn->close();
?>
