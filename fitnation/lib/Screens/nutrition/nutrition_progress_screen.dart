import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';

class NutritionProgressScreen extends ConsumerStatefulWidget {
  const NutritionProgressScreen({super.key});

  @override
  ConsumerState<NutritionProgressScreen> createState() =>
      _NutritionProgressScreenState();
}

class _NutritionProgressScreenState
    extends ConsumerState<NutritionProgressScreen> {
  // Dummy progress data
  final List<Map<String, dynamic>> _weeklyData = [
    {
      'day': 'Mon',
      'calories': 2100.0,
      'protein': 120.0,
      'carbs': 200.0,
      'fat': 80.0,
      'target_calories': 2200.0,
    },
    {
      'day': 'Tue',
      'calories': 2250.0,
      'protein': 135.0,
      'carbs': 220.0,
      'fat': 85.0,
      'target_calories': 2200.0,
    },
    {
      'day': 'Wed',
      'calories': 1950.0,
      'protein': 110.0,
      'carbs': 180.0,
      'fat': 75.0,
      'target_calories': 2200.0,
    },
    {
      'day': 'Thu',
      'calories': 2300.0,
      'protein': 140.0,
      'carbs': 240.0,
      'fat': 90.0,
      'target_calories': 2200.0,
    },
    {
      'day': 'Fri',
      'calories': 2150.0,
      'protein': 125.0,
      'carbs': 210.0,
      'fat': 82.0,
      'target_calories': 2200.0,
    },
    {
      'day': 'Sat',
      'calories': 2400.0,
      'protein': 145.0,
      'carbs': 250.0,
      'fat': 95.0,
      'target_calories': 2200.0,
    },
    {
      'day': 'Today',
      'calories': 489.0, // Sum of today's dummy meals
      'protein': 66.5,
      'carbs': 33.0,
      'fat': 8.2,
      'target_calories': 2200.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    // No API calls - using dummy data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nutrition Progress',
          style: AppTextStyles.darkHeadlineMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.darkGradientStart,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekly Calories Chart
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.darkGradientStart.withOpacity(0.1),
                        AppColors.darkGradientEnd.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: AppColors.darkGradientStart,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Weekly Calories Trend',
                            style: AppTextStyles.darkHeadlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            labelStyle: const TextStyle(fontSize: 12),
                          ),
                          primaryYAxis: NumericAxis(
                            minimum: 0,
                            maximum: 2600,
                            interval: 500,
                            labelStyle: const TextStyle(fontSize: 10),
                            majorGridLines: const MajorGridLines(width: 1),
                          ),
                          plotAreaBorderWidth: 1,
                          plotAreaBorderColor: Colors.grey.withOpacity(0.3),
                          series: <CartesianSeries<_XY, String>>[
                            SplineAreaSeries<_XY, String>(
                              dataSource:
                                  _weeklyData
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => _XY(
                                          e.value['day'],
                                          e.value['calories'].toDouble(),
                                        ),
                                      )
                                      .toList(),
                              xValueMapper: (p, _) => p.x,
                              yValueMapper: (p, _) => p.y,
                              color: AppColors.darkGradientStart.withOpacity(
                                0.1,
                              ),
                              borderColor: AppColors.darkGradientStart,
                              borderWidth: 3,
                              markerSettings: const MarkerSettings(
                                isVisible: true,
                                width: 6,
                                height: 6,
                              ),
                            ),
                            LineSeries<_XY, String>(
                              dataSource:
                                  _weeklyData
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => _XY(
                                          e.value['day'],
                                          e.value['target_calories'].toDouble(),
                                        ),
                                      )
                                      .toList(),
                              xValueMapper: (p, _) => p.x,
                              yValueMapper: (p, _) => p.y,
                              color: Colors.orange,
                              width: 2,
                              dashArray: const <double>[5, 5],
                              markerSettings: const MarkerSettings(
                                isVisible: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildLegendItem(
                            'Actual',
                            AppColors.darkGradientStart,
                            true,
                          ),
                          const SizedBox(width: 20),
                          _buildLegendItem('Target', Colors.orange, false),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Nutrition Breakdown
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pie_chart,
                            color: AppColors.darkGradientStart,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Today\'s Macros Breakdown',
                            style: AppTextStyles.darkHeadlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 150,
                              child: SfCircularChart(
                                margin: EdgeInsets.zero,
                                legend: const Legend(isVisible: false),
                                series: <DoughnutSeries<_Macro, String>>[
                                  DoughnutSeries<_Macro, String>(
                                    dataSource: <_Macro>[
                                      _Macro(
                                        'Protein',
                                        _weeklyData.last['protein'].toDouble(),
                                        Colors.red,
                                      ),
                                      _Macro(
                                        'Carbs',
                                        _weeklyData.last['carbs'].toDouble(),
                                        Colors.green,
                                      ),
                                      _Macro(
                                        'Fat',
                                        _weeklyData.last['fat'].toDouble(),
                                        Colors.blue,
                                      ),
                                    ],
                                    xValueMapper: (m, _) => m.name,
                                    yValueMapper: (m, _) => m.value,
                                    pointColorMapper: (m, _) => m.color,
                                    dataLabelMapper:
                                        (m, _) =>
                                            '${m.value.toStringAsFixed(0)}g',
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                    ),
                                    innerRadius: '40%',
                                    radius: '100%',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              children: [
                                _buildMacroItem(
                                  'Protein',
                                  _weeklyData.last['protein'],
                                  Colors.red,
                                  'g',
                                ),
                                const SizedBox(height: 8),
                                _buildMacroItem(
                                  'Carbs',
                                  _weeklyData.last['carbs'],
                                  Colors.green,
                                  'g',
                                ),
                                const SizedBox(height: 8),
                                _buildMacroItem(
                                  'Fat',
                                  _weeklyData.last['fat'],
                                  Colors.blue,
                                  'g',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Daily Averages
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.assessment,
                            color: AppColors.darkGradientStart,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Weekly Averages',
                            style: AppTextStyles.darkHeadlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAverageItem(
                              'Avg Calories',
                              _calculateAverage('calories'),
                              Icons.local_fire_department,
                              Colors.orange,
                              'kcal',
                            ),
                          ),
                          Expanded(
                            child: _buildAverageItem(
                              'Avg Protein',
                              _calculateAverage('protein'),
                              Icons.fitness_center,
                              Colors.red,
                              'g',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAverageItem(
                              'Avg Carbs',
                              _calculateAverage('carbs'),
                              Icons.grain,
                              Colors.green,
                              'g',
                            ),
                          ),
                          Expanded(
                            child: _buildAverageItem(
                              'Avg Fat',
                              _calculateAverage('fat'),
                              Icons.opacity,
                              Colors.blue,
                              'g',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Implementation Note
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.amber.withOpacity(0.1),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber[800]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Using Dummy Data',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This screen shows dummy progress data. Real nutrition tracking will be implemented once the nutrition API is connected.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isSolid) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: isSolid ? color : Colors.transparent,
            border: isSolid ? null : Border.all(color: color, width: 2),
          ),
          child:
              isSolid
                  ? null
                  : Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: color, width: 1),
                    ),
                  ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMacroItem(String label, double value, Color color, String unit) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ${value.toStringAsFixed(1)}$unit',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAverageItem(
    String label,
    double value,
    IconData icon,
    Color color,
    String unit,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateAverage(String nutrient) {
    if (_weeklyData.isEmpty) return 0.0;
    double sum = 0.0;
    for (var day in _weeklyData) {
      sum += day[nutrient].toDouble();
    }
    return sum / _weeklyData.length;
  }
}

class _XY {
  final String x;
  final double y;
  _XY(this.x, this.y);
}

class _Macro {
  final String name;
  final double value;
  final Color color;
  _Macro(this.name, this.value, this.color);
}
