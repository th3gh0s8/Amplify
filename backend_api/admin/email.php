<?php
// 1. Manually require the necessary PHPMailer files
// Make sure this path matches exactly where you uploaded the files on your server!
require 'PHPMailer/Exception.php';
require 'PHPMailer/PHPMailer.php';
require 'PHPMailer/SMTP.php';

// 2. Import the classes into the global namespace
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

function sendEnterpriseEmail($toEmail, $toName)
{
    // Create an instance; passing `true` enables exceptions
    $mail = new PHPMailer(true);

    try {
        // --- Server settings ---
        $mail->isSMTP();                                      // Tell PHPMailer to use SMTP
        $mail->Host       = 'smtp.your-enterprise.com';       // Set the SMTP server to send through
        $mail->SMTPAuth   = true;                             // Enable SMTP authentication
        $mail->Username   = 'your_email@enterprise.com';      // SMTP username
        $mail->Password   = 'your_email_password';            // SMTP password
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;   // Enable TLS encryption (or ENCRYPTION_SMTPS for port 465)
        $mail->Port       = 587;                              // TCP port to connect to

        // --- Recipients ---
        $mail->setFrom('noreply@enterprise.com', 'Enterprise System');
        $mail->addAddress($toEmail, $toName);                 // Add a recipient

        // --- Content ---
        $mail->isHTML(true);                                  // Set email format to HTML
        $mail->Subject = 'Vanilla PHP SMTP Test';
        $mail->Body    = '<h1>It works!</h1><p>We bypassed Composer and sent this via authenticated SMTP.</p>';
        $mail->AltBody = 'It works! We bypassed Composer and sent this via authenticated SMTP.';

        $mail->send();
        echo "Message has been sent successfully!";
    } catch (Exception $e) {
        echo "Message could not be sent. Mailer Error: {$mail->ErrorInfo}";
    }
}

// Run the test
sendEnterpriseEmail('test@example.com', 'Test User');
