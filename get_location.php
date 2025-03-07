<?php
    header('Content-Type: application/json');
    
    $db_name = "its66040233114";
    $db_user = "its66040233114";
    $db_pass = "password";
    $host = "localhost";

    // Create connection
    $conn = new mysqli($host, $db_user, $db_pass, $db_name);

    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    // SQL query to fetch locations
    $sql = "SELECT * FROM locations";
    $result = $conn->query($sql);

    $locations = [];

    // Fetch each row from the result and store it in the $locations array
    while($row = $result->fetch_assoc()) {
        $locations[] = [
            'id' => $row['id'],
            'name' => $row['name'],
            'latitude' => $row['latitude'],
            'longitude' => $row['longitude']
        ];
    }

    // Output the result as JSON
    echo json_encode($locations);

    // Close the database connection
    $conn->close();
?>
