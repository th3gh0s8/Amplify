<?php

echo '<h2>SMTP Outbound Network Test</h2>';

// The main incoming mail server for Gmail
$host = 'gmail-smtp-in.l.google.com';
$port = 25;
$timeout = 5;

echo "<p>Attempting to connect to Google's Mail Server (Port 25)...</p>";

$connection = @fsockopen($host, $port, $errno, $errstr, $timeout);

if (is_resource($connection)) {
    echo
        "<p style='color: green;'><strong>SUCCESS:</strong> Port 25 is OPEN. Your VPS can talk to the outside world.</p>"
    ;
    fclose($connection);
} else {
    echo "<p style='color: red;'><strong>FAILED:</strong> Port 25 is BLOCKED by the hosting provider's firewall.</p>";
    echo "<p>Error: $errno - $errstr</p>";
}
