<?php include 'header.php'; ?>

<?php
$sql = "SELECT * FROM partners ORDER BY ID DESC";
$result = $conn->query($sql);
?>

<h2>Partners Management</h2>
<div class="table-responsive">
    <table class="table table-striped table-hover mt-3">
        <thead class="table-dark">
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Mobile</th>
                <th>Email</th>
                <th>Bank Account</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <?php while($row = $result->fetch_assoc()): ?>
            <tr>
                <td><?php echo $row['ID']; ?></td>
                <td><?php echo $row['first_name'] . ' ' . $row['last_name']; ?></td>
                <td><?php echo $row['mobile_no']; ?></td>
                <td><?php echo $row['email']; ?></td>
                <td><?php echo $row['bank_account_no']; ?></td>
                <td>
                    <a href="edit_partner.php?id=<?php echo $row['ID']; ?>" class="btn btn-sm btn-warning">Edit</a>
                </td>
            </tr>
            <?php endwhile; ?>
        </tbody>
    </table>
</div>

<?php include 'footer.php'; ?>
