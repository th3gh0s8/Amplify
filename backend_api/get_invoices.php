<?php
header('Content-Type: application/json');
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');

require_once 'db_config.php';

$mobile_no = $_GET['mobile_no'] ?? '';

if (empty($mobile_no)) {
    echo json_encode(["success" => false, "message" => "Mobile number required"]);
    exit;
}

$stmt = $conn->prepare("SELECT * FROM invoices WHERE partner_tb = ?");
$stmt->bind_param("s", $mobile_no); // Changed to 's' as mobile_no is usually a string
$stmt->execute();
$result = $stmt->get_result();

$invoices = [];
while ($row = $result->fetch_assoc()) {
    $invoices[] = $row;
}

echo json_encode(["success" => true, "data" => $invoices]);

$stmt->close();
$conn->close();
?>
