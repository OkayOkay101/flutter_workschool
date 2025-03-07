import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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
      title: 'Google Map with API Data',
      home: GoogleMapFromDB(),
    );
  }
}

class GoogleMapFromDB extends StatefulWidget {
  @override
  State<GoogleMapFromDB> createState() => _GoogleMapFromDBState();
}

class _GoogleMapFromDBState extends State<GoogleMapFromDB> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  LatLng _currentLocation = LatLng(13.0827, 80.2707); // Default location
  bool _isLoading = true;
  List<dynamic> _apiData = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchData();
  }

  // Request location permission and get the current location
  Future<void> _getCurrentLocation() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });

        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLocation,
              zoom: 15,
            ),
          ),
        );
      } catch (e) {
        print("Error fetching location: $e");
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print("Permission not granted");
    }
  }

  // Fetch data from API and add markers to the map
  Future<void> _fetchData() async {
    final url = Uri.parse('https://hosting.udru.ac.th/its66040233114/get_location.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      Set<Marker> markers = {};

      for (var item in data) {
        final double latitude = double.parse(item['latitude']);
        final double longitude = double.parse(item['longitude']);
        final LatLng position = LatLng(latitude, longitude);

        markers.add(
          Marker(
            markerId: MarkerId(item['id'].toString()),
            position: position,
            infoWindow: InfoWindow(
              title: item['name'],
              snippet: '${item['latitude']}, ${item['longitude']}',
            ),
            onTap: () {
              _controller?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: position,
                    zoom: 15,
                  ),
                ),
              );
            },
          ),
        );
      }

      setState(() {
        _markers = markers;
        _apiData = data; // Store API data for displaying in the list
      });
    } else {
      print('Error fetching data: ${response.statusCode}');
    }
  }

  // Move the map camera to a specified location
  void _moveToLocation(double latitude, double longitude) {
    final LatLng newPosition = LatLng(latitude, longitude);
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: newPosition,
          zoom: 15,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  // New: Handle long press on the map to add a new location
  void _onMapLongPress(LatLng position) {
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Save Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Latitude: ${position.latitude.toStringAsFixed(5)}'),
              Text('Longitude: ${position.longitude.toStringAsFixed(5)}'),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Location Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  await _saveLocation(
                    nameController.text.trim(),
                    position.latitude,
                    position.longitude,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // New: Save location data via API call and refresh markers
  Future<void> _saveLocation(String name, double latitude, double longitude) async {
    final url = Uri.parse('https://hosting.udru.ac.th/its66040233114/save_location.php');
    final response = await http.post(url, body: {
      'name': name,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    });

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      if (result["success"] == true) {
        print("Location added successfully");
        _fetchData(); // Refresh markers from API
      } else {
        print("Failed to add location: ${result["message"]}");
      }
    } else {
      print("Error adding location: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map & API Data'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation,
                      zoom: 15,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    // Added onLongPress to enable pointing on map
                    onLongPress: _onMapLongPress,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _apiData.isNotEmpty
                      ? ListView.builder(
                          itemCount: _apiData.length,
                          itemBuilder: (context, index) {
                            var item = _apiData[index];
                            return GestureDetector(
                              onTap: () {
                                final double latitude = double.parse(item['latitude']);
                                final double longitude = double.parse(item['longitude']);
                                _moveToLocation(latitude, longitude);
                              },
                              child: Card(
                                margin: EdgeInsets.all(8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ID: ${item['id']}',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Name: ${item['name']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Location: ${item['latitude']}, ${item['longitude']}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(child: Text('No data available')),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AddLocationPage and refresh data on return
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddLocationPage()),
          ).then((value) {
            _fetchData();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddLocationPage extends StatefulWidget {
  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
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
