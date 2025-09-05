import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:fitnation/models/ExerciseLibrary.dart';
import 'package:fitnation/providers/data_providers.dart';
import 'package:fitnation/api/API_Services.dart';
import 'package:flutter/foundation.dart';

// --- Exercise Library Service ---

class ExerciseLibraryService {
  final ApiService _apiService;

  ExerciseLibraryService(this._apiService);

  // Advanced exercise search with filtering
  Future<ExerciseSearchResponse> searchExercises({
    String? searchQuery,
    List<String> categories = const [],
    List<String> muscleGroups = const [],
    List<String> equipment = const [],
    List<int> difficulty = const [],
    bool? compound,
    bool? unilateral,
    double? minPopularity,
    int page = 1,
    int pageSize = 20,
    String sortBy = 'popularity',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['q'] = searchQuery;
      }

      if (categories.isNotEmpty) {
        queryParams['categories'] = categories;
      }

      if (muscleGroups.isNotEmpty) {
        queryParams['muscle_groups'] = muscleGroups;
      }

      if (equipment.isNotEmpty) {
        queryParams['equipment'] = equipment;
      }

      if (difficulty.isNotEmpty) {
        queryParams['difficulty'] = difficulty;
      }

      if (compound != null) {
        queryParams['compound'] = compound;
      }

      if (unilateral != null) {
        queryParams['unilateral'] = unilateral;
      }

      if (minPopularity != null) {
        queryParams['min_popularity'] = minPopularity;
      }

      debugPrint(
        'ExerciseLibraryService: Searching exercises with params: $queryParams',
      );

      final response = await _apiService.get(
        '/exercise-library/library',
        queryParameters: queryParams,
      );

      debugPrint(
        'ExerciseLibraryService: Search response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return ExerciseSearchResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to search exercises: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('ExerciseLibraryService: Search error: ${e.message}');
      throw Exception('Network error while searching exercises: ${e.message}');
    }
  }

  // Get detailed exercise information
  Future<ExerciseLibrary> getExerciseDetails(String exerciseId) async {
    try {
      debugPrint(
        'ExerciseLibraryService: Fetching exercise details for: $exerciseId',
      );

      final response = await _apiService.get(
        '/exercise-library/library/$exerciseId',
      );

      debugPrint(
        'ExerciseLibraryService: Exercise details response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return ExerciseLibrary.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to get exercise details: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        'ExerciseLibraryService: Exercise details error: ${e.message}',
      );
      throw Exception(
        'Network error while fetching exercise details: ${e.message}',
      );
    }
  }

