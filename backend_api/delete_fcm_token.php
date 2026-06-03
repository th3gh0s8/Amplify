<?php
require_once 'cors_headers.php';
header('Content-Type: application/json');

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

$data = json_decode(file_get_contents("php://input"), true);
$token = $data['fcm_token'] ?? '';

if (empty($token)) {
    die(json_encode(["success" => false, "message" => "Missing token"]));
}

try {
    $stmt = $conn->prepare("DELETE FROM partner_devices WHERE fcm_token = ?");
    $stmt->bind_param("s", $token);
    
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Device token removed"]);
    } else {
        echo json_encode(["success" => false, "message" => "Delete failed"]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}

if (isset($conn)) $conn->close();
?>
