<?php
require_once 'cors_headers.php';

// FETCH ALL PARTNER DATA IN ONE SHOT
header('Content-Type: application/json');
header('Cache-Control: no-cache, no-store, must-revalidate');

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} elseif (file_exists('db_config.php')) {
    require_once 'db_config.php';
} else {
    die(json_encode(["success" => false, "message" => "CRITICAL: Database config not found."]));
}

$mobile_no = $_GET['mobile_no'] ?? '';
if (empty($mobile_no)) {
    die(json_encode(["success" => false, "message" => "Mobile number required"]));
}

// Normalize input
$clean_no = preg_replace('/\D/', '', $mobile_no);
$no_zero = ltrim($clean_no, '0');
$with_zero = '0' . $no_zero;

try {
    // Search Partner - SELECT * includes all business columns from the same table
    $stmt = $conn->prepare("SELECT * FROM partners WHERE mobile_no = ? OR mobile_no = ? LIMIT 1");
    $stmt->bind_param("ss", $no_zero, $with_zero);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $partner = $result->fetch_assoc();
        echo json_encode([
            "success" => true,
            "data" => $partner
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Partner not found for: $mobile_no"]);
    }
    $stmt->close();
} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Server Error: " . $e->getMessage()]);
}

$conn->close();
?>
