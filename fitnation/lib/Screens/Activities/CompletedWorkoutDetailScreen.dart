import 'package:fitnation/models/CompletedWorkout.dart';
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompletedWorkoutDetailScreen extends StatelessWidget {
  final CompletedWorkout workout;

  const CompletedWorkoutDetailScreen({super.key, required this.workout});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "${hours == '00' ? '' : '$hours:'}$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.workoutName, style: textTheme.titleLarge),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Workout Summary', style: textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    'Date',
                    DateFormat.yMMMd().format(workout.endTime),
                  ),
                  _buildInfoRow(
                    context,
                    Icons.access_time,
                    'Duration',
                    _formatDuration(workout.duration),
                  ),
                  _buildInfoRow(
                    context,
                    Icons.local_fire_department,
                    'Intensity Score',
                    '${workout.intensityScore.toStringAsFixed(1)}/10',
                  ),
                  _buildInfoRow(
                    context,
                    Icons.start,
                    'Start Time',
                    DateFormat.jm().format(workout.startTime),
                  ),
                  _buildInfoRow(
                    context,
                    Icons.stop,
                    'End Time',
                    DateFormat.jm().format(workout.endTime),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Exercises Performed', style: textTheme.titleLarge),
          const SizedBox(height: 16),
          if (workout.exercises.isEmpty)
            Center(
              child: Text(
                'No exercises recorded for this workout.',
                style: textTheme.bodyMedium,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workout.exercises.length,
              itemBuilder: (context, index) {
                final exercise = workout.exercises[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.exerciseName,
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (exercise.exerciseEquipments?.isNotEmpty == true)
                          _buildInfoRow(
                            context,
                            Icons.fitness_center,
                            'Equipment',
                            exercise.exerciseEquipments!.join(', '),
                          ),
                        const SizedBox(height: 8),
                        Text('Sets:', style: textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: exercise.sets.length,
                          itemBuilder: (context, setIndex) {
                            final set = exercise.sets[setIndex];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                'Set ${setIndex + 1}: ${set.reps} reps @ ${set.weight}',
                                style: textTheme.bodyMedium,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.mutedForeground),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
