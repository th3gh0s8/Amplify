<?php include 'header.php'; ?>

<?php
// Statistics
$partner_count = $conn->query("SELECT COUNT(*) as count FROM partners")->fetch_assoc()['count'];
$customer_count = $conn->query("SELECT COUNT(*) as count FROM new_clients")->fetch_assoc()['count'];
$invoice_total = $conn->query("SELECT SUM(value) as total FROM invoices")->fetch_assoc()['total'] ?? 0;
$total_comm = $conn->query("SELECT SUM(com_amount) as total FROM invoices")->fetch_assoc()['total'] ?? 0;
$pending_payouts = $conn->query("SELECT SUM(amount) as total FROM payout_request WHERE status = 'pending'")->fetch_assoc()['total'] ?? 0;

// Recent Data
$recent_partners = $conn->query("SELECT first_name, last_name, mobile_no, status FROM partners ORDER BY ID DESC LIMIT 5");
$recent_customers = $conn->query("SELECT com_name, admin_name, status, rDateTime FROM new_clients ORDER BY ID DESC LIMIT 5");
$pending_requests = $conn->query("SELECT p.first_name, r.amount, r.request_date, r.ID FROM payout_request r JOIN partners p ON r.partner_id = p.ID WHERE r.status = 'pending' ORDER BY r.ID DESC LIMIT 5");

// Chart Data (Last 7 Days Sales)
$chart_sql = "SELECT date, SUM(value) as daily_total FROM invoices GROUP BY date ORDER BY date DESC LIMIT 7";
$chart_res = $conn->query($chart_sql);
$chart_dates = [];
$chart_values = [];
while($row = $chart_res->fetch_assoc()) {
    $chart_dates[] = $row['date'];
    $chart_values[] = $row['daily_total'];
}
$chart_dates = array_reverse($chart_dates);
$chart_values = array_reverse($chart_values);
?>

<div class="row g-4 mb-4">
    <div class="col-md-3">
        <div class="card bg-primary text-white shadow-sm border-0">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h6 class="text-uppercase small">Total Partners</h6>
                        <h2 class="mb-0"><?php echo $partner_count; ?></h2>
                    </div>
                    <i class="bi bi-people-fill fs-1 opacity-50"></i>
                </div>
            </div>
            <div class="card-footer bg-transparent border-top border-light py-1">
                <a href="partners.php" class="text-white small text-decoration-none">View All <i class="bi bi-arrow-right"></i></a>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card bg-success text-white shadow-sm border-0">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h6 class="text-uppercase small">Total Customers</h6>
                        <h2 class="mb-0"><?php echo $customer_count; ?></h2>
                    </div>
                    <i class="bi bi-building-fill fs-1 opacity-50"></i>
                </div>
            </div>
            <div class="card-footer bg-transparent border-top border-light py-1">
                <a href="customers.php" class="text-white small text-decoration-none">View All <i class="bi bi-arrow-right"></i></a>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card bg-info text-white shadow-sm border-0">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h6 class="text-uppercase small">Gross Sales</h6>
                        <h2 class="mb-0">LKR <?php echo number_format($invoice_total / 1000, 1); ?>k</h2>
                    </div>
                    <i class="bi bi-cash-stack fs-1 opacity-50"></i>
                </div>
            </div>
            <div class="card-footer bg-transparent border-top border-light py-1 small">
                Commission: LKR <?php echo number_format($total_comm, 0); ?>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card bg-danger text-white shadow-sm border-0">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <h6 class="text-uppercase small">Pending Payouts</h6>
                        <h2 class="mb-0">LKR <?php echo number_format($pending_payouts, 0); ?></h2>
                    </div>
                    <i class="bi bi-clock-history fs-1 opacity-50"></i>
                </div>
            </div>
            <div class="card-footer bg-transparent border-top border-light py-1 small">
                Unpaid obligations
            </div>
        </div>
    </div>
</div>

<div class="row mb-4">
    <div class="col-md-8">
        <div class="card shadow-sm border-0 h-100">
            <div class="card-header bg-white fw-bold">Sales Trend (Last 7 Days)</div>
            <div class="card-body">
                <canvas id="salesChart" height="150"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card shadow-sm border-0 h-100">
            <div class="card-header bg-white fw-bold">Pending Payout Requests</div>
            <div class="card-body p-0">
                <ul class="list-group list-group-flush">
                    <?php if($pending_requests->num_rows == 0): ?>
                        <li class="list-group-item text-center text-muted py-4">No pending requests</li>
                    <?php else: while($r = $pending_requests->fetch_assoc()): ?>
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            <div>
                                <span class="fw-bold"><?php echo $r['first_name']; ?></span><br>
                                <small class="text-muted"><?php echo $r['request_date']; ?></small>
                            </div>
                            <span class="badge bg-warning text-dark">LKR <?php echo number_format($r['amount'], 0); ?></span>
                        </li>
                    <?php endwhile; endif; ?>
                </ul>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-6">
        <div class="card shadow-sm border-0">
            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                <span class="fw-bold">Latest Partners</span>
                <a href="partners.php" class="btn btn-sm btn-link text-decoration-none p-0">Manage</a>
            </div>
            <div class="card-body p-0">
                <table class="table table-sm table-hover mb-0">
                    <thead class="table-light small">
                        <tr><th>Name</th><th>Mobile</th><th>Status</th></tr>
                    </thead>
                    <tbody class="small">
                        <?php while($p = $recent_partners->fetch_assoc()): ?>
                        <tr>
                            <td><?php echo $p['first_name']; ?></td>
                            <td><?php echo $p['mobile_no']; ?></td>
                            <td><span class="badge <?php echo $p['status']=='authorized'?'bg-success':'bg-secondary'; ?>"><?php echo $p['status']; ?></span></td>
                        </tr>
                        <?php endwhile; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="card shadow-sm border-0">
            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                <span class="fw-bold">Latest Customers</span>
                <a href="customers.php" class="btn btn-sm btn-link text-decoration-none p-0">Manage</a>
            </div>
            <div class="card-body p-0">
                <table class="table table-sm table-hover mb-0">
                    <thead class="table-light small">
                        <tr><th>Company</th><th>Status</th><th>Date</th></tr>
                    </thead>
                    <tbody class="small">
                        <?php while($c = $recent_customers->fetch_assoc()): ?>
                        <tr>
                            <td><?php echo $c['com_name']; ?></td>
                            <td><span class="badge <?php echo $c['status']=='active'?'bg-success':'bg-warning'; ?>"><?php echo $c['status']; ?></span></td>
                            <td><?php echo date('M d', strtotime($c['rDateTime'])); ?></td>
                        </tr>
                        <?php endwhile; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
const ctx = document.getElementById('salesChart');
new Chart(ctx, {
    type: 'line',
    data: {
        labels: <?php echo json_encode($chart_dates); ?>,
        datasets: [{
            label: 'Daily Sales (LKR)',
            data: <?php echo json_encode($chart_values); ?>,
            borderWidth: 3,
            borderColor: '#0d6efd',
            backgroundColor: 'rgba(13, 110, 253, 0.1)',
            fill: true,
            tension: 0.4
        }]
    },
    options: {
        responsive: true,
        plugins: { legend: { display: false } },
        scales: {
            y: { beginAtZero: true, grid: { color: '#f0f0f0' } },
            x: { grid: { display: false } }
        }
    }
});
</script>

<?php include 'footer.php'; ?>
