<?php

echo '<h2>Mail Server Log Diagnostic</h2>';

// Common log paths for Ubuntu, CentOS, and cPanel environments
$log_files = [
    '/var/log/mail.log', // Ubuntu / Debian
    '/var/log/maillog', // CentOS / RedHat
    '/var/log/exim_mainlog', // cPanel / WHM
];

$found = false;

foreach ($log_files as $file) {
    if (file_exists($file)) {
        echo "<h3>Checking log file: <code>$file</code></h3>";
        $found = true;

        // Check if PHP has permission to read the file
        if (is_readable($file)) {
            // Grab the last 50 lines
            $output = shell_exec('tail -n 50 ' . escapeshellarg($file));
            if ($output) {
                echo "<pre style='background:#1e1e1e; color:#00ff00; padding:15px; overflow-x:auto;'>";
                echo htmlspecialchars($output);
                echo '</pre>';
            } else {
                echo '<p>Log is empty or shell_exec is disabled.</p>';
            }
        } else {
            echo
                "<p style='color:red;'><strong>Permission Denied:</strong> The log file exists, but PHP is not allowed to read it.</p>"
            ;
        }
        break; // Stop after finding the first valid log file
    }
}

if (!$found) {
    echo
        "<p style='color:orange;'>Could not locate standard mail logs. The server might be using a custom path, or the logs are completely restricted from the web directory.</p>"
    ;
}
