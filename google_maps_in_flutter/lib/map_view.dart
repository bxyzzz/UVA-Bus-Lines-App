import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:google_maps_in_flutter/src/locations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'src/bus_lines.dart';
import 'package:geolocator/geolocator.dart';

// Geolocation Source: https://developers.google.com/maps/documentation/javascript/geolocation

class MapViewPage extends StatefulWidget {
  final BusLine busLine;

  MapViewPage({required this.busLine});

  @override
  _MapViewPageState createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  late GoogleMapController _controller;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
    _markers = {}; // Initialize markers
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.busLine.longName),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(38.0316, -78.5108), // Default position set to Rice Hall
          zoom: 10,
        ),
        markers: _markers, // Use the _markers set
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    // So I had to split everything into functions because having everything as one async function wouldn't update the
    // map with the markers, so this displays the markers, then moves the camera to the bounds.
    _controller = controller;
    List<Stop> busStops = await getBusLineStops();
    await displayStops(busStops);
    _animateCameraToBounds();
  }

  // SOURCE: https://stackoverflow.com/questions/59920284/how-to-find-an-element-in-a-dart-list

  Future<List<Stop>> getBusLineStops() async {
    const url = 'https://www.cs.virginia.edu/~pm8fc/busses/busses.json';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    int busLineID = widget.busLine.id;
    final List<BusRoute> routes = (data['routes'] as List)
        .map<BusRoute>((json) => BusRoute.fromJson(json))
        .toList();
    BusRoute? findBusRoute(int id) => routes.firstWhere((route) => route.id == id);

    BusRoute? currentRoute = findBusRoute(busLineID);
    if (currentRoute == null) return [];
    List<int> currentRouteStops = currentRoute.stops;

    List<Stop> busLineStops = (data['stops'] as List)
        .where((json) => currentRouteStops.contains(json['id']))
        .map<Stop>((json) => Stop.fromJson(json))
        .toList();

    return busLineStops;
  }

  // Helper function to display the stops by adding all stops in the given stopList into _markers set.
  Future<void> displayStops(List<Stop> stopList) async {
    //Position currPosition = await getUserCurrentLocation();
    
    Position currPosition = await getSetLocation(); // FOR MANUALLY SETTING POSITION TO SEE IF CURRENT LOCATION MARKER WORKS

    print("CURRENT POSITION DEBUG: ");
    print(currPosition);



    final currLocationMarker = Marker(
      markerId: MarkerId('currentLocation'),
      position: LatLng(currPosition.latitude, currPosition.longitude),
      infoWindow: InfoWindow(title: 'Current Position'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Set marker color to blue
    );

    setState(() {
      _markers.clear(); // Clear existing markers
      for (final stop in stopList) {
        _markers.add(Marker(
          markerId: MarkerId(stop.id.toString()),
          position: LatLng(stop.position[0], stop.position[1]),
          infoWindow: InfoWindow(title: stop.name, snippet: stop.description),
        ));
      }
      _markers.add(currLocationMarker); // Add the current location marker to the map
    });
  }

  void _animateCameraToBounds() {
    _controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(widget.busLine.bounds[0], widget.busLine.bounds[1]),
          northeast: LatLng(widget.busLine.bounds[2], widget.busLine.bounds[3]),
        ),
        100, 
      ),
    );
  }
}

// Source: https://www.geeksforgeeks.org/how-to-get-users-current-location-on-google-maps-in-flutter/#google_vignette
// created method for getting user current location
Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR"+error.toString());
    });
    return await Geolocator.getCurrentPosition();
}


// DELETE LATER: HARDCODED

Future<Position> getSetLocation() async {
  return Position(
    latitude: 38.0316, // Example latitude for San Francisco
    longitude: -78.5108, // Example longitude for San Francisco
    timestamp: DateTime.now(),
    accuracy: 0.0,
    altitude: 0.0,

    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    altitudeAccuracy: 0.0,
  );
}



/*

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:google_maps_in_flutter/src/locations.dart';
import 'src/bus_lines.dart';
import 'package:http/http.dart' as http;

class MapViewPage extends StatefulWidget {
  final BusLine busLine;

  MapViewPage({required this.busLine});

  @override
  _MapViewPageState createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.busLine.longName),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          List<Stop> busStops = await getBusLineStops() as List<Stop>;

          _controller = controller;
          controller.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(widget.busLine.bounds[0], widget.busLine.bounds[1]),
                northeast: LatLng(widget.busLine.bounds[2], widget.busLine.bounds[3]),
              ),
              100, // Padding
            ),
          );

          displayStops(controller, busStops);
        },

        initialCameraPosition: CameraPosition(
          target: LatLng(38.0316,  -78.5108), // Default position set to Rice Hall
          zoom: 10,
        ),
        // Unnecessary, this restricts users scrolling/panning capability
        
        // Documentation: https://developers.google.com/maps/documentation/android-sdk/views
        
        /*cameraTargetBounds: CameraTargetBounds(
          LatLngBounds(
            southwest: LatLng(widget.busLine.bounds[0], widget.busLine.bounds[1]), 
            northeast: LatLng(widget.busLine.bounds[2], widget.busLine.bounds[3]),
          )
        ) ,
        */

        //markers: getMarkersForStops(), 
      ),
    );
  }
  
  Future<List<Stop>> getBusLineStops() async {

    const url = 'https://www.cs.virginia.edu/~pm8fc/busses/busses.json';
    final response = await http.get(
      Uri.parse(
        url) // taken from the https://github.com/cs-4720-uva/flutter_nytimes/blob/main/lib/data/ny_times_reader.dart
    );

    final data = jsonDecode(response.body); // JSON data decode
    print(data); // Debugging to see if I got the data

    int busLineID = widget.busLine.id;

    /*List<BusRoute> busLineRoutes = (data['routes']) as List).where((json) => json['id'] == busLineID).map<BusRoute>((json) {
      return BusRoute.fromJson(json);
    }).toList();
    */
    final List<BusRoute> routes = (data['routes'] as List)
    .map<BusRoute>((json) => BusRoute.fromJson(json))
    .toList();
    
    // SOURCE: https://stackoverflow.com/questions/59920284/how-to-find-an-element-in-a-dart-list

    BusRoute? findBusRoute(int id) => routes.firstWhere((route) => route.id == id); // it always exists but good practice

    BusRoute currentRoute = findBusRoute(busLineID) as BusRoute;
    print(currentRoute);

    List<int> currentRouteStops = currentRoute.stops; // This is our list of all of the stops as ints

    List<Stop> busLineStops = (data['stops'] as List).where((json) => currentRouteStops.contains(json['id'])).map<Stop>((json) {
      return Stop.fromJson(json);
    }).toList(); 

    return busLineStops;
  }

  void displayStops(GoogleMapController controller, List<Stop> stopList) {
    setState(() {
        _markers.clear(); // Clear existing markers, if you want to
        for (final stop in stopList) {
          _markers.add(Marker(
            markerId: MarkerId(stop.id.toString()),
            position: LatLng(stop.position[0], stop.position[1]),
            infoWindow: InfoWindow(title: stop.name, snippet: stop.description),
          ));
        }
    });
  }

}
*/





/* import 'package:flutter/material.dart';
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