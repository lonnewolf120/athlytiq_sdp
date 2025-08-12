import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
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
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              drawHorizontalLine: true,
                              horizontalInterval: 500,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.withOpacity(0.3),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() < _weeklyData.length) {
                                      return Text(
                                        _weeklyData[value.toInt()]['day'],
                                        style: TextStyle(fontSize: 12),
                                      );
                                    }
                                    return Text('');
                                  },
                                  reservedSize: 30,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 500,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}',
                                      style: TextStyle(fontSize: 10),
                                    );
                                  },
                                  reservedSize: 40,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            minX: 0,
                            maxX: (_weeklyData.length - 1).toDouble(),
                            minY: 0,
                            maxY: 2600,
                            lineBarsData: [
                              // Actual calories line
                              LineChartBarData(
                                spots:
                                    _weeklyData.asMap().entries.map((entry) {
                                      return FlSpot(
                                        entry.key.toDouble(),
                                        entry.value['calories'].toDouble(),
                                      );
                                    }).toList(),
                                isCurved: true,
                                color: AppColors.darkGradientStart,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (
                                    spot,
                                    percent,
                                    barData,
                                    index,
                                  ) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: AppColors.darkGradientStart,
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.darkGradientStart
                                      .withOpacity(0.1),
                                ),
                              ),
                              // Target calories line
                              LineChartBarData(
                                spots:
                                    _weeklyData.asMap().entries.map((entry) {
                                      return FlSpot(
                                        entry.key.toDouble(),
                                        entry.value['target_calories']
                                            .toDouble(),
                                      );
                                    }).toList(),
                                isCurved: false,
                                color: Colors.orange,
                                barWidth: 2,
                                dashArray: [5, 5],
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
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
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40,
                                  sections: [
                                    PieChartSectionData(
                                      color: Colors.red,
                                      value: _weeklyData.last['protein'],
                                      title:
                                          '${_weeklyData.last['protein'].toStringAsFixed(0)}g',
                                      radius: 50,
                                      titleStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      color: Colors.green,
                                      value: _weeklyData.last['carbs'],
                                      title:
                                          '${_weeklyData.last['carbs'].toStringAsFixed(0)}g',
                                      radius: 50,
                                      titleStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      color: Colors.blue,
                                      value: _weeklyData.last['fat'],
                                      title:
                                          '${_weeklyData.last['fat'].toStringAsFixed(0)}g',
                                      radius: 50,
                                      titleStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
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
