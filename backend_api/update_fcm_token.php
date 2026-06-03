<?php
require_once 'cors_headers.php';
header('Content-Type: application/json');

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

// 1. Ensure multi-device table exists
$conn->query("CREATE TABLE IF NOT EXISTS partner_devices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    partner_id INT NOT NULL,
    fcm_token TEXT NOT NULL,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY token_idx (fcm_token(255))
) ENGINE=InnoDB");

$data = json_decode(file_get_contents("php://input"), true);
$mobile_no = $data['mobile_no'] ?? '';
$token = $data['fcm_token'] ?? '';

if (empty($mobile_no) || empty($token)) {
    die(json_encode(["success" => false, "message" => "Missing data"]));
}

try {
    // 2. Resolve Partner ID
    $stmtP = $conn->prepare("SELECT ID FROM partners WHERE mobile_no = ?");
    $stmtP->bind_param("s", $mobile_no);
    $stmtP->execute();
    $p_res = $stmtP->get_result()->fetch_assoc();
    $partner_id = (int)($p_res['ID'] ?? 0);

    if ($partner_id == 0) {
        die(json_encode(["success" => false, "message" => "Partner not found"]));
    }

    // 3. Upsert token (multi-device + device handover support)
    $stmt = $conn->prepare("INSERT INTO partner_devices (partner_id, fcm_token) 
                           VALUES (?, ?) 
                           ON DUPLICATE KEY UPDATE partner_id = VALUES(partner_id), last_updated = CURRENT_TIMESTAMP");
    $stmt->bind_param("is", $partner_id, $token);
    
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Device token synced"]);
    } else {
        echo json_encode(["success" => false, "message" => "Update failed"]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}

if (isset($conn)) $conn->close();
?>
