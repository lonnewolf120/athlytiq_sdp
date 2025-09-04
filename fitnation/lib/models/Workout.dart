import 'package:fitnation/models/PlannedExercise.dart'; // Import PlannedExercise
import 'package:flutter/foundation.dart'; // For debugPrint

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
    // Normalize and defensively parse fields
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final iconUrl = json['icon_url'] as String?;
    final equipmentSelected = json['equipment_selected'] as String?;
    final oneRmGoal = json['one_rm_goal'] as String?;
    final type = json['type'] as String?;
    final prompt =
        json['prompt'] is String
            ? json['prompt'] as String
            : (json['prompt']?.toString());

    List<PlannedExercise> exercisesList = [];
    try {
      final rawExercises = json['exercises'];
      if (rawExercises is List) {
        exercisesList =
            rawExercises
                .where((e) => e != null)
                .map((e) => PlannedExercise.fromJson(e as Map<String, dynamic>))
                .toList();
      }
    } catch (e, st) {
      debugPrint('Workout.fromJson: Warning - could not parse exercises: $e');
      debugPrint('Workout.fromJson: Stacktrace: $st');
      exercisesList = [];
    }

    return Workout(
      id: id,
      name: name,
      iconUrl: iconUrl,
      equipmentSelected: equipmentSelected,
      oneRmGoal: oneRmGoal,
      type: type,
      prompt: prompt,
      exercises: exercisesList,
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