  // Get exercises for quick selection (optimized for mobile)
  Future<ExerciseQuickSelectResponse> getQuickSelectExercises({
    String? search,
    String? category,
    String? muscleGroup,
    String? equipment,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      if (muscleGroup != null && muscleGroup.isNotEmpty) {
        queryParams['muscle_group'] = muscleGroup;
      }

      if (equipment != null && equipment.isNotEmpty) {
        queryParams['equipment'] = equipment;
      }

      debugPrint(
        'ExerciseLibraryService: Fetching quick select exercises with params: $queryParams',
      );

      final response = await _apiService.get(
        '/exercise-library/quick-select',
        queryParameters: queryParams,
      );

      debugPrint(
        'ExerciseLibraryService: Quick select response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return ExerciseQuickSelectResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to get quick select exercises: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('ExerciseLibraryService: Quick select error: ${e.message}');
      throw Exception(
        'Network error while fetching quick select exercises: ${e.message}',
      );
    }
  }

  // Get exercise categories
  Future<List<ExerciseCategory>> getExerciseCategories() async {
    try {
      debugPrint('ExerciseLibraryService: Fetching exercise categories');

      final response = await _apiService.get('/exercise-library/categories');

      debugPrint(
        'ExerciseLibraryService: Categories response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return (response.data as List<dynamic>)
            .map((category) => ExerciseCategory.fromJson(category))
            .toList();
      } else {
        throw Exception('Failed to get categories: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('ExerciseLibraryService: Categories error: ${e.message}');
      throw Exception('Network error while fetching categories: ${e.message}');
    }
  }

  // Get muscle groups
  Future<List<MuscleGroup>> getExerciseMuscleGroups({String? groupType}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (groupType != null) {
        queryParams['group_type'] = groupType;
      }

      debugPrint(
        'ExerciseLibraryService: Fetching muscle groups with params: $queryParams',
      );

      final response = await _apiService.get(
        '/exercise-library/muscle-groups',
        queryParameters: queryParams,
      );

      debugPrint(
        'ExerciseLibraryService: Muscle groups response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return (response.data as List<dynamic>)
            .map((muscleGroup) => MuscleGroup.fromJson(muscleGroup))
            .toList();
      } else {
        throw Exception('Failed to get muscle groups: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('ExerciseLibraryService: Muscle groups error: ${e.message}');
      throw Exception(
        'Network error while fetching muscle groups: ${e.message}',
      );
    }
  }

  // Get equipment types
  Future<List<EquipmentType>> getExerciseEquipmentTypes({
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) {
        queryParams['category'] = category;
      }

      debugPrint(
        'ExerciseLibraryService: Fetching equipment types with params: $queryParams',
      );

      final response = await _apiService.get(
        '/exercise-library/equipment',
        queryParameters: queryParams,
      );

      debugPrint(
        'ExerciseLibraryService: Equipment types response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return (response.data as List<dynamic>)
            .map((equipment) => EquipmentType.fromJson(equipment))
            .toList();
      } else {
        throw Exception(
          'Failed to get equipment types: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('ExerciseLibraryService: Equipment types error: ${e.message}');
      throw Exception(
        'Network error while fetching equipment types: ${e.message}',
      );
    }
  }

  // Get popular exercises
  Future<List<ExerciseLibrary>> getPopularExercises({
    int limit = 10,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};

      if (category != null) {
        queryParams['category'] = category;
      }

      debugPrint(
        'ExerciseLibraryService: Fetching popular exercises with params: $queryParams',
      );

      final response = await _apiService.get(
        '/exercise-library/popular',
        queryParameters: queryParams,
      );

      debugPrint(
        'ExerciseLibraryService: Popular exercises response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return (response.data as List<dynamic>)
            .map((exercise) => ExerciseLibrary.fromJson(exercise))
            .toList();
      } else {
        throw Exception(
          'Failed to get popular exercises: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        'ExerciseLibraryService: Popular exercises error: ${e.message}',
      );
      throw Exception(
        'Network error while fetching popular exercises: ${e.message}',
      );
    }
  }

  // Get similar exercises
  Future<List<ExerciseLibrary>> getSimilarExercises(
    String exerciseId, {
    int limit = 5,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};

      debugPrint(
        'ExerciseLibraryService: Fetching similar exercises for: $exerciseId',
      );

      final response = await _apiService.get(
        '/exercise-library/similar/$exerciseId',
        queryParameters: queryParams,
      );

      debugPrint(
        'ExerciseLibraryService: Similar exercises response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return (response.data as List<dynamic>)
            .map((exercise) => ExerciseLibrary.fromJson(exercise))
            .toList();
      } else {
        throw Exception(
          'Failed to get similar exercises: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        'ExerciseLibraryService: Similar exercises error: ${e.message}',
      );
      throw Exception(
        'Network error while fetching similar exercises: ${e.message}',
      );
    }
  }

  // Get exercise variations
  Future<List<ExerciseLibrary>> getExerciseVariations(
    String exerciseId, {
    String? variationType,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (variationType != null) {
        queryParams['variation_type'] = variationType;
      }

      debugPrint(
        'ExerciseLibraryService: Fetching variations for: $exerciseId',
      );

      final response = await _apiService.get(
        '/exercise-library/variations/$exerciseId',
        queryParameters: queryParams,
      );

      debugPrint(
        'ExerciseLibraryService: Variations response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return (response.data as List<dynamic>)
            .map((exercise) => ExerciseLibrary.fromJson(exercise))
            .toList();
      } else {
        throw Exception(
          'Failed to get exercise variations: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('ExerciseLibraryService: Variations error: ${e.message}');
      throw Exception(
        'Network error while fetching exercise variations: ${e.message}',
      );
    }
  }
}

// --- State Classes for UI ---

@immutable
class ExerciseSearchState {
  final List<ExerciseLibrary> exercises;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final int totalCount;
  final ExerciseSearchFilters filters;

  ExerciseSearchState({
    this.exercises = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.totalCount = 0,
    ExerciseSearchFilters? filters,
  }) : filters = filters ?? ExerciseSearchFilters();

  ExerciseSearchState copyWith({
    List<ExerciseLibrary>? exercises,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    int? totalCount,
    ExerciseSearchFilters? filters,
  }) {
    return ExerciseSearchState(
      exercises: exercises ?? this.exercises,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      filters: filters ?? this.filters,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSearchState &&
          runtimeType == other.runtimeType &&
          exercises == other.exercises &&
          isLoading == other.isLoading &&
          error == other.error &&
          hasMore == other.hasMore &&
          currentPage == other.currentPage &&
          totalCount == other.totalCount &&
          filters == other.filters;

  @override
  int get hashCode =>
      exercises.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      hasMore.hashCode ^
      currentPage.hashCode ^
      totalCount.hashCode ^
      filters.hashCode;
}

@immutable
class SelectedExercisesState {
  final Map<String, ExerciseLibrary> selectedExercises;
  final bool isModified;

  const SelectedExercisesState({
    this.selectedExercises = const {},
    this.isModified = false,
  });

  SelectedExercisesState copyWith({
    Map<String, ExerciseLibrary>? selectedExercises,
    bool? isModified,
  }) {
    return SelectedExercisesState(
      selectedExercises: selectedExercises ?? this.selectedExercises,
      isModified: isModified ?? this.isModified,
    );
  }

  List<ExerciseLibrary> get exercisesList => selectedExercises.values.toList();
  int get count => selectedExercises.length;
  bool get hasSelections => selectedExercises.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedExercisesState &&
          runtimeType == other.runtimeType &&
          selectedExercises == other.selectedExercises &&
          isModified == other.isModified;

  @override
  int get hashCode => selectedExercises.hashCode ^ isModified.hashCode;
}

// --- Exercise Search Notifier ---

class ExerciseSearchNotifier extends StateNotifier<ExerciseSearchState> {
  final ExerciseLibraryService _service;

  ExerciseSearchNotifier(this._service) : super(ExerciseSearchState());

  // Search with filters
  Future<void> searchExercises({
    String? query,
    ExerciseSearchFilters? filters,
    bool reset = false,
  }) async {
    final searchFilters = filters ?? state.filters;

    if (reset) {
      state = state.copyWith(
        exercises: [],
        currentPage: 1,
        hasMore: true,
        totalCount: 0,
        filters: searchFilters,
      );
    }

    if (state.isLoading || (!state.hasMore && !reset)) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _service.searchExercises(
        searchQuery: query,
        categories: searchFilters.categoryIds,
        muscleGroups: searchFilters.muscleGroupIds,
        equipment: searchFilters.equipmentIds,
        difficulty: searchFilters.difficultyLevels,
        compound: searchFilters.isCompound,
        unilateral: searchFilters.isUnilateral,
        minPopularity: searchFilters.minPopularity,
        page: state.currentPage,
        pageSize: 20,
        sortBy: 'popularity',
        sortOrder: 'desc',
      );

      final newExercises =
          reset
              ? response.exercises
              : [...state.exercises, ...response.exercises];

      final hasMorePages = response.page < response.totalPages;

      state = state.copyWith(
        exercises: newExercises,
        isLoading: false,
        hasMore: hasMorePages,
        currentPage: state.currentPage + 1,
        totalCount: response.totalCount,
        filters: searchFilters,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      debugPrint('ExerciseSearchNotifier: Search error: $e');
    }
  }

  // Load more results (pagination)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await searchExercises();
  }

  // Update filters
  void updateFilters(ExerciseSearchFilters filters) {
    if (filters != state.filters) {
      searchExercises(filters: filters, reset: true);
    }
  }

  // Clear search
  void clearSearch() {
    state = ExerciseSearchState();
  }

  // Quick search (for search bar)
  Future<void> quickSearch(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    await searchExercises(query: query, reset: true);
  }
}

// --- Selected Exercises Notifier ---

class SelectedExercisesNotifier extends StateNotifier<SelectedExercisesState> {
  SelectedExercisesNotifier() : super(const SelectedExercisesState());

  // Add exercise to selection
  void addExercise(ExerciseLibrary exercise) {
    final newSelected = Map<String, ExerciseLibrary>.from(
      state.selectedExercises,
    );
    newSelected[exercise.id] = exercise;

    state = state.copyWith(selectedExercises: newSelected, isModified: true);

    debugPrint(
      'SelectedExercisesNotifier: Added exercise: ${exercise.name} (${exercise.id})',
    );
  }

  // Remove exercise from selection
  void removeExercise(String exerciseId) {
    final newSelected = Map<String, ExerciseLibrary>.from(
      state.selectedExercises,
    );
    final removed = newSelected.remove(exerciseId);

    if (removed != null) {
      state = state.copyWith(selectedExercises: newSelected, isModified: true);

      debugPrint(
        'SelectedExercisesNotifier: Removed exercise: ${removed.name} ($exerciseId)',
      );
    }
  }

  // Toggle exercise selection
  void toggleExercise(ExerciseLibrary exercise) {
    if (state.selectedExercises.containsKey(exercise.id)) {
      removeExercise(exercise.id);
    } else {
      addExercise(exercise);
    }
  }

  // Check if exercise is selected
  bool isSelected(String exerciseId) {
    return state.selectedExercises.containsKey(exerciseId);
  }

  // Clear all selections
  void clearSelections() {
    state = const SelectedExercisesState();
    debugPrint('SelectedExercisesNotifier: Cleared all selections');
  }

  // Set selected exercises (for initialization)
  void setSelectedExercises(List<ExerciseLibrary> exercises) {
    final exerciseMap = <String, ExerciseLibrary>{};
    for (final exercise in exercises) {
      exerciseMap[exercise.id] = exercise;
    }

    state = state.copyWith(selectedExercises: exerciseMap, isModified: false);

    debugPrint(
      'SelectedExercisesNotifier: Set ${exercises.length} selected exercises',
    );
  }

  // Mark as saved (reset modified flag)
  void markAsSaved() {
    state = state.copyWith(isModified: false);
  }
}

// --- Providers ---

// Exercise Library Service Provider
final exerciseLibraryServiceProvider = Provider<ExerciseLibraryService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ExerciseLibraryService(apiService);
});

// Exercise Search Provider
final exerciseSearchProvider =
    StateNotifierProvider<ExerciseSearchNotifier, ExerciseSearchState>((ref) {
      final service = ref.watch(exerciseLibraryServiceProvider);
      return ExerciseSearchNotifier(service);
    });

// Selected Exercises Provider
final selectedExercisesProvider =
    StateNotifierProvider<SelectedExercisesNotifier, SelectedExercisesState>((
      ref,
    ) {
      return SelectedExercisesNotifier();
    });

// Exercise Categories Provider
final exerciseCategoriesProvider = FutureProvider<List<ExerciseCategory>>((
  ref,
) async {
  final service = ref.watch(exerciseLibraryServiceProvider);
  return await service.getExerciseCategories();
});

// Muscle Groups Provider
final exerciseMuscleGroupsProvider = FutureProvider<List<MuscleGroup>>((
  ref,
) async {
  final service = ref.watch(exerciseLibraryServiceProvider);
  return await service.getExerciseMuscleGroups();
});

// Equipment Types Provider
final exerciseEquipmentTypesProvider = FutureProvider<List<EquipmentType>>((
  ref,
) async {
  final service = ref.watch(exerciseLibraryServiceProvider);
  return await service.getExerciseEquipmentTypes();
});

// Popular Exercises Provider
final popularExercisesProvider =
    FutureProvider.family<List<ExerciseLibrary>, String?>((
      ref,
      category,
    ) async {
      final service = ref.watch(exerciseLibraryServiceProvider);
      return await service.getPopularExercises(category: category, limit: 10);
    });

// Exercise Details Provider
final exerciseDetailsProvider = FutureProvider.family<ExerciseLibrary, String>((
  ref,
  exerciseId,
) async {
  final service = ref.watch(exerciseLibraryServiceProvider);
  return await service.getExerciseDetails(exerciseId);
});

// Similar Exercises Provider
final similarExercisesProvider =
    FutureProvider.family<List<ExerciseLibrary>, String>((
      ref,
      exerciseId,
    ) async {
      final service = ref.watch(exerciseLibraryServiceProvider);
      return await service.getSimilarExercises(exerciseId, limit: 5);
    });

// Exercise Variations Provider
final exerciseVariationsProvider =
    FutureProvider.family<List<ExerciseLibrary>, String>((
      ref,
      exerciseId,
    ) async {
      final service = ref.watch(exerciseLibraryServiceProvider);
      return await service.getExerciseVariations(exerciseId);
    });

// Quick Select Exercises Provider
final quickSelectExercisesProvider =
    FutureProvider.family<ExerciseQuickSelectResponse, QuickSelectParams>((
      ref,
      params,
    ) async {
      final service = ref.watch(exerciseLibraryServiceProvider);
      return await service.getQuickSelectExercises(
        search: params.search,
        category: params.category,
        muscleGroup: params.muscleGroup,
        equipment: params.equipment,
        limit: params.limit,
      );
    });

// --- Helper Classes ---

@immutable
class QuickSelectParams {
  final String? search;
  final String? category;
  final String? muscleGroup;
  final String? equipment;
  final int limit;

  const QuickSelectParams({
    this.search,
    this.category,
    this.muscleGroup,
    this.equipment,
    this.limit = 50,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickSelectParams &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          category == other.category &&
          muscleGroup == other.muscleGroup &&
          equipment == other.equipment &&
          limit == other.limit;

  @override
  int get hashCode =>
      search.hashCode ^
      category.hashCode ^
      muscleGroup.hashCode ^
      equipment.hashCode ^
      limit.hashCode;
}
