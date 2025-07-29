import 'package:flutter/material.dart';
import 'package:map_routes/themes/colors.dart';
import 'package:map_routes/themes/text_styles.dart';

class RouteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> route;

  const RouteDetailScreen({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          route['title'] ?? 'Route Details',
          style: AppTextStyles.lightHeadlineMedium,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.lightSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.map, size: 64, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            route['title'] ?? 'Route Title',
            style: AppTextStyles.darkHeadlineMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoTile(
                icon: Icons.directions,
                value: route['distance'] ?? '0 km',
                label: 'Distance',
              ),
              _buildInfoTile(
                icon: Icons.timer,
                value: route['duration'] ?? '0 min',
                label: 'Duration',
              ),
              _buildInfoTile(
                icon: Icons.fitness_center,
                value: route['difficulty'] ?? 'N/A',
                label: 'Difficulty',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Route Description', style: AppTextStyles.darkHeadlineMedium),
          const SizedBox(height: 8),
          Text(
            'This is a great route for ${route['difficulty']?.toLowerCase() ?? 'all'} level fitness enthusiasts. '
            'It offers beautiful scenery and varied terrain to keep things interesting throughout your session.',
            style: AppTextStyles.darkBody,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(
                context,
              ); // You can route to a live navigation screen here
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Route'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: AppTextStyles.buttonText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.darkBody),
        Text(label, style: AppTextStyles.darkBody),
      ],
    );
  }
}
