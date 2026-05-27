<?php
require_once 'db/db_config.php';
header('Content-Type: application/json');

$res = $conn->query("SELECT ID, first_name, fcm_token FROM partners WHERE fcm_token IS NOT NULL AND fcm_token != ''");
$data = [];
while($row = $res->fetch_assoc()) {
    $data[] = [
        'id' => $row['ID'],
        'name' => $row['first_name'],
        'token_preview' => substr($row['fcm_token'], 0, 20) . '...'
    ];
}

echo json_encode([
    'registered_tokens_count' => count($data),
    'partners_with_tokens' => $data
]);
?>
