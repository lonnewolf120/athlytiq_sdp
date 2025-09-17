import 'package:flutter/material.dart';
import '../models/Exercise.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final VoidCallback? onAddToWorkout;

  const ExerciseCard({
    Key? key,
    required this.exercise,
    this.onTap,
    this.onAddToWorkout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Exercise GIF/Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child:
                      exercise.gifUrl != null
                          ? Image.network(
                            exercise.gifUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(
                                      Icons.fitness_center,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                          )
                          : Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.fitness_center,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                ),
              ),

              const SizedBox(width: 16),

              // Exercise Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise Name
                    Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Body Parts
                    if (exercise.bodyParts.isNotEmpty)
                      Wrap(
                        spacing: 4.0,
                        children:
                            exercise.bodyParts
                                .take(2)
                                .map(
                                  (bodyPart) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 2.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: Colors.blue.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      bodyPart,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),

                    const SizedBox(height: 4),

                    // Target Muscles
                    if (exercise.targetMuscles.isNotEmpty)
                      Text(
                        'Target: ${exercise.targetMuscles.take(2).join(', ')}${exercise.targetMuscles.length > 2 ? '...' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 4),

                    // Equipment
                    if (exercise.equipments.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${exercise.equipments.take(2).join(', ')}${exercise.equipments.length > 2 ? '...' : ''}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Add to Workout Button
              if (onAddToWorkout != null)
                Column(
                  children: [
                    IconButton(
                      onPressed: onAddToWorkout,
                      icon: const Icon(Icons.add_circle),
                      color: Colors.blue.shade600,
                      tooltip: 'Add to workout',
                    ),
                    Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
