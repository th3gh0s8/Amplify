<?php include 'header.php'; ?>

<?php
$id = (int)($_GET['id'] ?? 0);
if ($id == 0) { header("Location: partners.php"); exit; }

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $first_name = $_POST['first_name'];
    $last_name = $_POST['last_name'];
    $email = $_POST['email'];
    $mobile_no = $_POST['mobile_no'];
    $bank_name = $_POST['bank_name'];
    $bank_account_no = $_POST['bank_account_no'];

    $stmt = $conn->prepare("UPDATE partners SET first_name=?, last_name=?, email=?, mobile_no=?, bank_name=?, bank_account_no=? WHERE ID=?");
    $stmt->bind_param("ssssssi", $first_name, $last_name, $email, $mobile_no, $bank_name, $bank_account_no, $id);
    
    if ($stmt->execute()) {
        echo "<div class='alert alert-success'>Partner updated!</div>";
    } else {
        echo "<div class='alert alert-danger'>Update failed: " . $conn->error . "</div>";
    }
}

$partner = $conn->query("SELECT * FROM partners WHERE ID = $id")->fetch_assoc();
if (!$partner) { echo "Partner not found"; include 'footer.php'; exit; }
?>

<h2>Edit Partner</h2>
<form method="POST" class="card p-4 shadow-sm">
    <div class="row">
        <div class="col-md-6 mb-3">
            <label>First Name</label>
            <input type="text" name="first_name" class="form-control" value="<?php echo $partner['first_name']; ?>" required>
        </div>
        <div class="col-md-6 mb-3">
            <label>Last Name</label>
            <input type="text" name="last_name" class="form-control" value="<?php echo $partner['last_name']; ?>" required>
        </div>
    </div>
    <div class="row">
        <div class="col-md-6 mb-3">
            <label>Email</label>
            <input type="email" name="email" class="form-control" value="<?php echo $partner['email']; ?>" required>
        </div>
        <div class="col-md-6 mb-3">
            <label>Mobile No</label>
            <input type="text" name="mobile_no" class="form-control" value="<?php echo $partner['mobile_no']; ?>" required>
        </div>
    </div>
    <div class="row">
        <div class="col-md-6 mb-3">
            <label>Bank Name</label>
            <input type="text" name="bank_name" class="form-control" value="<?php echo $partner['bank_name']; ?>">
        </div>
        <div class="col-md-6 mb-3">
            <label>Bank Account No</label>
            <input type="text" name="bank_account_no" class="form-control" value="<?php echo $partner['bank_account_no']; ?>">
        </div>
    </div>
    <button type="submit" class="btn btn-primary">Update Partner</button>
    <a href="partners.php" class="btn btn-secondary">Back</a>
</form>

<?php include 'footer.php'; ?>
