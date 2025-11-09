<?php
// Header izinkan akses dari domain manapun
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Detail Koneksi Database
$host = "localhost";
$db_name = "simasperbanas";
$username = "root";          
$password = "";              

try {
    // Membuat koneksi menggunakan PDO (PHP Data Objects)
    $conn = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $conn->exec("set names utf8");
} catch(PDOException $exception) {
    // Jika koneksi gagal, kembalikan JSON error
    http_response_code(500); 
    echo json_encode(
        array("message" => "Connection error: " . $exception->getMessage())
    );
    die();
}
?>