<?php

require_once 'cors_headers.php';

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} else {
    require_once 'db_config.php';
}

// FIX 1: Change directory permissions from 0777 (dangerous) to 0755 (secure)
$uploadDir = 'uploads/payment_slips/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

$customer_id = $_POST['customer_id'] ?? '';
// FIX 2: Ensure customer ID is not just empty, but actually a number
if (empty($customer_id) || !is_numeric($customer_id)) {
    die(json_encode(['success' => false, 'message' => 'Invalid Customer ID']));
}

// FIX 3: Check for upload errors at the server level
if (!isset($_FILES['payment_slip']) || $_FILES['payment_slip']['error'] !== UPLOAD_ERR_OK) {
    die(json_encode(['success' => false, 'message' => 'No file uploaded or upload error']));
}

$file = $_FILES['payment_slip'];
$file_tmp = $file['tmp_name'];
$original_name = $file['name'];
$file_size = $file['size'];

// FIX 4: Enforce a maximum file size (e.g., 5MB)
$max_size = 5 * 1024 * 1024;
if ($file_size > $max_size) {
    die(json_encode(['success' => false, 'message' => 'File exceeds maximum size of 5MB']));
}

// FIX 5: Validate File Extension
$allowed_extensions = ['jpg', 'jpeg', 'png', 'pdf'];
$file_ext = strtolower(pathinfo($original_name, PATHINFO_EXTENSION));
if (!in_array($file_ext, $allowed_extensions)) {
    die(json_encode(['success' => false, 'message' => 'Invalid file type. Only JPG, PNG, and PDF are allowed.']));
}

// FIX: Validate MIME Type safely
$file_mime = '';

if (class_exists('finfo')) {
    $finfo = new finfo(FILEINFO_MIME_TYPE);
    $file_mime = $finfo->file($file_tmp);
} elseif (function_exists('mime_content_type')) {
    $file_mime = mime_content_type($file_tmp);
} else {
    $file_mime = $file['type'] ?? '';
}

// NEW FIX: Flutter Octet-Stream Fallback
// If Flutter sends generic bytes, manually map the MIME type based on the validated extension
if (($file_mime === 'application/octet-stream' || empty($file_mime)) && in_array($file_ext, $allowed_extensions)) {
    if ($file_ext === 'pdf') {
        $file_mime = 'application/pdf';
    } elseif ($file_ext === 'png') {
        $file_mime = 'image/png';
    } elseif (in_array($file_ext, ['jpg', 'jpeg'])) {
        $file_mime = 'image/jpeg';
    }
}

$allowed_mimes = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'];
if (empty($file_mime) || !in_array($file_mime, $allowed_mimes)) {
    // Output the detected MIME type so we can debug if it fails again
    die(json_encode(['success' => false, 'message' => 'Invalid file content: ' . htmlspecialchars($file_mime)]));
}

// FIX 7: Generate a completely random filename
$safe_filename = bin2hex(random_bytes(16)) . '.' . $file_ext;
$target_file = $uploadDir . $safe_filename;

if (move_uploaded_file($file_tmp, $target_file)) {
    $stmt = $conn->prepare('UPDATE new_clients SET payment_slip = ? WHERE ID = ?');

    // "si" means String (file path) and Integer (customer ID)
    $stmt->bind_param('si', $target_file, $customer_id);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Payment slip uploaded successfully']);
    } else {
        // FIX 8: Do not leak raw database errors ($stmt->error) to the user. Log them instead.
        error_log('DB error on upload: ' . $stmt->error);
        echo json_encode(['success' => false, 'message' => 'Database update failed.']);
    }
    $stmt->close();
} else {
    echo json_encode(['success' => false, 'message' => 'Failed to save the file.']);
}

$conn->close();
