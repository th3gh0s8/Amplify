<?php
header('Content-Type: application/json');
header('Cache-Control: no-cache, no-store, must-revalidate');
require_once 'db_config.php';

$mobile_no = $_GET['mobile_no'] ?? '';

if (empty($mobile_no)) {
    echo json_encode(["success" => false, "message" => "Mobile number required"]);
    exit;
}

// 1. Resolve Partner ID
$stmtP = $conn->prepare("SELECT ID FROM partners WHERE mobile_no = ?");
$stmtP->bind_param("s", $mobile_no);
$stmtP->execute();
$partner = $stmtP->get_result()->fetch_assoc();
$partner_id = $partner['ID'] ?? 0;

if ($partner_id == 0) {
    echo json_encode(["success" => false, "message" => "Partner not found"]);
    exit;
}

// 2. Query from payout_request table
$stmt = $conn->prepare("SELECT * FROM payout_request WHERE partner_id = ? ORDER BY request_date DESC, request_time DESC");
$stmt->bind_param("i", $partner_id);
$stmt->execute();
$result = $stmt->get_result();

$payouts = [];
while ($row = $result->fetch_assoc()) {
    $payouts[] = $row;
}

echo json_encode(["success" => true, "data" => $payouts]);

$stmt->close();
$conn->close();
?>
