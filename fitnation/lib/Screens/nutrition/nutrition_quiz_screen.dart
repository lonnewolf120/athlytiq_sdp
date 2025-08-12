import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/auth_provider.dart';
import 'package:fitnation/api/API_Services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NutritionQuizScreen extends ConsumerStatefulWidget {
  const NutritionQuizScreen({super.key});

  @override
  ConsumerState<NutritionQuizScreen> createState() =>
      _NutritionQuizScreenState();
}

class _NutritionQuizScreenState extends ConsumerState<NutritionQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  String _activityLevel = 'Moderate (3-5 d/wk)'; // Default
  String _goal = 'Maintain Weight'; // Default
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _gender = 'Male'; // Default

  final ApiService _apiService = ApiService(
    Dio(),
    FlutterSecureStorage(),
  ); // Assuming ApiService can update user profiles

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submitQuiz() async {
    if (_formKey.currentState!.validate()) {
      final authState = ref.read(authProvider);
      String? userId;
      if (authState is Authenticated) {
        userId = authState.user.id;
      }

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not authenticated. Cannot save profile.'),
          ),
        );
        return;
      }

      final double height = double.tryParse(_heightController.text) ?? 0.0;
      final double weight = double.tryParse(_weightController.text) ?? 0.0;
      final int age = int.tryParse(_ageController.text) ?? 0;

      // Update user profile with new data
      try {
        await _apiService.updateUserProfile(userId, {
          'height_cm': height,
          'weight_kg': weight,
          'age': age,
          'gender': _gender,
          'fitness_goals': _goal, // Storing goal in fitness_goals
          'activity_level':
              _activityLevel, // Assuming backend can handle this field
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated and quiz submitted successfully!'),
          ),
        );
        Navigator.pop(context); // Go back after submission
      } catch (e) {
        print('Error submitting quiz: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error submitting quiz: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Goals')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid height';
                  }
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items:
                    <String>[
                      'Male',
                      'Female',
                      'Other',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue!;
                  });
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              DropdownButtonFormField<String>(
                value: _activityLevel,
                decoration: const InputDecoration(labelText: 'Activity Level'),
                items:
                    <String>[
                      'Sedentary (no exercise)',
                      'Lightly Active (1-3 d/wk)',
                      'Moderate (3-5 d/wk)',
                      'Very Active (6-7 d/wk)',
                      'Extra Active',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Wrap(children: [Text(value)]),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _activityLevel = newValue!;
                  });
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              DropdownButtonFormField<String>(
                value: _goal,
                decoration: const InputDecoration(labelText: 'Fitness Goal'),
                items:
                    <String>[
                      'Maintain Weight',
                      'Lose Weight',
                      'Gain Weight',
                      'Build Muscle',
                      'Improve Endurance',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _goal = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitQuiz,
                child: const Text('Submit Info'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
