import 'package:fitnation/models/PlannedExercise.dart'; // Import PlannedExercise
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart'; 

class WorkoutDetailWidget extends StatelessWidget {
  // Renamed to avoid conflict with model
  final List<PlannedExercise> exercises;

  const WorkoutDetailWidget({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView.builder(
      padding: EdgeInsets.zero, // Remove default ListView padding
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        // Use a similar item layout as in the UI
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              // Exercise GIF/Icon
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.mutedBackground,
                // backgroundImage:
                //     exercise.exerciseGifUrl != null
                //         ? CachedNetworkImageProvider(exercise.exerciseGifUrl!)
                //         : null,
                child:
                    exercise.exerciseGifUrl == null
                        ? Icon(
                          Icons.fitness_center,
                          size: 20,
                          color: AppColors.mutedForeground,
                        )
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
                    Text(
                      '${exercise.setsRepsString}' +
                          (exercise.plannedWeight != null &&
                                  exercise.plannedWeight!.isNotEmpty
                              ? ' • ${exercise.plannedWeight}'
                              : ''),
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
      },
    );
  }
}
