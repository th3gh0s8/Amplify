<?php
require_once 'cors_headers.php';
header('Content-Type: application/json');

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

$data = json_decode(file_get_contents("php://input"), true);
$mobile_no = $data['mobile_no'] ?? '';
$notification_id = (int)($data['notification_id'] ?? 0);

if (empty($mobile_no) || $notification_id <= 0) {
    die(json_encode(["success" => false, "message" => "Missing data"]));
}

try {
    // 1. Resolve Partner ID
    $stmtP = $conn->prepare("SELECT ID FROM partners WHERE mobile_no = ?");
    $stmtP->bind_param("s", $mobile_no);
    $stmtP->execute();
    $p_res = $stmtP->get_result()->fetch_assoc();
    $partner_id = (int)($p_res['ID'] ?? 0);

    if ($partner_id == 0) {
        die(json_encode(["success" => false, "message" => "Partner record not found"]));
    }

    // 2. Mark specific notification as read in tracking table
    $stmt = $conn->prepare("INSERT IGNORE INTO notification_reads (notification_id, partner_id) VALUES (?, ?)");
    $stmt->bind_param("ii", $notification_id, $partner_id);
    $stmt->execute();

    // 3. Also update main notifications table column
    $stmtU = $conn->prepare("UPDATE notifications SET is_read = 1 WHERE id = ?");
    $stmtU->bind_param("i", $notification_id);
    
    if ($stmtU->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "message" => $conn->error]);
    }

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "API Error: " . $e->getMessage()]);
}

$conn->close();
?>
