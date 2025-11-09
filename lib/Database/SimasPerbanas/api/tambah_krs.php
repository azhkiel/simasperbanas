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
$required_fields = ['nim', 'semester', 'tahun_akademik'];
foreach ($required_fields as $field) {
    if (!isset($data[$field]) || empty(trim($data[$field]))) {
        http_response_code(400);
        echo json_encode(["success" => false, "message" => "Field $field is required"]);
        exit;
    }
}

$nim = $data['nim'];
$semester = $data['semester'];
$tahun = $data['tahun_akademik'];

// Validasi format data (contoh: semester harus angka)
if (!is_numeric($semester)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Semester harus berupa angka"]);
    exit;
}

// Gunakan prepared statement untuk mencegah SQL injection
$query = "INSERT INTO krs (nim, semester, tahun_akademik) VALUES (?, ?, ?)";
$stmt = mysqli_prepare($conn, $query);

if ($stmt) {
    mysqli_stmt_bind_param($stmt, "sis", $nim, $semester, $tahun);
    
    if (mysqli_stmt_execute($stmt)) {
        // Dapatkan ID yang baru saja di-insert (jika diperlukan)
        $new_id = mysqli_insert_id($conn);
        echo json_encode([
            "success" => true, 
            "message" => "KRS berhasil ditambahkan",
            "id_krs" => $new_id
        ]);
    } else {
        http_response_code(500);
        // Untuk debugging, bisa tampilkan error, di production sebaiknya diganti dengan pesan umum
        echo json_encode(["success" => false, "message" => "Gagal menambah KRS: " . mysqli_error($conn)]);
    }
    
    mysqli_stmt_close($stmt);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Database error: " . mysqli_error($conn)]);
}

mysqli_close($conn);
?>