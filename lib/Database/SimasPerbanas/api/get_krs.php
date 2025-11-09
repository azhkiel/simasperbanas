<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include 'koneksi.php';

$input = json_decode(file_get_contents("php://input"), true);

$nim = $input['nim'] ?? '';
$tahun_akademik = $input['tahun_akademik'] ?? '';
$semester = $input['semester'] ?? '';

if (empty($nim) || empty($tahun_akademik) || empty($semester)) {
    echo json_encode(['success' => false, 'message' => 'Data tidak lengkap']);
    exit;
}

// Query untuk mengambil mata kuliah yang sudah diambil mahasiswa
$sql = "SELECT mk.kode_mk, mk.nama_mk, mk.sks, j.hari, j.jam_mulai, j.jam_selesai, j.ruang
        FROM krs k
        JOIN mata_kuliah mk ON k.id_mk = mk.id_mk
        LEFT JOIN jadwal j ON mk.id_mk = j.id_mk
        WHERE k.nim = ? AND k.tahun_akademik = ? AND k.semester = ? AND k.status = 'disetujui'";

$stmt = $conn->prepare($sql);
$stmt->bind_param("sss", $nim, $tahun_akademik, $semester);
$stmt->execute();
$result = $stmt->get_result();

$mata_kuliah = [];
while ($row = $result->fetch_assoc()) {
    $mata_kuliah[] = $row;
}

if (count($mata_kuliah) > 0) {
    echo json_encode(['success' => true, 'data' => $mata_kuliah]);
} else {
    echo json_encode(['success' => true, 'data' => [], 'message' => 'Tidak ada data KRS untuk semester ini']);
}

$stmt->close();
$conn->close();
?>