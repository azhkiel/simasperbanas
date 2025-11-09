<?php
ob_start(); // Mencegah output lain di luar JSON

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

// Query ambil data mata kuliah + jadwal dengan filter semester
$sql = "SELECT 
            mk.id_mk,
            mk.kode_mk,
            mk.nama_mk,
            mk.sks,
            mk.semester,
            mk.is_wajib,
            jk.hari,
            jk.jam_mulai,
            jk.jam_selesai,
            jk.ruang
        FROM mata_kuliah mk
        LEFT JOIN jadwal_kuliah jk ON mk.id_mk = jk.id_mk
        WHERE mk.semester = 5";

$result = $conn->query($sql);

// Jika query gagal
if (!$result) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Query error: " . $conn->error,
        "data" => []
    ]);
    exit;
}

$data = [];
while ($row = $result->fetch_assoc()) {
    // Buat konversi yee
    $row['id_mk'] = (int)$row['id_mk'];
    $row['sks'] = (int)$row['sks'];
    $row['semester'] = (int)$row['semester'];
    $row['is_wajib'] = (bool)$row['is_wajib'];

    // Pastikan kolom string nggak noll
    $row['kode_mk'] = $row['kode_mk'] ?? '';
    $row['nama_mk'] = $row['nama_mk'] ?? '';
    $row['hari'] = $row['hari'] ?? '';
    $row['jam_mulai'] = $row['jam_mulai'] ?? '';
    $row['jam_selesai'] = $row['jam_selesai'] ?? '';
    $row['ruang'] = $row['ruang'] ?? '';

    $data[] = $row;
}

// Kirim hasil ke Flutter
if (count($data) > 0) {
    echo json_encode([
        "success" => true,
        "message" => "Data mata kuliah berhasil diambil",
        "data" => $data
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Tidak ada mata kuliah tersedia untuk semester ini",
        "data" => []
    ]);
}

$conn->close();
ob_end_flush();
?>