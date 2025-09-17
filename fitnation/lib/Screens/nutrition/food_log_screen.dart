import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:fitnation/providers/nutrition_provider.dart';

class FoodLogScreen extends ConsumerStatefulWidget {
  const FoodLogScreen({super.key});

  @override
  ConsumerState<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends ConsumerState<FoodLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _servingSizeController = TextEditingController();

  String _selectedMealType = 'breakfast';
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _servingSizeController.dispose();
    super.dispose();
  }

  Future<void> _saveFoodLog() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final foodLogData = {
          'food_name': _foodNameController.text.trim(),
          'calories': double.tryParse(_caloriesController.text) ?? 0.0,
          'protein': double.tryParse(_proteinController.text) ?? 0.0,
          'carbs': double.tryParse(_carbsController.text) ?? 0.0,
          'fat': double.tryParse(_fatController.text) ?? 0.0,
          'serving_size': _servingSizeController.text.trim(),
          'meal_type': _selectedMealType,
          'consumed_at': _selectedDateTime.toIso8601String(),
        };

        await ref.read(nutritionProvider.notifier).addFoodLog(foodLogData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Food logged successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging food: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Log Food',
          style: AppTextStyles.darkHeadlineMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.darkGradientStart,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Details Section
              _buildSectionHeader('Food Details', Icons.restaurant),
              const SizedBox(height: 16),
              _buildFoodDetailsCard(),

              const SizedBox(height: 24),

              // Nutrition Information Section
              _buildSectionHeader('Nutrition Information', Icons.analytics),
              const SizedBox(height: 16),
              _buildNutritionCard(),

              const SizedBox(height: 24),

              // Meal Details Section
              _buildSectionHeader('Meal Details', Icons.schedule),
              const SizedBox(height: 16),
              _buildMealDetailsCard(),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveFoodLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGradientStart,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(
                            'Log Food',
                            style: AppTextStyles.darkHeadlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
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
    );
  }

  Widget _buildFoodDetailsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _foodNameController,
              decoration: InputDecoration(
                labelText: 'Food Name',
                hintText: 'e.g., Grilled Chicken Breast',
                prefixIcon: Icon(
                  Icons.restaurant,
                  color: AppColors.darkGradientStart,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.darkGradientStart,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter food name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _servingSizeController,
              decoration: InputDecoration(
                labelText: 'Serving Size',
                hintText: 'e.g., 1 medium, 100g, 1 cup',
                prefixIcon: Icon(
                  Icons.straighten,
                  color: AppColors.darkGradientStart,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.darkGradientStart,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter serving size';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildNutritionField(
                    controller: _caloriesController,
                    label: 'Calories',
                    unit: 'kcal',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNutritionField(
                    controller: _proteinController,
                    label: 'Protein',
                    unit: 'g',
                    icon: Icons.fitness_center,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNutritionField(
                    controller: _carbsController,
                    label: 'Carbs',
                    unit: 'g',
                    icon: Icons.grain,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNutritionField(
                    controller: _fatController,
                    label: 'Fat',
                    unit: 'g',
                    icon: Icons.opacity,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionField({
    required TextEditingController controller,
    required String label,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '$label ($unit)',
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (double.tryParse(value) == null || double.parse(value) < 0) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Widget _buildMealDetailsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Meal Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedMealType,
              decoration: InputDecoration(
                labelText: 'Meal Type',
                prefixIcon: Icon(
                  Icons.restaurant_menu,
                  color: AppColors.darkGradientStart,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.darkGradientStart,
                    width: 2,
                  ),
                ),
              ),
              items:
                  _mealTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type[0].toUpperCase() + type.substring(1),
                        style: AppTextStyles.darkBodyMedium,
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMealType = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // Date & Time Selector
            InkWell(
              onTap: _selectDateTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: AppColors.darkGradientStart),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date & Time',
                            style: AppTextStyles.darkBodySmall.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} at ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                            style: AppTextStyles.darkBodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
