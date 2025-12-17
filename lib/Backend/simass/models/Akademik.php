<?php
include_once 'BaseModel.php';
class Akademik extends BaseModel {
    protected $table = "akademik";

    public function __construct($db) {
        parent::__construct($db);
    }

    // CREATE
    public function create($data) {
        $query = "INSERT INTO " . $this->table . " 
                 (nim, id_mk, tahun_akademik, nilai) 
                 VALUES (:nim, :id_mk, :tahun_akademik, :nilai)";
        
        $params = [
            ':nim' => $data['nim'],
            ':id_mk' => $data['id_mk'],
            ':tahun_akademik' => $data['tahun_akademik'],
            ':nilai' => $data['nilai']
        ];

        $this->executeQuery($query, $params);
        return $this->conn->lastInsertId();
    }

    // READ ALL
    public function readAll() {
        $query = "SELECT a.*, u.nama, mk.nama_mk 
                 FROM " . $this->table . " a
                 JOIN user u ON a.nim = u.nim
                 JOIN mata_kuliah mk ON a.id_mk = mk.id_mk";
        $stmt = $this->executeQuery($query);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // READ BY NIM
    public function readByNim($nim) {
        $query = "SELECT a.*, mk.kode_mk, mk.nama_mk, mk.sks 
                 FROM " . $this->table . " a
                 JOIN mata_kuliah mk ON a.id_mk = mk.id_mk
                 WHERE a.nim = :nim";
        $stmt = $this->executeQuery($query, [':nim' => $nim]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // READ SINGLE
    public function readSingle($id_akademik) {
        $query = "SELECT * FROM " . $this->table . " WHERE id_akademik = :id_akademik";
        $stmt = $this->executeQuery($query, [':id_akademik' => $id_akademik]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // UPDATE
    public function update($id_akademik, $data) {
        $query = "UPDATE " . $this->table . " 
                 SET nim = :nim, id_mk = :id_mk, tahun_akademik = :tahun_akademik, nilai = :nilai 
                 WHERE id_akademik = :id_akademik";
        
        $params = [
            ':nim' => $data['nim'],
            ':id_mk' => $data['id_mk'],
            ':tahun_akademik' => $data['tahun_akademik'],
            ':nilai' => $data['nilai'],
            ':id_akademik' => $id_akademik
        ];

        return $this->executeQuery($query, $params);
    }

    // DELETE
    public function delete($id_akademik) {
        $query = "DELETE FROM " . $this->table . " WHERE id_akademik = :id_akademik";
        return $this->executeQuery($query, [':id_akademik' => $id_akademik]);
    }
}
?>