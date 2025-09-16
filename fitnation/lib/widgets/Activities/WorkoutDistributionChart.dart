// lib/widgets/Activities/WorkoutDistributionChart.dart
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Data structure for workout distribution (e.g., type and percentage)
class WorkoutDistributionData {
  final String type; // e.g., "Upper Body", "Cardio"
  final double percentage; // Percentage of total workouts

  WorkoutDistributionData({required this.type, required this.percentage});
}

class WorkoutDistributionChart extends StatelessWidget {
  final List<WorkoutDistributionData> data;

  const WorkoutDistributionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Define a color palette for the slices
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
            Text(
              'Workout Distribution',
              style: AppTextStyles.headlineSmall?.copyWith(
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.3, // Adjust aspect ratio
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SfCircularChart(
                      margin: EdgeInsets.zero,
                      legend: const Legend(isVisible: false),
                      series: <DoughnutSeries<WorkoutDistributionData, String>>[
                        DoughnutSeries<WorkoutDistributionData, String>(
                          dataSource: data,
                          xValueMapper: (d, _) => d.type,
                          yValueMapper: (d, _) => d.percentage,
                          pointColorMapper:
                              (d, i) => sliceColors[i! % sliceColors.length],
                          dataLabelMapper:
                              (d, _) =>
                                  d.percentage > 5
                                      ? '${d.percentage.toStringAsFixed(0)}%'
                                      : '',
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                          ),
                          innerRadius: '40%',
                          radius: '90%',
                          explode: false,
                        ),
                      ],
                    ),
                  ),
                  // Legend (Optional - can build a list of colored boxes and text)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          data.asMap().entries.map((entry) {
                            int index = entry.key;
                            WorkoutDistributionData item = entry.value;
                            // Show legend only for slices above a certain percentage
                            if (item.percentage < 5)
                              return const SizedBox.shrink(); // Hide small slices from legend

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          sliceColors[index %
                                              sliceColors.length],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.type,
                                    style: AppTextStyles.bodyMedium?.copyWith(
                                      color: AppColors.foreground,
                                    ),
                                  ),
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
