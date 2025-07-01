// lib/models/CompletedWorkoutSet.dart

import 'package:uuid/uuid.dart'; // For generating unique IDs

class CompletedWorkoutSet {
  final String id; // Unique ID for this completed set record
  final String weight;
  final String reps;
  final DateTime createdAt; // Timestamp for when the record was created

  CompletedWorkoutSet({
    String? id, // Optional, will generate if null
    required this.weight,
    required this.reps,
    DateTime? createdAt, // Optional, defaults to now
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // --- JSON serialization ---
  factory CompletedWorkoutSet.fromJson(Map<String, dynamic> json) {
    return CompletedWorkoutSet(
      id: json['id'] as String,
      weight: json['weight'] as String,
      reps: json['reps'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      'reps': reps,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // --- Database serialization (for sqflite) ---
  factory CompletedWorkoutSet.fromMap(Map<String, dynamic> map) {
    return CompletedWorkoutSet(
      id: map['id'] as String,
      weight: map['weight'] as String,
      reps: map['reps'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'reps': reps,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
