<?php
include_once 'BaseModel.php';
class MataKuliah extends BaseModel {
    protected $table = "mata_kuliah";

    public function __construct($db) {
        parent::__construct($db);
    }

    // CREATE
    public function create($data) {
        $query = "INSERT INTO " . $this->table . " 
                 (kode_mk, nama_mk, sks, semester) 
                 VALUES (:kode_mk, :nama_mk, :sks, :semester)";
        
        $params = [
            ':kode_mk' => $data['kode_mk'],
            ':nama_mk' => $data['nama_mk'],
            ':sks' => $data['sks'],
            ':semester' => $data['semester']
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

    // READ SINGLE
    public function readSingle($id_mk) {
        $query = "SELECT * FROM " . $this->table . " WHERE id_mk = :id_mk";
        $stmt = $this->executeQuery($query, [':id_mk' => $id_mk]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // READ BY SEMESTER
    public function readBySemester($semester) {
        $query = "SELECT * FROM " . $this->table . " WHERE semester = :semester";
        $stmt = $this->executeQuery($query, [':semester' => $semester]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // UPDATE
    public function update($id_mk, $data) {
        $query = "UPDATE " . $this->table . " 
                 SET kode_mk = :kode_mk, nama_mk = :nama_mk, sks = :sks, semester = :semester 
                 WHERE id_mk = :id_mk";
        
        $params = [
            ':kode_mk' => $data['kode_mk'],
            ':nama_mk' => $data['nama_mk'],
            ':sks' => $data['sks'],
            ':semester' => $data['semester'],
            ':id_mk' => $id_mk
        ];

        return $this->executeQuery($query, $params);
    }

    // DELETE
    public function delete($id_mk) {
        $query = "DELETE FROM " . $this->table . " WHERE id_mk = :id_mk";
        return $this->executeQuery($query, [':id_mk' => $id_mk]);
    }
}
?>