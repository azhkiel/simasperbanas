<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/debug.log');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Direktori penyimpanan foto (2 level up dari current dir)
    $uploadDir = __DIR__ . '/../uploads/photos/';
    
    // Buat folder jika belum ada
    if (!file_exists($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }
    
    // Cek apakah file ada
    if (isset($_FILES['foto']) && $_FILES['foto']['error'] === UPLOAD_ERR_OK) {
        $fileTmpPath = $_FILES['foto']['tmp_name'];
        $fileSize = $_FILES['foto']['size'];
        $fileType = $_FILES['foto']['type'];
        $fileName = $_FILES['foto']['name'];
        
        // Validasi ukuran (max 2MB)
        if ($fileSize > 2 * 1024 * 1024) {
            echo json_encode([
                'status' => 'error',
                'message' => 'File terlalu besar. Maksimal 2MB'
            ]);
            exit;
        }
        
        // Validasi tipe file
        $allowedTypes = ['image/jpeg', 'image/jpg', 'image/png'];
        if (!in_array($fileType, $allowedTypes)) {
            echo json_encode([
                'status' => 'error',
                'message' => 'Format file tidak valid. Hanya JPG/PNG yang diperbolehkan'
            ]);
            exit;
        }
        
        // Generate nama file unik
        $fileExtension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
        $newFileName = 'foto_' . time() . '_' . uniqid() . '.' . $fileExtension;
        $destPath = $uploadDir . $newFileName;
        
        // Pindahkan file
        if (move_uploaded_file($fileTmpPath, $destPath)) {
            // Path relatif untuk disimpan di database
            $relativePath = 'uploads/photos/' . $newFileName;
            
            // URL lengkap untuk akses
            $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http';
            $fullUrl = $protocol . '://' . $_SERVER['HTTP_HOST'] . '/' . $relativePath;
            
            error_log("✅ Upload Success - Path: " . $relativePath);
            
            echo json_encode([
                'status' => 'success',
                'message' => 'Upload berhasil',
                'path' => $relativePath,  // Untuk disimpan di database
                'url' => $fullUrl         // Untuk preview/display
            ]);
        } else {
            error_log("❌ Upload Failed - move_uploaded_file error");
            echo json_encode([
                'status' => 'error',
                'message' => 'Gagal memindahkan file'
            ]);
        }
    } else {
        $errorMsg = 'Tidak ada file yang diupload';
        if (isset($_FILES['foto']['error'])) {
            $errorMsg .= ' (Error code: ' . $_FILES['foto']['error'] . ')';
        }
        
        error_log("❌ No file uploaded: " . $errorMsg);
        echo json_encode([
            'status' => 'error',
            'message' => $errorMsg
        ]);
    }
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Method tidak valid. Gunakan POST'
    ]);
}
?>