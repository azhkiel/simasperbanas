<?php
include_once 'BaseModel.php';
class UsulanKelas extends BaseModel {
    protected $table = "usulan_kelas";

    public function __construct($db) {
        parent::__construct($db);
    }

    // CREATE
    public function create($data) {
        $query = "INSERT INTO " . $this->table . " 
                 (nim, nama_mk, hari, shift, alasan) 
                 VALUES (:nim, :nama_mk, :hari, :shift, :alasan)";
        
        $params = [
            ':nim' => $data['nim'],
            ':nama_mk' => $data['nama_mk'],
            ':hari' => $data['hari'],
            ':shift' => $data['shift'],
            ':alasan' => $data['alasan']
        ];

        $this->executeQuery($query, $params);
        return $this->conn->lastInsertId();
    }

    // READ ALL
    public function readAll() {
        $query = "SELECT u.*, us.nama 
                 FROM " . $this->table . " u
                 JOIN user us ON u.nim = us.nim";
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
    public function readSingle($id_usulan) {
        $query = "SELECT u.*, us.nama 
                 FROM " . $this->table . " u
                 JOIN user us ON u.nim = us.nim
                 WHERE u.id_usulan = :id_usulan";
        $stmt = $this->executeQuery($query, [':id_usulan' => $id_usulan]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // UPDATE
    public function update($id_usulan, $data) {
        $query = "UPDATE " . $this->table . " 
                 SET nim = :nim, nama_mk = :nama_mk, hari = :hari, shift = :shift, alasan = :alasan 
                 WHERE id_usulan = :id_usulan";
        
        $params = [
            ':nim' => $data['nim'],
            ':nama_mk' => $data['nama_mk'],
            ':hari' => $data['hari'],
            ':shift' => $data['shift'],
            ':alasan' => $data['alasan'],
            ':id_usulan' => $id_usulan
        ];

        return $this->executeQuery($query, $params);
    }

    // DELETE
    public function delete($id_usulan) {
        $query = "DELETE FROM " . $this->table . " WHERE id_usulan = :id_usulan";
        return $this->executeQuery($query, [':id_usulan' => $id_usulan]);
    }
}
?>