// lib/widgets/Activities/WeeklyActivityChart.dart
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeeklyActivityData {
  final DateTime date;
  final double minutes;

  WeeklyActivityData({required this.date, required this.minutes});
}

class WeeklyActivityChart extends StatelessWidget {
  final List<WeeklyActivityData> data;

  const WeeklyActivityChart({super.key, required this.data});

  String _getWeekdayLabel(double value) {
    if (value.toInt() < 0 || value.toInt() >= data.length) return '';
    final date = data[value.toInt()].date;
    return DateFormat('EEE').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final List<WeeklyActivityData> paddedData = List.generate(7, (index) {
      if (index < data.length) return data[index];
      return WeeklyActivityData(
        date: DateTime.now().subtract(Duration(days: 6 - index)),
        minutes: 0,
      );
    });

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Activity',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, // Fixed height to prevent overflow
              child: AspectRatio(
                aspectRatio: 3.0, // Slightly increased for better fit
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 120,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < 0 ||
                                value.toInt() >= data.length)
                              return const SizedBox.shrink();
                            final date = data[value.toInt()].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                DateFormat('EEE').format(date),
                                style: AppTextStyles.labelSmall?.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value == 0 || value == 30 || value == 60) {
                              return Text(
                                '${value.toInt()}',
                                style: AppTextStyles.labelSmall?.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          reservedSize: 30,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups:
                        data.asMap().entries.map((entry) {
                          int index = entry.key;
                          WeeklyActivityData dayData = entry.value;
                          return BarChartGroupData(
                            x: index,
                            groupVertically: true,
                            barRods: [
                              BarChartRodData(
                                toY: dayData.minutes,
                                color: AppColors.primary,
                                width:
                                    12, // Reduced bar width for better spacing
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                            showingTooltipIndicators: [],
                          );
                        }).toList(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppColors.mutedBackground,
                          strokeWidth: 1,
                          dashArray: [10, 10],
                        );
                      },
                      drawHorizontalLine: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
