<?php
// 1. Point to where your .env file is located.
// (Move it outside public_html if possible, e.g., __DIR__ . '/../../.env')
$env_path = __DIR__ . '/.env';

// 2. Read the file natively without plugins
if (!file_exists($env_path)) {
    die(json_encode(["success" => false, "message" => "Server configuration missing."]));
}
$env = parse_ini_file($env_path);

// 3. Connect using the variables
$host   = $env['DB_HOST'];
$user   = $env['DB_USER'];
$pass   = $env['DB_PASS'];
$dbname = $env['DB_NAME'];

$conn = new mysqli($host, $user, $pass, $dbname);

// 4. Secure Error Handling
if ($conn->connect_error) {
    // SECURITY FIX: Do not output $conn->connect_error to the screen in production!
    // It leaks system info to attackers. Log it secretly instead.
    error_log("DB Connection failed: " . $conn->connect_error);
    die(json_encode(["success" => false, "message" => "Database connection failed."]));
}

// Ensure correct character encoding
$conn->set_charset("utf8mb4");
?>
