<?php
require_once 'db.php';

// Auto-insert default admin if table empty (for users table)
$res = $conn->query("SELECT id FROM users WHERE role = 'admin' LIMIT 1");
if ($res && $res->num_rows == 0) {
    $pass = password_hash('lxd6Z967', PASSWORD_DEFAULT);
    $conn->query("INSERT INTO users (email, password_hash, first_name, role, is_active, is_verified) 
                  VALUES ('admin@xpower.com', '$pass', 'Admin', 'admin', 1, 1)");
}

$error = "";
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $email = $_POST['username']; // Using email as username
    $pass = $_POST['password'];
    
    $stmt = $conn->prepare("SELECT id, password_hash, role FROM users WHERE email = ? AND role = 'admin' AND is_active = 1");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $res = $stmt->get_result();
    
    if ($row = $res->fetch_assoc()) {
        if (password_verify($pass, $row['password_hash'])) {
            $_SESSION['admin_id'] = $row['id'];
            $_SESSION['admin_email'] = $email;
            header("Location: index.php");
            exit;
        }
    }
    $error = "Invalid credentials or not an admin";
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-4">
            <div class="card shadow">
                <div class="card-header bg-primary text-white text-center">Admin Login</div>
                <div class="card-body">
                    <p class="small text-muted text-center">Use email to login</p>
                    <?php if($error): ?><div class="alert alert-danger"><?php echo $error; ?></div><?php endif; ?>
                    <form method="POST">
                        <div class="mb-3">
                            <label>Email</label>
                            <input type="email" name="username" class="form-control" placeholder="admin@xpower.com" required>
                        </div>
                        <div class="mb-3">
                            <label>Password</label>
                            <input type="password" name="password" class="form-control" required>
                        </div>
                        <button type="submit" class="btn btn-primary w-100">Login</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
