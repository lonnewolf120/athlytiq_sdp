/*
import 'package:fitnation/Screens/nutrition/nutrition_quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File
import 'package:fitnation/services/nutrition_ai_service.dart';
import 'package:fitnation/Screens/nutrition/manual_meal_entry_screen.dart';
import 'package:fitnation/Screens/nutrition/nutrition_progress_screen.dart'; // Import NutritionProgressScreen
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:barcode_scan2/barcode_scan2.dart'; // Import barcode_scan2
import 'package:fitnation/providers/data_providers.dart'; // Import data providers
import 'package:fitnation/providers/nutrition_provider.dart'; // Import nutrition provider
import 'package:fitnation/core/themes/colors.dart'; // Import AppColors
import 'package:fitnation/core/themes/text_styles.dart'; // Import AppTextStyles

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  File? _pickedImage;
  Map<String, dynamic>? _analysisResult;

  // State for targets, now derived from user profile
  double _targetCalories = 0.0;
  double _targetProtein = 0.0;
  double _targetCarbs = 0.0;
  double _targetFat = 0.0;

  @override
  void initState() {
    super.initState();
    // Initial fetch of nutrition data when the screen loads
    // Deferring the call to avoid modifying provider during widget build
    Future.microtask(
      () => ref.read(nutritionProvider.notifier).fetchAllNutritionData(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTargetsBasedOnUserProfile();
  }

  void _updateTargetsBasedOnUserProfile() {
    final currentUserAsyncValue = ref.watch(currentUserProvider);
    currentUserAsyncValue.whenData((currentUser) {
      if (currentUser.profile != null) {
        setState(() {
          _targetCalories = _calculateTargetCalories(
            currentUser.profile!.weight_kg ?? 0,
            currentUser.profile!.height_cm ?? 0,
            currentUser.profile!.age ?? 0,
            currentUser.profile!.gender ?? 'Male',
            currentUser.profile!.activity_level ?? 'Moderate',
            currentUser.profile!.fitnessGoals ?? 'Maintain Weight',
          );
          _targetProtein =
              _targetCalories *
              0.25 /
              4; // 25% calories from protein (4 kcal/g)
          _targetCarbs =
              _targetCalories * 0.45 / 4; // 45% calories from carbs (4 kcal/g)
          _targetFat =
              _targetCalories * 0.30 / 9; // 30% calories from fat (9 kcal/g)
        });
      }
    });
  }

  double _calculateTargetCalories(
    double weight,
    double height,
    int age,
    String gender,
    String activityLevel,
    String goal,
  ) {
    // Simplified BMR calculation (Mifflin-St Jeor Equation)
    double bmr;
    if (gender == 'Male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Activity factor
    double activityFactor;
    switch (activityLevel) {
      case 'Sedentary (little or no exercise)':
        activityFactor = 1.2;
        break;
      case 'Lightly Active (light exercise/sports 1-3 days/week)':
        activityFactor = 1.375;
        break;
      case 'Moderate (moderate exercise/sports 3-5 days/week)':
        activityFactor = 1.55;
        break;
      case 'Very Active (hard exercise/sports 6-7 days a week)':
        activityFactor = 1.725;
        break;
      case 'Extra Active (very hard exercise/physical job)':
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.55;
    }

    double tdee = bmr * activityFactor; // Total Daily Energy Expenditure

    // Adjust for goal
    switch (goal) {
      case 'Lose Weight':
        tdee -= 500; // Deficit for weight loss
        break;
      case 'Gain Weight':
        tdee += 500; // Surplus for weight gain
        break;
      case 'Build Muscle':
        tdee += 300; // Moderate surplus for muscle gain
        break;
      default: // Maintain Weight, Improve Endurance
        break;
    }
    return tdee;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
        _analysisResult = null; // Clear previous results
      });

      try {
        final nutritionAIService = ref.read(nutritionAiServiceProvider);
        final result = await nutritionAIService.analyzeImage(_pickedImage!);
        setState(() {
          _analysisResult = result;
        });
        print('Analysis Result: $_analysisResult');

        if (_analysisResult != null) {
          // Prepare data for FoodLogCreate schema
          final foodLogData = {
            'food_name': 'Photo Analysis Meal', // A generic name for the meal
            'log_date': DateTime.now().toIso8601String(),
            'calories': _analysisResult!['totalCalories'].toDouble(),
            'protein': _analysisResult!['totalProtein'].toDouble(),
            'carbs': _analysisResult!['totalCarbs'].toDouble(),
            'fat': _analysisResult!['totalFat'].toDouble(),
            'meal_type': 'Photo Analysis',
            // You might want to add individual food items as a JSONB field in FoodLog if needed
          };

          try {
            await ref.read(nutritionProvider.notifier).addFoodLog(foodLogData);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Meal saved successfully!')),
            );
          } catch (e) {
            print('Error saving meal from photo analysis: $e');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error saving meal: $e')));
          }
        }
      } catch (e) {
        // Outer catch block
        print('Error analyzing image or saving meal: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing image or saving meal: $e')),
        );
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> _saveScannedMeal(Map<String, dynamic> productData) async {
    // Prepare data for FoodLogCreate schema
    final foodLogData = {
      'food_name': productData['name'],
      'log_date': DateTime.now().toIso8601String(),
      'calories': productData['calories'].toDouble(),
      'protein': productData['protein'].toDouble(),
      'carbs': productData['carbs'].toDouble(),
      'fat': productData['fat'].toDouble(),
      'serving_size': productData['serving_size'],
      'meal_type': 'Barcode Scan',
      'external_food_id':
          productData['barcode'], // Assuming barcode is the external ID
    };

    try {
      await ref.read(nutritionProvider.notifier).addFoodLog(foodLogData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal from barcode scan saved successfully!'),
        ),
      );
    } catch (e) {
      print('Error saving meal from barcode scan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving meal from barcode scan: $e')),
    );
  }

  // Helper method to build target nutrition items
  Widget _buildTargetItem(String label, String value, IconData icon, Color color) {
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
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build log option buttons
  Widget _buildLogOption(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build nutrient rows in analysis results
  Widget _buildNutrientRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build food log items
  Widget _buildFoodLogItem(Map<String, dynamic> log) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  log['food_name'] ?? 'Unknown Food',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkGradientStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  log['meal_type'] ?? 'N/A',
                  style: TextStyle(
                    color: AppColors.darkGradientStart,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildNutrientRow(
                  'Cal',
                  '${log['calories']?.toStringAsFixed(0) ?? 'N/A'} kcal',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildNutrientRow(
                  'Protein',
                  '${log['protein']?.toStringAsFixed(1) ?? 'N/A'} g',
                  Icons.fitness_center,
                  Colors.red,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildNutrientRow(
                  'Carbs',
                  '${log['carbs']?.toStringAsFixed(1) ?? 'N/A'} g',
                  Icons.grain,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildNutrientRow(
                  'Fat',
                  '${log['fat']?.toStringAsFixed(1) ?? 'N/A'} g',
                  Icons.opacity,
                  Colors.blue,
                ),
              ),
            ],
          ),
          if (log['log_date'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'Logged: ${DateTime.parse(log['log_date']).toLocal().toString().split(' ')[0]}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Method to handle barcode scanning
  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        print('Scanned barcode: ${result.rawContent}');
        final productData = await ref
            .read(foodDatabaseServiceProvider)
            .getProductByBarcode(result.rawContent);
        if (productData != null) {
          _saveScannedMeal(productData);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Product not found for scanned barcode. Please enter manually.',
              ),
            ),
          );
          final manualResult = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManualMealEntryScreen(
                initialMealData: {
                  'mealName': 'Scanned Barcode: ${result.rawContent}',
                  'totalCalories': 0.0,
                  'totalProtein': 0.0,
                  'totalCarbs': 0.0,
                  'totalFat': 0.0,
                },
              ),
            ),
          );
          if (manualResult != null) {
            setState(() {
              _analysisResult = manualResult;
              _pickedImage = null;
            });
          }
        }
      }
    } catch (e) {
      print('Error scanning barcode: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning barcode: $e')),
      );
    }
  }

  // Method to handle manual entry
  Future<void> _manualEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManualMealEntryScreen(),
      ),
    );
    if (result != null) {
      final foodLogData = {
        'food_name': result['mealName'],
        'log_date': DateTime.now().toIso8601String(),
        'calories': result['totalCalories'],
        'protein': result['totalProtein'],
        'carbs': result['totalCarbs'],
        'fat': result['totalFat'],
        'meal_type': 'Manual Entry',
      };
      await ref.read(nutritionProvider.notifier).addFoodLog(foodLogData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Manual meal saved successfully!'),
        ),
      );
      setState(() {
        _analysisResult = result;
        _pickedImage = null;
      });
    }
  }

  // Method to edit analysis results
  Future<void> _editAnalysisResults() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualMealEntryScreen(
          initialMealData: {
            'mealName': 'Analyzed Meal',
            'totalCalories': _analysisResult!['totalCalories'],
            'totalProtein': _analysisResult!['totalProtein'],
            'totalCarbs': _analysisResult!['totalCarbs'],
            'totalFat': _analysisResult!['totalFat'],
          },
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _analysisResult = result as Map<String, dynamic>;
      });
    }
  }
}  @override
  Widget build(BuildContext context) {
    final nutritionState = ref.watch(nutritionProvider);
    final currentUserAsyncValue = ref.watch(currentUserProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header with Gradient
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkGradientStart,
                    AppColors.darkGradientEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/logos/logo.png',
                              height: 30,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Diet',
                              style: AppTextStyles.darkHeadlineLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NutritionQuizScreen(),
                              ),
                            ).then((_) => _updateTargetsBasedOnUserProfile());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Handle previous day
                          },
                        ),
                        Column(
                          children: [
                            Text(
                              'Today',
                              style: AppTextStyles.darkBodyLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'July 28, 2025',
                              style: AppTextStyles.darkBodyMedium.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Handle next day
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Nutrition Targets Card
                  currentUserAsyncValue.when(
                    data: (currentUser) {
                      if (currentUser.profile == null) {
                        return Card(
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
                                      Icons.person_outline,
                                      color: AppColors.darkGradientStart,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Complete Your Profile',
                                      style: AppTextStyles.darkHeadlineMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Get personalized nutrition targets based on your goals, activity level, and body metrics.',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const NutritionQuizScreen(),
                                        ),
                                      ).then((_) => _updateTargetsBasedOnUserProfile());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.darkGradientStart,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text('Complete Profile'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Card(
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
                                    Icons.track_changes,
                                    color: AppColors.darkGradientStart,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Daily Targets',
                                    style: AppTextStyles.darkHeadlineMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTargetItem(
                                      'Calories',
                                      '${_targetCalories.toStringAsFixed(0)} kcal',
                                      Icons.local_fire_department,
                                      Colors.orange,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildTargetItem(
                                      'Protein',
                                      '${_targetProtein.toStringAsFixed(1)} g',
                                      Icons.fitness_center,
                                      Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTargetItem(
                                      'Carbs',
                                      '${_targetCarbs.toStringAsFixed(1)} g',
                                      Icons.grain,
                                      Colors.green,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildTargetItem(
                                      'Fat',
                                      '${_targetFat.toStringAsFixed(1)} g',
                                      Icons.opacity,
                                      Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error: ${err.toString()}'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Log Meal Card
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
                                Icons.restaurant,
                                color: AppColors.darkGradientStart,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Log Your Meal',
                                style: AppTextStyles.darkHeadlineMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Meal Logging Options
                          Row(
                            children: [
                              Expanded(
                                child: _buildLogOption(
                                  'Camera',
                                  Icons.camera_alt,
                                  Colors.blue,
                                  () => _pickImage(ImageSource.camera),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildLogOption(
                                  'Gallery',
                                  Icons.photo_library,
                                  Colors.green,
                                  () => _pickImage(ImageSource.gallery),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildLogOption(
                                  'Barcode',
                                  Icons.qr_code_scanner,
                                  Colors.orange,
                                  () => _scanBarcode(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildLogOption(
                                  'Manual',
                                  Icons.edit,
                                  Colors.purple,
                                  () => _manualEntry(),
                                ),
                              ),
                            ],
                          ),

                          // Show meal saving status
                          if (nutritionState is MealSaving) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.darkGradientStart,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('Saving meal...'),
                              ],
                            ),
                          ] else if (nutritionState is MealSavedSuccess) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Meal saved successfully!',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ],

                          // Show image analysis results
                          if (_pickedImage != null && _analysisResult != null) ...[
                            const SizedBox(height: 16),
                            Divider(),
                            const SizedBox(height: 16),
                            Text(
                              'Analysis Results',
                              style: AppTextStyles.darkHeadlineMedium,
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _pickedImage!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  _buildNutrientRow('Calories', '${_analysisResult!['totalCalories']} kcal', Icons.local_fire_department, Colors.orange),
                                  _buildNutrientRow('Protein', '${_analysisResult!['totalProtein']}g', Icons.fitness_center, Colors.red),
                                  _buildNutrientRow('Carbs', '${_analysisResult!['totalCarbs']}g', Icons.grain, Colors.green),
                                  _buildNutrientRow('Fat', '${_analysisResult!['totalFat']}g', Icons.opacity, Colors.blue),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _editAnalysisResults(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.darkGradientStart,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Edit Results'),
                              ),
                            ),
                          ] else if (_pickedImage != null) ...[
                            const SizedBox(height: 16),
                            Divider(),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _pickedImage!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Analyzing image...',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Food Logs Card
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    color: AppColors.darkGradientStart,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Today\'s Food Logs',
                                    style: AppTextStyles.darkHeadlineMedium,
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NutritionProgressScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'View Progress',
                                  style: TextStyle(color: AppColors.darkGradientStart),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          nutritionState is NutritionLoading
                              ? const Center(child: CircularProgressIndicator())
                              : nutritionState is NutritionLoaded
                              ? nutritionState.foodLogs.isEmpty
                                  ? Column(
                                      children: [
                                        Icon(
                                          Icons.no_meals,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No meals logged today',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Start logging your meals above!',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: nutritionState.foodLogs.length,
                                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                                      itemBuilder: (context, index) {
                                        final log = nutritionState.foodLogs[index];
                                        return _buildFoodLogItem(log);
                                      },
                                    )
                              : nutritionState is NutritionError
                              ? Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Error loading food logs',
                                      style: TextStyle(color: Colors.red[600]),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      nutritionState.message,
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
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
}
*/
