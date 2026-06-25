<?php

// Display errors for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// THE VISUAL PROOF BANNER
echo "<h1 style='color: blue; border: 2px solid blue; padding: 10px;'>VERSION 2.0: PRODUCTION SCRIPT RUNNING</h1>";

// THE CRITICAL FIX: These MUST match exactly.
$sender_email = 'hr@powersoftt.com';
$sender_name = 'XPower HR Team';
$recipient = 'chamudithapasindu54@gmail.com';

$subject = 'Welcome to the XPower Partner Network';

// Realistic HTML content (satisfies Gmail's AI)
$message = '
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; color: #333333; line-height: 1.6; }
        .footer { margin-top: 30px; font-size: 12px; color: #777777; border-top: 1px solid #eeeeee; padding-top: 10px; }
    </style>
</head>
<body>
    <h2>Welcome to the Team!</h2>
    <p>Dear Partner,</p>
    <p>Thank you for registering with the XPower Partner Network. Your account has been successfully provisioned on our new dedicated server.</p>
    <p>If you have any questions regarding your dashboard or upcoming invoices, please reach out to your account manager.</p>
    <br>
    <p>Best regards,<br><strong>The XPower Team</strong></p>

    <div class="footer">
        <p>Powersoftt Inc. | 123 Enterprise Way, Business District | Contact: support@powersoftt.com</p>
        <p><em>This is an automated operational message regarding your account.</em></p>
    </div>
</body>
</html>';

$headers = [];
$headers[] = 'MIME-Version: 1.0';
$headers[] = 'Content-Type: text/html; charset=UTF-8';
$headers[] = "From: {$sender_name} <{$sender_email}>";
$headers[] = "Reply-To: {$sender_email}";
$headers[] = "Return-Path: {$sender_email}"; // Matches the sender exactly
$headers[] = 'X-Mailer: PHP/' . phpversion();
$headers[] = 'Message-ID: <' . time() . '.' . uniqid() . '@powersoftt.com>';

// The -f flag MUST match the sender email exactly
$result = mail($recipient, $subject, $message, implode("\r\n", $headers), '-f' . $sender_email);

if ($result) {
    echo "<p style='color:green;'><strong>SUCCESS:</strong> Code executed. Check your Gmail Inbox and Spam folder.</p>";
} else {
    echo "<p style='color:red;'><strong>FAILED:</strong> mail() function failed to execute.</p>";
}
