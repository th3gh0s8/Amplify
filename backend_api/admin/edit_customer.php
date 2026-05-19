<?php include 'header.php'; ?>

<?php
$id = (int)($_GET['id'] ?? 0);
if ($id == 0) { header("Location: customers.php"); exit; }

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $com_name = $_POST['com_name'];
    $com_address = $_POST['com_address'];
    $admin_name = $_POST['admin_name'];
    $status = $_POST['status'];
    $remarks = $_POST['remarks'];

    $stmt = $conn->prepare("UPDATE new_clients SET com_name=?, com_address=?, admin_name=?, status=?, remarks=? WHERE ID=?");
    $stmt->bind_param("sssssi", $com_name, $com_address, $admin_name, $status, $remarks, $id);
    
    if ($stmt->execute()) {
        echo "<div class='alert alert-success'>Customer updated!</div>";
    } else {
        echo "<div class='alert alert-danger'>Update failed: " . $conn->error . "</div>";
    }
}

$customer = $conn->query("SELECT * FROM new_clients WHERE ID = $id")->fetch_assoc();
if (!$customer) { echo "Customer not found"; include 'footer.php'; exit; }
?>

<h2>Edit Customer</h2>
<form method="POST" class="card p-4 shadow-sm">
    <div class="row">
        <div class="col-md-6 mb-3">
            <label>Company Name</label>
            <input type="text" name="com_name" class="form-control" value="<?php echo $customer['com_name']; ?>" required>
        </div>
        <div class="col-md-6 mb-3">
            <label>Admin Name</label>
            <input type="text" name="admin_name" class="form-control" value="<?php echo $customer['admin_name']; ?>" required>
        </div>
    </div>
    <div class="mb-3">
        <label>Company Address</label>
        <textarea name="com_address" class="form-control" required><?php echo $customer['com_address']; ?></textarea>
    </div>
    <div class="row">
        <div class="col-md-6 mb-3">
            <label>Status</label>
            <select name="status" class="form-control">
                <option value="pending" <?php if($customer['status'] == 'pending') echo 'selected'; ?>>Pending</option>
                <option value="active" <?php if($customer['status'] == 'active') echo 'selected'; ?>>Active</option>
            </select>
        </div>
        <div class="col-md-6 mb-3">
            <label>Remarks</label>
            <input type="text" name="remarks" class="form-control" value="<?php echo $customer['remarks']; ?>">
        </div>
    </div>
    <button type="submit" class="btn btn-primary">Update Customer</button>
    <a href="customers.php" class="btn btn-secondary">Back</a>
</form>

<?php include 'footer.php'; ?>
