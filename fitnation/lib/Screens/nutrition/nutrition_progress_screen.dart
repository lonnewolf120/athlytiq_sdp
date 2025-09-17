import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:fitnation/providers/nutrition_provider.dart';
import 'package:fitnation/Screens/nutrition/nutrition_targets_screen.dart';
import 'package:fitnation/Screens/nutrition/food_log_screen.dart';

class NutritionProgressScreen extends ConsumerStatefulWidget {
  const NutritionProgressScreen({super.key});

  @override
  ConsumerState<NutritionProgressScreen> createState() =>
      _NutritionProgressScreenState();
}

class _NutritionProgressScreenState
    extends ConsumerState<NutritionProgressScreen> {
  @override
  void initState() {
    super.initState();
    // Load nutrition data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nutritionProvider.notifier).fetchAllNutritionData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Nutrition Progress',
            style: AppTextStyles.darkHeadlineMedium.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.darkGradientStart,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Log Food',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FoodLogScreen(),
                  ),
                );

                // Refresh data if food was logged successfully
                if (result == true) {
                  ref.read(nutritionProvider.notifier).fetchAllNutritionData();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Nutrition Targets',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NutritionTargetsScreen(),
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.today), text: 'Today'),
              Tab(icon: Icon(Icons.show_chart), text: 'Weekly'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildTodayTab(), _buildWeeklyTab()]),
      ),
    );
  }

  Widget _buildTodayTab() {
    return Consumer(
      builder: (context, ref, child) {
        final nutritionState = ref.watch(nutritionProvider);
        final targets = ref.watch(nutritionTargetsProvider);
        final todayProgress = ref.watch(todayProgressProvider);

        if (nutritionState is NutritionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (nutritionState is NutritionError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Failed to load nutrition data',
                  style: AppTextStyles.darkHeadlineSmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  nutritionState.message,
                  style: AppTextStyles.darkBodyMedium.copyWith(
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(nutritionProvider.notifier)
                        .fetchAllNutritionData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGradientStart,
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        // Use default values if no data available
        final currentTargets =
            targets ??
            {
              'target_calories': 2200.0,
              'target_protein': 130.0,
              'target_carbs': 275.0,
              'target_fat': 80.0,
            };

        final currentProgress =
            todayProgress ??
            {
              'total_calories': 1650.0,
              'total_protein': 95.0,
              'total_carbs': 180.0,
              'total_fat': 65.0,
              'entries_count': 4,
            };

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTodayOverview(currentProgress, currentTargets),
              const SizedBox(height: 24),
              _buildMacroProgress(currentProgress, currentTargets),
              const SizedBox(height: 24),
              _buildRecentMeals(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayOverview(
    Map<String, dynamic> progress,
    Map<String, double> targets,
  ) {
    final caloriesProgress = (progress['total_calories'] /
            targets['target_calories']! *
            100)
        .clamp(0, 100);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Progress',
                  style: AppTextStyles.darkHeadlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkGradientStart.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${progress['entries_count']} meals logged',
                    style: AppTextStyles.darkBodySmall.copyWith(
                      color: AppColors.darkGradientStart,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Calorie progress circle
            Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: caloriesProgress / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          caloriesProgress >= 100
                              ? Colors.green
                              : AppColors.darkGradientStart,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${progress['total_calories'].toInt()}',
                              style: AppTextStyles.darkHeadlineMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGradientStart,
                              ),
                            ),
                            Text(
                              'of ${targets['target_calories']!.toInt()}',
                              style: AppTextStyles.darkBodySmall.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'calories',
                              style: AppTextStyles.darkBodySmall.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // Quick stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickStat(
                        'Remaining',
                        '${(targets['target_calories']! - progress['total_calories']).clamp(0, double.infinity).toInt()} cal',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildQuickStat(
                        'Progress',
                        '${caloriesProgress.toInt()}%',
                        Icons.trending_up,
                        Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.darkBodySmall.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: AppTextStyles.darkBodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroProgress(
    Map<String, dynamic> progress,
    Map<String, double> targets,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Macronutrients',
              style: AppTextStyles.darkHeadlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            _buildMacroBar(
              'Protein',
              progress['total_protein'],
              targets['target_protein']!,
              'g',
              Colors.red,
            ),
            const SizedBox(height: 16),

            _buildMacroBar(
              'Carbs',
              progress['total_carbs'],
              targets['target_carbs']!,
              'g',
              Colors.blue,
            ),
            const SizedBox(height: 16),

            _buildMacroBar(
              'Fat',
              progress['total_fat'],
              targets['target_fat']!,
              'g',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBar(
    String name,
    double current,
    double target,
    String unit,
    Color color,
  ) {
    final progress = (current / target * 100).clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: AppTextStyles.darkBodyLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${current.toInt()}/${target.toInt()}$unit',
              style: AppTextStyles.darkBodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress / 100,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${progress.toInt()}%',
          style: AppTextStyles.darkBodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMeals() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Meals',
                  style: AppTextStyles.darkHeadlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FoodLogScreen(),
                      ),
                    );

                    // Refresh data if food was logged successfully
                    if (result == true) {
                      ref
                          .read(nutritionProvider.notifier)
                          .fetchAllNutritionData();
                    }
                  },
                  child: Text(
                    'Log Food',
                    style: AppTextStyles.darkBodyMedium.copyWith(
                      color: AppColors.darkGradientStart,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mock recent meals - replace with real data
            _buildMealItem(
              'Breakfast',
              'Oatmeal with Berries',
              '320 cal',
              '8:00 AM',
            ),
            _buildMealItem(
              'Lunch',
              'Grilled Chicken Salad',
              '450 cal',
              '12:30 PM',
            ),
            _buildMealItem('Snack', 'Greek Yogurt', '150 cal', '3:00 PM'),
            _buildMealItem('Dinner', 'Salmon with Rice', '520 cal', '7:00 PM'),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(
    String mealType,
    String foodName,
    String calories,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.darkGradientStart,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$mealType • $time',
                  style: AppTextStyles.darkBodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  foodName,
                  style: AppTextStyles.darkBodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            calories,
            style: AppTextStyles.darkBodyMedium.copyWith(
              color: AppColors.darkGradientStart,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab() {
    return Consumer(
      builder: (context, ref, child) {
        final foodLogs = ref.watch(foodLogsListProvider);

        // Generate weekly chart data from food logs
        final weeklyData = _generateWeeklyChartData(foodLogs);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWeeklyChart(weeklyData),
              const SizedBox(height: 24),
              _buildWeeklySummary(weeklyData),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _generateWeeklyChartData(List<dynamic> foodLogs) {
    // Mock weekly data for now - replace with actual calculation from foodLogs
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];

      return {
        'day': dayName,
        'date': date,
        'calories': 1800 + (index * 50) + (index % 2 == 0 ? 200 : 0),
        'protein': 100 + (index * 5),
        'carbs': 180 + (index * 10),
        'fat': 60 + (index * 3),
        'target_calories': 2200.0,
      };
    });
  }

  Widget _buildWeeklyChart(List<Map<String, dynamic>> weeklyData) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Calorie Intake',
              style: AppTextStyles.darkHeadlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                ),
                plotAreaBorderWidth: 0,
                series: <CartesianSeries>[
                  ColumnSeries<Map<String, dynamic>, String>(
                    dataSource: weeklyData,
                    xValueMapper: (data, _) => data['day'],
                    yValueMapper: (data, _) => data['calories'],
                    color: AppColors.darkGradientStart,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  LineSeries<Map<String, dynamic>, String>(
                    dataSource: weeklyData,
                    xValueMapper: (data, _) => data['day'],
                    yValueMapper: (data, _) => data['target_calories'],
                    color: Colors.red,
                    dashArray: const [5, 5],
                    width: 2,
                    markerSettings: const MarkerSettings(isVisible: false),
                  ),
                ],
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummary(List<Map<String, dynamic>> weeklyData) {
    final totalCalories = weeklyData.fold<double>(
      0,
      (sum, day) => sum + day['calories'],
    );
    final avgCalories = totalCalories / weeklyData.length;
    final targetCalories = weeklyData.first['target_calories'];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Summary',
              style: AppTextStyles.darkHeadlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Calories',
                    '${totalCalories.toInt()}',
                    'cal',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Daily Average',
                    '${avgCalories.toInt()}',
                    'cal',
                    Icons.analytics,
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Target Goal',
                    '${targetCalories.toInt()}',
                    'cal/day',
                    Icons.track_changes,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Performance',
                    '${((avgCalories / targetCalories) * 100).toInt()}',
                    '%',
                    Icons.trending_up,
                    (avgCalories / targetCalories) >= 0.9
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.darkBodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: value,
              style: AppTextStyles.darkHeadlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: AppTextStyles.darkBodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
