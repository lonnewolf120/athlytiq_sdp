import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/WorkoutTemplate.dart';
import '../api/API_Services.dart';
import 'data_providers.dart';

// Service class to wrap API calls for workout templates
class WorkoutTemplateService {
  final ApiService _apiService;

  WorkoutTemplateService(this._apiService);

  // Get list of workout templates with optional filters
  Future<WorkoutTemplateListResponse> getTemplates({
    TemplateFilters? filters,
  }) async {
    try {
      final queryParams = filters?.toQueryParams() ?? {'skip': 0, 'limit': 20};

      final response = await _apiService.get(
        '/api/v1/workout-templates/',
        queryParameters: queryParams,
      );

      return WorkoutTemplateListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch workout templates: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching workout templates: $e');
    }
  }

  // Get a specific workout template by ID
  Future<WorkoutTemplate> getTemplate(String templateId) async {
    try {
      final response = await _apiService.get(
        '/api/v1/workout-templates/$templateId',
      );

      return WorkoutTemplate.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Workout template not found');
      }
      throw Exception('Failed to fetch workout template: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching workout template: $e');
    }
  }

  // Import a workout template to create a personal workout plan
  Future<ImportTemplateResponse> importTemplate(
    String templateId, {
    String? customName,
  }) async {
    try {
      final request = ImportTemplateRequest(customName: customName);

      final response = await _apiService.post(
        '/api/v1/workout-templates/$templateId/import',
        request.toJson(),
      );

      return ImportTemplateResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Workout template not found');
      }
      if (e.response?.statusCode == 400) {
        throw Exception(
          'Invalid import request: ${e.response?.data['detail'] ?? 'Bad request'}',
        );
      }
      throw Exception('Failed to import workout template: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error importing workout template: $e');
    }
  }

  // Get available authors for filtering
  Future<List<String>> getAuthors() async {
    try {
      final response = await _apiService.get(
        '/api/v1/workout-templates/metadata/authors',
      );

      return List<String>.from(response.data['authors']);
    } on DioException catch (e) {
      throw Exception('Failed to fetch authors: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching authors: $e');
    }
  }

  // Get available tags for filtering
  Future<List<String>> getTags() async {
    try {
      final response = await _apiService.get(
        '/api/v1/workout-templates/metadata/tags',
      );

      return List<String>.from(response.data['tags']);
    } on DioException catch (e) {
      throw Exception('Failed to fetch tags: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching tags: $e');
    }
  }

  // Get available muscle groups for filtering
  Future<List<String>> getMuscleGroups() async {
    try {
      final response = await _apiService.get(
        '/api/v1/workout-templates/metadata/muscle-groups',
      );

      return List<String>.from(response.data['muscle_groups']);
    } on DioException catch (e) {
      throw Exception('Failed to fetch muscle groups: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching muscle groups: $e');
    }
  }
}

// Service provider
final workoutTemplateServiceProvider = Provider<WorkoutTemplateService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return WorkoutTemplateService(apiService);
});

// State classes for managing template data and filters
class WorkoutTemplatesState {
  final List<WorkoutTemplate> templates;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int totalCount;
  final int currentPage;
  final TemplateFilters filters;

  WorkoutTemplatesState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.totalCount = 0,
    this.currentPage = 1,
    TemplateFilters? filters,
  }) : filters = filters ?? TemplateFilters();

  WorkoutTemplatesState copyWith({
    List<WorkoutTemplate>? templates,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? totalCount,
    int? currentPage,
    TemplateFilters? filters,
  }) {
    return WorkoutTemplatesState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      filters: filters ?? this.filters,
    );
  }
}

// Main templates list provider
class WorkoutTemplatesNotifier extends StateNotifier<WorkoutTemplatesState> {
  final WorkoutTemplateService _templateService;

  WorkoutTemplatesNotifier(this._templateService)
    : super(WorkoutTemplatesState());

