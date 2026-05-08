<?php
require_once "cors_headers.php";
// ROBUST PRODUCTION REGISTRATION - WITH PATH FIX

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} elseif (file_exists('db_config.php')) {
    require_once 'db_config.php';
} else {
    die(json_encode(["success" => false, "message" => "CRITICAL: Database config not found."]));
}

$first_name = $_REQUEST['first_name'] ?? '';
$last_name = $_REQUEST['last_name'] ?? '';
$c_code = $_REQUEST['c_code'] ?? '';
$mobile_no = $_REQUEST['mobile_no'] ?? '';
$email = $_REQUEST['email'] ?? '';
$bank_account_no = $_REQUEST['bank_account_no'] ?? '';
$bank_name = $_REQUEST['bank_name'] ?? '';
$bank_account_type = $_REQUEST['bank_account_type'] ?? '';

if (empty($mobile_no) || empty($first_name) || empty($last_name)) {
    die(json_encode(["success" => false, "message" => "Required fields are missing"]));
}

try {
    // 1. Check if already exists
    $check = $conn->prepare("SELECT * FROM partners WHERE mobile_no = ?");
    $check->bind_param("s", $mobile_no);
    $check->execute();
    $existing = $check->get_result()->fetch_assoc();

    if ($existing) {
        // Just return the existing partner if they try to sign up again
        echo json_encode([
            "success" => true, 
            "message" => "Mobile number already registered",
            "data" => $existing
        ]);
        exit;
    }

    // 2. Insert new partner
    $stmt = $conn->prepare("INSERT INTO partners (first_name, last_name, c_code, mobile_no, email, bank_account_no, bank_name, bank_account_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssssss", $first_name, $last_name, $c_code, $mobile_no, $email, $bank_account_no, $bank_name, $bank_account_type);

    if ($stmt->execute()) {
        $partner_id = $conn->insert_id;
        $now = date('Y-m-d H:i:s');
        $otp = rand(1000, 9999);

        // Fetch user data for response
        $get_stmt = $conn->prepare("SELECT * FROM partners WHERE ID = ?");
        $get_stmt->bind_param("i", $partner_id);
        $get_stmt->execute();
        $partner_data = $get_stmt->get_result()->fetch_assoc();

        // 3. Log registration
        $conn->query("INSERT INTO login_activity (u_id, act_type, time, status) VALUES ('$partner_id', 'register', '$now', 1)");

        // 4. Clear old codes
        $conn->query("UPDATE web_codes SET status = 1 WHERE u_Id = '$mobile_no'");

        // 5. Save new OTP
        $insert_sql = "INSERT INTO web_codes (u_Id, otp_code, time, status) VALUES ('$mobile_no', $otp, '$now', 0)";

        if ($conn->query($insert_sql)) {
            require_once 'sendSms_xpartner.php';
            $country_code = ($c_code && $c_code != '0') ? $c_code : '94';
            $full_mobile = $country_code . ltrim($mobile_no, '0');

            $msg = "Welcome to xPower Partners! Your OTP is: $otp";
            sendSMSF($msg, $full_mobile, "Mahallah360", "PartnerRegistration", "partners", $first_name, $conn);

            echo json_encode([
                "success" => true,
                "message" => "Partner registered and OTP sent via SMS",
                "data" => $partner_data,
                "debug_otp" => $otp
            ]);
        } else {
            echo json_encode([
                "success" => true, 
                "message" => "Registration successful but failed to save OTP",
                "data" => $partner_data,
                "error" => $conn->error
            ]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Registration failed: " . $stmt->error]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "System Error: " . $e->getMessage()]);
}

$conn->close();
?>
