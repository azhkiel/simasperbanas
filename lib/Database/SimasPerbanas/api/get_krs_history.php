<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Koneksi ke database
$servername = "localhost";
$username = "root"; // sesuaikan dengan username database Anda
$password = ""; // sesuaikan dengan password database Anda
$dbname = "simasperbanas"; // sesuaikan dengan nama database Anda

// Buat koneksi
$conn = new mysqli($servername, $username, $password, $dbname);

// Cek koneksi
if ($conn->connect_error) {
    die(json_encode([
        "success" => false,
        "message" => "Koneksi database gagal: " . $conn->connect_error
    ]));
}

// Baca input JSON
$input = json_decode(file_get_contents('php://input'), true);
$nim = $conn->real_escape_string($input['nim']);

try {
    // Query untuk mengambil riwayat KRS berdasarkan NIM
    $sql = "
        SELECT 
            k.id_krs,
            k.semester,
            k.tahun_akademik,
            k.total_sks,
            k.tanggal_input,
            k.status,
            GROUP_CONCAT(CONCAT(mk.kode_mk, ' - ', mk.nama_mk) SEPARATOR '; ') as mata_kuliah_list,
            COUNT(kd.id_detail) as jumlah_matkul
        FROM krs k
        LEFT JOIN krs_detail kd ON k.id_krs = kd.id_krs
        LEFT JOIN mata_kuliah mk ON kd.id_mk = mk.id_mk
        WHERE k.nim = ?
        GROUP BY k.id_krs, k.semester, k.tahun_akademik, k.total_sks, k.tanggal_input, k.status
        ORDER BY k.tanggal_input DESC
    ";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $nim);
    $stmt->execute();
    $result = $stmt->get_result();

    $krsHistory = [];

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            // Format tanggal
            $tanggal_input = date('d/m/Y', strtotime($row['tanggal_input']));
            
            // Format mata kuliah menjadi array
            $mata_kuliah_array = [];
            if (!empty($row['mata_kuliah_list'])) {
                $mata_kuliah_items = explode('; ', $row['mata_kuliah_list']);
                foreach ($mata_kuliah_items as $item) {
                    $mata_kuliah_array[] = $item;
                }
            }

            $krsHistory[] = [
                "id_krs" => $row['id_krs'],
                "semester" => $row['semester'],
                "tahun_akademik" => $row['tahun_akademik'],
                "total_sks" => $row['total_sks'],
                "tanggal_input" => $tanggal_input,
                "status" => $row['status'],
                "jumlah_matkul" => $row['jumlah_matkul'],
                "mata_kuliah" => $mata_kuliah_array,
                "mata_kuliah_string" => $row['mata_kuliah_list']
            ];
        }

        echo json_encode([
            "success" => true,
            "message" => "Data riwayat KRS berhasil diambil",
            "data" => $krsHistory,
            "total" => count($krsHistory)
        ]);
    } else {
        echo json_encode([
            "success" => true,
            "message" => "Tidak ada riwayat KRS ditemukan",
            "data" => [],
            "total" => 0
        ]);
    }

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
} finally {
    $stmt->close();
    $conn->close();
}
?>