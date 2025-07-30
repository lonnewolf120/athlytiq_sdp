import 'package:fitnation/Screens/Activities/ActiveWorkoutScreen.dart';
import 'package:fitnation/models/Workout.dart'; // Import the Workout model
import 'package:fitnation/models/PlannedExercise.dart';
import 'package:fitnation/models/Exercise.dart'
    as exercise_db; // Aliased to avoid conflict if any
import 'package:fitnation/core/themes/colors.dart'; // Import PlannedExercise
import 'package:fitnation/providers/active_workout_provider.dart'; // Correct import
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For icon URL
import 'package:fitnation/widgets/Activities/WorkoutDetailExerciseItem.dart';
import 'package:flutter/material.dart';
import 'package:fitnation/Screens/Activities/MealPlanGeneratorScreen.dart'; // Import MealPlanGeneratorScreen

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workoutPlan; // Now accepts the full Workout model

  const WorkoutDetailScreen({
    super.key,
    required this.workoutPlan,
    required Workout workoutDetail,
  });

  // Helper function to parse planned sets from string like "4 Sets x 8 reps"
  // This helper is no longer strictly needed if PlannedExercise stores sets/reps as ints,
  // but keep it if you need to parse from a string representation elsewhere.
  int _parsePlannedSets(String setsReps) {
    try {
      final parts = setsReps.split(' Sets x ');
      if (parts.isNotEmpty) {
        return int.tryParse(parts[0]) ?? 0;
      }
    } catch (e) {
      print('Error parsing sets from string: $setsReps - $e');
    }
    return 0; // Default to 0 sets if parsing fails
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
              workoutPlan.name.toUpperCase(),
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
                      workoutPlan.iconUrl != null
                          ? CachedNetworkImageProvider(workoutPlan.iconUrl!)
                          : null,
                  child:
                      workoutPlan.iconUrl == null
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
                          if (workoutPlan.equipmentSelected != null &&
                              workoutPlan.equipmentSelected!.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  workoutPlan.equipmentSelected!,
                                  style: AppTextStyles.bodyLarge?.copyWith(
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
                          if (workoutPlan.oneRmGoal != null &&
                              workoutPlan.oneRmGoal!.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  workoutPlan.oneRmGoal ?? 'N/A',
                                  style: AppTextStyles.bodyLarge?.copyWith(
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
                    '${workoutPlan.exercises.length} exercises',
                    style: AppTextStyles.bodyLarge?.copyWith(
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
              final exercise = workoutPlan.exercises[index];
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
            }, childCount: workoutPlan.exercises.length),
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
                      onPressed: () {
                        // Create the initial state for the ActiveWorkoutState
                        final initialActiveState = ActiveWorkoutState(
                          id:
                              workoutPlan
                                  .id, // Use 'id' from ActiveWorkoutState
                          workoutName: workoutPlan.name,
                          startTime: DateTime.now(),
                          exercises:
                              workoutPlan.exercises.map((pe) {
                                // Create a base exercise_db.Exercise from PlannedExercise
                                // This is a bit of a workaround as PlannedExercise is not directly exercise_db.Exercise
                                // Ideally, PlannedExercise would hold a full exercise_db.Exercise object or enough info
                                final baseEx = exercise_db.Exercise(
                                  exerciseId: pe.exerciseId,
                                  name: pe.exerciseName,
                                  gifUrl: pe.exerciseGifUrl ?? '',
                                  bodyParts:
                                      [], // Placeholder or map from PlannedExercise if available
                                  equipments:
                                      pe.exerciseEquipments
                                          ?.whereType<String>()
                                          .toList() ??
                                      [],
                                  targetMuscles: [], // Placeholder
                                  secondaryMuscles: [], // Placeholder
                                  instructions: [], // Placeholder
                                );
                                return ActiveWorkoutExercise(
                                  baseExercise:
                                      baseEx, // Pass the created baseExercise
                                  sets: List.generate(
                                    pe.plannedSets,
                                    (_) => ActiveWorkoutSet(),
                                  ),
                                );
                              }).toList(),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ActiveWorkoutScreen(
                                  initialState: initialActiveState,
                                ),
                          ),
                        );
                      },
                      child: const Text('START'),
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
                                      workoutPlan, // Pass the workout plan
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
