import 'package:flutter/material.dart';

class SuggestedTab extends StatelessWidget {
  const SuggestedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final people = [
      {"name": "Sara Svensk", "location": "Unna, Dortmund, Germany"},
      {"name": "Polok Podder", "location": "Keranigonj, Dhaka, Bangladesh"},
      {"name": "Zara Hanoi", "location": "Las Vegas, USA"},
      {"name": "Zaman Alam", "location": "Shahata, Mymensingh, Bangladesh"},
      {"name": "Shehrin Rimi", "location": "Piererbag, Dhaka, Bangladesh"},
    ];

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search on Athlytiq",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: people.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(people[index]["name"]!),
                subtitle: Text(people[index]["location"]!),
                trailing: OutlinedButton(
                  onPressed: () {},
                  child: const Text("Add"),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton(
            onPressed: () {},
            child: const Text("Invite Friends"),
          ),
        ),
      ],
    );
  }
}
