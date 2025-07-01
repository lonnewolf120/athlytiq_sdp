// import 'package:fitnation/models/CompletedWorkoutExercise.dart'; // Now in CompletedWorkout.dart
// import 'package:fitnation/models/CompletedWorkoutSet.dart'; // Now in CompletedWorkout.dart
import 'package:fitnation/models/CompletedWorkout.dart'; // Import the consolidated file
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For exercise GIF
import 'package:flutter/material.dart';

class CompletedWorkoutExerciseItem extends StatelessWidget {
  final CompletedWorkoutExercise
  exercise; // Now accepts CompletedWorkoutExercise

  const CompletedWorkoutExerciseItem({super.key, required this.exercise});

  // Helper to format sets in the "Sets x Reps @ Weight" style
  String _summarizeSets(List<CompletedWorkoutSet> sets) {
    if (sets.isEmpty) return '0 sets';
    // This is a simplified summary. A real app might group sets by reps/weight.
    // Let's show the count and the details of the first set.
    final firstSet = sets.first;
    String summary = '${sets.length} sets';
    if (firstSet.reps.isNotEmpty) {
      summary += ' x ${firstSet.reps} reps';
    }
    if (firstSet.weight.isNotEmpty) {
      summary += ' @ ${firstSet.weight} kg'; // Assuming kg
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise GIF/Icon
        CircleAvatar(
          radius: 16, // Smaller icon for list item
          backgroundColor: AppColors.mutedBackground,
          backgroundImage:
              exercise.exerciseGifUrl != null
                  ? CachedNetworkImageProvider(exercise.exerciseGifUrl!)
                  : null,
          child:
              exercise.exerciseGifUrl == null
                  ? Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: AppColors.mutedForeground,
                  ) // Placeholder icon
                  : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Name
              Text(
                exercise.exerciseName,
                style: AppTextStyles.bodyMedium?.copyWith(
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 4),
              // Sets Summary and Equipment
              Text(
                _summarizeSets(exercise.sets) +
                    (exercise.exerciseEquipments?.isNotEmpty == true
                        ? ' • ${exercise.exerciseEquipments!.join(', ')}'
                        : ''),
                style: AppTextStyles.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
