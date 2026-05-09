<?php
require_once 'cors_headers.php';

// PRODUCTION OTP GENERATOR - FULL SCHEMA VERSION
header('Content-Type: application/json');

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

$mobile_no = $_GET['mobile_no'] ?? '';

if (empty($mobile_no)) {
    die(json_encode(["success" => false, "message" => "Mobile number missing"]));
}

try {
    // 1. Search for partner
    $stmt = $conn->prepare("SELECT * FROM partners WHERE mobile_no = ?");
    $stmt->bind_param("s", $mobile_no);
    $stmt->execute();
    $partner = $stmt->get_result()->fetch_assoc();

    if ($partner) {
        $otp = rand(1111, 9999);
        $now = date('Y-m-d H:i:s');

        // 2. Clear old codes
        $conn->query("UPDATE web_codes SET status = 1 WHERE u_Id = '$mobile_no'");

        // 3. Save new OTP
        $sql = "INSERT INTO web_codes (u_Id, otp_code, time, status) VALUES ('$mobile_no', $otp, '$now', 0)";

        if ($conn->query($sql)) {
            // Include SMS logic if available
            if (file_exists('sendSms_xpartner.php')) {
                require_once 'sendSms_xpartner.php';
                $c_code = ($partner['c_code'] && $partner['c_code'] != '0') ? $partner['c_code'] : '94';
                $full_mobile = $c_code . ltrim($partner['mobile_no'], '0');
                $msg = "Your xPower Partners OTP is: $otp";
                if (function_exists('sendSMSF')) {
                    sendSMSF($msg, $full_mobile, "Mahallah360", "PartnerOTP", "partners", $partner['first_name'], $conn);
                }
            }

            echo json_encode([
                "success" => true,
                "data" => $partner,
                "debug_otp" => $otp
            ]);
        } else {
            echo json_encode(["success" => false, "message" => "Database error: " . $conn->error]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Mobile number $mobile_no not found"]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Server Error: " . $e->getMessage()]);
}

if (isset($conn)) $conn->close();
?>
