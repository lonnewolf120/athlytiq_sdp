import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/models/Exercise.dart' as exercise_db; // From ExerciseDB
import 'package:fitnation/models/CompletedWorkout.dart';
// import 'package:fitnation/models/CompletedWorkoutExercise.dart'; // Now in CompletedWorkout.dart
// import 'package:fitnation/models/CompletedWorkoutSet.dart'; // Now in CompletedWorkout.dart
import 'package:uuid/uuid.dart';
import 'package:fitnation/api/API_Services.dart'; // For ApiService
import 'package:fitnation/services/database_helper.dart'; // For DatabaseHelper
import 'package:flutter/foundation.dart'; // For debugPrint

const _uuid = Uuid();

// --- State Classes for Active Workout ---

class ActiveWorkoutSet {
  final String id;
  String weight;
  String reps;
  bool isCompleted;

  ActiveWorkoutSet({
    String? id,
    this.weight = '',
    this.reps = '',
    this.isCompleted = false,
  }) : id = id ?? _uuid.v4();

  ActiveWorkoutSet copyWith({
    String? id,
    String? weight,
    String? reps,
    bool? isCompleted,
  }) {
    return ActiveWorkoutSet(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ActiveWorkoutExercise {
  final String id; // Unique ID for this instance in the active workout
  final exercise_db.Exercise baseExercise; // Reference to the ExerciseDB model
  List<ActiveWorkoutSet> sets;

  ActiveWorkoutExercise({
    String? id,
    required this.baseExercise,
    List<ActiveWorkoutSet>? sets,
  })  : id = id ?? _uuid.v4(),
        sets = sets ?? [];

  // Helper to add a default set based on planned sets/reps if available
  // Or just an empty set
  void addSet({String weight = '', String reps = ''}) {
    sets.add(ActiveWorkoutSet(weight: weight, reps: reps));
  }

  ActiveWorkoutExercise copyWith({
    String? id,
    exercise_db.Exercise? baseExercise,
    List<ActiveWorkoutSet>? sets,
  }) {
    return ActiveWorkoutExercise(
      id: id ?? this.id,
      baseExercise: baseExercise ?? this.baseExercise,
      sets: sets ?? this.sets,
    );
  }
}

class ActiveWorkoutState {
  final String? id; // ID for an existing workout being edited, or null for new
  String workoutName;
  DateTime? startTime;
  DateTime? endTime;
  List<ActiveWorkoutExercise> exercises;
  double? intensityScore; // User reported RPE

  ActiveWorkoutState({
    this.id,
    this.workoutName = 'My Workout', // Default name
    this.startTime,
    this.endTime,
    List<ActiveWorkoutExercise>? exercises,
    this.intensityScore,
  }) : exercises = exercises ?? [];

  ActiveWorkoutState copyWith({
    String? id,
    String? workoutName,
    DateTime? startTime,
    DateTime? endTime,
    List<ActiveWorkoutExercise>? exercises,
    double? intensityScore,
    bool clearStartTime = false, // Special flag to nullify startTime
    bool clearEndTime = false,   // Special flag to nullify endTime
  }) {
    final newStartTime = clearStartTime ? null : (startTime ?? this.startTime);
    // debugPrint("ActiveWorkoutState.copyWith: oldStartTime=${this.startTime}, newStartTimeAttempted=${startTime}, clearStartTime=${clearStartTime}, finalNewStartTime=${newStartTime}");
    return ActiveWorkoutState(
      id: id ?? this.id,
      workoutName: workoutName ?? this.workoutName,
      startTime: newStartTime,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      exercises: exercises ?? this.exercises,
      intensityScore: intensityScore ?? this.intensityScore,
    );
  }

  Duration? get duration {
    if (startTime != null && endTime != null && endTime!.isAfter(startTime!)) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  bool get isStarted => startTime != null;
  bool get isFinished => endTime != null;
}

// --- StateNotifier ---

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState> {
  ActiveWorkoutNotifier() : super(ActiveWorkoutState()) {
    // debugPrint("ActiveWorkoutNotifier: Initialized. Initial state startTime: ${state.startTime}");
  }

  @override
  set state(ActiveWorkoutState newState) {
    // debugPrint("ActiveWorkoutNotifier: State is being set. Old startTime: ${state.startTime}, New startTime: ${newState.startTime}");
    // debugPrint("ActiveWorkoutNotifier: State is being set. Old endTime: ${state.endTime}, New endTime: ${newState.endTime}");
    // debugPrint("ActiveWorkoutNotifier: State is being set. Old intensityScore: ${state.intensityScore}, New intensityScore: ${newState.intensityScore}");
    super.state = newState;
  }

  void startWorkout({String? name}) {
    debugPrint("ActiveWorkoutNotifier: startWorkout called. Current state startTime: ${state.startTime}");
    final newStartTime = DateTime.now();
    state = state.copyWith(
      startTime: newStartTime,
      workoutName: name ?? 'Workout Session - ${DateTime.now().toIso8601String().substring(0,10)}',
      clearEndTime: true, // Ensure endTime is cleared if restarting
      intensityScore: null, // Clear previous intensity
    );
    debugPrint("ActiveWorkoutNotifier: startWorkout finished. New state startTime: ${state.startTime}");
  }

  void setWorkoutName(String name) {
    // debugPrint("ActiveWorkoutNotifier: setWorkoutName called. Name: $name");
    state = state.copyWith(workoutName: name);
  }

  void addExercise(exercise_db.Exercise exercise) {
    // debugPrint("ActiveWorkoutNotifier: addExercise called. Exercise: ${exercise.name}");
    final newActiveExercise = ActiveWorkoutExercise(baseExercise: exercise);
    // Add a few default sets, e.g., 3 empty sets
    for (int i = 0; i < 3; i++) {
      newActiveExercise.addSet();
    }
    state = state.copyWith(exercises: [...state.exercises, newActiveExercise]);
  }

  void removeExercise(String activeExerciseId) {
    state = state.copyWith(
      exercises: state.exercises.where((ex) => ex.id != activeExerciseId).toList(),
    );
  }

  void addSetToExercise(String activeExerciseId, {String weight = '', String reps = ''}) {
    state = state.copyWith(
      exercises: state.exercises.map((ex) {
        if (ex.id == activeExerciseId) {
          final updatedExercise = ex.copyWith();
          updatedExercise.addSet(weight: weight, reps: reps);
          return updatedExercise;
        }
        return ex;
      }).toList(),
    );
  }
  
  void updateSet(String activeExerciseId, int setIndex, String weight, String reps, bool isCompleted) {
    state = state.copyWith(
      exercises: state.exercises.map((ex) {
        if (ex.id == activeExerciseId) {
          if (setIndex < ex.sets.length) {
            final updatedSets = List<ActiveWorkoutSet>.from(ex.sets);
            updatedSets[setIndex] = updatedSets[setIndex].copyWith(
              weight: weight,
              reps: reps,
              isCompleted: isCompleted,
            );
            return ex.copyWith(sets: updatedSets);
          }
        }
        return ex;
      }).toList(),
    );
  }

  void toggleSetComplete(String activeExerciseId, int setIndex) {
     state = state.copyWith(
      exercises: state.exercises.map((ex) {
        if (ex.id == activeExerciseId) {
          if (setIndex < ex.sets.length) {
            final updatedSets = List<ActiveWorkoutSet>.from(ex.sets);
            final currentSet = updatedSets[setIndex];
            updatedSets[setIndex] = currentSet.copyWith(isCompleted: !currentSet.isCompleted);
            return ex.copyWith(sets: updatedSets);
          }
        }
        return ex;
      }).toList(),
    );
  }
  
  void removeSetFromExercise(String activeExerciseId, String setId) {
    state = state.copyWith(
      exercises: state.exercises.map((ex) {
        if (ex.id == activeExerciseId) {
          return ex.copyWith(sets: ex.sets.where((s) => s.id != setId).toList());
        }
        return ex;
      }).toList(),
    );
  }

  void finishWorkout(double intensity) {
    debugPrint("ActiveWorkoutNotifier: finishWorkout called. Current state startTime: ${state.startTime}");
    if (state.startTime == null) {
      debugPrint("ActiveWorkoutNotifier: ERROR in finishWorkout - Workout not started (startTime is null).");
      return;
    }
    final newEndTime = DateTime.now();
    state = state.copyWith(
      endTime: newEndTime,
      intensityScore: intensity,
    );
    debugPrint("ActiveWorkoutNotifier: finishWorkout finished. New state endTime: ${state.endTime}, intensityScore: ${state.intensityScore}");
  }

  CompletedWorkout? generateCompletedWorkoutData(String userId) {
    debugPrint("generateCompletedWorkoutData: Checking conditions...");
    debugPrint("  state.isFinished: ${state.isFinished}");
    debugPrint("  state.startTime: ${state.startTime}");
    debugPrint("  state.endTime: ${state.endTime}");
    debugPrint("  state.duration: ${state.duration}");
    debugPrint("  state.intensityScore: ${state.intensityScore}");

    if (!state.isFinished || state.startTime == null || state.duration == null || state.intensityScore == null) {
      debugPrint("generateCompletedWorkoutData: Condition 1 FAILED - Workout not ready (isFinished, startTime, duration, or intensityScore is null/false).");
      return null; // Not ready to be completed
    }

    List<CompletedWorkoutExercise> completedExercises = [];
    for (var activeEx in state.exercises) {
      debugPrint("generateCompletedWorkoutData: Processing ActiveExercise ID: ${activeEx.id}, Name: ${activeEx.baseExercise.name}");
      activeEx.sets.asMap().forEach((idx, s) {
        debugPrint("  Set $idx for ${activeEx.baseExercise.name}: id=${s.id}, weight='${s.weight}', reps='${s.reps}', isCompleted=${s.isCompleted}");
      });
      List<CompletedWorkoutSet> completedSets = activeEx.sets
          .where((s) => s.isCompleted) // Only include completed sets
          .map((s) => CompletedWorkoutSet(id: s.id, weight: s.weight, reps: s.reps, createdAt: DateTime.now())) // Assuming createdAt for set is now
          .toList();
      debugPrint("  Found ${completedSets.length} completed sets for exercise ${activeEx.baseExercise.name}.");
      
      if (completedSets.isNotEmpty) { // Only add exercise if it has completed sets
        completedExercises.add(
          CompletedWorkoutExercise(
            id: activeEx.id, // Use the active exercise's ID
            exerciseId: activeEx.baseExercise.exerciseId!,
            exerciseName: activeEx.baseExercise.name,
            exerciseEquipments: activeEx.baseExercise.equipments,
            exerciseGifUrl: activeEx.baseExercise.gifUrl,
            sets: completedSets,
            createdAt: DateTime.now() // Assuming createdAt for exercise is now
          )
        );
      }
    }
    
    if (completedExercises.isEmpty && state.exercises.isNotEmpty) {
        // If there were exercises but none had completed sets, maybe don't save? Or save with empty exercises?
        // For now, let's require at least one completed exercise with sets.
        // This behavior can be adjusted.
        debugPrint("generateCompletedWorkoutData: Condition 2 FAILED - No exercises with completed sets to save.");
        return null;
    }
    
    debugPrint("generateCompletedWorkoutData: All conditions passed. Generating CompletedWorkout object.");
    return CompletedWorkout(
      id: state.id ?? _uuid.v4(), // Use existing ID if editing, else new
      userId: userId,
      workoutName: state.workoutName,
      // workoutIconUrl: null, // Add if you have icons for active workouts
      startTime: state.startTime!,
      endTime: state.endTime!,
      durationSeconds: state.duration!.inSeconds, // Use durationSeconds
      intensityScore: state.intensityScore!,
      exercises: completedExercises,
      createdAt: DateTime.now(), // Timestamp for the CompletedWorkout record itself
    );
  }

  void resetWorkout() {
    debugPrint("ActiveWorkoutNotifier: resetWorkout called. Current state startTime: ${state.startTime}");
    state = ActiveWorkoutState();
    debugPrint("ActiveWorkoutNotifier: resetWorkout finished. New state startTime: ${state.startTime}");
  }

  // Method to load an existing CompletedWorkout for editing (not fully implemented, placeholder)
  void loadWorkoutForEditing(CompletedWorkout workoutToEdit) {
    // This would transform CompletedWorkout back into ActiveWorkoutState
    // For simplicity, this is a basic reset and load. A full mapping would be needed.
    List<ActiveWorkoutExercise> activeExercises = [];
    for(var compEx in workoutToEdit.exercises) {
        // This requires fetching the baseExercise_db.Exercise if you only have IDs
        // For now, assuming we can construct a placeholder or have enough info
        var placeholderBaseExercise = exercise_db.Exercise(
            exerciseId: compEx.exerciseId,
            name: compEx.exerciseName,
        gifUrl: compEx.exerciseGifUrl,
            bodyParts: [], // Placeholder
            equipments: compEx.exerciseEquipments ?? [], // Ensure non-null
            targetMuscles: [], // Placeholder
            secondaryMuscles: [], // Placeholder
            instructions: [] // Placeholder
        );

        activeExercises.add(ActiveWorkoutExercise(
            id: compEx.id,
            baseExercise: placeholderBaseExercise,
            sets: compEx.sets.map((s) => ActiveWorkoutSet(id: s.id, weight: s.weight, reps: s.reps, isCompleted: true)).toList()
        ));
    }

    state = ActiveWorkoutState(
        id: workoutToEdit.id,
        workoutName: workoutToEdit.workoutName,
        startTime: workoutToEdit.startTime,
        endTime: workoutToEdit.endTime,
        exercises: activeExercises,
        intensityScore: workoutToEdit.intensityScore
    );
  }

  // New method to explicitly load an ActiveWorkoutState
  void loadState(ActiveWorkoutState stateToLoad) {
    debugPrint("ActiveWorkoutNotifier: loadState called. Loading state with startTime: ${stateToLoad.startTime}");
    state = stateToLoad;
  }

  // New method to initialize a workout without starting it (no startTime)
  void initializeNewWorkout({String? name, List<ActiveWorkoutExercise>? initialExercises}) {
    debugPrint("ActiveWorkoutNotifier: initializeNewWorkout called. Name: $name");
    state = ActiveWorkoutState( // Create a fresh state
      workoutName: name ?? 'New Workout',
      exercises: initialExercises ?? [],
      // startTime, endTime, intensityScore remain null
    );
  }

  void restartWorkout({String? name}) {
    debugPrint("ActiveWorkoutNotifier: restartWorkout called. Current state startTime: ${state.startTime}");
    // Reset exercises to their initial state (e.g., one empty set each)
    // This assumes we want to keep the same list of base exercises but reset their progress.
    final List<ActiveWorkoutExercise> restartedExercises = state.exercises.map((activeEx) {
      return ActiveWorkoutExercise(
        baseExercise: activeEx.baseExercise, // Keep the base exercise
        sets: [ActiveWorkoutSet()], // Reset to one new, empty set
      );
    }).toList();

    state = state.copyWith(
      startTime: DateTime.now(),
      workoutName: name ?? state.workoutName, // Keep current name if new one isn't provided
      clearEndTime: true,
      intensityScore: null, // Clear previous intensity
      exercises: restartedExercises,
    );
    debugPrint("ActiveWorkoutNotifier: restartWorkout finished. New state startTime: ${state.startTime}");
  }


  Future<bool> saveCompletedWorkout(String userId, ApiService apiService, DatabaseHelper dbHelper) async {
    final completedWorkoutData = generateCompletedWorkoutData(userId);
    if (completedWorkoutData == null) {
      debugPrint("ActiveWorkoutNotifier: No valid completed workout data to save.");
      return false;
    }

    try {
      debugPrint("ActiveWorkoutNotifier: Attempting to save workout session to API.");
      // Attempt to save to API
      await apiService.saveWorkoutSession(completedWorkoutData);
      debugPrint("ActiveWorkoutNotifier: Workout session saved to API successfully.");
      // If API save is successful, save to local DB as synced
      await dbHelper.insertCompletedWorkout(completedWorkoutData, synced: true);
      debugPrint("ActiveWorkoutNotifier: Workout session saved to local DB as synced.");
      resetWorkout(); // Reset state after successful save
      return true;
    } catch (e) {
      debugPrint("ActiveWorkoutNotifier: Failed to save workout session to API: $e. Saving locally as unsynced.");
      try {
        // If API save fails, save to local DB as unsynced
        await dbHelper.insertCompletedWorkout(completedWorkoutData, synced: false);
        debugPrint("ActiveWorkoutNotifier: Workout session saved to local DB as unsynced.");
        resetWorkout(); // Reset state after successful local save
        return true; // Still true as it's saved locally
      } catch (dbError) {
        debugPrint("ActiveWorkoutNotifier: Failed to save workout session to local DB: $dbError");
        return false;
      }
    }
  }
}

// Provider
final activeWorkoutProvider = StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState>((ref) {
  return ActiveWorkoutNotifier();
});
