import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';

class MealPlansScreen extends ConsumerStatefulWidget {
  const MealPlansScreen({super.key});

  @override
  ConsumerState<MealPlansScreen> createState() => _MealPlansScreenState();
}

class _MealPlansScreenState extends ConsumerState<MealPlansScreen> {
  // Dummy meal plans data
  final List<Map<String, dynamic>> _dummyMealPlans = [
    {
      'id': '1',
      'name': 'Muscle Building Plan',
      'description':
          'High-protein meal plan designed for muscle growth and recovery',
      'created_date': DateTime.now().subtract(Duration(days: 3)),
      'total_calories': 2800,
      'total_protein': 180.0,
      'total_carbs': 300.0,
      'total_fat': 90.0,
      'meals': [
        {
          'name': 'Protein Pancakes with Berries',
          'meal_type': 'Breakfast',
          'calories': 450,
          'protein': 35.0,
          'carbs': 45.0,
          'fat': 15.0,
          'ingredients': [
            'Oats',
            'Protein powder',
            'Eggs',
            'Banana',
            'Blueberries',
          ],
        },
        {
          'name': 'Grilled Chicken Buddha Bowl',
          'meal_type': 'Lunch',
          'calories': 520,
          'protein': 45.0,
          'carbs': 55.0,
          'fat': 18.0,
          'ingredients': [
            'Chicken breast',
            'Quinoa',
            'Sweet potato',
            'Avocado',
            'Spinach',
          ],
        },
        {
          'name': 'Salmon with Brown Rice',
          'meal_type': 'Dinner',
          'calories': 480,
          'protein': 40.0,
          'carbs': 50.0,
          'fat': 20.0,
          'ingredients': [
            'Salmon fillet',
            'Brown rice',
            'Broccoli',
            'Olive oil',
          ],
        },
        {
          'name': 'Greek Yogurt with Nuts',
          'meal_type': 'Snack',
          'calories': 220,
          'protein': 20.0,
          'carbs': 15.0,
          'fat': 12.0,
          'ingredients': ['Greek yogurt', 'Almonds', 'Honey', 'Walnuts'],
        },
      ],
      'source': 'AI Generated',
    },
    {
      'id': '2',
      'name': 'Weight Loss Plan',
      'description':
          'Balanced, calorie-controlled meals for healthy weight loss',
      'created_date': DateTime.now().subtract(Duration(days: 7)),
      'total_calories': 1800,
      'total_protein': 120.0,
      'total_carbs': 180.0,
      'total_fat': 60.0,
      'meals': [
        {
          'name': 'Veggie Omelette',
          'meal_type': 'Breakfast',
          'calories': 280,
          'protein': 25.0,
          'carbs': 8.0,
          'fat': 18.0,
          'ingredients': [
            'Eggs',
            'Spinach',
            'Mushrooms',
            'Bell peppers',
            'Cheese',
          ],
        },
        {
          'name': 'Quinoa Salad Bowl',
          'meal_type': 'Lunch',
          'calories': 380,
          'protein': 18.0,
          'carbs': 55.0,
          'fat': 12.0,
          'ingredients': [
            'Quinoa',
            'Chickpeas',
            'Cucumber',
            'Tomatoes',
            'Feta cheese',
          ],
        },
        {
          'name': 'Grilled Fish with Vegetables',
          'meal_type': 'Dinner',
          'calories': 320,
          'protein': 35.0,
          'carbs': 15.0,
          'fat': 15.0,
          'ingredients': [
            'White fish',
            'Zucchini',
            'Asparagus',
            'Lemon',
            'Herbs',
          ],
        },
        {
          'name': 'Apple with Almond Butter',
          'meal_type': 'Snack',
          'calories': 180,
          'protein': 6.0,
          'carbs': 20.0,
          'fat': 8.0,
          'ingredients': ['Apple', 'Almond butter'],
        },
      ],
      'source': 'AI Generated',
    },
    {
      'id': '3',
      'name': 'Vegetarian Power Plan',
      'description': 'Plant-based nutrition for optimal health and energy',
      'created_date': DateTime.now().subtract(Duration(days: 14)),
      'total_calories': 2200,
      'total_protein': 140.0,
      'total_carbs': 280.0,
      'total_fat': 70.0,
      'meals': [
        {
          'name': 'Chia Seed Pudding',
          'meal_type': 'Breakfast',
          'calories': 320,
          'protein': 15.0,
          'carbs': 35.0,
          'fat': 18.0,
          'ingredients': [
            'Chia seeds',
            'Almond milk',
            'Berries',
            'Maple syrup',
          ],
        },
        {
          'name': 'Lentil Power Bowl',
          'meal_type': 'Lunch',
          'calories': 450,
          'protein': 22.0,
          'carbs': 65.0,
          'fat': 15.0,
          'ingredients': [
            'Red lentils',
            'Quinoa',
            'Roasted vegetables',
            'Tahini',
          ],
        },
        {
          'name': 'Tofu Stir Fry',
          'meal_type': 'Dinner',
          'calories': 380,
          'protein': 25.0,
          'carbs': 40.0,
          'fat': 18.0,
          'ingredients': [
            'Firm tofu',
            'Mixed vegetables',
            'Brown rice',
            'Soy sauce',
          ],
        },
        {
          'name': 'Hummus with Veggies',
          'meal_type': 'Snack',
          'calories': 150,
          'protein': 8.0,
          'carbs': 18.0,
          'fat': 6.0,
          'ingredients': ['Hummus', 'Carrots', 'Bell peppers', 'Cucumber'],
        },
      ],
      'source': 'AI Generated',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Generate new meal plans from the Nutrition screen!',
                  ),
                  backgroundColor: AppColors.darkGradientStart,
                ),
              );
            },
          ),
        ],
      ),
      body:
          _dummyMealPlans.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Overview
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
                                    Icons.dashboard,
                                    color: AppColors.darkGradientStart,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Meal Plans Overview',
                                    style: AppTextStyles.darkHeadlineMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatsItem(
                                      'Total Plans',
                                      '${_dummyMealPlans.length}',
                                      Icons.restaurant_menu,
                                      Colors.blue,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildStatsItem(
                                      'AI Generated',
                                      '${_dummyMealPlans.where((plan) => plan['source'] == 'AI Generated').length}',
                                      Icons.auto_awesome,
                                      Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Meal Plans List
                      Text(
                        'Your Meal Plans',
                        style: AppTextStyles.darkHeadlineMedium,
                      ),
                      const SizedBox(height: 12),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _dummyMealPlans.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final plan = _dummyMealPlans[index];
                          return _buildMealPlanCard(plan);
                        },
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
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                            ),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.amber[800],
                              ),
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
                                      'These are sample meal plans. Real meal plan management will be implemented once the meal plan API is connected.',
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Meal Plans Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate your first meal plan from the Nutrition screen to see it here!',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
              label: Text('Back to Nutrition'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGradientStart,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsItem(
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanCard(Map<String, dynamic> plan) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showMealPlanDetails(plan),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGradientStart,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkGradientStart.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: AppColors.darkGradientStart,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          plan['source'],
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.darkGradientStart,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildNutrientInfo(
                    'Cal',
                    '${plan['total_calories']}',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _buildNutrientInfo(
                    'Protein',
                    '${plan['total_protein'].toStringAsFixed(0)}g',
                    Icons.fitness_center,
                    Colors.red,
                  ),
                  const SizedBox(width: 12),
                  _buildNutrientInfo(
                    'Carbs',
                    '${plan['total_carbs'].toStringAsFixed(0)}g',
                    Icons.grain,
                    Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildNutrientInfo(
                    'Fat',
                    '${plan['total_fat'].toStringAsFixed(0)}g',
                    Icons.opacity,
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created: ${_formatDate(plan['created_date'])}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Text(
                    '${plan['meals'].length} meals',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkGradientStart,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientInfo(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  void _showMealPlanDetails(Map<String, dynamic> plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    plan['name'],
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkGradientStart,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.close),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              plan['description'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Nutrition Summary
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.darkGradientStart.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildDetailNutrient(
                                    'Calories',
                                    '${plan['total_calories']}',
                                    Icons.local_fire_department,
                                    Colors.orange,
                                  ),
                                  _buildDetailNutrient(
                                    'Protein',
                                    '${plan['total_protein'].toStringAsFixed(0)}g',
                                    Icons.fitness_center,
                                    Colors.red,
                                  ),
                                  _buildDetailNutrient(
                                    'Carbs',
                                    '${plan['total_carbs'].toStringAsFixed(0)}g',
                                    Icons.grain,
                                    Colors.green,
                                  ),
                                  _buildDetailNutrient(
                                    'Fat',
                                    '${plan['total_fat'].toStringAsFixed(0)}g',
                                    Icons.opacity,
                                    Colors.blue,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Meals List
                            Text(
                              'Meals in this Plan',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            ...plan['meals'].map<Widget>((meal) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          meal['name'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getMealTypeColor(
                                              meal['meal_type'],
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            meal['meal_type'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _getMealTypeColor(
                                                meal['meal_type'],
                                              ),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _buildSmallNutrient(
                                          '${meal['calories']} cal',
                                          Colors.orange,
                                        ),
                                        const SizedBox(width: 12),
                                        _buildSmallNutrient(
                                          '${meal['protein'].toStringAsFixed(0)}g protein',
                                          Colors.red,
                                        ),
                                        const SizedBox(width: 12),
                                        _buildSmallNutrient(
                                          '${meal['carbs'].toStringAsFixed(0)}g carbs',
                                          Colors.green,
                                        ),
                                        const SizedBox(width: 12),
                                        _buildSmallNutrient(
                                          '${meal['fat'].toStringAsFixed(0)}g fat',
                                          Colors.blue,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ingredients: ${meal['ingredients'].join(', ')}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),

                            const SizedBox(height: 20),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _useMealPlan(plan);
                                    },
                                    icon: Icon(Icons.restaurant),
                                    label: Text('Use This Plan'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.darkGradientStart,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _duplicateMealPlan(plan);
                                    },
                                    icon: Icon(Icons.copy),
                                    label: Text('Duplicate'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          AppColors.darkGradientStart,
                                      side: BorderSide(
                                        color: AppColors.darkGradientStart,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
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
            );
          },
        );
      },
    );
  }

  Widget _buildDetailNutrient(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSmallNutrient(String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.blue;
      case 'snack':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _useMealPlan(Map<String, dynamic> plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Meal plan "${plan['name']}" activated! Meals will be added to your log.',
        ),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // Implement undo functionality
          },
        ),
      ),
    );
  }

  void _duplicateMealPlan(Map<String, dynamic> plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meal plan "${plan['name']}" duplicated successfully!'),
        backgroundColor: AppColors.darkGradientStart,
      ),
    );
  }
}
