<?php
include_once 'BaseModel.php';
class KRS extends BaseModel {
    protected $table = "krs";

    public function __construct($db) {
        parent::__construct($db);
    }

    // CREATE
    public function create($data) {
        $query = "INSERT INTO " . $this->table . " 
                 (nim, semester, tahun_akademik) 
                 VALUES (:nim, :semester, :tahun_akademik)";
        
        $params = [
            ':nim' => $data['nim'],
            ':semester' => $data['semester'],
            ':tahun_akademik' => $data['tahun_akademik']
        ];

        $this->executeQuery($query, $params);
        return $this->conn->lastInsertId();
    }

    // READ ALL
    public function readAll() {
        $query = "SELECT k.*, u.nama 
                 FROM " . $this->table . " k
                 JOIN user u ON k.nim = u.nim";
        $stmt = $this->executeQuery($query);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // READ BY NIM
    public function readByNim($nim) {
        $query = "SELECT k.*, u.nama 
                 FROM " . $this->table . " k
                 JOIN user u ON k.nim = u.nim
                 WHERE k.nim = :nim";
        $stmt = $this->executeQuery($query, [':nim' => $nim]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // READ SINGLE
    public function readSingle($id_krs) {
        $query = "SELECT k.*, u.nama 
                 FROM " . $this->table . " k
                 JOIN user u ON k.nim = u.nim
                 WHERE k.id_krs = :id_krs";
        $stmt = $this->executeQuery($query, [':id_krs' => $id_krs]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // UPDATE
    public function update($id_krs, $data) {
        $query = "UPDATE " . $this->table . " 
                 SET nim = :nim, semester = :semester, tahun_akademik = :tahun_akademik 
                 WHERE id_krs = :id_krs";
        
        $params = [
            ':nim' => $data['nim'],
            ':semester' => $data['semester'],
            ':tahun_akademik' => $data['tahun_akademik'],
            ':id_krs' => $id_krs
        ];

        return $this->executeQuery($query, $params);
    }

    // DELETE
    public function delete($id_krs) {
        $query = "DELETE FROM " . $this->table . " WHERE id_krs = :id_krs";
        return $this->executeQuery($query, [':id_krs' => $id_krs]);
    }
}
?>