<?php
include_once 'BaseModel.php';
class KRSDetail extends BaseModel {
    protected $table = "krs_detail";

    public function __construct($db) {
        parent::__construct($db);
    }

    // CREATE
    public function create($data) {
        $query = "INSERT INTO " . $this->table . " 
                 (id_krs, id_mk) 
                 VALUES (:id_krs, :id_mk)";
        
        $params = [
            ':id_krs' => $data['id_krs'],
            ':id_mk' => $data['id_mk']
        ];

        $this->executeQuery($query, $params);
        return $this->conn->lastInsertId();
    }

    // READ BY KRS ID
    public function readByKrsId($id_krs) {
        $query = "SELECT kd.*, mk.kode_mk, mk.nama_mk, mk.sks 
                 FROM " . $this->table . " kd
                 JOIN mata_kuliah mk ON kd.id_mk = mk.id_mk
                 WHERE kd.id_krs = :id_krs";
        $stmt = $this->executeQuery($query, [':id_krs' => $id_krs]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // READ SINGLE
    public function readSingle($id_detail) {
        $query = "SELECT * FROM " . $this->table . " WHERE id_detail = :id_detail";
        $stmt = $this->executeQuery($query, [':id_detail' => $id_detail]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // DELETE
    public function delete($id_detail) {
        $query = "DELETE FROM " . $this->table . " WHERE id_detail = :id_detail";
        return $this->executeQuery($query, [':id_detail' => $id_detail]);
    }

    // DELETE BY KRS AND MK
    public function deleteByKrsAndMk($id_krs, $id_mk) {
        $query = "DELETE FROM " . $this->table . " WHERE id_krs = :id_krs AND id_mk = :id_mk";
        return $this->executeQuery($query, [':id_krs' => $id_krs, ':id_mk' => $id_mk]);
    }
}
?>