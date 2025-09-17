import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:fitnation/providers/gemini_meal_plan_provider.dart';
import 'package:fitnation/providers/nutrition_provider.dart';
import 'package:fitnation/services/notification_service.dart';
import 'package:fitnation/Screens/nutrition/meal_plans_screen.dart';
import 'package:fitnation/Screens/nutrition/nutrition_progress_screen.dart';
import 'package:fitnation/Screens/nutrition/nutrition_targets_screen.dart';
import 'package:fitnation/Screens/nutrition/food_log_screen.dart';
import 'package:fitnation/Screens/Activities/MealPlanGeneratorScreen.dart';

class MealPlanTestScreen extends ConsumerStatefulWidget {
  const MealPlanTestScreen({super.key});

  @override
  ConsumerState<MealPlanTestScreen> createState() => _MealPlanTestScreenState();
}

class _MealPlanTestScreenState extends ConsumerState<MealPlanTestScreen> {
  String _statusMessage = 'Ready to test meal plan functionality';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meal Plan Functionality Test',
          style: AppTextStyles.darkHeadlineMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.darkGradientStart,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isLoading ? Icons.sync : Icons.info_outline,
                          color: AppColors.darkGradientStart,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Test Status',
                          style: AppTextStyles.darkHeadlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_statusMessage, style: AppTextStyles.darkBodyMedium),
                    if (_isLoading) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Provider Testing Section
            _buildTestSection('Provider Tests', Icons.api, [
              _buildTestButton(
                'Test Gemini Meal Plan Provider',
                'Generate a sample meal plan',
                Icons.restaurant,
                () => _testGeminiProvider(),
              ),
              _buildTestButton(
                'Test Nutrition Provider',
                'Load nutrition data and targets',
                Icons.analytics,
                () => _testNutritionProvider(),
              ),
              _buildTestButton(
                'Test Notification Service',
                'Schedule sample notifications',
                Icons.notifications,
                () => _testNotificationService(),
              ),
            ]),

            const SizedBox(height: 24),

            // Navigation Testing Section
            _buildTestSection('Screen Navigation Tests', Icons.navigation, [
              _buildNavigationButton(
                'Meal Plans Screen',
                'View all meal plans',
                Icons.restaurant_menu,
                () => const MealPlansScreen(),
              ),
              _buildNavigationButton(
                'Meal Plan Generator',
                'Generate new meal plan',
                Icons.add_circle,
                () => const MealPlanGeneratorScreen(),
              ),
              _buildNavigationButton(
                'Nutrition Progress',
                'View nutrition progress',
                Icons.show_chart,
                () => const NutritionProgressScreen(),
              ),
              _buildNavigationButton(
                'Nutrition Targets',
                'Set nutrition goals',
                Icons.track_changes,
                () => const NutritionTargetsScreen(),
              ),
              _buildNavigationButton(
                'Food Log',
                'Log food intake',
                Icons.add,
                () => const FoodLogScreen(),
              ),
            ]),

            const SizedBox(height: 24),

            // Integration Testing Section
            _buildTestSection(
              'Integration Tests',
              Icons.integration_instructions,
              [
                _buildTestButton(
                  'Full Workflow Test',
                  'Test complete meal plan workflow',
                  Icons.playlist_play,
                  () => _testFullWorkflow(),
                ),
                _buildTestButton(
                  'Database Integration',
                  'Test local database operations',
                  Icons.storage,
                  () => _testDatabaseIntegration(),
                ),
                _buildTestButton(
                  'Notification Integration',
                  'Test notification scheduling',
                  Icons.schedule,
                  () => _testNotificationIntegration(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.darkGradientStart),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.darkHeadlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.darkGradientStart,
          elevation: 2,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.darkGradientStart),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.darkBodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.darkBodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    String title,
    String subtitle,
    IconData icon,
    Widget Function() builder,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => builder()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkGradientStart.withOpacity(0.1),
          foregroundColor: AppColors.darkGradientStart,
          elevation: 1,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.darkGradientStart),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.darkBodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.darkBodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> _testGeminiProvider() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing Gemini Meal Plan Provider...';
    });

    try {
      // Test generating a meal plan instead of loading
      await ref.read(geminiMealPlanProvider.notifier).generateMealPlan({
        'age': 25,
        'gender': 'male',
        'weight': 70,
        'height': 175,
        'activityLevel': 'moderate',
        'goal': 'maintain',
        'dietaryPreferences': ['balanced'],
        'allergies': [],
      });

      setState(() {
        _statusMessage = 'Gemini Provider Test: SUCCESS - Meal plan generated';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Gemini Provider Test: ERROR - $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testNutritionProvider() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing Nutrition Provider...';
    });

    try {
      await ref.read(nutritionProvider.notifier).fetchAllNutritionData();

      final targets = ref.read(nutritionTargetsProvider);
      final progress = ref.read(todayProgressProvider);

      setState(() {
        _statusMessage =
            'Nutrition Provider Test: SUCCESS - Targets: ${targets != null ? "✓" : "✗"}, Progress: ${progress != null ? "✓" : "✗"}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Nutrition Provider Test: ERROR - $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testNotificationService() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing Notification Service...';
    });

    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.requestPermissions();

      setState(() {
        _statusMessage =
            'Notification Service Test: SUCCESS - Service initialized and permissions requested';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Notification Service Test: ERROR - $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testFullWorkflow() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing full meal plan workflow...';
    });

    try {
      // Step 1: Test meal plan generation
      await ref.read(geminiMealPlanProvider.notifier).generateMealPlan({
        'age': 25,
        'gender': 'male',
        'weight': 70,
        'height': 175,
        'activityLevel': 'moderate',
        'goal': 'maintain',
        'dietaryPreferences': ['balanced'],
        'allergies': [],
      });

      // Step 2: Load nutrition data
      await ref.read(nutritionProvider.notifier).fetchAllNutritionData();

      // Step 3: Test notification service
      final notificationService = NotificationService();
      await notificationService.initialize();

      setState(() {
        _statusMessage =
            'Full Workflow Test: SUCCESS - All components working together';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Full Workflow Test: ERROR - $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testDatabaseIntegration() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing database integration...';
    });

    try {
      // This would test DatabaseHelper operations when fully implemented
      setState(() {
        _statusMessage =
            'Database Integration Test: PENDING - DatabaseHelper not fully implemented yet';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Database Integration Test: ERROR - $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testNotificationIntegration() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing notification integration...';
    });

    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.requestPermissions();

      // Schedule a test notification
      await notificationService.scheduleDailyMealReminders(
        userName: 'Test User',
        breakfastTime: const TimeOfDay(hour: 8, minute: 0),
        lunchTime: const TimeOfDay(hour: 12, minute: 0),
        dinnerTime: const TimeOfDay(hour: 18, minute: 0),
        snackTime: const TimeOfDay(hour: 15, minute: 0),
      );

      setState(() {
        _statusMessage =
            'Notification Integration Test: SUCCESS - Daily reminders scheduled';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Notification Integration Test: ERROR - $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
