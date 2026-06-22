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

// 1. Get the Partner ID or Mobile No
$partner_mobile = $_POST['partnerTb'] ?? '';
$partner_identifier = $partner_mobile; // Default to mobile number

if (!empty($partner_mobile)) {
    $stmtP = $conn->prepare('SELECT ID FROM partners WHERE mobile_no = ? OR mobile_no = ? OR mobile_no = ?');
    $with_zero = '0' . ltrim($partner_mobile, '0');
    $no_zero = ltrim($partner_mobile, '0');
    $stmtP->bind_param('sss', $partner_mobile, $no_zero, $with_zero);
    $stmtP->execute();
    $p_res = $stmtP->get_result()->fetch_assoc();
    if ($p_res && isset($p_res['ID'])) {
        $partner_identifier = $p_res['ID']; // Use integer ID if available
    } else {
        die(json_encode(['success' => false, 'message' => 'Partner not found']));
    }
    $stmtP->close();
} else {
    die(json_encode(['success' => false, 'message' => 'Partner identifier empty']));
}

// 2. Handle File Upload (SECURED)
$file_path = '';
// Check if file exists and there are no upload errors at the server level
if (isset($_FILES['payment_slip']) && $_FILES['payment_slip']['error'] === UPLOAD_ERR_OK) {
    $file = $_FILES['payment_slip'];
    $file_tmp = $file['tmp_name'];
    $original_name = $file['name'];
    $file_size = $file['size'];

    // FIX 2: Enforce a maximum file size (e.g., 5MB)
    $max_size = 5 * 1024 * 1024;
    if ($file_size > $max_size) {
        die(json_encode(['success' => false, 'message' => 'File exceeds maximum size of 5MB']));
    }

    // FIX 3: Validate File Extension
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

    // FIX 5: Generate a completely random filename
    $safe_filename = bin2hex(random_bytes(16)) . '.' . $file_ext;
    $target_file = $uploadDir . $safe_filename;

    if (move_uploaded_file($file_tmp, $target_file)) {
        $file_path = $target_file;
    } else {
        die(json_encode(['success' => false, 'message' => 'Failed to save the uploaded file']));
    }
}

// 3. Insert Customer
$com_name = $_POST['com_name'] ?? '';
$com_address = $_POST['com_address'] ?? '';
$com_number = $_POST['com_number'] ?? '';
$admin_name = $_POST['admin_name'] ?? '';
$admin_number = $_POST['admin_number'] ?? '';
$com_area = $_POST['com_area'] ?? '';
$com_field = $_POST['com_field'] ?? '';
$remarks = $_POST['remarks'] ?? '-';
$additional_features = $_POST['additional_features'] ?? '-';
$reference = $_POST['reference'] ?? '';
$preferred_lang = $_POST['preferred_lang'] ?? 'English';
$package_name = $_POST['package_name'] ?? null;
$additional_packages = $_POST['additional_packages'] ?? null;
$discount = $_POST['discount'] ?? 0;
$total_cost = $_POST['total_cost'] ?? 0;

$status = 'Pending';
$rDateTime = date('Y-m-d H:i:s');

$sql = 'INSERT INTO new_clients (partnerTb, com_name, com_address, com_number, admin_name, admin_number,
com_area, com_field, remarks, additional_features, status, rDateTime, reference, preferred_lang,
package_name, additional_packages, discount, total_cost, payment_slip)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
$stmt = $conn->prepare($sql);
$stmt->bind_param(
    'sssssssssssssssssss',
    $partner_identifier,
    $com_name,
    $com_address,
    $com_number,
    $admin_name,
    $admin_number,
    $com_area,
    $com_field,
    $remarks,
    $additional_features,
    $status,
    $rDateTime,
    $reference,
    $preferred_lang,
    $package_name,
    $additional_packages,
    $discount,
    $total_cost,
    $file_path,
);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Customer registered successfully']);
} else {
    // FIX 6: Do not leak raw database errors ($stmt->error) to the user. Log them instead.
    error_log('DB error on add_customer: ' . $stmt->error);
    echo json_encode(['success' => false, 'message' => 'Database update failed.']);
}

$stmt->close();
$conn->close();
