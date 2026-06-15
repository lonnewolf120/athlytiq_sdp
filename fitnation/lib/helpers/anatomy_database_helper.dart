import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/anatomy_data.dart';
import '../models/muscle_group.dart';
import '../models/workout_split.dart';

/// Singleton helper for loading and querying the muscle anatomy & workout split data.
///
/// Data is loaded from `assets/data/muscle_anatomy.json` on first access
/// and cached in memory for the lifetime of the app.
///
/// Usage:
/// ```dart
/// final helper = AnatomyDatabaseHelper();
/// await helper.ensureLoaded();
/// final shoulder = helper.getMuscleGroupByName('Shoulder');
/// final splits = helper.getAllWorkoutSplits();
/// ```
class AnatomyDatabaseHelper {
  static final AnatomyDatabaseHelper _instance =
      AnatomyDatabaseHelper._internal();
  factory AnatomyDatabaseHelper() => _instance;
  AnatomyDatabaseHelper._internal();

  AnatomyData? _data;
  bool _isLoading = false;
  Future<void>? _loadingFuture;

  /// Whether the data has been loaded into memory.
  bool get isLoaded => _data != null;

  /// Ensures the anatomy data is loaded. Safe to call multiple times;
  /// subsequent calls return immediately if already loaded.
  Future<void> ensureLoaded() async {
    if (_data != null) return;
    if (_loadingFuture != null) return _loadingFuture!;

    _loadingFuture = _loadData();
    await _loadingFuture;
  }

  Future<void> _loadData() async {
    _isLoading = true;
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/muscle_anatomy.json',
      );

      // Parse JSON on a background isolate to avoid blocking UI
      final Map<String, dynamic> jsonMap = await compute(
        _parseJsonMap,
        jsonString,
      );

      _data = AnatomyData.fromJson(jsonMap);
      debugPrint(
        'AnatomyDatabaseHelper: Loaded '
        '${_data!.anatomyDatabase.length} muscle groups, '
        '${_data!.workoutSplits.length} workout splits',
      );
    } catch (e, st) {
      debugPrint('AnatomyDatabaseHelper: Error loading data: $e\n$st');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Top-level JSON parse helper for `compute()`.
  static Map<String, dynamic> _parseJsonMap(String jsonString) {
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // Anatomy queries
  // ---------------------------------------------------------------------------

  /// Returns all muscle groups in the anatomy database.
  List<MuscleGroup> getAllMuscleGroups() {
    _assertLoaded();
    return _data!.anatomyDatabase;
  }

  /// Finds a muscle group by name (case-insensitive).
  /// Returns `null` if not found.
  MuscleGroup? getMuscleGroupByName(String name) {
    _assertLoaded();
    final lower = name.toLowerCase();
    try {
      return _data!.anatomyDatabase.firstWhere(
        (mg) => mg.muscleGroupName.toLowerCase() == lower,
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns the target sub-regions for a given muscle group name.
  /// Returns an empty list if the muscle group is not found.
  List<TargetSubRegion> getSubRegionsForMuscle(String muscleGroup) {
    final mg = getMuscleGroupByName(muscleGroup);
    return mg?.targetSubRegions ?? [];
  }

  /// Returns exercise names for a specific sub-region within a muscle group.
  /// Returns an empty list if not found.
  List<String> getExercisesForSubRegion(
    String muscleGroup,
    String subRegionName,
  ) {
    final subRegions = getSubRegionsForMuscle(muscleGroup);
    try {
      final sr = subRegions.firstWhere(
        (s) => s.name.toLowerCase() == subRegionName.toLowerCase(),
      );
      return sr.exercises;
    } catch (_) {
      return [];
    }
  }

  /// Returns all exercise names across all muscle groups and sub-regions.
  List<String> getAllAnatomyExercises() {
    _assertLoaded();
    return _data!.anatomyDatabase.expand((mg) => mg.allExercises).toList();
  }

  // ---------------------------------------------------------------------------
  // Workout split queries
  // ---------------------------------------------------------------------------

  /// Returns all available workout splits.
  List<WorkoutSplit> getAllWorkoutSplits() {
    _assertLoaded();
    return _data!.workoutSplits;
  }

  /// Finds a workout split by name (case-insensitive).
  /// Returns `null` if not found.
  WorkoutSplit? getWorkoutSplitByName(String name) {
    _assertLoaded();
    final lower = name.toLowerCase();
    try {
      return _data!.workoutSplits.firstWhere(
        (ws) => ws.splitName.toLowerCase() == lower,
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns all focus areas (unique) across all workout splits.
  List<String> getAllFocusAreas() {
    _assertLoaded();
    final areas = <String>{};
    for (final split in _data!.workoutSplits) {
      for (final day in split.days) {
        areas.add(day.focusArea);
      }
    }
    return areas.toList()..sort();
  }

  /// Searches for exercises by name across both anatomy database and splits.
  /// Returns matching exercise names (deduplicated).
  List<String> searchExercises(String query) {
    _assertLoaded();
    final lower = query.toLowerCase();
    final results = <String>{};

    // Search anatomy database
    for (final mg in _data!.anatomyDatabase) {
      for (final sr in mg.targetSubRegions) {
        for (final exercise in sr.exercises) {
          if (exercise.toLowerCase().contains(lower)) {
            results.add(exercise);
          }
        }
      }
    }

    // Search workout splits
    for (final split in _data!.workoutSplits) {
      for (final day in split.days) {
        for (final exercise in day.exercises) {
          if (exercise.name.toLowerCase().contains(lower)) {
            results.add(exercise.name);
          }
        }
      }
    }

    return results.toList()..sort();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _assertLoaded() {
    assert(_data != null, 'AnatomyDatabaseHelper: Call ensureLoaded() first.');
  }
}