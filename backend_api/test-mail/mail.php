<?php
// TEST 1: Force PHP to show all hidden errors on the screen
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h2>Email Diagnostic Tests</h2>";

// Set up the exact headers your PM requested
$to = "chamudithapasindu54@gmail.com";
$subject = "Welcome to XPower - Diagnostic Test";

$message = '
<html>
<head><title>Welcome to XPower</title></head>
<body>
    <p>Dear Customer,</p>
    <p>Thank you for choosing XPower.</p>
    <p>We are pleased to have you with us.</p>
    <br>
    <p>Regards,<br>XPower Team</p>
</body>
</html>';

$headers = [];
$headers[] = "MIME-Version: 1.0";
$headers[] = "Content-Type: text/html; charset=UTF-8";
$headers[] = "From: XPower <ramzi@powersoftt.com>";
$headers[] = "Reply-To: ramzi@powersoftt.com";
$headers[] = "Return-Path: ramzi@powersoftt.com";
$headers[] = "X-Mailer: PHP/" . phpversion();
$headers[] = "Message-ID: <" . time() . "." . uniqid() . "@powersoftt.com>";

// Attempt to send the mail
$result = mail(
    $to,
    $subject,
    $message,
    implode("\r\n", $headers),
    "-fhr@powersoftt.com"
);

// TEST 2: Check the boolean execution result
echo "<h3>Test Result 1: Execution Status</h3>";
if ($result) {
    echo "<p style='color: green;'><strong>SUCCESS:</strong> The local mail server accepted the request and placed it in the outgoing queue.</p>";
    echo "<p><em>Note: This does NOT mean it bypassed the spam filter. Check your Gmail inbox and spam folder now.</em></p>";
} else {
    echo "<p style='color: red;'><strong>FAILED:</strong> The local mail server rejected the request entirely.</p>";

    // TEST 3: Grab the exact system error message if it failed
    $errorMessage = error_get_last();
    if ($errorMessage !== null) {
        echo "<h4>System Error Output:</h4>";
        echo "<pre>" . print_r($errorMessage, true) . "</pre>";
    } else {
        echo "<p>No specific error was logged by the server. The local Sendmail/Postfix service might be disabled.</p>";
    }
}

