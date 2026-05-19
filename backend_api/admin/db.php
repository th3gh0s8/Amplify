<?php
session_start();
require_once '../db/db_config.php';

function check_auth() {
    if (!isset($_SESSION['admin_id'])) {
        header("Location: login.php");
        exit;
    }
}
?>
