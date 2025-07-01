import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/gemini_workout_provider.dart';
import 'package:fitnation/core/themes/themes.dart'; // Assuming you have AppColors defined here

class WorkoutPlanGeneratorScreen extends ConsumerStatefulWidget {
  const WorkoutPlanGeneratorScreen({super.key});

  @override
  ConsumerState<WorkoutPlanGeneratorScreen> createState() => _WorkoutPlanGeneratorScreenState();
}

class _WorkoutPlanGeneratorScreenState extends ConsumerState<WorkoutPlanGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _goalsController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController(); // Re-added declaration
  String? _sex;
  String? _intensity;
  String? _selectedGoal;
  bool _showCustomGoalsField = false;
  bool _isLoading = false;

  List<String> _selectedEquipment = [];
  bool _showCustomEquipmentField = false;

  final List<String> _intensityOptions = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _goalOptions = [
    'Build muscle',
    'Lose weight',
    'Improve endurance',
    'Increase strength',
    'Improve flexibility',
    'General fitness',
    'Other'
  ];
  final List<String> _equipmentOptions = [
    'Dumbbells',
    'Barbell',
    'Resistance Bands',
    'Kettlebell',
    'Pull-up Bar',
    'Treadmill',
    'None',
    'Other'
  ];

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _goalsController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String finalGoals = _selectedGoal == 'Other' ? _goalsController.text : (_selectedGoal ?? '');
      List<String> finalEquipment = List.from(_selectedEquipment);
      if (_showCustomEquipmentField) {
        finalEquipment.addAll(_equipmentController.text.split(',').map((e) => e.trim()).toList());
      }

      final userInfo = {
        'height': _heightController.text,
        'weight': _weightController.text,
        'age': _ageController.text,
        'sex': _sex,
        'goals': finalGoals,
        'intensity': _intensity,
        'equipment': finalEquipment, // Use the selected or custom equipment
      };

      try {
        await ref.read(geminiWorkoutPlanProvider.notifier).generateWorkoutPlan(userInfo);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout plan generated successfully!')),
        );
        Navigator.pop(context); // Go back to WorkoutScreen
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
        title: Text('Generate Workout Plan', style: textTheme.titleLarge),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tell us about yourself to get a personalized workout plan!', style: textTheme.titleMedium),
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
                items: <String>['Male', 'Female']
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
              DropdownButtonFormField<String>(
                value: _selectedGoal,
                decoration: const InputDecoration(
                  labelText: 'Fitness Goals',
                  border: OutlineInputBorder(),
                ),
                items: _goalOptions
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGoal = newValue;
                    _showCustomGoalsField = newValue == 'Other';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your fitness goals';
                  }
                  return null;
                },
              ),
              if (_showCustomGoalsField) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _goalsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Custom Fitness Goals',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your custom fitness goals';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _intensity,
                decoration: const InputDecoration(
                  labelText: 'Workout Intensity',
                  border: OutlineInputBorder(),
                ),
                items: _intensityOptions
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _intensity = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your desired intensity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Available Equipment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: _equipmentOptions.map((equipment) {
                  return ChoiceChip(
                    label: Text(equipment),
                    selected: _selectedEquipment.contains(equipment),
                    onSelected: (selected) {
                      setState(() {
                        if (equipment == 'Other') {
                          _showCustomEquipmentField = selected;
                          if (!selected) {
                            _equipmentController.clear();
                          }
                        } else if (equipment == 'None') {
                          if (selected) {
                            _selectedEquipment = ['None'];
                            _showCustomEquipmentField = false;
                            _equipmentController.clear();
                          } else {
                            _selectedEquipment.remove('None');
                          }
                        } else {
                          if (_selectedEquipment.contains('None')) {
                            _selectedEquipment.remove('None');
                          }
                          if (selected) {
                            _selectedEquipment.add(equipment);
                          } else {
                            _selectedEquipment.remove(equipment);
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              if (_showCustomEquipmentField) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _equipmentController,
                  decoration: const InputDecoration(
                    labelText: 'Other Equipment (comma-separated)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_showCustomEquipmentField && (value == null || value.isEmpty)) {
                      return 'Please list your custom equipment';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              _isLoading
                  ? Column(
                    children: [
                      const Center(child: CircularProgressIndicator()),

                      const Text(
                        'Keep working out while we prepare your workout plan',
                      ),
                    ],
                  )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _generatePlan,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Generate Plan'),
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
