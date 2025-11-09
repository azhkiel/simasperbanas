<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$host = "localhost";
$user = "root";
$pass = "";
$db   = "simasperbanas";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode([
        "success" => false, 
        "message" => "Database connection failed: " . $conn->connect_error
    ]));
}

// Set charset to utf8
$conn->set_charset("utf8mb4");
?>