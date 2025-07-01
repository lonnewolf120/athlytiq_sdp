import 'package:fitnation/providers/active_workout_provider.dart'; // Corrected import
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:fitnation/models/Exercise.dart' as exercise_db; // For baseExercise type
import 'package:cached_network_image/cached_network_image.dart';
import 'ActiveWorkout_Row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import ConsumerWidget

// Changed to ConsumerStatefulWidget
class ActiveWorkoutExerciseItem extends ConsumerStatefulWidget {
  final ActiveWorkoutExercise exercise; // This is from active_workout_provider.dart
  final int exerciseIndex;
  // final ValueChanged<ActiveWorkoutExercise> onExerciseUpdated; // Removed
  final VoidCallback onAddSet;
  final ValueChanged<int> onRemoveExercise;

  const ActiveWorkoutExerciseItem({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    // required this.onExerciseUpdated, // Removed
    required this.onAddSet,
    required this.onRemoveExercise,
  });

  @override
  ConsumerState<ActiveWorkoutExerciseItem> createState() =>
      _ActiveWorkoutExerciseItemState();
}

class _ActiveWorkoutExerciseItemState extends ConsumerState<ActiveWorkoutExerciseItem> { // Changed State to ConsumerState
  bool _isExpanded = true;

  void _onSetUpdated(
    int setIndex, {
    String? weight,
    String? reps,
    bool? isCompleted,
  }) {
    final activeExerciseId = widget.exercise.id;
    
    // Determine if this is just a completion toggle or a full update
    // This logic assumes that if isCompleted is provided, it's the primary change.
    // If weight or reps are also provided, it's a more general update.
    // The ActiveWorkoutSetRow should ideally differentiate this or always provide all fields.

    // For simplicity, we'll use the existing updateSet method in the provider,
    // which takes all fields. ActiveWorkoutSetRow's onSetUpdated callback
    // (which calls this _onSetUpdated) is triggered by ActiveWorkoutSetRow,
    // which should pass the complete state of the set being modified.

    // The `updatedSet` parameter in ActiveWorkoutSetRow's `onSetUpdated` callback
    // provides the new state of the set.
    // So, `weight`, `reps`, and `isCompleted` here are the new values from that `updatedSet`.

    ref.read(activeWorkoutProvider.notifier).updateSet(
      activeExerciseId,
      setIndex,
      weight ?? widget.exercise.sets[setIndex].weight, // Fallback, but updatedSet should provide this
      reps ?? widget.exercise.sets[setIndex].reps,       // Fallback, but updatedSet should provide this
      isCompleted ?? widget.exercise.sets[setIndex].isCompleted // Fallback, but updatedSet should provide this
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 12),
                  // Exercise GIF/Icon
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.mutedBackground,
                    backgroundImage:
                        widget.exercise.baseExercise.gifUrl != null && widget.exercise.baseExercise.gifUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(
                              widget.exercise.baseExercise.gifUrl!,
                            )
                            : null,
                    child:
                        (widget.exercise.baseExercise.gifUrl == null || widget.exercise.baseExercise.gifUrl!.isEmpty)
                            ? Icon(
                              Icons.fitness_center,
                              size: 16,
                              color: AppColors.mutedForeground,
                            )
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.exercise.baseExercise.name, // Use baseExercise
                          style: AppTextStyles.bodyLarge?.copyWith(
                            color: AppColors.foreground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Builder(builder: (context) { // Added Builder for context
                          final completedCount = widget.exercise.sets.where((s) => s.isCompleted).length;
                          final totalSets = widget.exercise.sets.length;
                          final equipmentString = widget.exercise.baseExercise.equipments.join(', ');
                          return Text(
                            '$completedCount/$totalSets Done' +
                                (equipmentString.isNotEmpty
                                    ? ' • $equipmentString'
                                    : ''),
                            style: AppTextStyles.bodyMedium?.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.mutedForeground,
                    ),
                    onPressed: () {
                      // Consider showing a confirmation dialog before removing
                      widget.onRemoveExercise(widget.exerciseIndex);
                    },
                    tooltip: 'Remove Exercise', // Changed tooltip
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                children: [
                  ...widget.exercise.sets.asMap().entries.map((entry) {
                    int setIndex = entry.key;
                    ActiveWorkoutSet set = entry.value; // Type is now from active_workout_provider
                    return ActiveWorkoutSetRow(
                      set: set,
                      setNumber: setIndex + 1,
                      onSetUpdated: (updatedSet) { // updatedSet is ActiveWorkoutSet
                        _onSetUpdated(
                          setIndex,
                          weight: updatedSet.weight,
                          reps: updatedSet.reps,
                          isCompleted: updatedSet.isCompleted,
                        );
                      },
                      // onRemoveSet: () { // Optional: if you want to remove individual sets
                      //   final updatedExercise = widget.exercise.copyWith(
                      //     sets: widget.exercise.sets.where((s) => s.id != set.id).toList()
                      //   );
                      //   widget.onExerciseUpdated(updatedExercise);
                      // }
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: widget.onAddSet, // This callback is passed from WorkoutScreen
                    icon: Icon(Icons.add_circle_outline, color: AppColors.primary), // Removed const
                    label: Text('Add a set', style: TextStyle(color: AppColors.primary)), // Removed const
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: AppColors.primary.withOpacity(0.5))
                        )
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