  // Load templates with optional filters
  Future<void> loadTemplates({
    TemplateFilters? filters,
    bool resetList = true,
  }) async {
    if (resetList) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        templates: [],
        currentPage: 1,
        hasMore: true,
        filters: filters,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final effectiveFilters = filters ?? state.filters;
      final skip = resetList ? 0 : state.templates.length;
      final searchFilters = effectiveFilters.copyWith(skip: skip);

      final response = await _templateService.getTemplates(
        filters: searchFilters,
      );

      final newTemplates =
          resetList
              ? response.templates
              : [...state.templates, ...response.templates];

      state = state.copyWith(
        templates: newTemplates,
        isLoading: false,
        totalCount: response.totalCount,
        hasMore: response.page < response.totalPages,
        currentPage: response.page,
        filters: effectiveFilters,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Load more templates (pagination)
  Future<void> loadMoreTemplates() async {
    if (!state.hasMore || state.isLoading) return;
    await loadTemplates(resetList: false);
  }

  // Apply new filters
  Future<void> applyFilters(TemplateFilters filters) async {
    await loadTemplates(filters: filters, resetList: true);
  }

  // Clear filters
  Future<void> clearFilters() async {
    await loadTemplates(filters: TemplateFilters(), resetList: true);
  }

  // Refresh templates
  Future<void> refresh() async {
    await loadTemplates(filters: state.filters, resetList: true);
  }

  // Search templates
  Future<void> searchTemplates(String query) async {
    final searchFilters = state.filters.copyWith(
      search: query.isEmpty ? null : query,
    );
    await loadTemplates(filters: searchFilters, resetList: true);
  }
}

final workoutTemplatesProvider =
    StateNotifierProvider<WorkoutTemplatesNotifier, WorkoutTemplatesState>((
      ref,
    ) {
      final templateService = ref.watch(workoutTemplateServiceProvider);
      return WorkoutTemplatesNotifier(templateService);
    });

// Individual template provider
final workoutTemplateProvider = FutureProvider.family<WorkoutTemplate, String>((
  ref,
  templateId,
) {
  final templateService = ref.watch(workoutTemplateServiceProvider);
  return templateService.getTemplate(templateId);
});

// Metadata providers for filters
final templateAuthorsProvider = FutureProvider<List<String>>((ref) {
  final templateService = ref.watch(workoutTemplateServiceProvider);
  return templateService.getAuthors();
});

final templateTagsProvider = FutureProvider<List<String>>((ref) {
  final templateService = ref.watch(workoutTemplateServiceProvider);
  return templateService.getTags();
});

final templateMuscleGroupsProvider = FutureProvider<List<String>>((ref) {
  final templateService = ref.watch(workoutTemplateServiceProvider);
  return templateService.getMuscleGroups();
});

// Import template provider
class ImportTemplateNotifier
    extends StateNotifier<AsyncValue<ImportTemplateResponse?>> {
  final WorkoutTemplateService _templateService;

  ImportTemplateNotifier(this._templateService)
    : super(const AsyncValue.data(null));

  Future<void> importTemplate(String templateId, {String? customName}) async {
    state = const AsyncValue.loading();

    try {
      final response = await _templateService.importTemplate(
        templateId,
        customName: customName,
      );
      state = AsyncValue.data(response);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void resetState() {
    state = const AsyncValue.data(null);
  }
}

final importTemplateProvider = StateNotifierProvider<
  ImportTemplateNotifier,
  AsyncValue<ImportTemplateResponse?>
>((ref) {
  final templateService = ref.watch(workoutTemplateServiceProvider);
  return ImportTemplateNotifier(templateService);
});

// Convenience providers for common filter combinations
final popularTemplatesProvider = FutureProvider<List<WorkoutTemplate>>((
  ref,
) async {
  final templateService = ref.watch(workoutTemplateServiceProvider);
  final response = await templateService.getTemplates(
    filters: TemplateFilters(limit: 10),
  );
  return response.templates;
});

final beginnerTemplatesProvider = FutureProvider<List<WorkoutTemplate>>((
  ref,
) async {
  final templateService = ref.watch(workoutTemplateServiceProvider);
  final response = await templateService.getTemplates(
    filters: TemplateFilters(difficultyLevel: 'beginner', limit: 10),
  );
  return response.templates;
});

final advancedTemplatesProvider = FutureProvider<List<WorkoutTemplate>>((
  ref,
) async {
  final templateService = ref.watch(workoutTemplateServiceProvider);
  final response = await templateService.getTemplates(
    filters: TemplateFilters(difficultyLevel: 'advanced', limit: 10),
  );
  return response.templates;
});

// Template by author provider
final templatesByAuthorProvider =
    FutureProvider.family<List<WorkoutTemplate>, String>((ref, author) async {
      final templateService = ref.watch(workoutTemplateServiceProvider);
      final response = await templateService.getTemplates(
        filters: TemplateFilters(author: author, limit: 20),
      );
      return response.templates;
    });
