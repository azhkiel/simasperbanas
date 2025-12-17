<?php
function response($status, $message, $data = null) {
    http_response_code($status);
    echo json_encode([
        "message" => $message,
        "data" => $data
    ]);
    exit;
}
