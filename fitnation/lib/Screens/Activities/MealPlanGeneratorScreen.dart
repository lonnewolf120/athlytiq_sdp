import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/gemini_meal_plan_provider.dart';
import 'package:fitnation/core/themes/themes.dart'; // Assuming AppColors is here
import 'package:fitnation/models/Workout.dart'; // Import Workout model

class MealPlanGeneratorScreen extends ConsumerStatefulWidget {
  final Workout? linkedWorkoutPlan; // New optional parameter

  const MealPlanGeneratorScreen({
    super.key,
    this.linkedWorkoutPlan, // Initialize the new parameter
  });

  @override
  ConsumerState<MealPlanGeneratorScreen> createState() => _MealPlanGeneratorScreenState();
}

class _MealPlanGeneratorScreenState extends ConsumerState<MealPlanGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _goalsController = TextEditingController();
  final TextEditingController _dietaryRestrictionsController = TextEditingController();
  final TextEditingController _preferredCuisinesController = TextEditingController();
  String? _sex;
  String? _mealCount; // e.g., 3, 4, 5 meals a day
  bool _isLoading = false;

  final List<String> _mealCountOptions = ['3', '4', '5', '6'];

  @override
  void initState() {
    super.initState();
    // Pre-fill goals if a linked workout plan is provided
    if (widget.linkedWorkoutPlan != null) {
      _goalsController.text = widget.linkedWorkoutPlan!.name; // Or a more detailed summary
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _goalsController.dispose();
    _dietaryRestrictionsController.dispose();
    _preferredCuisinesController.dispose();
    super.dispose();
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
        'preferred_cuisines': _preferredCuisinesController.text.split(',').map((e) => e.trim()).toList(),
        'meal_count': _mealCount,
        'linked_workout_plan_id': widget.linkedWorkoutPlan?.id, // Pass linked workout ID
      };

      try {
        await ref.read(geminiMealPlanProvider.notifier).generateMealPlan(userInfo);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan generated successfully!')),
        );
        Navigator.pop(context); // Go back to previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate plan: $e')),
        );
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Meal Plan', style: textTheme.titleLarge),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tell us about yourself to get a personalized meal plan!', style: textTheme.titleMedium),
              const SizedBox(height: 20),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _sex,
                decoration: const InputDecoration(
                  labelText: 'Sex',
                  border: OutlineInputBorder(),
                ),
                items: <String>['Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
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
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _goalsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Fitness Goals (e.g., Build muscle, Lose weight, Improve endurance)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your fitness goals';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dietaryRestrictionsController,
                decoration: const InputDecoration(
                  labelText: 'Dietary Restrictions (e.g., Vegetarian, Vegan, Gluten-Free)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter any dietary restrictions or "None"';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _preferredCuisinesController,
                decoration: const InputDecoration(
                  labelText: 'Preferred Cuisines (comma-separated, e.g., Italian, Mexican, Asian)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please list your preferred cuisines or "Any"';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _mealCount,
                decoration: const InputDecoration(
                  labelText: 'Number of Meals per Day',
                  border: OutlineInputBorder(),
                ),
                items: _mealCountOptions
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
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
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? Column(
                    children: [
                      const Center(child: CircularProgressIndicator()),
                      const Text('Keep working out while we prepare your meal plan'),
                    ],
                  )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _generatePlan,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Generate Meal Plan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.primaryForeground,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
