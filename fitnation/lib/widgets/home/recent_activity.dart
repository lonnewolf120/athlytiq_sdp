import 'package:flutter/material.dart';

class RecentActivity extends StatelessWidget {
  final List<dynamic> recentWorkouts;
  const RecentActivity({Key? key, required this.recentWorkouts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Recent Activity', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.secondary,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: recentWorkouts.isEmpty
                  ? Column(
                      children: [
                        Text("You haven't logged any workouts yet.", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Start Logging'),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        ...recentWorkouts.map((workout) => _WorkoutTile(workout: workout)).toList(),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Start Logging'),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  final dynamic workout;
  const _WorkoutTile({Key? key, required this.workout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with actual workout fields
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(workout['name'] ?? 'Workout', style: Theme.of(context).textTheme.bodyMedium),
          Text(workout['duration'] != null ? '${workout['duration']} min' : '', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
