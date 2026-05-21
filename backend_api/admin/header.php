<?php
require_once 'db.php';
check_auth();
?>
<!DOCTYPE html>
<html>
<head>
    <title>XPower Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <link href="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/css/tom-select.bootstrap5.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/tom-select@2.2.2/dist/js/tom-select.complete.min.js"></script>
    <style>
        .table th, .table td { min-width: 150px; }
        .table th:first-child, .table td:first-child { min-width: 50px; } /* ID column */
        .table th:last-child, .table td:last-child { min-width: 100px; } /* Actions column */
        /* Tom Select height adjustment */
        .ts-control { min-height: 38px !important; padding: 7px 12px !important; }
    </style>
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4">
    <div class="container-fluid">
        <a class="navbar-brand" href="index.php">XPower Admin</a>
        <div class="navbar-nav me-auto">
            <a class="nav-link" href="index.php">Dashboard</a>
            <a class="nav-link" href="partners.php">Partners</a>
            <a class="nav-link" href="customers.php">Customers</a>
            <a class="nav-link" href="invoices.php">Invoices</a>
            <a class="nav-link" href="notifications.php">Notifications</a>
        </div>
        <div class="navbar-nav">
            <a class="nav-link" href="logout.php">Logout</a>
        </div>
    </div>
</nav>
<div class="container-fluid">
