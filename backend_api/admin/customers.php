<?php include 'header.php'; ?>

<?php
if (isset($_GET['activate'])) {
    $id = (int)$_GET['activate'];
    $conn->query("UPDATE new_clients SET status = 'active' WHERE ID = $id");
    header("Location: customers.php?msg=activated");
    exit;
}

$sql = "SELECT c.*, p.first_name as partner_first, p.last_name as partner_last 
        FROM new_clients c 
        LEFT JOIN partners p ON c.partnerTb = p.ID 
        ORDER BY c.ID DESC";
$result = $conn->query($sql);
?>

<h2>Customers Management</h2>
<?php if(isset($_GET['msg'])): ?>
    <div class="alert alert-success">Customer activated successfully!</div>
<?php endif; ?>

<div class="table-responsive">
    <table class="table table-striped table-hover mt-3">
        <thead class="table-dark">
            <tr>
                <th>ID</th>
                <th>Company</th>
                <th>Admin Name</th>
                <th>Status</th>
                <th>Partner</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <?php while($row = $result->fetch_assoc()): ?>
            <tr>
                <td><?php echo $row['ID']; ?></td>
                <td><?php echo $row['com_name']; ?></td>
                <td><?php echo $row['admin_name']; ?></td>
                <td>
                    <span class="badge <?php echo $row['status'] == 'active' ? 'bg-success' : 'bg-warning'; ?>">
                        <?php echo strtoupper($row['status']); ?>
                    </span>
                </td>
                <td><?php echo $row['partner_first'] . ' ' . $row['partner_last']; ?></td>
                <td>
                    <?php if($row['status'] == 'pending'): ?>
                        <a href="customers.php?activate=<?php echo $row['ID']; ?>" class="btn btn-sm btn-success" onclick="return confirm('Activate this customer?')">Activate</a>
                    <?php endif; ?>
                    <a href="edit_customer.php?id=<?php echo $row['ID']; ?>" class="btn btn-sm btn-warning">Edit</a>
                </td>
            </tr>
            <?php endwhile; ?>
        </tbody>
    </table>
</div>

<?php include 'footer.php'; ?>
