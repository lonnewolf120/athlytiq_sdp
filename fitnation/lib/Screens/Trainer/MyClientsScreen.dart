import 'package:flutter/material.dart';

class MyClientsScreen extends StatelessWidget {
  const MyClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> clients = [
      {
        'name': 'Alice Johnson',
        'goal': 'Weight Loss',
      },
      {
        'name': 'Michael Chen',
        'goal': 'Muscle Gain',
      },
      {
        'name': 'Sara Ahmed',
        'goal': 'General Fitness',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Clients'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: clients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final client = clients[index];
          return Card(
            child: ListTile(
              title: Text(client['name'] ?? 'Client'),
              subtitle: Text('Goal: ${client['goal'] ?? '-'}'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                // TODO: Navigate to client detail when available
              },
            ),
          );
        },
      ),
    );
  }
}
