<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once '../config/database.php';
include_once '../models/User.php';
include_once '../models/Softskills.php';
include_once '../models/MataKuliah.php';
include_once '../models/Akademik.php';
include_once '../models/KRS.php';
include_once '../models/KRSDetail.php';
include_once '../models/UsulanKelas.php';

$database = new Database();
$db = $database->getConnection();

$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents("php://input"), true);
$params = $_GET;

function sendResponse($data, $status = 200) {
    http_response_code($status);
    echo json_encode($data);
    exit();
}

function sendError($message, $status = 400) {
    sendResponse(['error' => $message], $status);
}

try {
    switch($method) {
        case 'GET':
            handleGetRequest($db, $params);
            break;
        case 'POST':
            handlePostRequest($db, $input);
            break;
        case 'PUT':
            handlePutRequest($db, $input, $params);
            break;
        case 'DELETE':
            handleDeleteRequest($db, $params);
            break;
        default:
            sendError('Method not allowed', 405);
    }
} catch(Exception $e) {
    sendError($e->getMessage(), 500);
}

function handleGetRequest($db, $params) {
    $table = $params['table'] ?? '';
    $id = $params['id'] ?? '';
    $nim = $params['nim'] ?? '';
    $semester = $params['semester'] ?? '';
    $id_krs = $params['id_krs'] ?? '';

    switch($table) {
        case 'user':
            $model = new User($db);
            if ($id) {
                sendResponse($model->readSingle($id));
            } else if ($nim) {
                sendResponse($model->readByNim($nim));
            } else {
                sendResponse($model->readAll());
            }
            break;

        case 'softskills':
            $model = new Softskills($db);
            if ($id) {
                sendResponse($model->readSingle($id));
            } else if ($nim) {
                sendResponse($model->readByNim($nim));
            } else {
                sendResponse($model->readAll());
            }
            break;

        case 'mata_kuliah':
            $model = new MataKuliah($db);
            if ($id) {
                sendResponse($model->readSingle($id));
            } else if ($semester) {
                sendResponse($model->readBySemester($semester));
            } else {
                sendResponse($model->readAll());
            }
            break;

        case 'akademik':
            $model = new Akademik($db);
            if ($id) {
                sendResponse($model->readSingle($id));
            } else if ($nim) {
                sendResponse($model->readByNim($nim));
            } else {
                sendResponse($model->readAll());
            }
            break;

        case 'krs':
            $model = new KRS($db);
            if ($id) {
                sendResponse($model->readSingle($id));
            } else if ($nim) {
                sendResponse($model->readByNim($nim));
            } else {
                sendResponse($model->readAll());
            }
            break;

        case 'krs_detail':
            $model = new KRSDetail($db);
            if ($id_krs) {
                sendResponse($model->readByKrsId($id_krs));
            } else {
                sendError('id_krs parameter required');
            }
            break;

        case 'usulan_kelas':
            $model = new UsulanKelas($db);
            if ($id) {
                sendResponse($model->readSingle($id));
            } else if ($nim) {
                sendResponse($model->readByNim($nim));
            } else {
                sendResponse($model->readAll());
            }
            break;

        default:
            sendError('Table not found');
    }
}

