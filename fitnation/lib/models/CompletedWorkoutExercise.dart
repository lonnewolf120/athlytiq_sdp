import 'package:fitnation/models/CompletedWorkoutSet.dart';
// No need to import Exercise.dart here, just reference its ID and store key details

import 'package:uuid/uuid.dart'; // For generating unique IDs

class CompletedWorkoutExercise {
  final String id; // Unique ID for this completed exercise record
  final String exerciseId; // Reference to the ExerciseDB exercise ID
  final String exerciseName; // Store name at time of completion
  final List<String>
      exerciseEquipments; // Store equipment list at time of completion
  final String? exerciseGifUrl; // Store GIF URL at time of completion
  final List<CompletedWorkoutSet> sets; // Actual sets recorded
  final DateTime createdAt; // Timestamp for when the record was created

  CompletedWorkoutExercise({
    String? id, // Optional, will generate if null
    required this.exerciseId,
    required this.exerciseName,
    required this.exerciseEquipments, // Requires list
    this.exerciseGifUrl,
    required this.sets,
    DateTime? createdAt, // Optional, defaults to now
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Factory constructor from JSON
  factory CompletedWorkoutExercise.fromJson(Map<String, dynamic> json) {
    return CompletedWorkoutExercise(
      id: json['id'] as String,
      exerciseId: json['exercise_id'] as String,
      exerciseName: json['exercise_name'] as String,
      exerciseEquipments: List<String>.from(
        json['exercise_equipments'] ?? [],
      ), // Parse list
      exerciseGifUrl: json['exercise_gif_url'] as String?,
      sets: (json['sets'] as List<dynamic>)
          .map(
            (e) => CompletedWorkoutSet.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'exercise_equipments': exerciseEquipments, // Save list
      'exercise_gif_url': exerciseGifUrl,
      'sets': sets.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // --- Database serialization (for sqflite) ---
  factory CompletedWorkoutExercise.fromMap(Map<String, dynamic> map) {
    return CompletedWorkoutExercise(
      id: map['id'] as String,
      exerciseId: map['exercise_id'] as String,
      exerciseName: map['exercise_name'] as String,
      exerciseEquipments: (map['exercise_equipments'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [], // Parse comma-separated string back to list
      exerciseGifUrl: map['exercise_gif_url'] as String?,
      sets: [], // Sets will be loaded separately
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'exercise_equipments': exerciseEquipments.join(','), // Store as comma-separated string
      'exercise_gif_url': exerciseGifUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper to get a single equipment string for display
  String get equipmentString => exerciseEquipments.join(', ');

  CompletedWorkoutExercise copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    List<String>? exerciseEquipments,
    String? exerciseGifUrl,
    List<CompletedWorkoutSet>? sets,
    DateTime? createdAt,
  }) {
    return CompletedWorkoutExercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseEquipments: exerciseEquipments ?? this.exerciseEquipments,
      exerciseGifUrl: exerciseGifUrl ?? this.exerciseGifUrl,
      sets: sets ?? this.sets,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
