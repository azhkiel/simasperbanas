<?php
class BaseModel {
    protected $conn;
    protected $table;

    public function __construct($db) {
        $this->conn = $db;
    }

    protected function executeQuery($query, $params = []) {
        try {
            $stmt = $this->conn->prepare($query);
            $stmt->execute($params);
            return $stmt;
        } catch(PDOException $exception) {
            throw new Exception("Query error: " . $exception->getMessage());
        }
    }
}
?>