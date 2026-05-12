<?php
require_once 'db/db_config.php';
$result = $conn->query("DESCRIBE new_clients");
while ($row = $result->fetch_assoc()) {
    echo $row['Field'] . " - " . $row['Type'] . "\n";
}
?>