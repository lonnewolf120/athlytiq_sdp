import 'package:flutter/material.dart';
import '../pages/exercise_search_page.dart';

class ExerciseSearchDemo extends StatelessWidget {
  const ExerciseSearchDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Search Demo'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 100, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Exercise Search System',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Search through thousands of exercises with local database for fast performance. Filter by body part, equipment, or target muscle.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExerciseSearchPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Open Exercise Search',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _showFeatures(context);
              },
              child: const Text('View Features'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeatures(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Exercise Search Features'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FeatureItem(
                  icon: Icons.search,
                  title: 'Dynamic Search',
                  description: 'Real-time search with auto-suggestions',
                ),
                _FeatureItem(
                  icon: Icons.filter_list,
                  title: 'Advanced Filters',
                  description:
                      'Filter by body part, equipment, and muscle groups',
                ),
                _FeatureItem(
                  icon: Icons.image,
                  title: 'Exercise GIFs',
                  description: 'Visual demonstrations for proper form',
                ),
                _FeatureItem(
                  icon: Icons.storage,
                  title: 'Local Database',
                  description: 'Fast offline search with SQLite',
                ),
                _FeatureItem(
                  icon: Icons.add_circle,
                  title: 'Add to Workout',
                  description: 'Easy integration with workout plans',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
