<?php
header('Content-Type: application/json');

// Database configuration
$host = 'localhost';
$user = 'root';
$pass = '';
$db   = 'xpower_partners'; // UPDATED: Changed from 'xpower_partners_db' to 'xpower_partners'

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => 'Database connection failed']));
}

// Ensure uploads directory exists
$uploadDir = 'uploads/payment_slips/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

// 1. Handle File Upload (Payment Slip)
$file_path = "";
$file_name = "";
$file_type = "";
$size_kb = 0;

if (isset($_FILES['payment_slip'])) {
    $file = $_FILES['payment_slip'];
    $file_name = time() . '_' . basename($file['name']);
    $target_file = $uploadDir . $file_name;
    $ext = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

    if (move_uploaded_file($file['tmp_name'], $target_file)) {
        $file_path = $target_file;
        $file_type = (in_array($ext, ['jpg', 'jpeg', 'png'])) ? 'image' : 'pdf';
        $size_kb = round($file['size'] / 1024);

        // Insert into files/slips table first (based on your schema)
        $stmtFile = $conn->prepare("INSERT INTO payment_slips (file_name, file_type, file_path, size_kb, status) VALUES (?, ?, ?, ?, 'active')");
        $stmtFile->bind_param("sssi", $file['name'], $file_type, $file_path, $size_kb);
        $stmtFile->execute();
        $slip_id = $conn->insert_id;
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to move uploaded file']);
        exit;
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Payment slip is required']);
    exit;
}

// 2. Handle Customer Data
$partnerTb = $_POST['partnerTb'] ?? 0;
$com_name = $_POST['com_name'] ?? '';
$com_address = $_POST['com_address'] ?? '';
$com_number = $_POST['com_number'] ?? '';
$admin_name = $_POST['admin_name'] ?? '';
$admin_number = $_POST['admin_number'] ?? '';
$com_area = $_POST['com_area'] ?? '';
$com_field = $_POST['com_field'] ?? '';
$remarks = $_POST['remarks'] ?? '';
$additional_features = $_POST['additional_features'] ?? '';

// Handle empty optional fields
if (empty($remarks)) $remarks = "-";
if (empty($additional_features)) $additional_features = "-";

$sql = "INSERT INTO customers (partnerTb, com_name, com_address, com_number, admin_name, admin_number, com_area, com_field, remarks, additional_features, status, rDateTime)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Pending', NOW())";

$stmt = $conn->prepare($sql);
$stmt->bind_param("isssssssss", $partnerTb, $com_name, $com_address, $com_number, $admin_name, $admin_number, $com_area, $com_field, $remarks, $additional_features);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Customer registered successfully']);
} else {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
