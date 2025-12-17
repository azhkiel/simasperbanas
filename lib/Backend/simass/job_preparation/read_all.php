<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . "/../config/database.php";
require_once __DIR__ . "/../helpers/Encryption.php"; // ← IMPORT ENCRYPTION CLASS

/**
 * BUAT KONEKSI PDO
 */
$database = new Database();
$conn = $database->getConnection();

if (!$conn) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Koneksi database gagal"
    ]);
    exit;
}

$id_user = $_GET['id_user'] ?? null;

if (!$id_user) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "id_user wajib dikirim"
    ]);
    exit;
}

/**
 * 1️⃣ Ambil job_preparation
 */
$stmt = $conn->prepare("
    SELECT *
    FROM job_preparations
    WHERE id_user = :id_user
    LIMIT 1
");
$stmt->bindParam(':id_user', $id_user, PDO::PARAM_INT);
$stmt->execute();

$jobPrep = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$jobPrep) {
    echo json_encode([
        "status" => "empty",
        "message" => "Data job preparation belum ada"
    ]);
    exit;
}

if (!empty($jobPrep['no_ktp'])) {
    $jobPrep['no_ktp'] = Encryption::decrypt($jobPrep['no_ktp']);
}

$jobPrepId = $jobPrep['id'];

function fetchList($conn, $table, $jobPrepId) {
    $stmt = $conn->prepare("
        SELECT *
        FROM $table
        WHERE job_preparation_id = :job_preparation_id
    ");
    $stmt->bindParam(':job_preparation_id', $jobPrepId, PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function fetchOne($conn, $table, $jobPrepId) {
    $stmt = $conn->prepare("
        SELECT *
        FROM $table
        WHERE job_preparation_id = :job_preparation_id
        LIMIT 1
    ");
    $stmt->bindParam(':job_preparation_id', $jobPrepId, PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetch(PDO::FETCH_ASSOC);
}

//ambil semua data terkait
$data = [
    "job_preparation" => $jobPrep, // ← KTP sudah didekripsi
    "pendidikan_formal" => fetchList($conn, "pendidikan_formal", $jobPrepId),
    "pendidikan_non_formal" => fetchList($conn, "pendidikan_non_formal", $jobPrepId),
    "bahasa_asing" => fetchList($conn, "bahasa_asing", $jobPrepId),
    "keterampilan_komputer" => fetchOne($conn, "keterampilan_komputer", $jobPrepId),
    "pengalaman_kerja" => fetchList($conn, "pengalaman_kerja", $jobPrepId),
    "organisasi" => fetchList($conn, "organisasi", $jobPrepId),
    "kontak_darurat" => fetchList($conn, "kontak_darurat", $jobPrepId),
    "referensi" => fetchList($conn, "referensi", $jobPrepId),
    "kesehatan" => fetchList($conn, "kesehatan", $jobPrepId),
    "preferensi_pekerjaan" => fetchOne($conn, "preferensi_pekerjaan", $jobPrepId),
];

echo json_encode([
    "status" => "success",
    "data" => $data
]);