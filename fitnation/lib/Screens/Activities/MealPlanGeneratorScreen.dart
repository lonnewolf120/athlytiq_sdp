import 'package:fitnation/Screens/shop_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/gemini_meal_plan_provider.dart';
import 'package:fitnation/core/themes/themes.dart'; // Assuming AppColors is here
import 'package:fitnation/models/Workout.dart'; // Import Workout model
import 'dart:async'; // Import for Timer

class MealPlanGeneratorScreen extends ConsumerStatefulWidget {
  final Workout? linkedWorkoutPlan; // New optional parameter

  const MealPlanGeneratorScreen({
    super.key,
    this.linkedWorkoutPlan, // Initialize the new parameter
  });

  @override
  ConsumerState<MealPlanGeneratorScreen> createState() =>
      _MealPlanGeneratorScreenState();
}

class _MealPlanGeneratorScreenState
    extends ConsumerState<MealPlanGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _goalsController = TextEditingController();
  final TextEditingController _dietaryRestrictionsController =
      TextEditingController();
  final TextEditingController _preferredCuisinesController =
      TextEditingController();
  String? _sex;
  String? _mealCount; // e.g., 3, 4, 5 meals a day
  bool _isLoading = false;

  final List<String> _mealCountOptions = ['3', '4', '5', '6'];

  // Nutrient recommendation specific fields
  final List<String> _nutrientRecommendations = [
    'Protein Powder',
    'Creatine',
    'Multivitamins',
    'Fish Oil',
    'BCAAs',
  ];
  int _currentNutrientRecommendationIndex = 0;
  Timer? _nutrientRecommendationTimer;

  @override
  void initState() {
    super.initState();
    // Pre-fill goals if a linked workout plan is provided
    if (widget.linkedWorkoutPlan != null) {
      _goalsController.text =
          widget.linkedWorkoutPlan!.name; // Or a more detailed summary
    }
    _startNutrientRecommendationTimer();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _goalsController.dispose();
    _dietaryRestrictionsController.dispose();
    _preferredCuisinesController.dispose();
    _nutrientRecommendationTimer?.cancel(); // Cancel the timer
    super.dispose();
  }

  void _startNutrientRecommendationTimer() {
    _nutrientRecommendationTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) {
      setState(() {
        _currentNutrientRecommendationIndex =
            (_currentNutrientRecommendationIndex + 1) %
            _nutrientRecommendations.length;
      });
    });
  }

  Future<void> _generatePlan() async {
    debugPrint('MealPlanGeneratorScreen: _generatePlan called.');
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final userInfo = {
        'height': _heightController.text,
        'weight': _weightController.text,
        'age': _ageController.text,
        'sex': _sex,
        'goals': _goalsController.text,
        'dietary_restrictions': _dietaryRestrictionsController.text,
        'preferred_cuisines':
            _preferredCuisinesController.text
                .split(',')
                .map((e) => e.trim())
                .toList(),
        'meal_count': _mealCount,
        'linked_workout_plan_id':
            widget.linkedWorkoutPlan?.id, // Pass linked workout ID
      };

      try {
        await ref
            .read(geminiMealPlanProvider.notifier)
            .generateMealPlan(userInfo);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan generated successfully!')),
        );
        Navigator.pop(context); // Go back to previous screen
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to generate plan: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme; // Access color scheme

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Generate Meal Plan',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary, // Text on primary color
          ),
        ),
        backgroundColor: colorScheme.primary, // Use primary color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us about yourself to get a personalized meal plan!',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _heightController,
                labelText: 'Height (cm)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _weightController,
                labelText: 'Weight (kg)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ageController,
                labelText: 'Age',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                value: _sex,
                labelText: 'Sex',
                items: ['Male', 'Female', 'Other'],
                onChanged: (String? newValue) {
                  setState(() {
                    _sex = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your sex';
                  }
                  return null;
                },
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _goalsController,
                labelText:
                    'Fitness Goals (e.g., Build muscle, Lose weight, Improve endurance)',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your fitness goals';
                  }
                  return null;
                },
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _dietaryRestrictionsController,
                labelText:
                    'Dietary Restrictions (e.g., Vegetarian, Vegan, Gluten-Free)',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter any dietary restrictions or "None"';
                  }
                  return null;
                },
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _preferredCuisinesController,
                labelText:
                    'Preferred Cuisines (comma-separated, e.g., Italian, Mexican, Asian)',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please list your preferred cuisines or "Any"';
                  }
                  return null;
                },
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                value: _mealCount,
                labelText: 'Number of Meals per Day',
                items: _mealCountOptions,
                onChanged: (String? newValue) {
                  setState(() {
                    _mealCount = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the number of meals';
                  }
                  return null;
                },
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 24),

              // Nutrient Recommendation Section
              _buildNutrientRecommendations(colorScheme),
              const SizedBox(height: 24),

              _isLoading
                  ? Column(
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep working out while we prepare your meal plan',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _generatePlan,
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: Text(
                        'Generate Meal Plan',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    required ColorScheme colorScheme,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.6)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: validator,
      style: TextStyle(color: colorScheme.onSurface),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String labelText,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
    required ColorScheme colorScheme,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.6)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items:
          items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: TextStyle(color: colorScheme.onSurface)),
            );
          }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildNutrientRecommendations(ColorScheme colorScheme) {
    if (_nutrientRecommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    String currentNutrient =
        _nutrientRecommendations[_currentNutrientRecommendationIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Looking for supplements?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                colorScheme.tertiary, // A suitable tertiary color from MD3
                colorScheme
                    .tertiaryContainer, // A lighter shade for gradient effect
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (ctx) => ShopPage(
                        initialCategory: 'Supplements',
                      ), // Navigate to ShopPage with 'supplements' category
                ),
              );
            },
            icon: Icon(
              Icons.fitness_center_rounded,
              size: 20,
              color: colorScheme.onTertiary,
            ), // Icon color contrasting with tertiary
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.0, -1.0),
                  end: Offset.zero,
                ).animate(animation);
                return ClipRect(
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                );
              },
              child: Text(
                key: ValueKey<int>(_currentNutrientRecommendationIndex),
                'Buy the best & affordable $currentNutrient from our shop',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      colorScheme
                          .onTertiary, // Text color contrasting with tertiary
                ),
                textAlign: TextAlign.center,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor:
                  Colors
                      .transparent, // Make button background transparent to show gradient
              foregroundColor:
                  colorScheme
                      .onTertiary, // Ensure icon and text color are correct
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0, // Remove default button elevation
              shadowColor: Colors.transparent, // Remove default button shadow
            ),
          ),
        ),
      ],
    );
  }
}
