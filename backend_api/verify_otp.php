<?php
// UNIVERSAL OTP VERIFIER - FINAL SYNCED VERSION
require_once 'cors_headers.php';
header('Content-Type: application/json');

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} elseif (file_exists('db_config.php')) {
    require_once 'db_config.php';
} else {
    die(json_encode(["success" => false, "message" => "Database config not found."]));
}

$mobile_no = $_POST['mobile_no'] ?? '';
$otp_code = $_POST['otp_code'] ?? '';

if (empty($mobile_no) || empty($otp_code)) {
    die(json_encode(["success" => false, "message" => "Fields missing"]));
}

try {
    // 1. Resolve every possible ID for this partner
    $stmtP = $conn->prepare("SELECT ID, mobile_no FROM partners WHERE mobile_no = ? OR mobile_no = ? LIMIT 1");
    $no_zero = ltrim(preg_replace('/\D/', '', $mobile_no), '0');
    $with_zero = '0' . $no_zero;
    $stmtP->bind_param("ss", $no_zero, $with_zero);
    $stmtP->execute();
    $partner = $stmtP->get_result()->fetch_assoc();

    $partner_id = $partner['ID'] ?? null;
    $db_mobile = $partner['mobile_no'] ?? null;

    // 2. CHECK EVERY POSSIBILITY (ID, Raw Mobile, Clean Mobile)
    // This ensures verification works even if get_partner.php is using a different identifier
    $stmt = $conn->prepare("SELECT * FROM web_codes
                            WHERE (u_Id = ? OR u_Id = ? OR u_Id = ? OR u_Id = ?)
                            AND otp_code = ?
                            AND status = 0
                            ORDER BY time DESC LIMIT 1");

    // Identifiers to check
    $id_str = (string)$partner_id;
    $stmt->bind_param("sssss", $id_str, $no_zero, $with_zero, $db_mobile, $otp_code);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $code_db_id = $row['ID'];

        // 3. SUCCESS: Mark as used
        $conn->query("UPDATE web_codes SET status = 1 WHERE ID = $code_db_id");

        // 4. Log Success
        if ($partner_id) {
            $now = date('Y-m-d H:i:s');
            $conn->query("INSERT INTO login_activity (u_id, act_type, time, status) VALUES ($partner_id, 3, '$now', 1)");
        }

        echo json_encode([
            "success" => true,
            "message" => "Verified",
            "partner_id" => $partner_id
        ]);
    } else {
        // 5. DETAILED FAILURE LOGIC (For debugging)
        $msg = "Invalid or expired code";

        // Check if the code exists but is expired (status 1)
        $check_exp = $conn->query("SELECT status FROM web_codes WHERE (u_Id = '$id_str' OR u_Id = '$no_zero') AND otp_code = '$otp_code' LIMIT 1");
        if ($check_exp && $check_exp->num_rows > 0) {
            $exp_row = $check_exp->fetch_assoc();
            if ($exp_row['status'] == 1) $msg = "This code has already been used or has expired.";
        }

        echo json_encode([
            "success" => false,
            "message" => $msg,
            "debug" => [
                "tried_id" => $partner_id,
                "tried_mobile" => $no_zero,
                "tried_code" => $otp_code
            ]
        ]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Server Error: " . $e->getMessage()]);
}

$conn->close();
?>
