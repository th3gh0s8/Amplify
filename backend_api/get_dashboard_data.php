<?php
// ROBUST DASHBOARD DATA FETCH - WITH PATH FIX
require_once 'cors_headers.php';

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} elseif (file_exists('db_config.php')) {
    require_once 'db_config.php';
} else {
    die(json_encode(["success" => false, "message" => "CRITICAL: Database config not found."]));
}

$mobile_no = $_GET['mobile_no'] ?? '';

if (empty($mobile_no)) {
    echo json_encode(["success" => false, "message" => "Mobile number required"]);
    exit;
}

try {
    // 1. Resolve Partner ID (checking variations for safety)
    $stmtP = $conn->prepare("SELECT ID FROM partners WHERE mobile_no = ? OR mobile_no = ?");
    $no_zero = ltrim(preg_replace('/\D/', '', $mobile_no), '0');
    $with_zero = '0' . $no_zero;
    $stmtP->bind_param("ss", $no_zero, $with_zero);
    $stmtP->execute();
    $p_res = $stmtP->get_result()->fetch_assoc();
    $partner_id = (int)($p_res['ID'] ?? 0);

    if ($partner_id == 0) {
        echo json_encode(["success" => false, "message" => "Partner record not found"]);
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

    // 3. Calculate COMPLETED paid amounts from payout_request table
    $stmtPaid = $conn->prepare("SELECT SUM(amount) as total_paid FROM payout_request WHERE partner_id = ? AND status = 'completed'");
    $stmtPaid->bind_param("i", $partner_id);
    $stmtPaid->execute();
    $total_paid = (float)($stmtPaid->get_result()->fetch_assoc()['total_paid'] ?? 0);

    // 4. Calculate PENDING amounts for display
    $stmtPending = $conn->prepare("SELECT SUM(amount) as pending_payouts FROM payout_request WHERE partner_id = ? AND status IN ('pending', 'processing')");
    $stmtPending->bind_param("i", $partner_id);
    $stmtPending->execute();
    $pending_payouts = (float)($stmtPending->get_result()->fetch_assoc()['pending_payouts'] ?? 0);

    // 5. Final Available Balance
    $available_balance = $gross_balance - $total_paid;
    if ($available_balance < 0) $available_balance = 0;

    // 6. Get Active Customers count
    $stmtC = $conn->prepare("SELECT COUNT(ID) as total_customers FROM new_clients WHERE partnerTb = ? AND status = 'Active'");
    $stmtC->bind_param("i", $partner_id);
    $stmtC->execute();
    $total_customers = (int)($stmtC->get_result()->fetch_assoc()['total_customers'] ?? 0);

    // 7. Determine Level
    $stmt3 = $conn->prepare("SELECT * FROM partner_levels WHERE min_coustomers <= ? ORDER BY min_coustomers DESC LIMIT 1");
    $stmt3->bind_param("i", $total_customers);
    $stmt3->execute();
    $level_data = $stmt3->get_result()->fetch_assoc();
    $level = $level_data['level_name'] ?? 'ASSOCIATE';
    $comm_rate = $level_data['profitPr_monthly'] ?? 10;

    // 8. Unread Notifications Count
    $stmtN = $conn->prepare("SELECT COUNT(n.id) as unread_count 
                            FROM notifications n 
                            WHERE (n.partner_id = 0 OR n.partner_id = ?) 
                            AND NOT EXISTS (
                                SELECT 1 FROM notification_reads nr 
                                WHERE nr.notification_id = n.id AND nr.partner_id = ?
                            )");
    $stmtN->bind_param("ii", $partner_id, $partner_id);
    $stmtN->execute();
    $unread_count = (int)($stmtN->get_result()->fetch_assoc()['unread_count'] ?? 0);

    echo json_encode([
        "success" => true,
        "data" => [
            "total_earned" => $total_earned,
            "total_invoices" => $total_invoices,
            "available_balance" => $available_balance,
            "pending_payouts" => $pending_payouts,
            "total_customers" => $total_customers,
            "level" => $level,
            "commission_rate" => $comm_rate . "%",
            "unread_notifications" => $unread_count
        ]
    ]);

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "API Error: " . $e->getMessage()]);
}

$conn->close();
?>
