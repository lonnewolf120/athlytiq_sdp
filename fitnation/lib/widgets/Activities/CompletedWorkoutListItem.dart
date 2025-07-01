// lib/widgets/Activities/CompletedWorkoutListItem.dart
import 'package:fitnation/Screens/Activities/CompletedWorkoutExerciseItem.dart';
import 'package:fitnation/models/CompletedWorkout.dart';
// import 'package:fitnation/models/CompletedWorkoutExercise.dart'; // Import exercise model
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For icon URL
import 'package:intl/intl.dart'; // For date formatting
// import 'package:fitnation/models/CompletedWorkoutSet.dart'; // Now in CompletedWorkout.dart

class CompletedWorkoutListItem extends StatefulWidget {
  final CompletedWorkout
  workout; //FIX TODO: replace with CompletedWorkoutExercise
  final VoidCallback? onViewDetails; // Callback to navigate to full detail screen

  const CompletedWorkoutListItem({
    super.key,
    required this.workout,
    this.onViewDetails,
  });

  @override
  State<CompletedWorkoutListItem> createState() => _CompletedWorkoutListItemState();
}

class _CompletedWorkoutListItemState extends State<CompletedWorkoutListItem> {
  bool _isExpanded = false; // State to manage expansion

  // Helper to format duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    return "${hours == '00' ? '' : '$hours:'}$minutes min"; // Hide hours if 00, add "min"
  }

   // Helper to format intensity
  String _formatIntensity(double intensity) {
     // Assuming intensity is 0-10 scale, maybe 1 decimal place
     return '${intensity.toStringAsFixed(0)}/10'; // Or 1 decimal: intensity.toStringAsFixed(1)
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: Column( // Use Column to stack header and expandable content
        children: [
          // Header Row (similar to ExpansionTile header)
          InkWell( // Make header tappable to toggle expansion
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  // Workout Icon (Circular)
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.mutedBackground,
                    backgroundImage: widget.workout.workoutIconUrl != null
                        ? CachedNetworkImageProvider(widget.workout.workoutIconUrl!)
                        : null, // Replace with actual icon loading logic
                    child: widget.workout.workoutIconUrl == null
                        ? Icon(Icons.fitness_center, size: 20, color: AppColors.primary) // Default icon
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.workout.workoutName, style: AppTextStyles.bodyLarge?.copyWith(color: AppColors.foreground, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(DateFormat.yMMMd().format(widget.workout.endTime), style: AppTextStyles.bodyMedium?.copyWith(color: AppColors.mutedForeground)), // Use end time for date
                      ],
                    ),
                  ),
                  // Duration and Intensity
                  Row(
                     mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_outlined, size: 16, color: AppColors.mutedForeground),
                      const SizedBox(width: 4),
                      Text(_formatDuration(widget.workout.duration), style: AppTextStyles.bodyMedium?.copyWith(color: AppColors.mutedForeground)),
                      const SizedBox(width: 12),
                       Icon(Icons.local_fire_department_outlined, size: 16, color: AppColors.primary), // Intensity icon
                      const SizedBox(width: 4),
                      Text(_formatIntensity(widget.workout.intensityScore), style: AppTextStyles.bodyMedium?.copyWith(color: AppColors.mutedForeground)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Expansion Indicator
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.mutedForeground,
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content (Exercises List and View Details Button)
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Inner padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Exercise List
                   ...widget.workout.exercises.map((exercise) => Padding(
                     padding: const EdgeInsets.only(bottom: 8.0),
                     child: CompletedWorkoutExerciseItem(exercise: exercise), // Use the new exercise item widget
                   )).toList(),
                   const SizedBox(height: 8),

                   // View Details Button
                   Align(
                     alignment: Alignment.centerRight,
                     child: TextButton(
                       onPressed: widget.onViewDetails,
                       child: const Text('View Details'),
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

class CompletedWorkoutExerciseItem extends StatelessWidget {
  final CompletedWorkoutExercise exercise;

  const CompletedWorkoutExerciseItem({super.key, required this.exercise});

  // Helper to format sets in the "Sets x Reps @ Weight" style
  String _summarizeSets(List<CompletedWorkoutSet> sets) {
    if (sets.isEmpty) return '0 sets';
    final firstSet = sets.first;
    String summary = '${sets.length} sets';
    if (firstSet.reps.isNotEmpty) {
       summary += ' x ${firstSet.reps} reps';
    }
    if (firstSet.weight.isNotEmpty) {
       summary += ' @ ${firstSet.weight} kg';
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
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.mutedBackground,
            shape: BoxShape.circle,
          ),
          child:
              (exercise.exerciseGifUrl != null &&
                      exercise.exerciseGifUrl!.isNotEmpty)
                  ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: exercise.exerciseGifUrl!,
                      fit: BoxFit.cover,
                      width: 32,
                      height: 32,
                      placeholder:
                          (context, url) => Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Icon(
                            Icons.fitness_center,
                            size: 16,
                            color: AppColors.mutedForeground,
                          ),
                    ),
                  )
                  : Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: AppColors.mutedForeground,
                  ),
         ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Name
              Text(exercise.exerciseName, style: AppTextStyles.bodyMedium?.copyWith(color: AppColors.foreground)),
              const SizedBox(height: 4),
              // Sets Summary and Equipment
              Text(
                _summarizeSets(exercise.sets) + (exercise.exerciseEquipments?.isNotEmpty == true ? ' • ${exercise.exerciseEquipments!.join(', ')}' : ''),
                style: AppTextStyles.bodyMedium?.copyWith(color: AppColors.mutedForeground),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
