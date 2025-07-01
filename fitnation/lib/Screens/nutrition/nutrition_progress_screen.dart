import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import 'package:fitnation/api/API_Services.dart';
import 'package:fitnation/api/meal_api_service.dart';
import 'package:fitnation/models/meal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fitnation/providers/auth_provider.dart';

class NutritionProgressScreen extends ConsumerStatefulWidget {
  const NutritionProgressScreen({super.key});

  @override
  ConsumerState<NutritionProgressScreen> createState() => _NutritionProgressScreenState();
}

class _NutritionProgressScreenState extends ConsumerState<NutritionProgressScreen> {
  final MealApiService _mealApiService = MealApiService(ApiService(Dio(), FlutterSecureStorage()));
  List<Meal> _meals = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  Future<void> _fetchMeals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authState = ref.read(authProvider);
      String? userId;
      if (authState is Authenticated) {
        userId = authState.user.id;
      }

      if (userId == null) {
        setState(() {
          _errorMessage = 'User not authenticated.';
          _isLoading = false;
        });
        return;
      }

      final fetchedMeals = await _mealApiService.getMealsForUser();
      setState(() {
        _meals = fetchedMeals;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load meals: $e';
      });
      print('Error fetching meals: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(
              onPressed: _fetchMeals,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_meals.isEmpty) {
      return const Center(child: Text('No meals logged yet.'));
    }

    // Prepare data for charts
    // For simplicity, let's aggregate daily calories for a LineChart
    Map<DateTime, double> dailyCalories = {};
    for (var meal in _meals) {
      final date = DateTime(meal.date.year, meal.date.month, meal.date.day);
      dailyCalories.update(date, (value) => value + meal.totalCalories,
          ifAbsent: () => meal.totalCalories);
    }

    List<FlSpot> spots = [];
    List<DateTime> sortedDates = dailyCalories.keys.toList()..sort();
    for (int i = 0; i < sortedDates.length; i++) {
      spots.add(FlSpot(i.toDouble(), dailyCalories[sortedDates[i]]!));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nutrition Progress',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  minY: 0,
                  maxY: dailyCalories.values.reduce((a, b) => a > b ? a : b) * 1.2, // 20% buffer
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.redAccent,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Recent Meals',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _meals.length,
              itemBuilder: (context, index) {
                final meal = _meals[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${meal.mealType} - ${meal.date.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Calories: ${meal.totalCalories.toStringAsFixed(1)} kcal'),
                        Text('Protein: ${meal.totalProtein.toStringAsFixed(1)}g'),
                        Text('Carbs: ${meal.totalCarbs.toStringAsFixed(1)}g'),
                        Text('Fat: ${meal.totalFat.toStringAsFixed(1)}g'),
                        if (meal.foodItems.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: meal.foodItems
                                .map((item) => Text('  - ${item.name} (${item.calories.toStringAsFixed(0)} kcal)'))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
