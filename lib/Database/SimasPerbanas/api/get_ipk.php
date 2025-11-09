<?php
error_reporting(0);
ini_set('display_errors', 0);
ob_start();

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

// Tangani preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

include 'koneksi.php';

// Baca input JSON
$input = json_decode(file_get_contents('php://input'), true);
$nim = isset($input['nim']) ? trim($input['nim']) : '';

if ($nim === '') {
    echo json_encode([
        'success' => false,
        'message' => 'NIM is required',
        'ipk' => 0.0 
    ]);
    $conn->close();
    ob_end_flush();
    exit;
}

// Konversi nilai huruf ke bobot
function convertGradeToScore($grade) {
    $grade_map = [
        'A'  => 4.0,
        'A-' => 3.7,
        'B+' => 3.3, 
        'B'  => 3.0,
        'B-' => 2.7,
        'C+' => 2.3,
        'C'  => 2.0,
        'D'  => 1.0,
        'E'  => 0.0,
        'T'  => 0.0
    ];
    $g = strtoupper(trim((string)$grade));
    return isset($grade_map[$g]) ? $grade_map[$g] : 0.0;
}

// Ambil semua nilai mahasiswa beserta SKS
$sql = "SELECT a.nilai, mk.sks
        FROM akademik a
        JOIN mata_kuliah mk ON a.id_mk = mk.id_mk
        WHERE a.nim = ?";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode([
        'success' => false,
        'message' => 'Prepare statement error',
        'error' => $conn->error,
        'ipk' => 0.0 // DEFAULT VALUE
    ]);
    $conn->close();
    ob_end_flush();
    exit;
}

$stmt->bind_param("s", $nim);
$stmt->execute();
$result = $stmt->get_result();

$total_bobot = 0.0;
$total_sks = 0;
$total_matkul = 0;

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $nilai = isset($row['nilai']) ? $row['nilai'] : '';
        $sks = isset($row['sks']) ? (int)$row['sks'] : 0;

        $bobot = convertGradeToScore($nilai);
        $total_bobot += ($bobot * $sks);
        $total_sks += $sks;
        $total_matkul++;
    }

    // Hitung IPK
    if ($total_sks > 0) {
        $ipk = round($total_bobot / $total_sks, 2);
    } else {
        $ipk = 0.0;
    }

    echo json_encode([
        'success' => true,
        'ipk' => $ipk, // float
        'total_sks' => (int)$total_sks,
        'total_matkul' => (int)$total_matkul,
        'nim' => $nim
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
} else {
    echo json_encode([
        'success' => true,
        'ipk' => 0.0,
        'total_sks' => 0,
        'total_matkul' => 0,
        'nim' => $nim,
        'message' => 'Belum ada data nilai untuk menghitung IPK'
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
}

$stmt->close();
$conn->close();
ob_end_flush();
exit;
?>