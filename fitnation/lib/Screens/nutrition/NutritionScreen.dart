import 'package:fitnation/Screens/nutrition/nutrition_quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File
import 'package:fitnation/Screens/nutrition/manual_meal_entry_screen.dart';
import 'package:fitnation/Screens/nutrition/nutrition_progress_screen.dart'; // Import NutritionProgressScreen
import 'package:fitnation/Screens/nutrition/meal_plans_screen.dart'; // Import MealPlansScreen
import 'package:fitnation/Screens/nutrition/all_food_logs_screen.dart'; // Import AllFoodLogsScreen
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:barcode_scan2/barcode_scan2.dart'; // Import barcode_scan2
import 'package:fitnation/core/themes/colors.dart'; // Import AppColors
import 'package:fitnation/core/themes/text_styles.dart'; // Import AppTextStyles
import 'package:fitnation/providers/auth_provider.dart' as auth_provider;
import 'package:fitnation/providers/theme_provider.dart';
import 'package:fitnation/Screens/ProfileScreen.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  File? _pickedImage;
  Map<String, dynamic>? _analysisResult;

  // State for targets, now derived from user profile
  double _targetCalories = 2200.0; // Dummy data
  double _targetProtein = 137.5; // Dummy data
  double _targetCarbs = 247.5; // Dummy data
  double _targetFat = 73.3; // Dummy data

  // Dummy food logs data
  List<Map<String, dynamic>> _dummyFoodLogs = [
    // Today's meals (July 29, 2025)
    {
      'food_name': 'Grilled Chicken Breast',
      'meal_type': 'Lunch',
      'calories': 231.0,
      'protein': 43.5,
      'carbs': 0.0,
      'fat': 5.0,
      'log_date': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
    },
    {
      'food_name': 'Oatmeal with Berries',
      'meal_type': 'Breakfast',
      'calories': 158.0,
      'protein': 6.0,
      'carbs': 27.0,
      'fat': 3.2,
      'log_date': DateTime.now().subtract(Duration(hours: 6)).toIso8601String(),
    },
    {
      'food_name': 'Greek Yogurt',
      'meal_type': 'Snack',
      'calories': 100.0,
      'protein': 17.0,
      'carbs': 6.0,
      'fat': 0.0,
      'log_date': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
    },

    // Yesterday's meals (July 28, 2025)
    {
      'food_name': 'Salmon Fillet with Rice',
      'meal_type': 'Dinner',
      'calories': 450.0,
      'protein': 35.0,
      'carbs': 45.0,
      'fat': 18.0,
      'log_date':
          DateTime.now()
              .subtract(Duration(days: 1, hours: 3))
              .toIso8601String(),
    },
    {
      'food_name': 'Avocado Toast',
      'meal_type': 'Breakfast',
      'calories': 280.0,
      'protein': 8.5,
      'carbs': 24.0,
      'fat': 18.5,
      'log_date':
          DateTime.now()
              .subtract(Duration(days: 1, hours: 18))
              .toIso8601String(),
    },
    {
      'food_name': 'Caesar Salad',
      'meal_type': 'Lunch',
      'calories': 320.0,
      'protein': 12.0,
      'carbs': 15.0,
      'fat': 25.0,
      'log_date':
          DateTime.now()
              .subtract(Duration(days: 1, hours: 8))
              .toIso8601String(),
    },
    {
      'food_name': 'Mixed Nuts',
      'meal_type': 'Snack',
      'calories': 170.0,
      'protein': 6.0,
      'carbs': 6.0,
      'fat': 15.0,
      'log_date':
          DateTime.now()
              .subtract(Duration(days: 1, hours: 5))
              .toIso8601String(),
    },

    // Day before yesterday's meals (July 27, 2025)
    {
      'food_name': 'Beef Stir Fry',
      'meal_type': 'Dinner',
      'calories': 380.0,
      'protein': 28.0,
      'carbs': 22.0,
      'fat': 20.0,
      'log_date':
          DateTime.now()
              .subtract(Duration(days: 2, hours: 2))
              .toIso8601String(),
    },
    {
      'food_name': 'Protein Smoothie',
      'meal_type': 'Breakfast',
      'calories': 250.0,
      'protein': 25.0,
      'carbs': 30.0,
      'fat': 5.0,
      'log_date':
          DateTime.now()
              .subtract(Duration(days: 2, hours: 17))
              .toIso8601String(),
    },
    {
      'food_name': 'Turkey Sandwich',
      'meal_type': 'Lunch',
      'calories': 420.0,
      'protein': 32.0,
      'carbs': 35.0,
      'fat': 18.0,
      'log_date':
          DateTime.now()
              .subtract(Duration(days: 2, hours: 9))
              .toIso8601String(),
    },
    {
      'food_name': 'Apple with Peanut Butter',
      'meal_type': 'Snack',
      'calories': 190.0,
      'protein': 8.0,
      'carbs': 20.0,
      'fat': 10.0,
      'log_date':
          DateTime.now()
              .subtract(Duration(days: 2, hours: 6))
              .toIso8601String(),
    },
    {
      'food_name': 'Dark Chocolate',
      'meal_type': 'Snack',
      'calories': 80.0,
      'protein': 1.5,
      'carbs': 8.0,
      'fat': 5.5,
      'log_date':
          DateTime.now()
              .subtract(Duration(days: 2, hours: 4))
              .toIso8601String(),
    },
  ];

  // Mock states for UI testing
  bool _isLoading = false;
  bool _mealSaved = false;

  // Helper method to get today's food logs
  List<Map<String, dynamic>> get _todaysFoodLogs {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(Duration(days: 1));

    return _dummyFoodLogs.where((log) {
      final logDate = DateTime.parse(log['log_date']);
      return logDate.isAfter(todayStart) && logDate.isBefore(todayEnd);
    }).toList();
  }

  // Helper method to format log date with relative time
  String _formatLogDate(String dateString) {
    final logDate = DateTime.parse(dateString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logDay = DateTime(logDate.year, logDate.month, logDate.day);

    final difference = today.difference(logDay).inDays;

    if (difference == 0) {
      // Today - show time
      final hour = logDate.hour;
      final minute = logDate.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return 'Today at $displayHour:$minute $period';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference <= 7) {
      return '$difference days ago';
    } else {
      return '${logDate.month}/${logDate.day}/${logDate.year}';
    }
  }

  @override
  void initState() {
    super.initState();
    // Initial fetch of nutrition data when the screen loads
    // Deferring the call to avoid modifying provider during widget build
    // Future.microtask(
    //   () => ref.read(nutritionProvider.notifier).fetchAllNutritionData(),
    // );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _updateTargetsBasedOnUserProfile();
  }

  void _updateTargetsBasedOnUserProfile() {
    // Commented out for dummy data implementation
    // final currentUserAsyncValue = ref.watch(currentUserProvider);
    // currentUserAsyncValue.whenData((currentUser) {
    //   if (currentUser.profile != null) {
    //     setState(() {
    //       _targetCalories = _calculateTargetCalories(
    //         currentUser.profile!.weight_kg ?? 0,
    //         currentUser.profile!.height_cm ?? 0,
    //         currentUser.profile!.age ?? 0,
    //         currentUser.profile!.gender ?? 'Male',
    //         currentUser.profile!.activity_level ?? 'Moderate',
    //         currentUser.profile!.fitnessGoals ?? 'Maintain Weight',
    //       );
    //       _targetProtein =
    //           _targetCalories *
    //           0.25 /
    //           4; // 25% calories from protein (4 kcal/g)
    //       _targetCarbs =
    //           _targetCalories * 0.45 / 4; // 45% calories from carbs (4 kcal/g)
    //       _targetFat =
    //           _targetCalories * 0.30 / 9; // 30% calories from fat (9 kcal/g)
    //     });
    //   }
    // });
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
        // Commented out AI service call - using dummy data for now
        // final nutritionAIService = ref.read(nutritionAiServiceProvider);
        // final result = await nutritionAIService.analyzeImage(_pickedImage!);

        // Mock analysis result for testing
        final result = {
          'totalCalories': 320,
          'totalProtein': 25.5,
          'totalCarbs': 12.0,
          'totalFat': 18.5,
        };

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
            // Commented out API call - using dummy data for now
            // await ref.read(nutritionProvider.notifier).addFoodLog(foodLogData);
            setState(() {
              _dummyFoodLogs.insert(0, foodLogData);
            });
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
      // Commented out API call - using dummy data for now
      // await ref.read(nutritionProvider.notifier).addFoodLog(foodLogData);
      setState(() {
        _dummyFoodLogs.insert(0, foodLogData);
      });
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
    // Commented out provider watchers - using dummy data for now
    // final nutritionState = ref.watch(nutritionProvider);
    // final currentUserAsyncValue = ref.watch(currentUserProvider);

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
                            // Builder(
                            //   builder:
                            //       (context) => IconButton(
                            //         icon: const Icon(
                            //           Icons.menu,
                            //           color: Colors.white,
                            //         ),
                            //         onPressed:
                            //             () => Scaffold.of(context).openDrawer(),
                            //       ),
                            // ),
                            Image.asset('assets/logos/logo.png', height: 48),
                            const SizedBox(width: 8),
                            Text(
                              'Diet',
                              style: AppTextStyles.darkHeadlineLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.restaurant_menu,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const MealPlansScreen(),
                                  ),
                                );
                              },
                              tooltip: 'My Meal Plans',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const NutritionQuizScreen(),
                                  ),
                                ).then(
                                  (_) => _updateTargetsBasedOnUserProfile(),
                                );
                              },
                              tooltip: 'Nutrition Settings',
                            ),
                            // Profile PopupMenuButton
                            PopupMenuButton<String>(
                              child: Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    final currentUser = ref.watch(
                                      auth_provider.currentUserProvider,
                                    );
                                    return ClipOval(
                                      child:
                                          currentUser?.avatarUrl != null
                                              ? Image.network(
                                                currentUser!.avatarUrl,
                                                width: 36,
                                                height: 36,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                              )
                                              : Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                    );
                                  },
                                ),
                              ),
                              onSelected:
                                  (String value) =>
                                      _handleMenuSelection(context, value),
                              itemBuilder:
                                  (BuildContext context) => [
                                    PopupMenuItem<String>(
                                      value: 'profile',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          ),
                                          const SizedBox(width: 12),
                                          const Text('Profile'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'reminders',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.notifications,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          ),
                                          const SizedBox(width: 12),
                                          const Text('Reminders'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'notifications',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.notification_important,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          ),
                                          const SizedBox(width: 12),
                                          const Text('Notifications'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'settings',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.settings,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          ),
                                          const SizedBox(width: 12),
                                          const Text('Settings'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'themes',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.palette,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          ),
                                          const SizedBox(width: 12),
                                          const Text('Themes'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuDivider(),
                                    PopupMenuItem<String>(
                                      value: 'logout',
                                      child: Row(
                                        children: [
                                          Icon(Icons.logout, color: Colors.red),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Logout',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                            ),
                          ],
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
                              'July 29, 2025',
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
                  // Nutrition Targets Card - using dummy data
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

                          const SizedBox(height: 16),
                          Divider(color: Colors.grey[300]),
                          const SizedBox(height: 16),

                          // Generate Meal Plan Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.darkGradientStart.withOpacity(0.1),
                                  AppColors.darkGradientEnd.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.darkGradientStart.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      color: AppColors.darkGradientStart,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'AI Meal Planning',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  AppColors.darkGradientStart,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Get personalized meal plans based on your goals',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _generateMealPlan(),
                                    icon: Icon(Icons.restaurant_menu, size: 20),
                                    label: Text('Generate Meal Plan'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.darkGradientStart,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Show meal saving status - using dummy states
                          if (_isLoading) ...[
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
                          ] else if (_mealSaved) ...[
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
                          if (_pickedImage != null &&
                              _analysisResult != null) ...[
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
                                  _buildNutrientRow(
                                    'Calories',
                                    '${_analysisResult!['totalCalories']} kcal',
                                    Icons.local_fire_department,
                                    Colors.orange,
                                  ),
                                  _buildNutrientRow(
                                    'Protein',
                                    '${_analysisResult!['totalProtein']}g',
                                    Icons.fitness_center,
                                    Colors.red,
                                  ),
                                  _buildNutrientRow(
                                    'Carbs',
                                    '${_analysisResult!['totalCarbs']}g',
                                    Icons.grain,
                                    Colors.green,
                                  ),
                                  _buildNutrientRow(
                                    'Fat',
                                    '${_analysisResult!['totalFat']}g',
                                    Icons.opacity,
                                    Colors.blue,
                                  ),
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
                                    'Today',
                                    style: AppTextStyles.darkHeadlineMedium,
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              NutritionProgressScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'View Progress',
                                  style: TextStyle(
                                    color: AppColors.darkGradientStart,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Using dummy food logs instead of provider state - show only today's meals
                          _todaysFoodLogs.isEmpty
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
                              : Column(
                                children: [
                                  // Show only first 2 logs
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        _todaysFoodLogs.length > 2
                                            ? 2
                                            : _todaysFoodLogs.length,
                                    separatorBuilder:
                                        (context, index) =>
                                            const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final log = _todaysFoodLogs[index];
                                      return _buildFoodLogItem(log);
                                    },
                                  ),

                                  // Show "View All Logs" button if there are more than 2 logs or if there are logs from other days
                                  if (_todaysFoodLogs.length > 2 ||
                                      _dummyFoodLogs.length >
                                          _todaysFoodLogs.length) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      AllFoodLogsScreen(
                                                        allFoodLogs:
                                                            _dummyFoodLogs,
                                                      ),
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.list_alt,
                                          size: 18,
                                          color: AppColors.darkGradientStart,
                                        ),
                                        label: Text(
                                          _todaysFoodLogs.length > 2
                                              ? 'View All Logs (${_dummyFoodLogs.length} total)'
                                              : 'View All Logs',
                                          style: TextStyle(
                                            color: AppColors.darkGradientStart,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: AppColors.darkGradientStart,
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Access to Meal Plans Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MealPlansScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.withOpacity(0.1),
                              Colors.deepPurple.withOpacity(0.1),
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
                                  Icons.restaurant_menu,
                                  color: Colors.purple,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'My Meal Plans',
                                    style: AppTextStyles.darkHeadlineMedium
                                        .copyWith(color: Colors.purple),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.purple,
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Access your saved meal plans and create new ones',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.purple.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        size: 16,
                                        color: Colors.purple,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '3 AI Plans',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.purple,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Ready to Use',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build target nutrition items
  Widget _buildTargetItem(
    String label,
    String value,
    IconData icon,
    Color color,
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
  Widget _buildLogOption(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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
  Widget _buildNutrientRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
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
              'Logged: ${_formatLogDate(log['log_date'])}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

        // Commented out API call - using dummy data for now
        // final productData = await ref
        //     .read(foodDatabaseServiceProvider)
        //     .getProductByBarcode(result.rawContent);

        // Mock product data for testing
        final productData = {
          'name': 'Scanned Product',
          'calories': 150.0,
          'protein': 8.0,
          'carbs': 20.0,
          'fat': 4.5,
          'serving_size': '1 package',
          'barcode': result.rawContent,
        };

        _saveScannedMeal(productData);
      }
    } catch (e) {
      print('Error scanning barcode: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error scanning barcode: $e')));
    }
  }

  // Method to handle manual entry
  Future<void> _manualEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManualMealEntryScreen()),
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
      // Commented out API call - using dummy data for now
      // await ref.read(nutritionProvider.notifier).addFoodLog(foodLogData);
      setState(() {
        _dummyFoodLogs.insert(0, foodLogData);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manual meal saved successfully!')),
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
        builder:
            (context) => ManualMealEntryScreen(
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

  // Method to generate meal plan using Gemini AI
  Future<void> _generateMealPlan() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.darkGradientStart,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Generating personalized meal plan...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'This may take a few moments',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
      );

      // Simulate API call to Gemini - replace with actual implementation
      await Future.delayed(Duration(seconds: 3));

      // Mock meal plan data - replace with actual Gemini response
      final mealPlan = {
        'breakfast': [
          {
            'name': 'Protein Pancakes',
            'calories': 350,
            'protein': 25.0,
            'carbs': 35.0,
            'fat': 12.0,
            'ingredients': [
              'Oats',
              'Protein powder',
              'Eggs',
              'Banana',
              'Blueberries',
            ],
          },
        ],
        'lunch': [
          {
            'name': 'Quinoa Buddha Bowl',
            'calories': 420,
            'protein': 18.0,
            'carbs': 55.0,
            'fat': 15.0,
            'ingredients': [
              'Quinoa',
              'Chickpeas',
              'Avocado',
              'Sweet potato',
              'Spinach',
            ],
          },
        ],
        'dinner': [
          {
            'name': 'Grilled Salmon with Vegetables',
            'calories': 380,
            'protein': 35.0,
            'carbs': 20.0,
            'fat': 18.0,
            'ingredients': [
              'Salmon fillet',
              'Broccoli',
              'Brown rice',
              'Olive oil',
              'Lemon',
            ],
          },
        ],
        'snacks': [
          {
            'name': 'Greek Yogurt with Nuts',
            'calories': 180,
            'protein': 15.0,
            'carbs': 12.0,
            'fat': 8.0,
            'ingredients': ['Greek yogurt', 'Almonds', 'Honey', 'Berries'],
          },
        ],
      };

      Navigator.of(context).pop(); // Close loading dialog

      setState(() {
        _isLoading = false;
      });

      // Show meal plan dialog
      _showMealPlanDialog(mealPlan);
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating meal plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to show meal plan dialog
  void _showMealPlanDialog(Map<String, dynamic> mealPlan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.darkGradientStart),
              const SizedBox(width: 8),
              Text('Your Meal Plan'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personalized for your goals and preferences',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Breakfast
                  _buildMealSection(
                    'Breakfast',
                    mealPlan['breakfast'],
                    Icons.wb_sunny,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),

                  // Lunch
                  _buildMealSection(
                    'Lunch',
                    mealPlan['lunch'],
                    Icons.lunch_dining,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),

                  // Dinner
                  _buildMealSection(
                    'Dinner',
                    mealPlan['dinner'],
                    Icons.dinner_dining,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),

                  // Snacks
                  _buildMealSection(
                    'Snacks',
                    mealPlan['snacks'],
                    Icons.cookie,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveMealPlan(mealPlan);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGradientStart,
                foregroundColor: Colors.white,
              ),
              child: Text('Save Plan'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to build meal section in dialog
  Widget _buildMealSection(
    String mealType,
    List<dynamic> meals,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                mealType,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...meals
              .map(
                (meal) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${meal['calories']} kcal • ${meal['protein']}g protein • ${meal['carbs']}g carbs • ${meal['fat']}g fat',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  // Method to save meal plan (add to food logs)
  void _saveMealPlan(Map<String, dynamic> mealPlan) {
    try {
      // Add each meal to the food logs
      mealPlan.forEach((mealType, meals) {
        for (var meal in meals) {
          final foodLogData = {
            'food_name': meal['name'],
            'log_date': DateTime.now().toIso8601String(),
            'calories': meal['calories'].toDouble(),
            'protein': meal['protein'].toDouble(),
            'carbs': meal['carbs'].toDouble(),
            'fat': meal['fat'].toDouble(),
            'meal_type':
                mealType.substring(0, 1).toUpperCase() + mealType.substring(1),
            'source': 'AI Generated',
          };

          _dummyFoodLogs.insert(0, foodLogData);
        }
      });

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Meal plan saved successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving meal plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to handle profile menu selection
  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
      case 'reminders':
        // TODO: Navigate to reminders screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminders feature coming soon!')),
        );
        break;
      case 'notifications':
        // TODO: Navigate to notifications screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications feature coming soon!')),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NutritionQuizScreen()),
        ).then((_) => _updateTargetsBasedOnUserProfile());
        break;
      case 'themes':
        _showThemeDialog(context);
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
    }
  }

  // Method to show theme selection dialog
  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Light Theme'),
                onTap: () {
                  ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(AppThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Theme'),
                onTap: () {
                  ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(AppThemeMode.dark);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_system_daydream),
                title: const Text('System Theme'),
                onTap: () {
                  ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(AppThemeMode.system);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(auth_provider.authProvider.notifier).logout();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
