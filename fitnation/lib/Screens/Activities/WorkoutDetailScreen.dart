import 'package:fitnation/Screens/Activities/ActiveWorkoutScreen.dart';
import 'package:fitnation/models/Workout.dart'; // Import the Workout model
import 'package:fitnation/models/Exercise.dart'
    as exercise_db; // Aliased to avoid conflict if any
import 'package:fitnation/core/themes/colors.dart'; // Import PlannedExercise
import 'package:fitnation/providers/active_workout_provider.dart'; // Correct import
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For icon URL
import 'package:fitnation/services/workout_notification_service.dart'; // Import notification service
import 'package:flutter/material.dart';
import 'package:fitnation/Screens/Activities/MealPlanGeneratorScreen.dart'; // Import MealPlanGeneratorScreen
import 'package:fitnation/helpers/exercise_database_helper.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workoutPlan; // Now accepts the full Workout model

  const WorkoutDetailScreen({
    super.key,
    required this.workoutPlan,
    required Workout workoutDetail, // Added for backward compatibility
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final WorkoutNotificationService _notificationService =
      WorkoutNotificationService();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initializeNotifications();
  }

  /// Resolve each PlannedExercise to a real catalog Exercise (full gif/muscles/instructions),
  /// then launch ActiveWorkoutScreen.
  Future<void> _startWorkout(BuildContext context) async {
    final db = ExerciseDatabaseHelper();
    await db.loadExercisesFromJson();

    final activeExercises = <ActiveWorkoutExercise>[];
    for (final pe in widget.workoutPlan.exercises) {
      // Try to get full exercise data from catalog
      exercise_db.Exercise? fullEx;
      if (pe.exerciseId.isNotEmpty) {
        fullEx = await db.getExerciseById(pe.exerciseId);
      }
      // Fallback: name search
      if (fullEx == null && pe.exerciseName.isNotEmpty) {
        final results = await db.searchExercises(query: pe.exerciseName, limit: 1);
        if (results.isNotEmpty) fullEx = results.first;
      }
      // Final fallback: build from PlannedExercise fields (same as before, but explicit)
      final baseEx = fullEx ??
          exercise_db.Exercise(
            exerciseId: pe.exerciseId,
            name: pe.exerciseName,
            gifUrl: pe.exerciseGifUrl ?? '',
            bodyParts: const [],
            equipments: pe.exerciseEquipments?.whereType<String>().toList() ?? const [],
            targetMuscles: const [],
            secondaryMuscles: const [],
            instructions: const [],
          );

      activeExercises.add(ActiveWorkoutExercise(
        baseExercise: baseEx,
        sets: List.generate(pe.plannedSets > 0 ? pe.plannedSets : 3, (_) {
          return ActiveWorkoutSet(
            weight: pe.plannedWeight ?? '',
            reps: pe.plannedReps > 0 ? pe.plannedReps.toString() : '',
          );
        }),
      ));
    }

    if (!context.mounted) return;

    final initialState = ActiveWorkoutState(
      id: widget.workoutPlan.id,
      workoutName: widget.workoutPlan.name,
      startTime: DateTime.now(),
      exercises: activeExercises,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutScreen(initialState: initialState),
      ),
    );
  }

  /// Show dialog to schedule workout with date/time picker
  Future<void> _showScheduleWorkoutDialog(BuildContext context) async {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Schedule Workout'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Schedule "${widget.workoutPlan.name}" for:'),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      selectedDate != null
                          ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                          : 'Select Date',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 1),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      selectedTime != null
                          ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                          : 'Select Time',
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          selectedTime = time;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      selectedDate != null && selectedTime != null
                          ? () => Navigator.of(dialogContext).pop(true)
                          : null,
                  child: const Text('Schedule'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && selectedDate != null && selectedTime != null) {
      await _scheduleWorkout(selectedDate!, selectedTime!);
    }
  }

  /// Schedule the workout notification
  Future<void> _scheduleWorkout(DateTime date, TimeOfDay time) async {
    final scheduledDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final success = await _notificationService.scheduleMultipleReminders(
      workoutId: widget.workoutPlan.id,
      workoutName: widget.workoutPlan.name,
      scheduledTime: scheduledDateTime,
      workoutType: widget.workoutPlan.type,
    );

    if (!mounted) return;

    if (success.any((s) => s)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Workout "${widget.workoutPlan.name}" scheduled for ${scheduledDateTime.day}/${scheduledDateTime.month} at ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to schedule workout notifications'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // No need for screenWidth here unless needed for specific layout adjustments

    return Scaffold(
      body: CustomScrollView(
        // Allows for AppBar collapsing effects
        slivers: [
          SliverAppBar(
            // No cover image in this UI, so a standard AppBar is fine
            // If adding a cover image, use expandedHeight and FlexibleSpaceBar
            // expandedHeight: 200.0,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.workoutPlan.name.toUpperCase(),
              style: textTheme.titleLarge,
            ),
            centerTitle: true,
            actions: [
              // Workout Icon (Circular) - Placed in AppBar actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CircleAvatar(
                  radius: 18, // Smaller radius for AppBar
                  backgroundColor: AppColors.mutedBackground,
                  backgroundImage:
                      widget.workoutPlan.iconUrl != null
                          ? CachedNetworkImageProvider(
                            widget.workoutPlan.iconUrl!,
                          )
                          : null,
                  child:
                      widget.workoutPlan.iconUrl == null
                          ? Icon(
                            Icons.fitness_center,
                            size: 18,
                            color: AppColors.primary,
                          ) // Default icon
                          : null,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  /* TODO: More options */
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile/Equipment/1RM Section
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (widget.workoutPlan.equipmentSelected != null &&
                              widget.workoutPlan.equipmentSelected!.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.workoutPlan.equipmentSelected!,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.foreground,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: AppColors.mutedForeground,
                                ),
                              ],
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1RM (Main Lift): ',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (widget.workoutPlan.oneRmGoal != null &&
                              widget.workoutPlan.oneRmGoal!.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.workoutPlan.oneRmGoal ?? 'N/A',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.foreground,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: AppColors.mutedForeground,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24), // Margin between sections
                  // Exercises List Section
                  Text(
                    '${widget.workoutPlan.exercises.length} exercises',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8), // Space after count
                ],
              ),
            ),
          ),

          // List of Exercises (using SliverList for efficiency)
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final exercise = widget.workoutPlan.exercises[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ), // Apply horizontal padding here
                child: Card(
                  color: Theme.of(context).cardColor,
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${exercise.exerciseName}',
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.cardForeground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Equipment: ${exercise.exerciseEquipments ?? ''}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Use Image.network for GIFs to ensure auto-play
                        if (exercise.exerciseGifUrl != null &&
                            exercise.exerciseGifUrl!.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: exercise.exerciseGifUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                            errorWidget:
                                (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  height: 200,
                                  width: double.infinity,
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 48,
                                  ),
                                ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }, childCount: widget.workoutPlan.exercises.length),
          ),

          // Add padding at the bottom of the list before buttons
          SliverToBoxAdapter(
            child: SizedBox(height: 24), // Margin before bottom buttons
          ),

          // Bottom Action Buttons (using SliverToBoxAdapter to put them in the scroll view)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _startWorkout(context),
                      child: const Text('START'),
                    ),
                  ),
                  const SizedBox(height: 12), // Margin between buttons
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showScheduleWorkoutDialog(context),
                      icon: const Icon(Icons.schedule),
                      label: const Text('Schedule Workout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12), // Margin between buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MealPlanGeneratorScreen(
                                  linkedWorkoutPlan:
                                      widget
                                          .workoutPlan, // Pass the workout plan
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text('Generate Meal Plan for this Workout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryForeground,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12), // Margin between buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          /* TODO: Regenerate workout logic */
                        },
                        icon: const Icon(Icons.refresh_outlined),
                        label: const Text('Regenerate'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.mutedForeground,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          /* TODO: Edit workout logic */
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
