<?php
include_once 'BaseModel.php';
class Softskills extends BaseModel {
    protected $table = "softskills";

    public function __construct($db) {
        parent::__construct($db);
    }

    // CREATE
    public function create($data) {
        $query = "INSERT INTO " . $this->table . " 
                 (nim, kategori, sub_kategori, kegiatan, tanggal, poin, status, deskripsi, file_name, file_path) 
                 VALUES (:nim, :kategori, :sub_kategori, :kegiatan, :tanggal, :poin, :status, :deskripsi, :file_name, :file_path)";
        
        $params = [
            ':nim' => $data['nim'],
            ':kategori' => $data['kategori'],
            ':sub_kategori' => $data['sub_kategori'],
            ':kegiatan' => $data['kegiatan'],
            ':tanggal' => $data['tanggal'],
            ':poin' => $data['poin'],
            ':status' => $data['status'],
            ':deskripsi' => $data['deskripsi'],
            ':file_name' => $data['file_name'],
            ':file_path' => $data['file_path']
        ];

        $this->executeQuery($query, $params);
        return $this->conn->lastInsertId();
    }

    // READ ALL
    public function readAll() {
        $query = "SELECT * FROM " . $this->table;
        $stmt = $this->executeQuery($query);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // READ BY NIM
    public function readByNim($nim) {
        $query = "SELECT * FROM " . $this->table . " WHERE nim = :nim";
        $stmt = $this->executeQuery($query, [':nim' => $nim]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // READ SINGLE
    public function readSingle($id) {
        $query = "SELECT * FROM " . $this->table . " WHERE id = :id";
        $stmt = $this->executeQuery($query, [':id' => $id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // UPDATE
    public function update($id, $data) {
        $query = "UPDATE " . $this->table . " 
                 SET nim = :nim, kategori = :kategori, sub_kategori = :sub_kategori, 
                     kegiatan = :kegiatan, tanggal = :tanggal, poin = :poin, 
                     status = :status, deskripsi = :deskripsi, 
                     file_name = :file_name, file_path = :file_path 
                 WHERE id = :id";
        
        $params = [
            ':nim' => $data['nim'],
            ':kategori' => $data['kategori'],
            ':sub_kategori' => $data['sub_kategori'],
            ':kegiatan' => $data['kegiatan'],
            ':tanggal' => $data['tanggal'],
            ':poin' => $data['poin'],
            ':status' => $data['status'],
            ':deskripsi' => $data['deskripsi'],
            ':file_name' => $data['file_name'],
            ':file_path' => $data['file_path'],
            ':id' => $id
        ];

        return $this->executeQuery($query, $params);
    }

    // UPDATE STATUS
    public function updateStatus($id, $status) {
        $query = "UPDATE " . $this->table . " SET status = :status WHERE id = :id";
        return $this->executeQuery($query, [':status' => $status, ':id' => $id]);
    }

    // DELETE
    public function delete($id) {
        $query = "DELETE FROM " . $this->table . " WHERE id = :id";
        return $this->executeQuery($query, [':id' => $id]);
    }
}
?>