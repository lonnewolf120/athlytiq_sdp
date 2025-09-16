import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/Exercise.dart';
import '../helpers/exercise_database_helper.dart';

class ExerciseSearchState {
  final List<Exercise> exercises;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int currentOffset;

  const ExerciseSearchState({
    this.exercises = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.currentOffset = 0,
  });

  ExerciseSearchState copyWith({
    List<Exercise>? exercises,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? currentOffset,
  }) {
    return ExerciseSearchState(
      exercises: exercises ?? this.exercises,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }
}

class ExerciseSearchNotifier
    extends StateNotifier<AsyncValue<ExerciseSearchState>> {
  final ExerciseDatabaseHelper _databaseHelper;

  ExerciseSearchNotifier(this._databaseHelper)
    : super(const AsyncValue.loading());

  static const int _pageSize = 20;

  Future<void> loadInitialData() async {
    state = const AsyncValue.loading();
    try {
      // Load exercises from JSON into SQLite if needed
      await _databaseHelper.loadExercisesFromJson();

      // Load initial exercises
      final exercises = await _databaseHelper.searchExercises(limit: _pageSize);

      state = AsyncValue.data(
        ExerciseSearchState(
          exercises: exercises,
          isLoading: false,
          hasMore: exercises.length == _pageSize,
          currentOffset: exercises.length,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> searchExercises({
    String? query,
    String? bodyPart,
    String? equipment,
    String? targetMuscle,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final exercises = await _databaseHelper.searchExercises(
        query: query,
        bodyPart: bodyPart,
        equipment: equipment,
        targetMuscle: targetMuscle,
        limit: _pageSize,
        offset: 0,
      );

      state = AsyncValue.data(
        ExerciseSearchState(
          exercises: exercises,
          isLoading: false,
          hasMore: exercises.length == _pageSize,
          currentOffset: exercises.length,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMoreExercises({
    String? query,
    String? bodyPart,
    String? equipment,
    String? targetMuscle,
  }) async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoading ||
        !currentState.hasMore) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final newExercises = await _databaseHelper.searchExercises(
        query: query,
        bodyPart: bodyPart,
        equipment: equipment,
        targetMuscle: targetMuscle,
        limit: _pageSize,
        offset: currentState.currentOffset,
      );

      final allExercises = [...currentState.exercises, ...newExercises];

      state = AsyncValue.data(
        ExerciseSearchState(
          exercises: allExercises,
          isLoading: false,
          hasMore: newExercises.length == _pageSize,
          currentOffset: allExercises.length,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider for the database helper
final exerciseDatabaseHelperProvider = Provider<ExerciseDatabaseHelper>((ref) {
  return ExerciseDatabaseHelper();
});

// Provider for exercise search
final exerciseSearchProvider = StateNotifierProvider<
  ExerciseSearchNotifier,
  AsyncValue<ExerciseSearchState>
>((ref) {
  final databaseHelper = ref.watch(exerciseDatabaseHelperProvider);
  return ExerciseSearchNotifier(databaseHelper);
});

// Provider for filter options
final exerciseBodyPartsProvider = FutureProvider<List<String>>((ref) async {
  final databaseHelper = ref.watch(exerciseDatabaseHelperProvider);
  await databaseHelper.loadExercisesFromJson();
  return databaseHelper.getUniqueBodyParts();
});

final exerciseEquipmentsProvider = FutureProvider<List<String>>((ref) async {
  final databaseHelper = ref.watch(exerciseDatabaseHelperProvider);
  await databaseHelper.loadExercisesFromJson();
  return databaseHelper.getUniqueEquipments();
});

final exerciseTargetMusclesProvider = FutureProvider<List<String>>((ref) async {
  final databaseHelper = ref.watch(exerciseDatabaseHelperProvider);
  await databaseHelper.loadExercisesFromJson();
  return databaseHelper.getUniqueTargetMuscles();
});
