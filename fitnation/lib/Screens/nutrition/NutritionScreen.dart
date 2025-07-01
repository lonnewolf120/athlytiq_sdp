import 'package:fitnation/Screens/nutrition/nutrition_quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File
import 'package:fitnation/services/nutrition_ai_service.dart';
import 'package:fitnation/Screens/nutrition/manual_meal_entry_screen.dart';
import 'package:fitnation/Screens/nutrition/nutrition_progress_screen.dart'; // Import NutritionProgressScreen
import 'package:fitnation/models/meal.dart'; // Import Meal model
import 'package:uuid/uuid.dart'; // For generating UUIDs
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:barcode_scan2/barcode_scan2.dart'; // Import barcode_scan2
import 'package:fitnation/models/User.dart'; // Import User model for profile data
import 'package:fitnation/providers/data_providers.dart'; // Import data providers
import 'package:fitnation/providers/nutrition_provider.dart'; // Import nutrition provider

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  File? _pickedImage;
  Map<String, dynamic>? _analysisResult;
  final Uuid _uuid = Uuid();

  // State for targets, now derived from user profile
  double _targetCalories = 0.0;
  double _targetProtein = 0.0;
  double _targetCarbs = 0.0;
  double _targetFat = 0.0;

  @override
  void initState() {
    super.initState();
    // No initial fetch needed here, NutritionProgressScreen will handle it
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTargetsBasedOnUserProfile();
  }

  void _updateTargetsBasedOnUserProfile() {
    final currentUserAsyncValue = ref.watch(currentUserProvider);
    currentUserAsyncValue.whenData((currentUser) {
      if (currentUser != null && currentUser.profile != null) {
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
            'protein_g':
                _analysisResult!['totalProtein'].toDouble(), // Corrected key
            'carbs_g':
                _analysisResult!['totalCarbs'].toDouble(), // Corrected key
            'fat_g': _analysisResult!['totalFat'].toDouble(), // Corrected key
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
      'protein_g': productData['protein'].toDouble(), // Corrected key
      'carbs_g': productData['carbs'].toDouble(), // Corrected key
      'fat_g': productData['fat'].toDouble(), // Corrected key
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
  }

  @override
  Widget build(BuildContext context) {
    final nutritionState = ref.watch(nutritionProvider);
    final currentUserAsyncValue = ref.watch(currentUserProvider);

    return DefaultTabController(
      length: 3, // Overview, Log Meal, Progress
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nutrition'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Log Meal'),
              Tab(text: 'Progress'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Overview Tab Content
            currentUserAsyncValue.when(
              data: (currentUser) {
                if (currentUser == null || currentUser.profile == null) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Please complete your profile to get personalized nutrition targets.',
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const NutritionQuizScreen(),
                              ),
                            ).then(
                              (_) => _updateTargetsBasedOnUserProfile(),
                            ); // Refresh data on return
                          },
                          child: const Text('Complete Nutrition Profile'),
                        ),
                      ],
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Nutrition Targets',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Height: ${currentUser.profile!.height_cm?.toStringAsFixed(1)} cm',
                      ),
                      Text(
                        'Weight: ${currentUser.profile!.weight_kg?.toStringAsFixed(1)} kg',
                      ),
                      Text('Age: ${currentUser.profile!.age}'),
                      Text('Gender: ${currentUser.profile!.gender}'),
                      Text(
                        'Activity Level: ${currentUser.profile!.activity_level}',
                      ),
                      Text(
                        'Fitness Goal: ${currentUser.profile!.fitnessGoals}',
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Daily Targets:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Calories: ${_targetCalories.toStringAsFixed(0)} kcal',
                      ),
                      Text('Protein: ${_targetProtein.toStringAsFixed(1)} g'),
                      Text('Carbs: ${_targetCarbs.toStringAsFixed(1)} g'),
                      Text('Fat: ${_targetFat.toStringAsFixed(1)} g'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NutritionQuizScreen(),
                            ),
                          ).then(
                            (_) => _updateTargetsBasedOnUserProfile(),
                          ); // Refresh data on return
                        },
                        child: const Text('Update Profile/Goals'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Your Food Logs:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      nutritionState is NutritionLoading
                          ? const Center(child: CircularProgressIndicator())
                          : nutritionState is NutritionLoaded
                          ? nutritionState
                                  .foodLogs
                                  .isEmpty // Use foodLogs for overview
                              ? const Text(
                                'No food logs yet. Log your first meal!',
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    nutritionState
                                        .foodLogs
                                        .length, // Use foodLogs
                                itemBuilder: (context, index) {
                                  final log =
                                      nutritionState
                                          .foodLogs[index]; // Use foodLogs
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${log['food_name']} (${log['meal_type']})', // Access dynamic map keys
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Calories: ${log['calories']?.toStringAsFixed(1) ?? 'N/A'} kcal', // Access dynamic map keys
                                          ),
                                          Text(
                                            'Protein: ${log['protein']?.toStringAsFixed(1) ?? 'N/A'} g', // Access dynamic map keys
                                          ),
                                          Text(
                                            'Carbs: ${log['carbs']?.toStringAsFixed(1) ?? 'N/A'} g', // Access dynamic map keys
                                          ),
                                          Text(
                                            'Fat: ${log['fat']?.toStringAsFixed(1) ?? 'N/A'} g', // Access dynamic map keys
                                          ),
                                          Text(
                                            'Date: ${DateTime.parse(log['log_date']).toLocal().toString().split(' ')[0]}', // Access dynamic map keys
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                          : nutritionState is NutritionError
                          ? Text(
                            'Error loading food logs: ${nutritionState.message}', // Changed message back
                          )
                          : const SizedBox.shrink(),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, stack) =>
                      Center(child: Text('Error: ${err.toString()}')),
            ),
            // Log Meal Tab Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Log Meal with Photo (Camera)'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ), // full width
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Log Meal with Photo (Gallery)'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        var result = await BarcodeScanner.scan();
                        if (result.rawContent.isNotEmpty) {
                          print('Scanned barcode: ${result.rawContent}');
                          // No need for local _isLoading, nutritionProvider handles it
                          final productData = await ref
                              .read(foodDatabaseServiceProvider)
                              .getProductByBarcode(result.rawContent);
                          if (productData != null) {
                            _saveScannedMeal(productData);
                          } else {
                            // If product not found, navigate to manual entry screen
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
                                builder:
                                    (context) => ManualMealEntryScreen(
                                      initialMealData: {
                                        'mealName':
                                            'Scanned Barcode: ${result.rawContent}',
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
                      } finally {
                        // No need for local _isLoading, nutritionProvider handles it
                      }
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan Barcode'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManualMealEntryScreen(),
                        ),
                      );
                      if (result != null) {
                        // Assuming manualResult is a Map<String, dynamic> that can be directly logged
                        final foodLogData = {
                          'food_name': result['mealName'],
                          'log_date': DateTime.now().toIso8601String(),
                          'calories': result['totalCalories'],
                          'protein_g': result['totalProtein'], // Corrected key
                          'carbs_g': result['totalCarbs'], // Corrected key
                          'fat_g': result['totalFat'], // Corrected key
                          'meal_type': 'Manual Entry',
                        };
                        await ref
                            .read(nutritionProvider.notifier)
                            .addFoodLog(foodLogData);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Manual meal saved successfully!'),
                          ),
                        );
                        setState(() {
                          _analysisResult = result;
                          _pickedImage =
                              null; // Clear image if manual entry is used
                        });
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Manual Entry'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  if (nutritionState is MealSaving) ...[
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                    const Text('Saving meal...'),
                  ] else if (nutritionState is MealSavedSuccess) ...[
                    const SizedBox(height: 20),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 50,
                    ),
                    const Text('Meal saved!'),
                  ] else if (_pickedImage != null &&
                      _analysisResult != null) ...[
                    const SizedBox(height: 20),
                    Image.file(_pickedImage!, height: 200),
                    const Text('Analysis Result:'),
                    Text(
                      'Total Calories: ${_analysisResult!['totalCalories']}',
                    ),
                    Text('Total Protein: ${_analysisResult!['totalProtein']}g'),
                    Text('Total Carbs: ${_analysisResult!['totalCarbs']}g'),
                    Text('Total Fat: ${_analysisResult!['totalFat']}g'),
                    // Display food items
                    if (_analysisResult!['foodItems'] != null)
                      ...(_analysisResult!['foodItems'] as List)
                          .map(
                            (item) => Text(
                              '${item['name']}: ${item['calories']} kcal',
                            ),
                          )
                          .toList(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ManualMealEntryScreen(
                                  initialMealData: {
                                    'mealName':
                                        'Analyzed Meal', // Placeholder name
                                    'totalCalories':
                                        _analysisResult!['totalCalories'],
                                    'totalProtein':
                                        _analysisResult!['totalProtein'],
                                    'totalCarbs':
                                        _analysisResult!['totalCarbs'],
                                    'totalFat': _analysisResult!['totalFat'],
                                  },
                                ),
                          ),
                        );
                        if (result != null) {
                          // The ManualMealEntryScreen now directly saves via nutritionProvider.notifier.addFoodLog
                          // and returns the data it saved. We just need to update local state if necessary.
                          setState(() {
                            _analysisResult =
                                result
                                    as Map<
                                      String,
                                      dynamic
                                    >; // Cast to Map<String, dynamic>
                          });
                        }
                      },
                      child: const Text('Edit Analysis Results'),
                    ),
                  ] else if (_pickedImage != null) ...[
                    const SizedBox(height: 20),
                    Image.file(_pickedImage!, height: 200),
                    Text(
                      'Image selected: ${_pickedImage!.path.split('/').last}',
                    ),
                  ],
                ],
              ),
            ),
            NutritionProgressScreen(), // Display NutritionProgressScreen in the Progress tab
          ],
        ),
      ),
    );
  }
}
