<?php
include 'koneksi.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $nim = $conn->real_escape_string($data['nim']);
    $semester = $conn->real_escape_string($data['semester']);
    $tahun_akademik = $conn->real_escape_string($data['tahun_akademik']);

    // Query untuk mengecek apakah sudah ada KRS untuk NIM, semester, dan tahun akademik ini
    $sql = "SELECT COUNT(*) as total FROM krs 
            WHERE nim = '$nim'
            AND semester = '$semester'
            AND tahun_akademik = '$tahun_akademik'";
    
    $result = $conn->query($sql);
    
    if ($result) {
        $row = $result->fetch_assoc();
        $exists = $row['total'] > 0;
        
        echo json_encode([
            "success" => true,
            "exists" => $exists,
            "message" => $exists ? "KRS sudah ada" : "Belum ada KRS"
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "exists" => false,
            "message" => "Error checking KRS: " . $conn->error
        ]);
    }
} else {
    echo json_encode([
        "success" => false,
        "exists" => false,
        "message" => "Method tidak diizinkan"
    ]);
}

$conn->close();
?>