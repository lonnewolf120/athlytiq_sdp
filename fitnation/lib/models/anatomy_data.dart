import 'package:fitnation/models/muscle_group.dart';
import 'package:fitnation/models/workout_split.dart';

/// Top-level container for the complete anatomy and workout split dataset.
///
/// Parsed from `assets/data/muscle_anatomy.json`.
class AnatomyData {
  final List<MuscleGroup> anatomyDatabase;
  final List<WorkoutSplit> workoutSplits;

  AnatomyData({
    required this.anatomyDatabase,
    required this.workoutSplits,
  });

  factory AnatomyData.fromJson(Map<String, dynamic> json) {
    return AnatomyData(
      anatomyDatabase: (json['anatomy_database'] as List<dynamic>?)
              ?.map((e) =>
                  MuscleGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      workoutSplits: (json['workout_splits'] as List<dynamic>?)
              ?.map((e) =>
                  WorkoutSplit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anatomy_database':
          anatomyDatabase.map((e) => e.toJson()).toList(),
      'workout_splits':
          workoutSplits.map((e) => e.toJson()).toList(),
    };
  }
}