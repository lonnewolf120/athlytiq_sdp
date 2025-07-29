import 'package:flutter/material.dart';
import 'package:map_routes/themes/colors.dart';
import 'package:map_routes/themes/text_styles.dart';

class RouteFilterScreen extends StatefulWidget {
  const RouteFilterScreen({super.key});

  @override
  State<RouteFilterScreen> createState() => _RouteFilterScreenState();
}

class _RouteFilterScreenState extends State<RouteFilterScreen> {
  final Map<String, bool> difficultyFilters = {
    'Easy': false,
    'Medium': false,
    'Hard': false,
  };

  final Map<String, bool> distanceFilters = {
    '< 5 km': false,
    '5–15 km': false,
    '> 15 km': false,
  };

  final Map<String, bool> durationFilters = {
    '< 30 min': false,
    '30–60 min': false,
    '> 60 min': false,
  };

  void clearAll() {
    setState(() {
      difficultyFilters.updateAll((key, value) => false);
      distanceFilters.updateAll((key, value) => false);
      durationFilters.updateAll((key, value) => false);
    });
  }

  void applyFilters() {
    Navigator.pop(context);
  }

  Widget buildFilterSection(String title, Map<String, bool> filters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.darkHeadlineMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filters.keys.map((key) {
            final selected = filters[key]!;
            return FilterChip(
              label: Text(
                key,
                style: AppTextStyles.chipLabel.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? AppColors.primaryForeground
                      : AppColors.darkPrimaryText,
                ),
              ),
              selected: selected,
              onSelected: (value) {
                setState(() {
                  filters[key] = value;
                });
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.lightSecondary,
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('Filter Routes', style: AppTextStyles.lightHeadlineMedium),
        actions: [
          TextButton(
            onPressed: clearAll,
            child: Text('Clear All', style: AppTextStyles.buttonText),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            buildFilterSection('Difficulty', difficultyFilters),
            buildFilterSection('Distance', distanceFilters),
            buildFilterSection('Duration', durationFilters),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Apply Filters', style: AppTextStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
