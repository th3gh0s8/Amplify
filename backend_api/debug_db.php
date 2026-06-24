<?php
require_once 'db/db_config.php';
$result = $conn->query("SELECT * FROM new_clients");
$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}
echo json_encode(['data' => $data]);
?>