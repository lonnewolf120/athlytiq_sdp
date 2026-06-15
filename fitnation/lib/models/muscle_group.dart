/// Represents a target sub-region within a muscle group (e.g., "Front Delt" within "Shoulder").
class TargetSubRegion {
  final String name;
  final String? notes;
  final List<String> exercises;

  TargetSubRegion({
    required this.name,
    this.notes,
    required this.exercises,
  });

  factory TargetSubRegion.fromJson(Map<String, dynamic> json) {
    return TargetSubRegion(
      name: json['name'] as String,
      notes: json['notes'] as String?,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (notes != null) 'notes': notes,
      'exercises': exercises,
    };
  }
}

/// Represents a muscle group with its target sub-regions and associated exercises.
///
/// Example: MuscleGroup(muscleGroupName: "Shoulder", targetSubRegions: [...])
class MuscleGroup {
  final String muscleGroupName;
  final List<TargetSubRegion> targetSubRegions;

  MuscleGroup({
    required this.muscleGroupName,
    required this.targetSubRegions,
  });

  factory MuscleGroup.fromJson(Map<String, dynamic> json) {
    return MuscleGroup(
      muscleGroupName: json['muscle_group'] as String,
      targetSubRegions: (json['target_sub_regions'] as List<dynamic>?)
              ?.map((e) =>
                  TargetSubRegion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'muscle_group': muscleGroupName,
      'target_sub_regions': targetSubRegions.map((e) => e.toJson()).toList(),
    };
  }

  /// Get all exercise names across all sub-regions.
  List<String> get allExercises {
    return targetSubRegions.expand((sr) => sr.exercises).toList();
  }
}