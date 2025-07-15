import 'package:fitnation/models/PlannedExercise.dart'; // Import PlannedExercise

class Workout {
  final String id;
  final String name;
  final String? iconUrl; // Icon for the workout plan
  final String? equipmentSelected; // e.g., "5 Selected"
  final String? oneRmGoal; // e.g., "100 kg"
  final String? type;
  final String? prompt; // Re-added as String type

  final List<PlannedExercise> exercises; // List of exercises in this plan

  Workout({
    required this.id,
    required this.name,
    this.iconUrl,
    this.equipmentSelected,
    this.type,
    this.oneRmGoal,
    this.prompt,
    required this.exercises,
  });

  // Factory constructor for JSON (loading plans)
  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String?,
      equipmentSelected: json['equipment_selected'] as String?,
      oneRmGoal: json['one_rm_goal'] as String?,
      type: json['type'] as String?,
      prompt: json['type'] as String?, // Assign type to prompt
      exercises:
          (json['exercises'] as List<dynamic>)
              .map((e) => PlannedExercise.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  // To JSON (saving plans)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_url': iconUrl,
      'equipment_selected': equipmentSelected,
      'one_rm_goal': oneRmGoal,
      'type': type, // Add type to toJson
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class WorkoutSummary {
  final String id;
  final String name;
  final String? iconUrl;
  final int exerciseCount;
  final List<WorkoutExerciseSummary> exercisesPreview;

  WorkoutSummary({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.exerciseCount,
    required this.exercisesPreview,
  });

  factory WorkoutSummary.fromWorkout(Workout workout) {
    return WorkoutSummary(
      id: workout.id,
      name: workout.name,
      iconUrl: workout.iconUrl,
      exerciseCount: workout.exercises.length,
      exercisesPreview:
          workout.exercises
              .take(3)
              .map((pe) => WorkoutExerciseSummary.fromPlannedExercise(pe))
              .toList(),
    );
  }
}

class WorkoutExerciseSummary {
  final String name;
  final String? equipment;
  final String setsReps;

  WorkoutExerciseSummary({
    required this.name,
    this.equipment,
    required this.setsReps,
  });

  factory WorkoutExerciseSummary.fromPlannedExercise(PlannedExercise pe) {
    return WorkoutExerciseSummary(
      name: pe.exerciseName,
      equipment: pe.exerciseEquipments?.join(', '), // Join list to string
      setsReps: '${pe.plannedSets}x${pe.plannedReps}',
    );
  }
}
