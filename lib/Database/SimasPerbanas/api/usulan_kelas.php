<?php
include 'config.php';
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

// Validasi bahwa request method adalah POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["success" => false, "message" => "Method not allowed"]);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);

// Validasi bahwa data JSON berhasil di-decode
if ($data === null) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Invalid JSON data"]);
    exit;
}

// Validasi field yang required
$required_fields = ['nim', 'nama_mk', 'hari', 'shift', 'alasan'];
foreach ($required_fields as $field) {
    if (!isset($data[$field]) || empty(trim($data[$field]))) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Field $field is required"]);
        exit;
    }
}

$nim = $data['nim'];
$nama_mk = $data['nama_mk'];
$hari = $data['hari'];
$shift = $data['shift'];
$alasan = $data['alasan'];

// Gunakan prepared statement untuk mencegah SQL injection
$query = "INSERT INTO usulan_kelas (nim, nama_mk, hari, shift, alasan) VALUES (?, ?, ?, ?, ?)";
$stmt = mysqli_prepare($conn, $query);

if ($stmt) {
    mysqli_stmt_bind_param($stmt, "sssss", $nim, $nama_mk, $hari, $shift, $alasan);
    
    if (mysqli_stmt_execute($stmt)) {
        echo json_encode(["success" => true, "message" => "Usulan kelas berhasil dikirim"]);
    } else {
        http_response_code(500);
        echo json_encode(["success" => false, "message" => "Gagal mengirim usulan: " . mysqli_error($conn)]);
    }
    
    mysqli_stmt_close($stmt);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Database error: " . mysqli_error($conn)]);
}

// Jangan lupa tutup koneksi
mysqli_close($conn);
?>