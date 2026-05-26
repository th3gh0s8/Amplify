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

    // 2. Fetch notifications with actual read status
    $stmt = $conn->prepare("SELECT n.id, n.title, n.message, n.created_at, 
                                   (CASE WHEN r.id IS NOT NULL THEN 1 ELSE 0 END) as is_read
                           FROM notifications n
                           LEFT JOIN notification_reads r ON n.id = r.notification_id AND r.partner_id = ?
                           WHERE n.partner_id = 0 OR n.partner_id = ? 
                           ORDER BY n.created_at DESC");
    $stmt->bind_param("ii", $partner_id, $partner_id);
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
