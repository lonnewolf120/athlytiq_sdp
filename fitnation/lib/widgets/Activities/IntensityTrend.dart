// lib/widgets/Activities/IntensityTrendChart.dart
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

  // Helper to get the date label for the x-axis
  String _getDateLabel(double value) {
     if (value.toInt() < 0 || value.toInt() >= data.length) return '';
     final date = data[value.toInt()].date;
     return DateFormat('MMM d').format(date); // e.g., May 13
  }
  

  @override
  Widget build(BuildContext context) {
     final textTheme = Theme.of(context).textTheme;

    // Define sideTitles and formattedValue
    final sideTitles = SideTitles(showTitles: true);
    // Correct formattedValue to return a String directly
    final formattedValue = (value) => value.toString();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('Intensity Trend', style: AppTextStyles.headlineSmall?.copyWith(color: AppColors.foreground)),
             const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.5, // Adjust aspect ratio
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true, // Vertical grid lines for dates
                    getDrawingHorizontalLine: (value) {
                       return FlLine(
                         color: AppColors.mutedBackground,
                         strokeWidth: 1,
                         dashArray: [5, 5],
                       );
                     },
                     getDrawingVerticalLine: (value) {
                       return FlLine(
                         color: AppColors.mutedBackground,
                         strokeWidth: 1,
                         dashArray: [5, 5],
                       );
                     },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1, // Show title for every data point
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            fitInside: SideTitleFitInsideData(
                              enabled: true,
                              axisPosition: 0,
                              parentAxisSize: 0,
                              distanceFromEdge: 0,
                            ),
                            meta: TitleMeta(
                              min: 0,
                              max: 60,
                              parentAxisSize:
                                  200, // Adjust based on the chart's height
                              axisPosition: 0, // Default axis position
                              appliedInterval:
                                  10, // Interval for the axis labels
                              sideTitles:
                                  sideTitles, // Use the defined sideTitles
                              // Update TitleMeta usage
                              formattedValue: formattedValue(
                                value,
                              ), // Pass the value to formattedValue
                              axisSide:
                                  AxisSide.bottom, // Specify the axis side
                              rotationQuarterTurns:
                                  0, // No rotation for the labels
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                value.toInt() >= 0 && value.toInt() < data.length
                                    ? DateFormat('EEE').format(data[value.toInt()].date)
                                    : '',
                                style: AppTextStyles.labelSmall?.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 3, // Show titles at intervals (e.g., 0, 3, 6, 9)
                         getTitlesWidget: (value, meta) {
                           if (value == 0 || value == 3 || value == 6 || value == 9) {
                              return Text('${value.toInt()}', style: AppTextStyles.labelSmall?.copyWith(color: AppColors.mutedForeground));
                           }
                           return const SizedBox.shrink();
                         },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: AppColors.mutedBackground, width: 1),
                  ),
                  minX: 0,
                  maxX: data.length > 1 ? data.length - 1.toDouble() : 1, // Ensure maxX is valid
                  minY: 0,
                  maxY: 10, // Assuming intensity is 0-10 scale
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                         int index = entry.key;
                         IntensityTrendData item = entry.value;
                         return FlSpot(index.toDouble(), item.intensity); // Use index as x, intensity as y
                      }).toList(),
                      isCurved: true, // Smooth curve
                      color: AppColors.primary, // Red line
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true), // Show data points
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.3), // Shaded area below line
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}