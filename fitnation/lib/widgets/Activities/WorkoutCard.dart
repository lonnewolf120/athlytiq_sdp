// lib/workouts/widgets/workout_card.dart
import 'package:fitnation/models/Workout.dart';
import 'package:fitnation/core/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For icon URL

class WorkoutCard extends StatelessWidget {
  final WorkoutSummary workout;
  final VoidCallback? onTap;

  const WorkoutCard({super.key, required this.workout, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workout.name, style: textTheme.headlineSmall?.copyWith(color: AppColors.cardForeground)),
                    const SizedBox(height: 4),
                    Text('${workout.exerciseCount} exercises', style: textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground)),
                    const SizedBox(height: 8),
                    // Exercise previews
                    ...workout.exercisesPreview.map((exercise) => Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        '${exercise.name} • ${exercise.equipment ?? ''} ${exercise.setsReps}',
                        style: textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                    const SizedBox(height: 8),
                    Text('View all', style: textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Workout Icon (Circular)
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.mutedBackground,
                backgroundImage: workout.iconUrl != null
                    ? CachedNetworkImageProvider(workout.iconUrl!)
                    : null, // Replace with actual icon loading logic
                child: workout.iconUrl == null
                    ? Icon(Icons.fitness_center, size: 30, color: AppColors.primary) // Default icon
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}