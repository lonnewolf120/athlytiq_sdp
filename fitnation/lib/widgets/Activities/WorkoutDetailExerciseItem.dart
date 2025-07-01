import 'package:fitnation/models/PlannedExercise.dart';
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class WorkoutDetailExerciseItem extends StatelessWidget {
  final PlannedExercise exercise;

  const WorkoutDetailExerciseItem({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Exercise GIF/Icon
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.mutedBackground,
            // backgroundImage:
            //     exercise.exerciseGifUrl != null &&
            //             exercise
            //                 .exerciseGifUrl!
            //                 .isNotEmpty // Check for empty string too
            //         ? CachedNetworkImageProvider(exercise.exerciseGifUrl!)
            //         : null,
            child:
                (exercise.exerciseGifUrl == null ||
                        exercise.exerciseGifUrl!.isEmpty)
                    ? Icon(
                      Icons.fitness_center,
                      size: 20,
                      color: AppColors.mutedForeground,
                    ) // Placeholder icon
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseName,
                  style: AppTextStyles.bodyLarge?.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Display planned sets, reps, weight, and equipment
                Text(
                  '${exercise.setsRepsString}${exercise.plannedWeight != null && exercise.plannedWeight!.isNotEmpty ? ' • ${exercise.plannedWeight}' : ''}${exercise.exerciseEquipments!.isNotEmpty ? ' • ${exercise.equipmentString}' : ''}', // Use equipmentString helper
                  style: AppTextStyles.bodyMedium?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
