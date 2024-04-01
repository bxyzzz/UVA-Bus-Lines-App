// Source code taken from McBurney's NYTimes Bestsellers app

// Used this for JSON to dart file:

// https://quicktype.io/dart

import 'package:flutter/material.dart';
// This is a simplified version. You'll need to adjust according to your data structure and requirements.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    fetchBusLines(); // Implement this method to fetch bus lines and sort them based on favorites and alphabetically
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
              busLine.name,
              style: TextStyle(color: Color(busLine.textColor)), // Assuming textColor is an int
            ),
            trailing: IconButton(
              icon: Icon(
                busLine.isFavorite ? Icons.star : Icons.star_border,
              ),
              onPressed: () {
                setState(() {
                  busLine.isFavorite = !busLine.isFavorite;
                  saveFavoriteStatus(busLine.name, busLine.isFavorite); // Implement this
                });
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
}