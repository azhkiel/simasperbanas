<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Baca data JSON yang dikirim
$input = json_decode(file_get_contents('php://input'), true);

$host = "localhost";
$user = "root";
$pass = "";
$db   = "simasperbanas";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Database connection failed"]));
}

// Validasi keberadaan data POST
if (!isset($input['nim']) || !isset($input['password'])) {
    die(json_encode([
        "success" => false, 
        "message" => "Data tidak lengkap! Pastikan mengirim NIM dan password"
    ]));
}

$nim = $input['nim'];
$password = $input['password'];

// Validasi input tidak boleh kosong
if (empty(trim($nim)) || empty(trim($password))) {
    die(json_encode([
        "success" => false, 
        "message" => "NIM atau password tidak boleh kosong"
    ]));
}

$sql = "SELECT * FROM user WHERE nim = ? AND password = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $nim, $password);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $data = $result->fetch_assoc();
    
    echo json_encode([ 
        "success" => true, 
        "status" => "success",
        "data" => [ 
            "id_user" => $data['id_user'] ?? null,
            "nim" => $data['nim'] ?? '',
            "nama" => $data['nama'] ?? '',
            "email" => $data['email'] ?? '',
            "program_studi" => $data['program_studi'] ?? '',
            "dosen_wali" => $data['dosen_wali'] ?? ''
        ],
        "message" => "Login berhasil"
    ]);
} else {
    echo json_encode([
        "success" => false, 
        "message" => "NIM atau password salah",
        "status" => "failed"
    ]);
}   

$stmt->close();
$conn->close();
?>