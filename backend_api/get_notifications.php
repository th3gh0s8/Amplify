<?php
require_once 'cors_headers.php';
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
    // 1. Get Partner ID
    $stmt = $conn->prepare("SELECT ID FROM partners WHERE mobile_no = ?");
    $stmt->bind_param("s", $mobile_no);
    $stmt->execute();
    $res = $stmt->get_result();
    $partner = $res->fetch_assoc();

    if (!$partner) {
        die(json_encode(["success" => false, "message" => "Partner not found"]));
    }

    $partner_id = $partner['ID'];

    // 2. Fetch notifications for ALL (0) or THIS partner
    $stmt = $conn->prepare("SELECT id, title, message, created_at, is_read 
                           FROM notifications 
                           WHERE partner_id = 0 OR partner_id = ? 
                           ORDER BY created_at DESC");
    $stmt->bind_param("i", $partner_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $notifications = [];
    while ($row = $result->fetch_assoc()) {
        $notifications[] = $row;
    }

    echo json_encode([
        "success" => true,
        "data" => $notifications
    ]);

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Server Error: " . $e->getMessage()]);
}

if (isset($conn)) $conn->close();
?>
