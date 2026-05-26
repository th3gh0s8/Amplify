<?php
require_once 'cors_headers.php';
header('Content-Type: application/json');

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

// Auto-update table if column missing
$conn->query("ALTER TABLE partners ADD COLUMN IF NOT EXISTS fcm_token TEXT");

$data = json_decode(file_get_contents("php://input"), true);
$mobile_no = $data['mobile_no'] ?? '';
$token = $data['fcm_token'] ?? '';

if (empty($mobile_no) || empty($token)) {
    die(json_encode(["success" => false, "message" => "Missing data"]));
}

try {
    $stmt = $conn->prepare("UPDATE partners SET fcm_token = ? WHERE mobile_no = ?");
    $stmt->bind_param("ss", $token, $mobile_no);
    
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Token updated"]);
    } else {
        echo json_encode(["success" => false, "message" => "Update failed"]);
    }
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}

if (isset($conn)) $conn->close();
?>
