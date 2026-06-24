<?php
// PRODUCTION OTP PRECISION FIX & LIVE TESTER
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once 'db/db_config.php';

echo "<h2>XPower Production OTP Fixer</h2>";

// 1. Convert Column to VARCHAR if it's still INT
echo "<h3>1. Checking Live Table Structure...</h3>";
$res = $conn->query("DESCRIBE web_codes");
if (!$res) die("Table web_codes not found!");

while($row = $res->fetch_assoc()) {
    if ($row['Field'] == 'u_Id' && strpos($row['Type'], 'int') !== false) {
        echo "<p style='color:orange'>CONVERTING: Column 'u_Id' is INT. Changing to VARCHAR(20) for live server compatibility...</p>";
        $conn->query("SET FOREIGN_KEY_CHECKS = 0");
        $fix = $conn->query("ALTER TABLE web_codes MODIFY u_Id VARCHAR(20) NOT NULL");
        $conn->query("SET FOREIGN_KEY_CHECKS = 1");
        if ($fix) echo "SUCCESS: Column converted.<br>";
        else echo "FAILED: " . $conn->error . "<br>";
    }
}

// 2. Test Live Generation
echo "<h3>2. Testing Live OTP Generation...</h3>";
$test_mobile = "771234567"; // A real-looking format
$test_otp = rand(1111, 9999);
$now = date('Y-m-d H:i:s');

$stmt = $conn->prepare("INSERT INTO web_codes (u_Id, otp_code, time, status) VALUES (?, ?, ?, 0)");
$stmt->bind_param("sis", $test_mobile, $test_otp, $now);

if ($stmt->execute()) {
    echo "<span style='color:green; font-size: 20px;'>SUCCESS! The live server successfully saved OTP $test_otp for $test_mobile</span><br>";
    echo "<p>Please delete this script from your server after verification.</p>";
} else {
    echo "<span style='color:red;'>FAILURE: The live database rejected the OTP. Reason: " . $stmt->error . "</span>";
}

$conn->close();
?>