function handlePostRequest($db, $input) {
    $table = $input['table'] ?? '';
    $data = $input['data'] ?? [];

    if (empty($data)) {
        sendError('No data provided');
    }

    switch($table) {
        case 'user':
            $model = new User($db);
            $id = $model->create($data);
            sendResponse(['id' => $id, 'message' => 'User created successfully'], 201);
            break;

        case 'softskills':
            $model = new Softskills($db);
            $id = $model->create($data);
            sendResponse(['id' => $id, 'message' => 'Softskill created successfully'], 201);
            break;

        case 'mata_kuliah':
            $model = new MataKuliah($db);
            $id = $model->create($data);
            sendResponse(['id' => $id, 'message' => 'Mata kuliah created successfully'], 201);
            break;

        case 'akademik':
            $model = new Akademik($db);
            $id = $model->create($data);
            sendResponse(['id' => $id, 'message' => 'Akademik record created successfully'], 201);
            break;

        case 'krs':
            $model = new KRS($db);
            $id = $model->create($data);
            sendResponse(['id' => $id, 'message' => 'KRS created successfully'], 201);
            break;

        case 'krs_detail':
            $model = new KRSDetail($db);
            $id = $model->create($data);
            sendResponse(['id' => $id, 'message' => 'KRS detail created successfully'], 201);
            break;

        case 'usulan_kelas':
            $model = new UsulanKelas($db);
            $id = $model->create($data);
            sendResponse(['id' => $id, 'message' => 'Usulan kelas created successfully'], 201);
            break;

        default:
            sendError('Table not found');
    }
}

function handlePutRequest($db, $input, $params) {
    $table = $input['table'] ?? '';
    $id = $params['id'] ?? '';
    $data = $input['data'] ?? [];

    if (empty($id)) {
        sendError('ID parameter required');
    }

    if (empty($data)) {
        sendError('No data provided');
    }

    switch($table) {
        case 'user':
            $model = new User($db);
            $model->update($id, $data);
            sendResponse(['message' => 'User updated successfully']);
            break;

        case 'softskills':
            $model = new Softskills($db);
            $model->update($id, $data);
            sendResponse(['message' => 'Softskill updated successfully']);
            break;

        case 'mata_kuliah':
            $model = new MataKuliah($db);
            $model->update($id, $data);
            sendResponse(['message' => 'Mata kuliah updated successfully']);
            break;

        case 'akademik':
            $model = new Akademik($db);
            $model->update($id, $data);
            sendResponse(['message' => 'Akademik record updated successfully']);
            break;

        case 'krs':
            $model = new KRS($db);
            $model->update($id, $data);
            sendResponse(['message' => 'KRS updated successfully']);
            break;

        case 'usulan_kelas':
            $model = new UsulanKelas($db);
            $model->update($id, $data);
            sendResponse(['message' => 'Usulan kelas updated successfully']);
            break;

        default:
            sendError('Table not found');
    }
}

function handleDeleteRequest($db, $params) {
    $table = $params['table'] ?? '';
    $id = $params['id'] ?? '';
    $id_krs = $params['id_krs'] ?? '';
    $id_mk = $params['id_mk'] ?? '';

    if (empty($id) && $table !== 'krs_detail') {
        sendError('ID parameter required');
    }

    switch($table) {
        case 'user':
            $model = new User($db);
            $model->delete($id);
            sendResponse(['message' => 'User deleted successfully']);
            break;

        case 'softskills':
            $model = new Softskills($db);
            $model->delete($id);
            sendResponse(['message' => 'Softskill deleted successfully']);
            break;

        case 'mata_kuliah':
            $model = new MataKuliah($db);
            $model->delete($id);
            sendResponse(['message' => 'Mata kuliah deleted successfully']);
            break;

        case 'akademik':
            $model = new Akademik($db);
            $model->delete($id);
            sendResponse(['message' => 'Akademik record deleted successfully']);
            break;

        case 'krs':
            $model = new KRS($db);
            $model->delete($id);
            sendResponse(['message' => 'KRS deleted successfully']);
            break;

        case 'krs_detail':
            $model = new KRSDetail($db);
            if ($id_krs && $id_mk) {
                $model->deleteByKrsAndMk($id_krs, $id_mk);
                sendResponse(['message' => 'KRS detail deleted successfully']);
            } else if ($id) {
                $model->delete($id);
                sendResponse(['message' => 'KRS detail deleted successfully']);
            } else {
                sendError('ID or id_krs and id_mk parameters required');
            }
            break;

        case 'usulan_kelas':
            $model = new UsulanKelas($db);
            $model->delete($id);
            sendResponse(['message' => 'Usulan kelas deleted successfully']);
            break;

        default:
            sendError('Table not found');
    }
}
?>