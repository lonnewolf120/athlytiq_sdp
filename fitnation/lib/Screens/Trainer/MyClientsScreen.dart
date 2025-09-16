import 'package:flutter/material.dart';

class MyClientsScreen extends StatelessWidget {
  const MyClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> clients = [
      {
        'name': 'Akram Emtiaz',
        'goal': 'Muscle Gain',
      },
      {
        'name': 'Sadia Islam',
        'goal': 'Weight Loss',
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
