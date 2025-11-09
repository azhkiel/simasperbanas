<?php
// 1. Sertakan file koneksi database
include_once 'config.php';

// 2. Tentukan header respons sebagai JSON
header("Content-Type: application/json; charset=UTF-8");

// 3. Ambil parameter dari URL
$jenis = isset($_GET['jenis']) ? $_GET['jenis'] : '';
$kriteria = isset($_GET['kriteria']) ? $_GET['kriteria'] : '';
$query = isset($_GET['query']) ? $_GET['query'] : '';

// 4. Siapkan Query SQL
$table_name = "catalog"; // NAMA TABEL SUDAH FINAL: catalog

$sql = "SELECT * FROM " . $table_name . " WHERE 1=1 ";
$params = array();

// FILTER JENIS: Menggunakan nama kolom yang benar: jenis_buku
if (!empty($jenis)) {
    $sql .= " AND jenis_buku = :jenis";
    $params[':jenis'] = $jenis;
}

// Filter berdasarkan Kriteria Pencarian
if (!empty($query)) {
    switch ($kriteria) {
        // MENGGUNAKAN NAMA KOLOM DARI DATABASE: judul
        case 'Judul':
        case 'Subyek': 
            $sql .= " AND judul LIKE :query";
            break;
        // MENGGUNAKAN NAMA KOLOM DARI DATABASE: pengarang
        case 'Pengarang':
            $sql .= " AND pengarang LIKE :query";
            break;
        case 'Penerbit':
            $sql .= " AND penerbit LIKE :query";
            break;
        // MENGGUNAKAN NAMA KOLOM DARI DATABASE: tahun_terbit
        case 'Tahun Terbit':
            $sql .= " AND tahun_terbit = :query_exact";
            $params[':query_exact'] = $query;
            break;
        case 'No. ISBN':
            // Asumsi: Jika ada kolom no_isbn, gunakan itu. Jika tidak, gunakan judul.
            // Jika kolom 'no_isbn' tidak ada, ubah atau hapus case ini.
            $sql .= " AND no_isbn LIKE :query"; 
            break;
        default:
            $sql .= " AND judul LIKE :query";
            break;
    }

    if ($kriteria != 'Tahun Terbit') {
        $params[':query'] = '%' . $query . '%';
    }
}

$sql .= " ORDER BY judul ASC";


// 5. Eksekusi Query
try {
    $stmt = $conn->prepare($sql);
    $stmt->execute($params);

    $num = $stmt->rowCount();
    $katalog_arr = array();
    
    if ($num > 0) {
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            extract($row);

            // MAPPING DATA FINAL: Kunci Kanan = Nama Kolom di Database
            $koleksi_item = array(
                "title" => $judul,
                "asset" => $asset_path,
                "description" => $deskripsi,
                "publisher" => $penerbit,
                "year" => $tahun_terbit,
                "author" => $pengarang
            );

            array_push($katalog_arr, $koleksi_item);
        }

        http_response_code(200);
        echo json_encode($katalog_arr);

    } else {
        // Jika data tidak ditemukan, kembalikan array kosong
        http_response_code(200);
        echo json_encode(array());
    }

} catch (PDOException $e) {
    // Jika terjadi error SQL
    http_response_code(500);
    echo json_encode(
        array("message" => "Query execution error: " . $e->getMessage())
    );
}
?>