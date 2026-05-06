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

// 1. Resolve Partner ID
$stmtP = $conn->prepare("SELECT ID FROM partners WHERE mobile_no = ?");
$stmtP->bind_param("s", $mobile_no);
$stmtP->execute();
$partner = $stmtP->get_result()->fetch_assoc();
$partner_id = (int)($partner['ID'] ?? 0);

if ($partner_id == 0) {
    echo json_encode(["success" => false, "message" => "Partner not found"]);
    exit;
}

// 2. Calculate Gross Balance from invoices table
$stmtI = $conn->prepare("SELECT SUM(balance) as gross_balance, SUM(com_amount) as total_earned, COUNT(ID) as total_invoices FROM invoices WHERE partner_tb = ?");
$stmtI->bind_param("i", $partner_id);
$stmtI->execute();
$invoice_stats = $stmtI->get_result()->fetch_assoc();
$gross_balance = (float)($invoice_stats['gross_balance'] ?? 0);
$total_earned = (float)($invoice_stats['total_earned'] ?? 0);
$total_invoices = (int)($invoice_stats['total_invoices'] ?? 0);

// 3. Calculate COMPLETED paid amounts
$stmtPaid = $conn->prepare("SELECT SUM(amount) as total_paid FROM payout_request WHERE partner_id = ? AND status = 'completed'");
$stmtPaid->bind_param("i", $partner_id);
$stmtPaid->execute();
$total_paid = (float)($stmtPaid->get_result()->fetch_assoc()['total_paid'] ?? 0);

// 4. Calculate PENDING/PROCESSING amounts
$stmtPending = $conn->prepare("SELECT SUM(amount) as pending_payouts FROM payout_request WHERE partner_id = ? AND status IN ('pending', 'processing')");
$stmtPending->bind_param("i", $partner_id);
$stmtPending->execute();
$pending_stats = $stmtPending->get_result()->fetch_assoc();
$pending_payouts = (float)($pending_stats['pending_payouts'] ?? 0);

// 5. Final Balance
$available_balance = $gross_balance - $total_paid;
if ($available_balance < 0) $available_balance = 0;

// 6. Get Registered Customers - ONLY ACTIVE ONES
// As requested: Only show clients who have status 'Active'
$stmtC = $conn->prepare("SELECT COUNT(ID) as total_customers FROM new_clients WHERE (partnerTb = ? OR partnerTb = ?) AND status = 'Active'");
$stmtC->bind_param("is", $partner_id, $mobile_no);
$stmtC->execute();
$total_customers = (int)($stmtC->get_result()->fetch_assoc()['total_customers'] ?? 0);

// 7. Determine Level based on ACTIVE customers
$stmt3 = $conn->prepare("SELECT * FROM partner_levels WHERE min_coustomers <= ? ORDER BY min_coustomers DESC LIMIT 1");
$stmt3->bind_param("i", $total_customers);
$stmt3->execute();
$level_data = $stmt3->get_result()->fetch_assoc();
$level = $level_data['level_name'] ?? 'ASSOCIATE';
$comm_rate = $level_data['profitPr_monthly'] ?? 10;

echo json_encode([
    "success" => true,
    "data" => [
        "partner_id" => $partner_id,
        "total_earned" => $total_earned,
        "total_invoices" => $total_invoices,
        "available_balance" => $available_balance,
        "total_paid" => $total_paid,
        "pending_payouts" => $pending_payouts,
        "total_customers" => $total_customers,
        "level" => $level,
        "commission_rate" => $comm_rate . "%"
    ]
]);

$conn->close();
?>
