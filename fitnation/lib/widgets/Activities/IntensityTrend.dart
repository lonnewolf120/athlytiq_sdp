// lib/widgets/Activities/IntensityTrendChart.dart
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart'; // For date formatting

// Data structure for intensity trend (e.g., intensity score per workout date)
class IntensityTrendData {
  final DateTime date; // Date of the workout
  final double intensity; // Intensity score

  IntensityTrendData({required this.date, required this.intensity});
}

class IntensityTrendChart extends StatelessWidget {
  final List<IntensityTrendData> data; // Data points for the trend

  const IntensityTrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Intensity Trend',
              style: AppTextStyles.headlineSmall?.copyWith(
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.5,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelStyle: AppTextStyles.labelSmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 10,
                  interval: 3,
                  labelStyle: AppTextStyles.labelSmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                  majorGridLines: const MajorGridLines(width: 1),
                ),
                plotAreaBorderWidth: 1,
                plotAreaBorderColor: AppColors.mutedBackground,
                series: <CartesianSeries<GraphPoint, String>>[
                  SplineSeries<GraphPoint, String>(
                    dataSource:
                        data
                            .asMap()
                            .entries
                            .map(
                              (e) => GraphPoint(
                                DateFormat('EEE').format(e.value.date),
                                e.value.intensity,
                              ),
                            )
                            .toList(),
                    xValueMapper: (p, _) => p.label,
                    yValueMapper: (p, _) => p.value,
                    color: AppColors.primary,
                    width: 2,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      width: 6,
                      height: 6,
                    ),
                    enableTooltip: false,
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

class GraphPoint {
  final String label;
  final double value;
  GraphPoint(this.label, this.value);
}
