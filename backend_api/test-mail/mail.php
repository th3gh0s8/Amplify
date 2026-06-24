<?php

$to = "chamudithapasindu54@gmail.com";
$subject = "Welcome to XPower";

$message = '
<html>
<head>
    <title>Welcome to XPower</title>
</head>
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

$result = mail(
    $to,
    $subject,
    $message,
    implode("\r\n", $headers),
    "-framzi@powersoftt.com"
);

if ($result) {
    echo "Mail sent successfully";
} else {
    echo "Mail sending failed";
}
?>