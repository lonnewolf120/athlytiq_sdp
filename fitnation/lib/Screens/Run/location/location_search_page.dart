import 'package:flutter/material.dart';

class LocationSearchPage extends StatelessWidget {
  const LocationSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Location")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search here",
                prefixIcon: Icon(Icons.search),
                suffixIcon: TextButton(onPressed: null, child: Text("Cancel")),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.my_location),
            title: Text("Current Location"),
          ),
        ],
      ),
    );
  }
}
