<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once '../config/database.php';
include_once '../models/User.php';

$database = new Database();
$db = $database->getConnection();

$input = json_decode(file_get_contents("php://input"), true);

function sendResponse($data, $status = 200) {
    http_response_code($status);
    echo json_encode($data);
    exit();
}

function sendError($message, $status = 400) {
    sendResponse(['status' => 'error', 'message' => $message], $status);
}

try {
    if ($_SERVER['REQUEST_METHOD'] != 'POST') {
        sendError('Method not allowed', 405);
    }

    if (empty($input)) {
        sendError('No data provided');
    }

    $nim = $input['nim'] ?? '';
    $password = $input['password'] ?? '';

    if (empty($nim) || empty($password)) {
        sendError('NIM dan password harus diisi');
    }

    $userModel = new User($db);
    
    // Cari user by NIM
    $user = $userModel->readByNim($nim);
    
    if (!$user) {
        sendError('NIM tidak ditemukan');
    }

    // Verifikasi password (dalam kasus real, gunakan password_hash() dan password_verify())
    // Untuk sementara, bandingkan langsung karena password di database masih plain text
    if ($password !== $user['password']) {
        sendError('Password salah');
    }

    // Login berhasil
    $response = [
        'status' => 'success',
        'message' => 'Login berhasil',
        'data' => [
            'id_user' => $user['id_user'],
            'nim' => $user['nim'],
            'nama' => $user['nama'],
            'email' => $user['email']
        ]
    ];

    sendResponse($response);

} catch(Exception $e) {
    sendError($e->getMessage(), 500);
}
?>