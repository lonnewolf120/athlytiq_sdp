import 'package:fitnation/models/WorkoutPostModel.dart'; // Assuming Exercise.dart is in lib/models/
// This model represents an exercise chosen for a workout plan or a workout post. It links to the Exercise definition and adds the plan-specific parameters.

class PlannedExercise {
  // Reference to the ExerciseDB exercise
  final String exerciseId;
  // Optionally store key details to avoid fetching the full Exercise just for display
  final String exerciseName;
  final String? type;
  final List<String?>? exerciseEquipments; // Equipment from ExerciseDB
  final String? exerciseGifUrl; // GIF URL from ExerciseDB

  // Plan-specific details
  final int plannedSets;
  final int plannedReps;
  final String? plannedWeight; // e.g., "Bodyweight", "135 lbs", or empty string

  PlannedExercise({
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseEquipments,
    this.exerciseGifUrl,
    this.type,
    required this.plannedSets,
    required this.plannedReps,
    this.plannedWeight,
  });

  // Factory constructor from JSON (for loading plans/posts from backend)
  factory PlannedExercise.fromJson(Map<String, dynamic> json) {
    return PlannedExercise(
      exerciseId: json['exercise_id'] as String,
      exerciseName: json['exercise_name'] as String,
      exerciseEquipments: (json['exercise_equipment'] as List<dynamic>?)
          ?.map((e) => e?.toString())
          .toList(),
      exerciseGifUrl: json['exercise_gif_url'] as String?,
      type: json['type'] as String?,
      plannedSets: json['planned_sets'] as int,
      plannedReps: json['planned_reps'] as int,
      plannedWeight: json['planned_weight'] as String?,
    );
  }

  // To JSON (for saving plans/posts to backend)
  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'exercise_equipment': exerciseEquipments,
      'exercise_gif_url': exerciseGifUrl,
      'planned_sets': plannedSets,
      'planned_reps': plannedReps,
      'planned_weight': plannedWeight,
    };
  }

  // Helper to get the "Sets x Reps" string for display
  String get setsRepsString => '${plannedSets} Sets x ${plannedReps} reps';

  get equipmentString => null;
}
