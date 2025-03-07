<?php
header('Content-Type: application/json');

// Database configuration – update these variables with your own values
$host = 'localhost';
$db   = 'its66040233114';
$user = 'its66040233114';
$pass = 'password';

// Create a connection
$conn = new mysqli($host, $user, $pass, $db);

// Check connection
if ($conn->connect_error) {
    echo json_encode([
        'success' => false, 
        'message' => 'Database connection failed: ' . $conn->connect_error
    ]);
    exit();
}

// Get POST parameters
$id = isset($_POST['id']) ? $_POST['id'] : null;
$name = isset($_POST['name']) ? $_POST['name'] : null;
$latitude = isset($_POST['latitude']) ? $_POST['latitude'] : null;
$longitude = isset($_POST['longitude']) ? $_POST['longitude'] : null;

// Validate input
if ($id === null || $name === null || $latitude === null || $longitude === null) {
    echo json_encode([
        'success' => false, 
        'message' => 'Missing parameters'
    ]);
    exit();
}

// Prepare and execute the update query
$stmt = $conn->prepare("UPDATE locations SET name = ?, latitude = ?, longitude = ? WHERE id = ?");
$stmt->bind_param("sssi", $name, $latitude, $longitude, $id);

if ($stmt->execute()) {
    echo json_encode([
        'success' => true, 
        'message' => 'Location updated successfully'
    ]);
} else {
    echo json_encode([
        'success' => false, 
        'message' => 'Update failed: ' . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
