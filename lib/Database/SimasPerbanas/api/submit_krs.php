<?php
include 'koneksi.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $id_user = $conn->real_escape_string($data['id_user']);
    $nim = $conn->real_escape_string($data['nim']);
    $semester = $conn->real_escape_string($data['semester']);
    $tahun_akademik = $conn->real_escape_string($data['tahun_akademik']);
    $total_sks = $conn->real_escape_string($data['total_sks']);
    $mata_kuliah = $data['mata_kuliah'];

    // Mulai transaction
    $conn->begin_transaction();

    try {
        // 1. Insert ke tabel krs dengan status langsung Disetujui
        $sql_krs = "INSERT INTO krs (id_user, nim, semester, tahun_akademik, total_sks, tanggal_input, status) 
                   VALUES ('$id_user', '$nim', '$semester', '$tahun_akademik', '$total_sks', NOW(), 'Disetujui')";
        
        if (!$conn->query($sql_krs)) {
            throw new Exception("Gagal menyimpan KRS: " . $conn->error);
        }
        
        $id_krs = $conn->insert_id;

        // 2. Insert ke tabel krs_detail untuk setiap mata kuliah
        foreach ($mata_kuliah as $mk) {
            $id_mk = $conn->real_escape_string($mk['id_mk']);
            
            // Cari id_jadwal untuk mata kuliah ini
            $sql_jadwal = "SELECT id_jadwal FROM jadwal_kuliah WHERE id_mk = '$id_mk' LIMIT 1";
            $result_jadwal = $conn->query($sql_jadwal);
            $id_jadwal = $result_jadwal->num_rows > 0 ? $result_jadwal->fetch_assoc()['id_jadwal'] : NULL;

            $sql_detail = "INSERT INTO krs_detail (id_krs, id_mk, id_jadwal) 
                          VALUES ('$id_krs', '$id_mk', " . ($id_jadwal ? "'$id_jadwal'" : "NULL") . ")";
            
            if (!$conn->query($sql_detail)) {
                throw new Exception("Gagal menyimpan detail KRS: " . $conn->error);
            }
        }

        // Commit transaction
        $conn->commit();

        echo json_encode([
            "success" => true,
            "message" => "KRS berhasil disimpan dan langsung disetujui",
            "id_krs" => $id_krs,
            "status" => "Disetujui"
        ]);

    } catch (Exception $e) {
        // Rollback transaction jika ada error
        $conn->rollback();
        
        echo json_encode([
            "success" => false,
            "message" => $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        "success" => false,
        "message" => "Method tidak diizinkan"
    ]);
}

$conn->close();
?>