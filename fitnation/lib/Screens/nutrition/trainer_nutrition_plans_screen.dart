import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/auth_provider.dart'; // Assuming authProvider gives user role

class TrainerNutritionPlansScreen extends ConsumerWidget {
  const TrainerNutritionPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState is Authenticated && authState.user.role == 'trainer') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Trainer Nutrition Plans'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome, Trainer!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('Here you can create and assign nutrition plans to your clients.'),
              // TODO: Add UI for listing, creating, editing, and assigning nutrition plans
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
        ),
        body: const Center(
          child: Text('You must be a trainer to access this page.'),
        ),
      );
    }
  }
}
