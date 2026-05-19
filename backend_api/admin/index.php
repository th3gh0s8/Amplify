<?php include 'header.php'; ?>

<?php
$partner_count = $conn->query("SELECT COUNT(*) as count FROM partners")->fetch_assoc()['count'];
$customer_count = $conn->query("SELECT COUNT(*) as count FROM new_clients")->fetch_assoc()['count'];
$invoice_total = $conn->query("SELECT SUM(value) as total FROM invoices")->fetch_assoc()['total'] ?? 0;
?>

<div class="row text-center">
    <div class="col-md-4">
        <div class="card bg-primary text-white mb-4">
            <div class="card-body">
                <h3><?php echo $partner_count; ?></h3>
                <p>Total Partners</p>
                <a href="partners.php" class="text-white">View Details</a>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card bg-success text-white mb-4">
            <div class="card-body">
                <h3><?php echo $customer_count; ?></h3>
                <p>Total Customers</p>
                <a href="customers.php" class="text-white">View Details</a>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card bg-info text-white mb-4">
            <div class="card-body">
                <h3>$<?php echo number_format($invoice_total, 2); ?></h3>
                <p>Total Sales</p>
            </div>
        </div>
    </div>
</div>

<?php include 'footer.php'; ?>
