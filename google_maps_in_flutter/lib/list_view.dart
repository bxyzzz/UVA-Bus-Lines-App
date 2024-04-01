// Source code taken from McBurney's NYTimes Bestsellers app

// Used this for JSON to dart file:

// https://quicktype.io/dart

import 'package:flutter/material.dart';

// This is a simplified version. You'll need to adjust according to your data structure and requirements.
import 'src/bus_lines.dart';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; TO
import 'dart:convert';
import 'package:http/http.dart' as http;

class ListViewPage extends StatefulWidget {
  @override
  _ListViewPageState createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  // This will be your list of bus lines fetched from the JSON
  List<BusLine> busLines = [];

  @override
  void initState() {
    super.initState();
    fetchBusLines().then((lines) {
    setState(() {
      busLines = lines; // This updates your widget's state with the fetched bus lines
    });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bus Lines"),
      ),
      body: ListView.builder(
        itemCount: busLines.length,
        itemBuilder: (context, index) {
          final busLine = busLines[index];
          return ListTile(
            title: Text(
              busLine.shortName,
              //style: TextStyle(color: Color(busLine.textColor)), // Assuming textColor is an int
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.star
                //busLine.isFavorite ? Icons.star : Icons.star_border,
              ),
              onPressed: () {
                setState(() {
                  //busLine.isFavorite = !busLine.isFavorite;
                  //saveFavoriteStatus(busLine.name, busLine.isFavorite); // Implement this
                });
              },
            ),
            //onTap: () => Navigator.push(
            //  context,
            //  MaterialPageRoute(builder: (context) => MapViewPage(busLine: busLine)),
            //),
          );
        },
      ),
    );
  }
}



Future<List<BusLine>> fetchBusLines() async {
  const url = 'https://www.cs.virginia.edu/~pm8fc/busses/busses.json';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // Parse the JSON data
    final data = jsonDecode(response.body);
    print(data); // Debug
    final lines = data['lines'] as List;
    return lines.map<BusLine>((json) => BusLine.fromJson(json)).toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load bus lines');
  }
}