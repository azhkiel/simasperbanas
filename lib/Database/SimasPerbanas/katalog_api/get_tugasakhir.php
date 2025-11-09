<?php
// ==========================================================
// FILE: get_tugasakhir.php
// LOKASI: C:\xampp\htdocs\SimasPerbanas\katalog_api\
// ==========================================================

// Header wajib agar Flutter tahu responsnya adalah JSON
header('Content-Type: application/json');

// --- 1. KONFIGURASI DATABASE (WAJIB KOREKSI) ---
$servername = "localhost";
$username = "root";     // Ganti jika username database Anda berbeda
$password = "";         // Ganti jika password database Anda berbeda
$dbname = "simasperbanas"; // <--- GANTI TEKS INI DENGAN NAMA DATABASE ANDA (Contoh: "simasperbanas_db")

// --- 2. AMBIL PARAMETER DARI URL ---
$jenis_koleksi = isset($_GET['jenis_koleksi']) ? $_GET['jenis_koleksi'] : '';
$kriteria = isset($_GET['kriteria']) ? $_GET['kriteria'] : '';
$query = isset($_GET['query']) ? $_GET['query'] : '';

// Jika tidak ada parameter penting, kembalikan array kosong
if (empty($query) || empty($jenis_koleksi) || empty($kriteria)) {
    echo json_encode([]);
    exit;
}

// --- 3. KONEKSI KE DATABASE ---
// Koneksi sekarang menggunakan @ untuk menekan Warning atau Fatal Error 
// yang disebabkan oleh kesalahan koneksi (seperti yang terjadi sebelumnya)
$conn = @new mysqli($servername, $username, $password, $dbname);

// Cek koneksi
if ($conn->connect_error) {
    // Jika koneksi gagal, kembalikan respons 500 (Internal Server Error)
    // dan berikan pesan error (hanya untuk debugging, bisa dihapus di production)
    http_response_code(500); 
    echo json_encode(["error" => "Koneksi database gagal: " . $conn->connect_error]);
    exit;
}

// --- 4. MAP KRITERIA KE KOLOM DATABASE ---
$column = '';
switch ($kriteria) {
    case 'Subyek':
        $column = 'subyek';
        break;
    case 'Judul':
        $column = 'judul';
        break;
    case 'Pengarang':
        $column = 'pengarang';
        break;
    case 'Tahun Pengesahan':
        $column = 'tahun_pengesahan';
        break;
    case 'NIM':
        $column = 'nim';
        break;
    case 'Dosen Pembimbing':
        $column = 'dosen_pembimbing';
        break;
    default:
        $column = 'judul'; 
}

// --- 5. EKSEKUSI QUERY ---
$search_term = "%" . $query . "%";
$table_name = "catalog_tugasakhir"; // ASUMSI: Nama tabel Tugas Akhir Anda

// Menggunakan Prepared Statement untuk keamanan SQL Injection
$sql = "SELECT id, jenis_koleksi, no_induk, judul, pengarang, nim, dosen_pembimbing, tahun_pengesahan, fakultas, file_url
        FROM $table_name 
        WHERE $column LIKE ? AND jenis_koleksi = ?";

$stmt = $conn->prepare($sql);

if ($stmt === false) {
    // Gagal menyiapkan statement (mungkin nama kolom/tabel salah)
    http_response_code(500); 
    echo json_encode(["error" => "Error prepare statement: " . $conn->error]);
    exit;
}

$stmt->bind_param("ss", $search_term, $jenis_koleksi);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
if ($result->num_rows > 0) {
    // Ambil setiap baris hasil sebagai associative array
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
}

// Tutup koneksi
$stmt->close();
$conn->close();

// --- 6. OUTPUT JSON ---
echo json_encode($data);

?>