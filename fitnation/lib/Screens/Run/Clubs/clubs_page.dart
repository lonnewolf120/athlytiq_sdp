import 'package:flutter/material.dart';
import '../location/location_search_page.dart';

class ClubsTab extends StatelessWidget {
  const ClubsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final clubs = [
      {"title": "Solo Running", "desc": "11,098 runners. Dhaka, Bangladesh"},
      {"title": "Bangladesh", "desc": "4,298 cyclists. Dhaka, Bangladesh"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Clubs")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Find a club...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationSearchPage()),
              );
            },
            icon: const Icon(Icons.location_on),
            label: const Text("Location"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: clubs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.image),
                  title: Text(clubs[index]["title"]!),
                  subtitle: Text(clubs[index]["desc"]!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
