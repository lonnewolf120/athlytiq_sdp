import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:fitnation/providers/gemini_meal_plan_provider.dart';
import 'package:fitnation/models/MealPlan.dart';
import 'package:fitnation/Screens/Activities/MealPlanDetailScreen.dart';
import 'package:fitnation/Screens/Activities/MealPlanGeneratorScreen.dart';
import 'package:fitnation/Screens/nutrition/nutrition_targets_screen.dart';

class MealPlansScreen extends ConsumerStatefulWidget {
  const MealPlansScreen({super.key});

  @override
  ConsumerState<MealPlansScreen> createState() => _MealPlansScreenState();
}

class _MealPlansScreenState extends ConsumerState<MealPlansScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger loading of meal plans
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider will automatically load plans when authenticated
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealPlans = ref.watch(geminiMealPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Meal Plans',
          style: AppTextStyles.darkHeadlineMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.darkGradientStart,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.track_changes),
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
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Meal Plan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MealPlanGeneratorScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body:
          mealPlans.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: () async {
                  // Force refresh meal plans
                  ref.invalidate(geminiMealPlanProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mealPlans.length,
                  itemBuilder: (context, index) {
                    final mealPlan = mealPlans[index];
                    return _buildMealPlanCard(mealPlan);
                  },
                ),
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No Meal Plans Yet',
              style: AppTextStyles.darkHeadlineMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first personalized meal plan using AI',
              style: AppTextStyles.darkBodyMedium.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MealPlanGeneratorScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Meal Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGradientStart,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanCard(MealPlan mealPlan) {
    final totalCalories = mealPlan.meals.fold(
      0,
      (sum, meal) => sum + (meal.calories ?? 0),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MealPlanDetailScreen(mealPlan: mealPlan),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkGradientStart.withOpacity(0.1),
                AppColors.darkGradientEnd.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      mealPlan.name,
                      style: AppTextStyles.darkHeadlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkGradientStart,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'AI Generated',
                      style: AppTextStyles.darkBodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (mealPlan.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  mealPlan.description!,
                  style: AppTextStyles.darkBodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.local_fire_department,
                    '$totalCalories kcal',
                    Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.restaurant,
                    '${mealPlan.meals.length} meals',
                    Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Tap to view details',
                style: AppTextStyles.darkBodySmall.copyWith(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.darkBodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
