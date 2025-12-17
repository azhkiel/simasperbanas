<?php
include_once 'BaseModel.php';

class User extends BaseModel {
    protected $table = "user";

    public function __construct($db) {
        parent::__construct($db);
    }

    // CREATE
    public function create($data) {
        $query = "INSERT INTO " . $this->table . " 
                 (nim, nama, email, password) 
                 VALUES (:nim, :nama, :email, :password)";
        
        $params = [
            ':nim' => $data['nim'],
            ':nama' => $data['nama'],
            ':email' => $data['email'],
            ':password' => $data['password']
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
    public function readSingle($id_user) {
        $query = "SELECT * FROM " . $this->table . " WHERE id_user = :id_user";
        $stmt = $this->executeQuery($query, [':id_user' => $id_user]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // READ BY NIM
    public function readByNim($nim) {
        $query = "SELECT * FROM " . $this->table . " WHERE nim = :nim";
        $stmt = $this->executeQuery($query, [':nim' => $nim]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // LOGIN METHOD
    public function login($nim, $password) {
        $query = "SELECT * FROM " . $this->table . " WHERE nim = :nim AND password = :password";
        $stmt = $this->executeQuery($query, [':nim' => $nim, ':password' => $password]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // UPDATE
    public function update($id_user, $data) {
        $query = "UPDATE " . $this->table . " 
                 SET nim = :nim, nama = :nama, email = :email, password = :password 
                 WHERE id_user = :id_user";
        
        $params = [
            ':nim' => $data['nim'],
            ':nama' => $data['nama'],
            ':email' => $data['email'],
            ':password' => $data['password'],
            ':id_user' => $id_user
        ];

        return $this->executeQuery($query, $params);
    }

    // DELETE
    public function delete($id_user) {
        $query = "DELETE FROM " . $this->table . " WHERE id_user = :id_user";
        return $this->executeQuery($query, [':id_user' => $id_user]);
    }
}
?>