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

$name = $_POST['name'];
$latitude = $_POST['latitude'];
$longitude = $_POST['longitude'];

$sql = "INSERT INTO locations (name, latitude, longitude) VALUES ('$name', '$latitude', '$longitude')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "Location saved successfully!"]);
} else {
    echo json_encode(["success" => false, "message" => "Failed to save location: " . $conn->error]);
}

$conn->close();
?>
