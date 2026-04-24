<?php
header('Content-Type: application/json');
header('Cache-Control: no-cache, no-store, must-revalidate'); // HTTP 1.1
header('Pragma: no-cache'); // HTTP 1.0
header('Expires: 0'); // Proxies

require_once 'db_config.php';

$mobile_no = $_GET['mobile_no'] ?? '';

if (empty($mobile_no)) {
    echo json_encode(["success" => false, "message" => "Mobile number required"]);
    exit;
}

// 1. Resolve Partner's internal numeric ID
$stmtP = $conn->prepare("SELECT ID FROM partners WHERE mobile_no = ?");
$stmtP->bind_param("s", $mobile_no);
$stmtP->execute();
$partner = $stmtP->get_result()->fetch_assoc();
$partner_id = $partner['ID'] ?? 0;

if ($partner_id == 0) {
    echo json_encode(["success" => false, "message" => "Partner not found"]);
    exit;
}

// 2. Get Total Registered Customers (from new_clients) using numeric ID
$stmtC = $conn->prepare("SELECT COUNT(ID) as total_customers FROM new_clients WHERE partnerTb = ?");
$stmtC->bind_param("i", $partner_id);
$stmtC->execute();
$client_stats = $stmtC->get_result()->fetch_assoc();
$total_customers = $client_stats['total_customers'] ?? 0;

// 3. Get Total Earned and Total Invoices
$stmtI = $conn->prepare("SELECT SUM(com_amount) as total_earned, COUNT(ID) as total_invoices FROM invoices WHERE partner_tb = ?");
$stmtI->bind_param("s", $mobile_no);
$stmtI->execute();
$invoice_stats = $stmtI->get_result()->fetch_assoc();

// 4. Get Pending Payouts
$stmt2 = $conn->prepare("SELECT SUM(amount) as pending_payouts FROM payout_request WHERE partner_id = ? AND status = 0");
$stmt2->bind_param("s", $mobile_no);
$stmt2->execute();
$payout_stats = $stmt2->get_result()->fetch_assoc();

// 5. Determine Level
$stmt3 = $conn->prepare("SELECT level_name FROM partner_levels WHERE min_coustomers <= ? ORDER BY min_coustomers DESC LIMIT 1");
$stmt3->bind_param("i", $total_customers);
$stmt3->execute();
$level_result = $stmt3->get_result()->fetch_assoc();
$level = $level_result['level_name'] ?? 'ASSOCIATE';

echo json_encode([
    "success" => true,
    "data" => [
        "total_earned" => (float)($invoice_stats['total_earned'] ?? 0),
        "total_invoices" => (int)($invoice_stats['total_invoices'] ?? 0),
        "total_customers" => (int)$total_customers,
        "pending_payouts" => (float)($payout_stats['pending_payouts'] ?? 0),
        "level" => $level
    ]
]);

$conn->close();
?>
