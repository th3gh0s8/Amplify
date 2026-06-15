<?php
    require_once 'cors_headers.php';
    if (file_exists('db/db_config.php')) {
        require_once 'db/db_config.php';
    } else {
        require_once 'db_config.php';
    }

    $uploadDir = 'uploads/payment_slips/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $customer_id = $_POST['customer_id'] ?? '';
    if (empty($customer_id)) {
        die(json_encode(['success' => false, 'message' => 'Customer ID empty']));
    }

    if (!isset($_FILES['payment_slip'])) {
        die(json_encode(['success' => false, 'message' => 'No file uploaded']));
    }

    $file = $_FILES['payment_slip'];
    $file_name = time() . '_' . basename($file['name']);
    $target_file = $uploadDir . $file_name;

    if (move_uploaded_file($file['tmp_name'], $target_file)) {
        $stmt = $conn->prepare("UPDATE new_clients SET payment_slip = ? WHERE ID = ?");
        $stmt->bind_param("si", $target_file, $customer_id);
        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'Payment slip uploaded', 'payment_slip' =>
  $target_file]);
        } else {
            echo json_encode(['success' => false, 'message' => 'DB error: ' . $stmt->error]);
        }
        $stmt->close();
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to move file']);
    }
    $conn->close();
?>
