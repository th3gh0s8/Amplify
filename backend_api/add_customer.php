<?php
header('Content-Type: application/json');

// Use existing database configuration
require_once 'db_config.php';

// The $conn variable is now available from db_config.php

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

        // Match the schema provided: id, file_name, file_type, file_path, size_kb, uploaded_at, thumbnail_url, status
        // FINAL UPDATE: Table name is 'web_documents'
        $stmtFile = $conn->prepare("INSERT INTO web_documents (file_name, file_type, file_path, size_kb, status) VALUES (?, ?, ?, ?, 'active')");
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

// FINAL UPDATE: Customer table name is 'new_clients'
// Match the schema provided: id, partnerTb, com_name, com_address, com_number, admin_name, admin_number, com_area, com_field, remarks, additional_features, rDateTime, status
$sql = "INSERT INTO new_clients (partnerTb, com_name, com_address, com_number, admin_name, admin_number, com_area, com_field, remarks, additional_features, status, rDateTime)
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
