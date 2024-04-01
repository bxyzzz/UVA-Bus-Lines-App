// Source code taken from McBurney's NYTimes Bestsellers app

// Used this for JSON to dart file:

// https://quicktype.io/dart

import 'package:flutter/material.dart';

// This is a simplified version. You'll need to adjust according to your data structure and requirements.
import 'src/bus_lines.dart';
import 'package:flutter/material.dart';
import 'map_view.dart'; // Adjust the path as necessary based on your project structure
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ListViewPage extends StatefulWidget {
  @override
  _ListViewPageState createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  // List of bus lines from the JSON file
  List<BusLine> busLines = [];

  @override
  void initState() {
    super.initState();
    getBusLines().then((lines) {
    setState(() {
      busLines = lines; // Updates the state with bus lines
    });
    });
  }

  @override
  // SOURCE: https://docs.flutter.dev/cookbook/lists/long-lists

  Widget build(BuildContext context) {
    const title = "UVA Bus Lines";
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
      ),
      
      body: ListView.builder(
        itemCount: busLines.length,
        //prototypeItem: ListTile(
            //title: Text(busLines.first),
          //),
        itemBuilder: (context, index) {
          final busLine = busLines[index];
          return ListTile(
            title: Text(busLine.longName),
            trailing: IconButton(
              icon: Icon(
                busLine.isFavorite ? Icons.star : Icons.star_border, // If favorited, have it be a filled-in star, otherwise its an outline
              ),
              onPressed: () {
                toggleFavoriteStatus(busLine);
              },

            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapViewPage(busLine: busLine)),
            ),
          );
        },
      ),
    );
  }
  Future<void> toggleFavoriteStatus(BusLine busLine) async {
    final preferences = await SharedPreferences.getInstance();

    setState(() {
      busLine.isFavorite = !busLine.isFavorite; // Just toggle the isFavorite boolean
    });

    preferences.setBool('busLine.id', busLine.isFavorite);

  }
}

Future<List<BusLine>> getBusLines() async {
  // Must get SharedPreferences to update the bus line Favorites!!
  final preferences = await SharedPreferences.getInstance();

  const url = 'https://www.cs.virginia.edu/~pm8fc/busses/busses.json';
  final response = await http.get(
    Uri.parse(
      url) // taken from the https://github.com/cs-4720-uva/flutter_nytimes/blob/main/lib/data/ny_times_reader.dart
  );

  final data = jsonDecode(response.body); // JSON data decode
  print(data); // Debugging to see if I got the data
  final lines = data['lines'] as List;

  // Sort my data when initially getting bus lines

  // SOURCE: https://stackoverflow.com/questions/53547997/sort-a-list-of-objects-in-flutter-dart-by-property-value

  lines.sort((a, b) => 
    a.isFavorite.compareTo(b.isFavorite)
  );

  return lines.map<BusLine>((json) => BusLine.fromJson(json)).toList();
}