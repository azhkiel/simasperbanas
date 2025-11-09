<?php
include 'koneksi.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['nim'])) {
        sendResponse(false, "NIM harus diisi");
    }

    $database = new Database();
    $db = $database->getConnection();

    $nim = $input['nim'];

    try {
        $query = "SELECT id_user, nim, nama, email, no_hp, program_studi, dosen_wali 
                  FROM user 
                  WHERE nim = :nim";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':nim', $nim);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            sendResponse(true, "Data user ditemukan", $user);
        } else {
            sendResponse(false, "User tidak ditemukan");
        }
    } catch (PDOException $e) {
        sendResponse(false, "Error: " . $e->getMessage());
    }
} else {
    sendResponse(false, "Method tidak diizinkan");
}
?>