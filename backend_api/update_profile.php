<?php
require_once 'cors_headers.php';

if (file_exists('db/db_config.php')) {
    require_once 'db/db_config.php';
} elseif (file_exists('db_config.php')) {
    require_once 'db_config.php';
} else {
    die(json_encode(["success" => false, "message" => "CRITICAL: Database config not found."]));
}

$mobile_no = $_POST['mobile_no'] ?? '';
$c_code = $_POST['c_code'] ?? '';
$first_name = $_POST['first_name'] ?? '';
$last_name = $_POST['last_name'] ?? '';
$email = $_POST['email'] ?? '';
$bank_account_no = $_POST['bank_account_no'] ?? '';
$bank_name = $_POST['bank_name'] ?? '';
$bank_ac_branch = $_POST['bank_ac_branch'] ?? '';
$remarks = $_POST['remarks'] ?? '';

// Business Details
$partner_type = $_POST['partner_type'] ?? 'freelancer';
$nic_number = $_POST['nic_number'] ?? null;
$business_name = $_POST['business_name'] ?? null;
$business_type = $_POST['business_type'] ?? null;
$address_line1 = $_POST['address_line1'] ?? null;
$city = $_POST['city'] ?? null;
$tax_id = $_POST['tax_id'] ?? null;
$website = $_POST['website'] ?? null;

if (empty($mobile_no)) {
    echo json_encode(["success" => false, "message" => "Mobile number is required"]);
    exit;
}

try {
    $conn->begin_transaction();

    $stmt = $conn->prepare("SELECT ID FROM partners WHERE mobile_no = ? OR mobile_no = ?");
    $with_zero = '0' . ltrim($mobile_no, '0');
    $no_zero = ltrim($mobile_no, '0');
    $stmt->bind_param("ss", $no_zero, $with_zero);
    $stmt->execute();
    $result = $stmt->get_result();
    $partner = $result->fetch_assoc();
    $stmt->close();

    if (!$partner) {
        throw new Exception("Partner not found");
    }
    $partner_id = $partner['ID'];

    $stmt = $conn->prepare("UPDATE partners SET first_name = ?, last_name = ?, c_code = ?, email = ?, bank_account_no = ?, bank_name = ?, bank_ac_branch = ?, remarks = ? WHERE ID = ?");
    $stmt->bind_param("ssssssssi", $first_name, $last_name, $c_code, $email, $bank_account_no, $bank_name, $bank_ac_branch, $remarks, $partner_id);
    $stmt->execute();
    $stmt->close();

    // Check if partner_business_details table exists before trying to update/insert
    $table_check = $conn->query("SHOW TABLES LIKE 'partner_business_details'");
    if ($table_check->num_rows > 0) {
        $stmt = $conn->prepare("SELECT id FROM partner_business_details WHERE partner_id = ?");
        $stmt->bind_param("i", $partner_id);
        $stmt->execute();
        $biz_res = $stmt->get_result();
        $biz = $biz_res->fetch_assoc();
        $stmt->close();

        if ($biz) {
            $stmt = $conn->prepare("UPDATE partner_business_details SET partner_type = ?, nic_number = ?, business_name = ?, business_type = ?, address_line1 = ?, city = ?, tax_id = ?, website = ? WHERE partner_id = ?");
            $stmt->bind_param("ssssssssi", $partner_type, $nic_number, $business_name, $business_type, $address_line1, $city, $tax_id, $website, $partner_id);
        } else {
            $stmt = $conn->prepare("INSERT INTO partner_business_details (partner_id, partner_type, nic_number, business_name, business_type, address_line1, city, tax_id, website) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("issssssss", $partner_id, $partner_type, $nic_number, $business_name, $business_type, $address_line1, $city, $tax_id, $website);
        }
        $stmt->execute();
        $stmt->close();
    }

    $conn->commit();
    echo json_encode(["success" => true, "message" => "Profile updated successfully"]);
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(["success" => false, "message" => "Server Error: " . $e->getMessage()]);
}

$conn->close();
?>
