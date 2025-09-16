import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:fitnation/services/notification_service.dart';
import 'package:fitnation/providers/auth_provider.dart';

class NutritionTargetsScreen extends ConsumerStatefulWidget {
  const NutritionTargetsScreen({super.key});

  @override
  ConsumerState<NutritionTargetsScreen> createState() =>
      _NutritionTargetsScreenState();
}

class _NutritionTargetsScreenState
    extends ConsumerState<NutritionTargetsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();

  // Meal time controllers
  TimeOfDay? _breakfastTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay? _lunchTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay? _dinnerTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay? _snackTime = const TimeOfDay(hour: 15, minute: 0);

  bool _enableNotifications = true;
  bool _enableHydrationReminders = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentTargets();
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _loadCurrentTargets() {
    // Set default values based on user profile or previous settings
    _caloriesController.text = '2200';
    _proteinController.text = '130';
    _carbsController.text = '275';
    _fatController.text = '80';
  }

  Future<void> _saveTargets() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authState = ref.read(authProvider);
        String userName = 'User';
        if (authState is Authenticated) {
          userName = authState.user.displayName;
        }

        // Save nutrition targets to database
        final targets = {
          'target_calories':
              double.tryParse(_caloriesController.text) ?? 2200.0,
          'target_protein': double.tryParse(_proteinController.text) ?? 130.0,
          'target_carbs': double.tryParse(_carbsController.text) ?? 275.0,
          'target_fat': double.tryParse(_fatController.text) ?? 80.0,
        };

        // TODO: Save to database using DatabaseHelper
        // await DatabaseHelper().insertNutritionTargets(userId, targets);
        debugPrint('Nutrition targets to save: $targets');

        // Setup notifications if enabled
        if (_enableNotifications) {
          final notificationService = NotificationService();
          await notificationService.initialize();
          await notificationService.requestPermissions();

          await notificationService.scheduleDailyMealReminders(
            userName: userName,
            breakfastTime: _breakfastTime,
            lunchTime: _lunchTime,
            dinnerTime: _dinnerTime,
            snackTime: _snackTime,
          );

          if (_enableHydrationReminders) {
            await notificationService.scheduleHydrationReminder(
              userName: userName,
            );
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Nutrition targets and reminders saved successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving targets: $e'),
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

  Future<void> _selectTime(BuildContext context, String mealType) async {
    TimeOfDay? currentTime;
    switch (mealType) {
      case 'Breakfast':
        currentTime = _breakfastTime;
        break;
      case 'Lunch':
        currentTime = _lunchTime;
        break;
      case 'Dinner':
        currentTime = _dinnerTime;
        break;
      case 'Snack':
        currentTime = _snackTime;
        break;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        switch (mealType) {
          case 'Breakfast':
            _breakfastTime = picked;
            break;
          case 'Lunch':
            _lunchTime = picked;
            break;
          case 'Dinner':
            _dinnerTime = picked;
            break;
          case 'Snack':
            _snackTime = picked;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nutrition Targets',
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
              // Daily Nutrition Goals Section
              _buildSectionHeader('Daily Nutrition Goals', Icons.track_changes),
              const SizedBox(height: 16),
              _buildTargetCard(),

              const SizedBox(height: 32),

              // Meal Reminders Section
              _buildSectionHeader('Meal Reminders', Icons.schedule),
              const SizedBox(height: 16),
              _buildMealRemindersCard(),

              const SizedBox(height: 32),

              // Notification Settings Section
              _buildSectionHeader('Notification Settings', Icons.notifications),
              const SizedBox(height: 16),
              _buildNotificationSettingsCard(),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTargets,
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
                            'Save Targets',
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

  Widget _buildTargetCard() {
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
                  child: _buildTargetField(
                    controller: _caloriesController,
                    label: 'Calories',
                    unit: 'kcal',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTargetField(
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
                  child: _buildTargetField(
                    controller: _carbsController,
                    label: 'Carbs',
                    unit: 'g',
                    icon: Icons.grain,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTargetField(
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

  Widget _buildTargetField({
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
          return 'Please enter $label target';
        }
        if (double.tryParse(value) == null || double.parse(value) <= 0) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildMealRemindersCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMealTimeRow('Breakfast', Icons.wb_sunny, _breakfastTime),
            const Divider(),
            _buildMealTimeRow('Lunch', Icons.wb_sunny_outlined, _lunchTime),
            const Divider(),
            _buildMealTimeRow('Dinner', Icons.nights_stay, _dinnerTime),
            const Divider(),
            _buildMealTimeRow('Snack', Icons.local_cafe, _snackTime),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTimeRow(String meal, IconData icon, TimeOfDay? time) {
    return InkWell(
      onTap: () => _selectTime(context, meal),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.darkGradientStart),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                meal,
                style: AppTextStyles.darkBodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              time != null
                  ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                  : 'Not set',
              style: AppTextStyles.darkBodyMedium.copyWith(
                color: time != null ? AppColors.darkGradientStart : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettingsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                'Enable Meal Reminders',
                style: AppTextStyles.darkBodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Get notified when it\'s time to eat',
                style: AppTextStyles.darkBodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              value: _enableNotifications,
              onChanged: (value) {
                setState(() {
                  _enableNotifications = value;
                });
              },
              activeColor: AppColors.darkGradientStart,
            ),
            const Divider(),
            SwitchListTile(
              title: Text(
                'Hydration Reminders',
                style: AppTextStyles.darkBodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Regular reminders to stay hydrated',
                style: AppTextStyles.darkBodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              value: _enableHydrationReminders,
              onChanged: (value) {
                setState(() {
                  _enableHydrationReminders = value;
                });
              },
              activeColor: AppColors.darkGradientStart,
            ),
          ],
        ),
      ),
    );
  }
}
