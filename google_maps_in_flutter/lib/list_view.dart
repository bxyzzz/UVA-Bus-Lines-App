// Source code taken from McBurney's NYTimes Bestsellers app

// Used this for JSON to dart file:

// https://quicktype.io/dart

import 'package:flutter/material.dart';
import 'src/bus_lines.dart';
import 'map_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;

// Source for permissions:
// https://medium.com/@dudhatkirtan/how-to-use-permission-handler-in-flutter-db964943237e

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
        backgroundColor: Colors.blueAccent,
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
             // Set it to be black if the default color is white
            textColor: hexStringToColor(busLine.textColor) == Colors.white ? Colors.black : hexStringToColor(busLine.textColor),
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

      busLines.sort(compareLines);
    });

    //preferences.setBool('busLine.id', busLine.isFavorite);
    preferences.setBool('favorite_${busLine.id}', busLine.isFavorite);

  }
}

Color hexStringToColor(String hexString) {
    String addPrefix = "0xFF" + hexString;
  
    return Color(int.parse(addPrefix));
}

int compareLines(BusLine a, BusLine b) {
  int favA = a.isFavorite ? 1 : 0; // Apparently doesn't work for bools... so I have to convert it to int since compareTo doesn't work
  int favB = b.isFavorite ? 1 : 0;

  var comparisonResult = favB.compareTo(favA); // B compareTo A so it puts favorites up TOP
  if (comparisonResult != 0) {
    return comparisonResult;
  }
  // Favorite value are the same, so subsort by given name.
  return a.longName.compareTo(b.longName);
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
  
  // First, convert JSON objects to BusLine instances
  List<BusLine> lines = (data['lines'] as List).map<BusLine>((json) {
    bool isFavorite = preferences.getBool('favorite_${json['id']}') ?? false;
    return BusLine.fromJson(json)..isFavorite = isFavorite;
  }).toList();

  // Sort my data when initially getting bus lines

  // SOURCE: https://stackoverflow.com/questions/53547997/sort-a-list-of-objects-in-flutter-dart-by-property-value

  lines.sort(compareLines);

  return lines;
}