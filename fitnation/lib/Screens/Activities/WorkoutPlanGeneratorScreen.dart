import 'package:fitnation/Screens/shop_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/gemini_workout_provider.dart';
import 'dart:async'; // Import for Timer

class WorkoutPlanGeneratorScreen extends ConsumerStatefulWidget {
  const WorkoutPlanGeneratorScreen({super.key});

  @override
  ConsumerState<WorkoutPlanGeneratorScreen> createState() =>
      _WorkoutPlanGeneratorScreenState();
}

class _WorkoutPlanGeneratorScreenState
    extends ConsumerState<WorkoutPlanGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _goalsController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();

  String? _sex;
  String? _intensity;
  String? _selectedGoal;
  bool _showCustomGoalsField = false;
  bool _isLoading = false;
  List<String> _selectedEquipment = [];
  bool _showCustomEquipmentField = false;

  final List<String> _intensityOptions = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];
  final List<String> _goalOptions = [
    'Build muscle',
    'Lose weight',
    'Improve endurance',
    'Increase strength',
    'Improve flexibility',
    'General fitness',
    'Other',
  ];
  final List<String> _equipmentOptions = [
    'Dumbbells',
    'Barbell',
    'Resistance Bands',
    'Kettlebell',
    'Pull-up Bar',
    'Treadmill',
    'None',
    'Other',
  ];

  final List<String> _shopRecommendations = [
    'Dumbbells',
    'Barbell',
    'Kettlebell',
    'Pull-up Bar',
    'Treadmill',
  ];

  int _currentRecommendationIndex = 0;
  Timer? _recommendationTimer;

  @override
  void initState() {
    super.initState();
    _startRecommendationTimer();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _goalsController.dispose();
    _equipmentController.dispose();
    _recommendationTimer?.cancel(); // Cancel the timer
    super.dispose();
  }

  void _startRecommendationTimer() {
    _recommendationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentRecommendationIndex =
            (_currentRecommendationIndex + 1) % _shopRecommendations.length;
      });
    });
  }

  Future<void> _generatePlan() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String finalGoals =
          _selectedGoal == 'Other'
              ? _goalsController.text
              : (_selectedGoal ?? '');
      List<String> finalEquipment = List.from(_selectedEquipment);
      if (_showCustomEquipmentField) {
        finalEquipment.addAll(
          _equipmentController.text.split(',').map((e) => e.trim()).toList(),
        );
      }

      final userInfo = {
        'height': _heightController.text,
        'weight': _weightController.text,
        'age': _ageController.text,
        'sex': _sex,
        'goals': finalGoals,
        'intensity': _intensity,
        'equipment': finalEquipment,
      };

      try {
        await ref
            .read(geminiWorkoutPlanProvider.notifier)
            .generateWorkoutPlan(userInfo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Workout plan generated successfully!'),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to generate plan: $e')),
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Generate Workout Plan',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer.withOpacity(0.3),
                  colorScheme.secondaryContainer.withOpacity(0.2),
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 48,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'AI-Powered Workout Plan',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell us about yourself to get a personalized workout plan tailored to your goals and equipment!',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Form Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      'Personal Information',
                      Icons.person_rounded,
                      colorScheme,
                    ),
                    const SizedBox(height: 16),

                    // Height and Weight Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _heightController,
                            label: 'Height (cm)',
                            icon: Icons.height_rounded,
                            colorScheme: colorScheme,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _weightController,
                            label: 'Weight (kg)',
                            icon: Icons.monitor_weight_rounded,
                            colorScheme: colorScheme,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Age and Sex Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _ageController,
                            label: 'Age',
                            icon: Icons.cake_rounded,
                            colorScheme: colorScheme,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            value: _sex,
                            label: 'Sex',
                            icon: Icons.wc_rounded,
                            items: ['Male', 'Female'],
                            onChanged: (value) => setState(() => _sex = value),
                            colorScheme: colorScheme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle(
                      'Fitness Goals',
                      Icons.flag_rounded,
                      colorScheme,
                    ),
                    const SizedBox(height: 16),
                    _buildGoalSelection(colorScheme),
                    const SizedBox(height: 32),

                    _buildSectionTitle(
                      'Experience Level',
                      Icons.trending_up_rounded,
                      colorScheme,
                    ),
                    const SizedBox(height: 16),
                    _buildIntensitySelection(colorScheme),
                    const SizedBox(height: 32),

                    _buildSectionTitle(
                      'Available Equipment',
                      Icons.fitness_center_rounded,
                      colorScheme,
                    ),
                    const SizedBox(height: 16),
                    _buildEquipmentSelection(colorScheme),
                    // The _buildShopRecommendations now contains the button logic
                    _buildShopRecommendations(colorScheme),
                    const SizedBox(
                      height: 40,
                    ), // Spacing before the final generate button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
          top: 16,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _generatePlan,
            icon:
                _isLoading
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                    : const Icon(Icons.auto_awesome_rounded, size: 20),
            label: Text(
              _isLoading ? 'Generating...' : 'Generate My Workout Plan',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    required ColorScheme colorScheme,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items:
          items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an option';
        }
        return null;
      },
    );
  }

  Widget _buildGoalSelection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField(
          value: _selectedGoal,
          label: 'Primary Goal',
          icon: Icons.flag_rounded,
          items: _goalOptions,
          onChanged: (value) {
            setState(() {
              _selectedGoal = value;
              _showCustomGoalsField = value == 'Other';
            });
          },
          colorScheme: colorScheme,
        ),
        if (_showCustomGoalsField) ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _goalsController,
            label: 'Describe your custom goals',
            icon: Icons.edit_rounded,
            colorScheme: colorScheme,
            maxLines: 3,
            validator: (value) {
              if (_showCustomGoalsField && (value == null || value.isEmpty)) {
                return 'Please describe your goals';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildIntensitySelection(ColorScheme colorScheme) {
    return Column(
      children:
          _intensityOptions.map((intensity) {
            final isSelected = _intensity == intensity;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _intensity = intensity),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? colorScheme.primary
                                : colorScheme.outline.withOpacity(0.5),
                        width: isSelected ? 2 : 1,
                      ),
                      color:
                          isSelected
                              ? colorScheme.primaryContainer.withOpacity(0.3)
                              : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color:
                              isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                intensity,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isSelected
                                          ? colorScheme.primary
                                          : colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getIntensityDescription(intensity),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  // ONLY THIS WIDGET IS MODIFIED
  Widget _buildShopRecommendations(ColorScheme colorScheme) {
    if (_shopRecommendations.isEmpty) {
      return const SizedBox.shrink(); // Don't show if no recommendations
    }

    String currentEquipment = _shopRecommendations[_currentRecommendationIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32), // Add spacing before the recommendation
        Text(
          'Looking for equipment?',
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
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 226, 24, 5), // A red shade
                Color.fromARGB(255, 251, 4, 78), // An orange shade
                Color.fromARGB(255, 255, 0, 106), // A pinkish shade
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => ShopPage(initialCategory: currentEquipment),
                ),
              );
            },
            icon: const Icon(
              Icons.shopping_cart_rounded,
              size: 20,
              color: Colors.white,
            ),
            label: AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 500,
              ), // Transition duration
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.0, -1.0), // Start from top
                  end: Offset.zero,
                ).animate(animation);
                return ClipRect(
                  // Clip to prevent text from showing outside bounds during transition
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(
                      // Add fade for smoother transition
                      opacity: animation,
                      child: child,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  // Text(
                  //   '',
                  //   style: TextStyle(
                  //     fontSize: MediaQuery.of(context).size.width * 0.04,
                  //     fontWeight: FontWeight.w600,
                  //     color: Colors.white,
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // ),
                  Text(
                    key: ValueKey<int>(
                      _currentRecommendationIndex,
                    ), // Key for AnimatedSwitcher
                    'Buy the best & affordable $currentEquipment ',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      color:
                          Colors
                              .white, // Text color should contrast with gradient
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor:
                  Colors
                      .transparent, // Make button background transparent to show gradient
              foregroundColor:
                  Colors.white, // Ensure icon and text color are white
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

  Widget _buildEquipmentSelection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children:
              _equipmentOptions.map((equipment) {
                final isSelected = _selectedEquipment.contains(equipment);
                return FilterChip(
                  label: Text(equipment),
                  selected: isSelected,
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
                  backgroundColor:
                      isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surface,
                  selectedColor: colorScheme.primaryContainer,
                  checkmarkColor: colorScheme.onPrimaryContainer,
                  side: BorderSide(
                    color:
                        isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(0.5),
                  ),
                );
              }).toList(),
        ),
        if (_showCustomEquipmentField) ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _equipmentController,
            label: 'Other equipment (comma-separated)',
            icon: Icons.add_circle_outline_rounded,
            colorScheme: colorScheme,
            validator: (value) {
              if (_showCustomEquipmentField &&
                  (value == null || value.isEmpty)) {
                return 'Please list your equipment';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  String _getIntensityDescription(String intensity) {
    switch (intensity) {
      case 'Beginner':
        return 'New to working out or returning after a break';
      case 'Intermediate':
        return 'Regular exercise routine, comfortable with most movements';
      case 'Advanced':
        return 'Experienced athlete with excellent form and conditioning';
      default:
        return '';
    }
  }
}
