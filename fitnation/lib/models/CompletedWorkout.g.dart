// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CompletedWorkout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompletedWorkoutSet _$CompletedWorkoutSetFromJson(Map<String, dynamic> json) =>
    CompletedWorkoutSet(
      weight: json['weight'] as String,
      reps: json['reps'] as String,
    );

Map<String, dynamic> _$CompletedWorkoutSetToJson(
  CompletedWorkoutSet instance,
) => <String, dynamic>{'weight': instance.weight, 'reps': instance.reps};

CompletedWorkoutExercise _$CompletedWorkoutExerciseFromJson(
  Map<String, dynamic> json,
) => CompletedWorkoutExercise(
  exerciseId: json['exercise_id'] as String,
  exerciseName: json['exercise_name'] as String,
  exerciseEquipments:
      (json['exercise_equipments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  exerciseGifUrl: json['exercise_gif_url'] as String?,
  sets:
      (json['sets'] as List<dynamic>)
          .map((e) => CompletedWorkoutSet.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CompletedWorkoutExerciseToJson(
  CompletedWorkoutExercise instance,
) => <String, dynamic>{
  'exercise_id': instance.exerciseId,
  'exercise_name': instance.exerciseName,
  'exercise_equipments': instance.exerciseEquipments,
  'exercise_gif_url': instance.exerciseGifUrl,
  'sets': instance.sets.map((e) => e.toJson()).toList(),
};

CompletedWorkout _$CompletedWorkoutFromJson(
  Map<String, dynamic> json,
) => CompletedWorkout(
  originalWorkoutId: json['original_workout_id'] as String?,
  workoutName: json['workout_name'] as String,
  workoutIconUrl: json['workout_icon_url'] as String?,
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: DateTime.parse(json['end_time'] as String),
  durationSeconds: (json['duration_seconds'] as num).toInt(),
  intensityScore: (json['intensity_score'] as num).toDouble(),
  exercises:
      (json['exercises'] as List<dynamic>)
          .map(
            (e) => CompletedWorkoutExercise.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$CompletedWorkoutToJson(CompletedWorkout instance) =>
    <String, dynamic>{
      if (instance.originalWorkoutId case final value?)
        'original_workout_id': value,
      'workout_name': instance.workoutName,
      if (instance.workoutIconUrl case final value?) 'workout_icon_url': value,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'duration_seconds': instance.durationSeconds,
      'intensity_score': instance.intensityScore,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
    };
