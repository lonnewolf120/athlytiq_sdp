// lib/widgets/Activities/WorkoutDistributionChart.dart
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Data structure for workout distribution (e.g., type and percentage)
class WorkoutDistributionData {
  final String type; // e.g., "Upper Body", "Cardio"
  final double percentage; // Percentage of total workouts

  WorkoutDistributionData({required this.type, required this.percentage});
}

class WorkoutDistributionChart extends StatelessWidget {
  final List<WorkoutDistributionData> data;

  const WorkoutDistributionChart({super.key, required this.data});

  // Helper to generate PieChartSections
  List<PieChartSectionData> _getSections() {
    // Define a color palette for the slices
    final List<Color> sliceColors = [
      AppColors.primary, // Red
      AppColors.primary.withOpacity(0.8),
      AppColors.primary.withOpacity(0.6),
      AppColors.primary.withOpacity(0.4),
      AppColors.primary.withOpacity(0.2),
      AppColors.mutedBackground, // Fallback color
    ];

    return data.asMap().entries.map((entry) {
      int index = entry.key;
      WorkoutDistributionData item = entry.value;
      final isTouched = false; // Implement touch logic if needed
      final double fontSize = isTouched ? 18 : 14;
      final double radius = isTouched ? 60 : 50; // Adjust size on touch

      // Limit percentage text for small slices if needed
      final String percentageText = item.percentage > 5 ? '${item.percentage.toStringAsFixed(0)}%' : '';

      return PieChartSectionData(
        color: sliceColors[index % sliceColors.length], // Cycle through colors
        value: item.percentage,
        title: percentageText,
        radius: radius,
        titleStyle: AppTextStyles.bodyMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.primary, // White text on slices
          shadows: [Shadow(color: Colors.black54, blurRadius: 2)], // Subtle shadow for readability
        ),
        badgeWidget: null, // Add badges if needed
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
     final textTheme = Theme.of(context).textTheme;

    // Define a color palette for the slices (moved from _getSections)
    final List<Color> sliceColors = [
      AppColors.primary, // Red
      AppColors.primary.withOpacity(0.8),
      AppColors.primary.withOpacity(0.6),
      AppColors.primary.withOpacity(0.4),
      AppColors.primary.withOpacity(0.2),
      AppColors.mutedBackground, // Fallback color
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('Workout Distribution', style: AppTextStyles.headlineSmall?.copyWith(color: AppColors.foreground)),
             const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.3, // Adjust aspect ratio
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(enabled: false), // Disable touch for simplicity
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2, // Space between slices
                        centerSpaceRadius: 40, // Inner circle radius
                        sections: _getSections(),
                      ),
                    ),
                  ),
                  // Legend (Optional - can build a list of colored boxes and text)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.asMap().entries.map((entry) {
                         int index = entry.key;
                         WorkoutDistributionData item = entry.value;
                         // Show legend only for slices above a certain percentage
                         if (item.percentage < 5) return const SizedBox.shrink(); // Hide small slices from legend

                         return Padding(
                           padding: const EdgeInsets.symmetric(vertical: 4.0),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Container(
                                 width: 12,
                                 height: 12,
                                 decoration: BoxDecoration(
                                   shape: BoxShape.circle,
                                   color: sliceColors[index % sliceColors.length],
                                 ),
                               ),
                               const SizedBox(width: 8),
                               Text(item.type, style: AppTextStyles.bodyMedium?.copyWith(color: AppColors.foreground)),
                             ],
                           ),
                         );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

