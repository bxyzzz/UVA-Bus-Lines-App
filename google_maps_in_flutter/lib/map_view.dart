import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'src/bus_lines.dart'; // Ensure this path is correct

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
    _controller = controller;
    List<Stop> busStops = await getBusLineStops();
    displayStops(busStops);
    _animateCameraToBounds();
  }

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

  void displayStops(List<Stop> stopList) {
    setState(() {
      _markers.clear(); // Clear existing markers
      for (final stop in stopList) {
        _markers.add(Marker(
          markerId: MarkerId(stop.id.toString()),
          position: LatLng(stop.position[0], stop.position[1]),
          infoWindow: InfoWindow(title: stop.name, snippet: stop.description),
        ));
      }
    });
  }

  void _animateCameraToBounds() {
    if (widget.busLine.bounds.isEmpty || widget.busLine.bounds.length < 4) return; // Check for valid bounds
    _controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(widget.busLine.bounds[0], widget.busLine.bounds[1]),
          northeast: LatLng(widget.busLine.bounds[2], widget.busLine.bounds[3]),
        ),
        100, // Padding
      ),
    );
  }
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

        //markers: getMarkersForStops(), // Implement this based on widget.busLine.stops
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