<?php
class Encryption {
    // Method enkripsi yang digunakan
    private static $method = 'AES-256-CBC';
    // Key rahasia untuk enkripsi/dekripsi
    private static $key = 'JobPrep2024SystemSecureKey12345'; // Harus 32 karakter!
    
    public static function encrypt($data) {
        // Jika data kosong, return string kosong
        if (empty($data)) {
            return '';
        }
        
        try {
            // Generate Initialization Vector (IV) random
            $ivLength = openssl_cipher_iv_length(self::$method);
            $iv = openssl_random_pseudo_bytes($ivLength);
            
            // Enkripsi data menggunakan key
            $encrypted = openssl_encrypt(
                $data,          // Data asli
                self::$method,  // Method AES-256-CBC
                self::$key,     // Key rahasia
                0,              // Options
                $iv             // IV
            );
            
            // Gabungkan IV + encrypted data, lalu encode ke Base64
            // IV perlu disimpan karena diperlukan saat decrypt
            return base64_encode($iv . $encrypted);
            
        } catch (Exception $e) {
            // Jika error, return string kosong
            error_log("Encryption error: " . $e->getMessage());
            return '';
        }
    }
    
    public static function decrypt($data) {
        // Jika data kosong, return string kosong
        if (empty($data)) {
            return '';
        }
        
        try {
            // Data terenkripsi akan selalu Base64 valid dengan panjang tertentu
            $decoded = base64_decode($data, true);
            $ivLength = openssl_cipher_iv_length(self::$method);
            
            // (berarti ini data lama yang belum terenkripsi)
            if ($decoded === false || strlen($decoded) <= $ivLength) {
                return $data; // ← Return data asli (plain text lama)
            }
            
            // Pisahkan IV dan encrypted data
            $iv = substr($decoded, 0, $ivLength);
            $encrypted = substr($decoded, $ivLength);
            
            // Dekripsi menggunakan key yang sama
            $decrypted = openssl_decrypt(
                $encrypted,     // Data terenkripsi
                self::$method,  // Method AES-256-CBC
                self::$key,     // Key rahasia (harus sama!)
                0,              // Options
                $iv             // IV yang sama saat encrypt
            );
            
            // Jika dekripsi gagal, kembalikan data asli
            return $decrypted !== false ? $decrypted : $data;
            
        } catch (Exception $e) {
            // Jika error, return data asli (kemungkinan plain text)
            error_log("Decryption error: " . $e->getMessage());
            return $data;
        }
    }
}