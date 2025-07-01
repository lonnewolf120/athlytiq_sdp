import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // For generating UUIDs
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:fitnation/providers/data_providers.dart'; // Import data_providers for nutritionProvider
import 'package:fitnation/providers/nutrition_provider.dart'; // Import nutritionProvider

class ManualMealEntryScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialMealData;

  const ManualMealEntryScreen({super.key, this.initialMealData});

  @override
  ConsumerState<ManualMealEntryScreen> createState() =>
      _ManualMealEntryScreenState();
}

class _ManualMealEntryScreenState extends ConsumerState<ManualMealEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();

  final Uuid _uuid =
      Uuid(); // Still needed for generating UUIDs if creating new local Meal objects

  // No direct service initialization here, use ref.read()

  @override
  void initState() {
    super.initState();
    if (widget.initialMealData != null) {
      _mealNameController.text = widget.initialMealData!['mealName'] ?? '';
      _caloriesController.text =
          widget.initialMealData!['totalCalories']?.toString() ?? '';
      _proteinController.text =
          widget.initialMealData!['totalProtein']?.toString() ?? '';
      _carbsController.text =
          widget.initialMealData!['totalCarbs']?.toString() ?? '';
      _fatController.text =
          widget.initialMealData!['totalFat']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _saveMeal() async {
    if (_formKey.currentState!.validate()) {
      final mealName = _mealNameController.text;
      final calories = double.tryParse(_caloriesController.text) ?? 0.0;
      final protein = double.tryParse(_proteinController.text) ?? 0.0;
      final carbs = double.tryParse(_carbsController.text) ?? 0.0;
      final fat = double.tryParse(_fatController.text) ?? 0.0;

      // Create a dummy FoodItem for the manual entry
      // Prepare data for FoodLogCreate schema
      final foodLogData = {
        'food_name': mealName,
        'log_date': DateTime.now().toIso8601String(),
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'meal_type': 'Manual Entry', // Or allow user to select meal type
      };

      try {
        await ref.read(nutritionProvider.notifier).addFoodLog(foodLogData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal saved successfully!')),
        );
        Navigator.pop(context, foodLogData); // Return the saved meal data
      } catch (e) {
        print('Error saving meal: $e');
        // Show error to user
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving meal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Meal Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: _mealNameController,
                decoration: const InputDecoration(labelText: 'Meal Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a meal name';
                  }
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter calories';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: _proteinController,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter protein';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: _carbsController,
                decoration: const InputDecoration(
                  labelText: 'Carbohydrates (g)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter carbohydrates';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: _fatController,
                decoration: const InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter fat';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMeal,
                child: const Text('Save Meal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
