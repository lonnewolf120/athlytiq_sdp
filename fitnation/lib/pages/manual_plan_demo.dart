import 'package:flutter/material.dart';
import 'add_manual_plan_screen.dart';

class ManualPlanDemo extends StatelessWidget {
  const ManualPlanDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Plan Demo'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, size: 100, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Manual Workout Plan Creator',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Create custom workout plans with exercises from our comprehensive database. Search, filter, and add exercises with proper sets, reps, and weight configurations.',
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
                    builder: (context) => const AddManualPlanScreen(),
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
                'Create Manual Plan',
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
            title: const Text('Manual Plan Creator Features'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FeatureItem(
                  icon: Icons.search,
                  title: 'Exercise Database Search',
                  description:
                      'Search from thousands of exercises with real-time filtering',
                ),
                _FeatureItem(
                  icon: Icons.tune,
                  title: 'Advanced Filters',
                  description: 'Filter by body part and equipment type',
                ),
                _FeatureItem(
                  icon: Icons.settings,
                  title: 'Exercise Configuration',
                  description:
                      'Set custom sets, reps, and weights for each exercise',
                ),
                _FeatureItem(
                  icon: Icons.image,
                  title: 'Exercise Previews',
                  description: 'View exercise GIFs and detailed instructions',
                ),
                _FeatureItem(
                  icon: Icons.save,
                  title: 'Plan Management',
                  description: 'Save plans locally and sync with backend',
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
