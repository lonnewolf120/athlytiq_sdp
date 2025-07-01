// import 'package:fitnation/models/All_Models.dart';
// lib/models/Exercise.dart
// Update this model to match the ExerciseDB API response structure

import 'package:fitnation/models/PlannedExercise.dart';
import 'package:fitnation/models/Exercise.dart';


class WorkoutPostData {
  final String workoutType;
  final int durationMinutes;
  final int caloriesBurned;
  final List<Exercise> exercises; // List of exercises in this post
  final String? notes;

  WorkoutPostData({
    required this.workoutType,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.exercises,
    this.notes,
  });

  // Factory constructor from JSON
factory WorkoutPostData.fromJson(Map<String, dynamic> json) {
    return WorkoutPostData(
      workoutType: json['workout_type'] as String,
      durationMinutes: json['duration_minutes'] as int,
      caloriesBurned: json['calories_burned'] as int,
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      notes: json['notes'] as String?,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'workout_type': workoutType,
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      if (notes != null) 'notes': notes,
    };
  }
}
