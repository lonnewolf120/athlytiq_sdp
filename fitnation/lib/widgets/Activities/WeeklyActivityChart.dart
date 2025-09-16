// lib/widgets/Activities/WeeklyActivityChart.dart
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelStyle: AppTextStyles.labelSmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 120,
                  interval: 30,
                  labelStyle: AppTextStyles.labelSmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                  majorGridLines: const MajorGridLines(width: 1),
                ),
                plotAreaBorderWidth: 0,
                series: <CartesianSeries<WeeklyActivityData, String>>[
                  ColumnSeries<WeeklyActivityData, String>(
                    dataSource: paddedData,
                    xValueMapper: (d, _) => DateFormat('EEE').format(d.date),
                    yValueMapper: (d, _) => d.minutes,
                    pointColorMapper: (d, _) => AppColors.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    width: 0.6,
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
