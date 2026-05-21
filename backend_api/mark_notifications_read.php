<?php
require_once 'cors_headers.php';
header('Content-Type: application/json');

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

$mobile_no = $_POST['mobile_no'] ?? '';

if (empty($mobile_no)) {
    die(json_encode(["success" => false, "message" => "Mobile number missing"]));
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

    // 2. Mark all relevant notifications as read for this partner
    // We insert into notification_reads for all notifications targeted to them or ALL
    $sql = "INSERT IGNORE INTO notification_reads (notification_id, partner_id)
            SELECT id, ? FROM notifications 
            WHERE partner_id = 0 OR partner_id = ?";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ii", $partner_id, $partner_id);
    
    if ($stmt->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "message" => $conn->error]);
    }

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "API Error: " . $e->getMessage()]);
}

$conn->close();
?>
