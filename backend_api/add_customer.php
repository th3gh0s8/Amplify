<?php
header('Content-Type: application/json');

// Use existing database configuration
require_once 'db_config.php';

// Ensure uploads directory exists
$uploadDir = 'uploads/payment_slips/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

// 1. Get the Partner's numeric ID from their mobile number
$partner_mobile = $_POST['partnerTb'] ?? ''; // App sends mobile number here
$partner_id = 0;

if (!empty($partner_mobile)) {
    $stmtP = $conn->prepare("SELECT ID FROM partners WHERE mobile_no = ?");
    $stmtP->bind_param("s", $partner_mobile);
    $stmtP->execute();
    $p_res = $stmtP->get_result()->fetch_assoc();
    if ($p_res) {
        $partner_id = $p_res['ID'];
    }
    $stmtP->close();
}

if ($partner_id == 0) {
    die(json_encode(['success' => false, 'message' => 'Partner not found for mobile: ' . $partner_mobile]));
}

// 2. Handle File Upload (Payment Slip)
$file_path = "";
if (isset($_FILES['payment_slip'])) {
    $file = $_FILES['payment_slip'];
    $file_name = time() . '_' . basename($file['name']);
    $target_file = $uploadDir . $file_name;
    $ext = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

    if (move_uploaded_file($file['tmp_name'], $target_file)) {
        $file_path = $target_file;
        $file_type = (in_array($ext, ['jpg', 'jpeg', 'png'])) ? 'image' : 'pdf';
        $size_kb = round($file['size'] / 1024);

        $stmtFile = $conn->prepare("INSERT INTO web_documents (file_name, file_type, file_path, size_kb, status) VALUES (?, ?, ?, ?, 'active')");
        $stmtFile->bind_param("sssi", $file['name'], $file_type, $file_path, $size_kb);
        $stmtFile->execute();
        $slip_id = $conn->insert_id;
        $stmtFile->close();
    } else {
        die(json_encode(['success' => false, 'message' => 'Failed to move uploaded file']));
    }
} else {
    die(json_encode(['success' => false, 'message' => 'Payment slip is required']));
}

// 3. Handle Customer Data
$com_name = $_POST['com_name'] ?? '';
$com_address = $_POST['com_address'] ?? '';
$com_number = $_POST['com_number'] ?? '';
$admin_name = $_POST['admin_name'] ?? '';
$admin_number = $_POST['admin_number'] ?? '';
$com_area = $_POST['com_area'] ?? '';
$com_field = $_POST['com_field'] ?? '';
$remarks = $_POST['remarks'] ?? '-';
$additional_features = $_POST['additional_features'] ?? '-';

if (empty($remarks)) $remarks = "-";
if (empty($additional_features)) $additional_features = "-";

$sql = "INSERT INTO new_clients (partnerTb, com_name, com_address, com_number, admin_name, admin_number, com_area, com_field, remarks, additional_features, status, rDateTime)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Pending', NOW())";

$stmt = $conn->prepare($sql);
$stmt->bind_param("isssssssss", $partner_id, $com_name, $com_address, $com_number, $admin_name, $admin_number, $com_area, $com_field, $remarks, $additional_features);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Customer registered successfully']);
} else {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
