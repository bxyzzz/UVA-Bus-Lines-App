import 'package:flutter/material.dart';
import 'list_view.dart'; // Make sure to create this file and define ListViewPage widget in it
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  locationPermissionStatus();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Lines App',
      theme: ThemeData(
        primaryColor: Colors.blue,
        // accentColor: Colors.blueAccent,
        
        useMaterial3: true,
      ),
      home: ListViewPage(), // Home page is the list view
    );
  }
}

 void locationPermissionStatus() async {
   // Request location permission
   
    bool serviceEnabled;
    LocationPermission permission;

  // this code block i found online tests if its enabled but I think I already do that in my later code
  /*
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    permission = await Geolocator.requestPermission();
    return Future.error('Location services are disabled.');
  }
  */

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  final position = await Geolocator.getCurrentPosition();
  print('Latitude: ${position.latitude}, Longitude: ${position.longitude}'); // debug statement


   /*
   
   const permissionLocation = Permission.location;

   final status = await permissionLocation.request();
   if (status == PermissionStatus.granted) {
     // Get the current location
     final position = await Geolocator.getCurrentPosition();
     print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
   } else {
     // Permission denied
     print('Location permission denied.');
   }
   */
  }


/*
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'src/locations.dart' as locations;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleOffices = await locations.getGoogleOffices();
    setState(() {
      _markers.clear();
      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
          ),
        );
        _markers[office.name] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Google Office Locations'),
          elevation: 2,
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: LatLng(0, 0),
            zoom: 2,
          ),
          markers: _markers.values.toSet(),
        ),
      ),
    );
  }
}
*/