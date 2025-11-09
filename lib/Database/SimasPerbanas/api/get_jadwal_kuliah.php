<?php
include 'koneksi.php';

// Ambil jadwal kuliah untuk semester 5
$sql = "SELECT 
            j.id_jadwal,
            j.id_mk,
            j.hari,
            DATE_FORMAT(j.jam_mulai, '%H.%i') as jam_mulai,
            DATE_FORMAT(j.jam_selesai, '%H.%i') as jam_selesai,
            j.ruang,
            j.kelas,
            mk.kode_mk,
            mk.nama_mk,
            mk.sks
        FROM jadwal_kuliah j
        JOIN mata_kuliah mk ON j.id_mk = mk.id_mk
        WHERE mk.semester = 5
        ORDER BY 
            CASE j.hari
                WHEN 'Senin' THEN 1
                WHEN 'Selasa' THEN 2
                WHEN 'Rabu' THEN 3
                WHEN 'Kamis' THEN 4
                WHEN 'Jumat' THEN 5
                ELSE 6
            END,
            j.jam_mulai";

$result = $conn->query($sql);

$jadwal = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $jadwal[] = $row;
    }
    
    echo json_encode([
        'success' => true, 
        'data' => $jadwal
    ]);
} else {
    echo json_encode([
        'success' => false, 
        'message' => 'Tidak ada jadwal kuliah yang tersedia'
    ]);
}

$conn->close();
?>