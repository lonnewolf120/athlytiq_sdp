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
    // Helper to parse integer-like values safely
    int parseInt(dynamic v, {int fallback = 0}) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    List<String>? parseStringList(dynamic v) {
      if (v == null) return null;
      if (v is List) {
        return v
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
      // If it's a single string, try splitting by comma
      if (v is String) {
        return v
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return null;
    }

    return PlannedExercise(
      exerciseId: json['exercise_id']?.toString() ?? '',
      exerciseName: json['exercise_name']?.toString() ?? '',
      exerciseEquipments: parseStringList(json['exercise_equipment']),
      exerciseGifUrl: json['exercise_gif_url'] as String?,
      type: json['type'] as String?,
      plannedSets: parseInt(json['planned_sets'], fallback: 0),
      plannedReps: parseInt(json['planned_reps'], fallback: 0),
      plannedWeight: json['planned_weight']?.toString(),
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
