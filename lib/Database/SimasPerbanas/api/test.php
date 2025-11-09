<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Test koneksi database
$host = "localhost";
$username = "root";
$password = "";
$database = "simasperbanas";

$conn = new mysqli($host, $username, $password, $database);

$response = [
    "status" => "success",
    "message" => "✅ API SimasPerbanas is working!",
    "timestamp" => date("Y-m-d H:i:s"),
    "server" => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
    "php_version" => phpversion(),
    "database_connected" => !$conn->connect_error,
    "database_error" => $conn->connect_error ? $conn->connect_error : "None"
];

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $response['post_data'] = $_POST;
    $response['input_data'] = file_get_contents("php://input");
}

echo json_encode($response, JSON_PRETTY_PRINT);
$conn->close();
?>