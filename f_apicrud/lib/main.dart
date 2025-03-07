import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location CRUD',
      home: LocationListPage(),
    );
  }
}

class LocationListPage extends StatefulWidget {
  @override
  _LocationListPageState createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
  bool _isLoading = true;
  List<dynamic> _locations = [];

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  // Fetch location data from API
  Future<void> _fetchLocations() async {
    final url = Uri.parse('https://hosting.udru.ac.th/its66040233114/get_location.php');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _locations = data;
        _isLoading = false;
      });
    } else {
      print('Error fetching data: ${response.statusCode}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Delete a location by id
  Future<void> _deleteLocation(String id) async {
    final url = Uri.parse('https://hosting.udru.ac.th/its66040233114/delete_location.php');
    final response = await http.post(url, body: {'id': id});
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      if (result["success"] == true) {
        print("Location deleted successfully");
        _fetchLocations();
      } else {
        print("Failed to delete location: ${result["message"]}");
      }
    } else {
      print("Error deleting location: ${response.statusCode}");
    }
  }

  // Build each list item with edit and delete actions
  Widget _buildLocationItem(Map location) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text('Name: ${location['name']}'),
        subtitle: Text('Lat: ${location['latitude']}, Lng: ${location['longitude']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditLocationPage(location: location),
                  ),
                ).then((value) {
                  _fetchLocations();
                });
              },
            ),
            // Delete button
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Confirm deletion before proceeding
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Location'),
                    content: Text('Are you sure you want to delete this location?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteLocation(location['id'].toString());
                        },
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location CRUD'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchLocations,
              child: ListView.builder(
                itemCount: _locations.length,
                itemBuilder: (context, index) {
                  var location = _locations[index];
                  return _buildLocationItem(location);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AddLocationPage and refresh the list when returning
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddLocationPage()),
          ).then((value) {
            _fetchLocations();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddLocationPage extends StatefulWidget {
  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitData() async {
    setState(() {
      _isSubmitting = true;
    });
    final url = Uri.parse('https://hosting.udru.ac.th/its66040233114/save_location.php');
    final response = await http.post(url, body: {
      'name': _nameController.text,
      'latitude': _latitudeController.text,
      'longitude': _longitudeController.text,
    });
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      if (result["success"] == true) {
        print("Location added successfully");
        Navigator.pop(context);
      } else {
        print("Failed to add location: ${result["message"]}");
      }
    } else {
      print("Error adding location: ${response.statusCode}");
    }
    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Location Name'),
            ),
            TextField(
              controller: _latitudeController,
              decoration: InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _longitudeController,
              decoration: InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _isSubmitting
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitData,
                    child: Text('Add Location'),
                  ),
          ],
        ),
      ),
    );
  }
}

class EditLocationPage extends StatefulWidget {
  final Map location;
  EditLocationPage({required this.location});

  @override
  _EditLocationPageState createState() => _EditLocationPageState();
}

class _EditLocationPageState extends State<EditLocationPage> {
  late TextEditingController _nameController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.location['name']);
    _latitudeController = TextEditingController(text: widget.location['latitude']);
    _longitudeController = TextEditingController(text: widget.location['longitude']);
  }

  Future<void> _updateData() async {
    setState(() {
      _isSubmitting = true;
    });
    final url = Uri.parse('https://hosting.udru.ac.th/its66040233114/update_location.php');
    final response = await http.post(url, body: {
      'id': widget.location['id'].toString(),
      'name': _nameController.text,
      'latitude': _latitudeController.text,
      'longitude': _longitudeController.text,
    });
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      if (result["success"] == true) {
        print("Location updated successfully");
        Navigator.pop(context);
      } else {
        print("Failed to update location: ${result["message"]}");
      }
    } else {
      print("Error updating location: ${response.statusCode}");
    }
    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Location Name'),
            ),
            TextField(
              controller: _latitudeController,
              decoration: InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _longitudeController,
              decoration: InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _isSubmitting
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updateData,
                    child: Text('Update Location'),
                  ),
          ],
        ),
      ),
    );
  }
}
