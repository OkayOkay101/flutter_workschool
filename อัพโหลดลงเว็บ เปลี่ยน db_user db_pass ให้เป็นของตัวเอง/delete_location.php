<?php
header('Content-Type: application/json');

// Database credentials
$db_name = "its66040233114";
$db_user = "its66040233114";
$db_pass = "password";
$host = "localhost";

// Create connection
$conn = new mysqli($host, $db_user, $db_pass, $db_name);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Get the ID of the location to delete
$id = isset($_POST['id']) ? intval($_POST['id']) : 0;

if ($id > 0) {
    $sql = "DELETE FROM locations WHERE id = $id";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["success" => true, "message" => "Location deleted successfully!"]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to delete location: " . $conn->error]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid ID"]);
}

$conn->close();
?>
