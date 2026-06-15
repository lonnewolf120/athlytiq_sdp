/// Represents a single exercise within a workout split day.
///
/// May include optional sets/reps prescribed for that split.
class SplitExercise {
  final String name;
  final String? targetMuscleGroup;
  final int? sets;
  final String? reps;

  SplitExercise({
    required this.name,
    this.targetMuscleGroup,
    this.sets,
    this.reps,
  });

  factory SplitExercise.fromJson(Map<String, dynamic> json) {
    return SplitExercise(
      name: json['name'] as String,
      targetMuscleGroup: json['target_muscle_group'] as String?,
      sets: json['sets'] as int?,
      reps: json['reps'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (targetMuscleGroup != null) 'target_muscle_group': targetMuscleGroup,
      if (sets != null) 'sets': sets,
      if (reps != null) 'reps': reps,
    };
  }
}

/// Represents a single training day within a workout split.
class SplitDay {
  final int dayNumber;
  final String focusArea;
  final List<SplitExercise> exercises;

  SplitDay({
    required this.dayNumber,
    required this.focusArea,
    required this.exercises,
  });

  factory SplitDay.fromJson(Map<String, dynamic> json) {
    return SplitDay(
      dayNumber: json['day_number'] as int,
      focusArea: json['focus_area'] as String,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) =>
                  SplitExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_number': dayNumber,
      'focus_area': focusArea,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

/// Represents a complete workout split (e.g., "PPL Split", "4 Day Split").
///
/// Contains multiple training days, each with its own focus area and exercises.
class WorkoutSplit {
  final String splitName;
  final List<SplitDay> days;

  WorkoutSplit({
    required this.splitName,
    required this.days,
  });

  factory WorkoutSplit.fromJson(Map<String, dynamic> json) {
    return WorkoutSplit(
      splitName: json['split_name'] as String,
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => SplitDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'split_name': splitName,
      'days': days.map((e) => e.toJson()).toList(),
    };
  }

  /// Total number of training days in this split.
  int get totalDays => days.length;

  /// Total number of exercises across all days.
  int get totalExercises => days.fold(0, (sum, day) => sum + day.exercises.length);
}