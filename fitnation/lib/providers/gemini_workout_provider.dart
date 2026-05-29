import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/models/Workout.dart';
import 'package:fitnation/api/API_Services.dart'; // Import ApiService
import 'package:fitnation/providers/auth_provider.dart'; // Import authProvider
import 'package:fitnation/providers/data_providers.dart'; // Import apiServiceProvider
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:fitnation/services/connectivity_service.dart'; // Import ConnectivityService
import 'package:fitnation/providers/workout_generation_provider.dart'; // Import workout generation provider
import 'package:fitnation/services/coach/workout_recommendation_service.dart';
import 'package:fitnation/services/coach/history/workout_history_summarizer.dart';
import 'package:fitnation/services/coach/local_exercise_catalog.dart';
import 'package:fitnation/services/database_helper.dart';
import 'package:fitnation/helpers/exercise_database_helper.dart';

// StateNotifier for managing generated workout plans
class GeminiWorkoutNotifier extends StateNotifier<List<Workout>> {
  final ApiService _apiService;
  final Ref _ref;

  GeminiWorkoutNotifier(this._apiService, this._ref) : super([]);

  Future<void> _loadWorkoutPlans() async {
    debugPrint('GeminiWorkoutNotifier: Loading workout plans.');
    try {
      final authState = _ref.read(authProvider);
      String? currentUserId;
      if (authState is Authenticated) {
        currentUserId = authState.user.id;
        debugPrint(
          'GeminiWorkoutNotifier: User authenticated with ID: $currentUserId',
        );
        final loadedPlans = await _apiService.getWorkoutPlans(
          skip: 0, // Adjust as needed for pagination
          limit: 100, // Adjust as needed
        );
        state = loadedPlans;
        debugPrint(
          'GeminiWorkoutNotifier: Successfully loaded ${loadedPlans.length} workout plans.',
        );
      } else {
        debugPrint(
          'GeminiWorkoutNotifier: User not authenticated. Cannot load workout plans.',
        );
        state = []; // Clear plans if not authenticated
      }
    } on NoInternetException catch (e) {
      debugPrint(
        'GeminiWorkoutNotifier: No internet connection while loading workout plans: ${e.message}',
      );
      state = []; // Clear plans on no internet
      rethrow; // Re-throw to be caught by UI if needed
    } catch (e) {
      debugPrint('GeminiWorkoutNotifier: Error loading workout plans: $e');
      state = []; // Clear plans on error
      rethrow; // Re-throw to be caught by UI if needed
    }
  }

  Future<void> generateWorkoutPlan(Map<String, dynamic> userInfo) async {
    debugPrint(
      'GeminiWorkoutNotifier: generateWorkoutPlan called with userInfo: $userInfo',
    );

    _ref.read(workoutGenerationProvider.notifier).startGeneration();

    try {
      final authState = _ref.read(authProvider);
      String? currentUserId;
      if (authState is Authenticated) {
        currentUserId = authState.user.id;
        debugPrint('GeminiWorkoutNotifier: User authenticated: $currentUserId');
      } else {
        _ref
            .read(workoutGenerationProvider.notifier)
            .setError('User not authenticated. Cannot generate workout plan.');
        throw Exception('User not authenticated. Cannot generate workout plan.');
      }

      _ref.read(workoutGenerationProvider.notifier).updateParsingStep();

      // Load completed workout history for progressive overload
      final dbHelper = DatabaseHelper();
      final history = await dbHelper.getCompletedWorkouts(currentUserId);
      const summarizer = WorkoutHistorySummarizer();
      final progressHints = summarizer.summarize(history);
      debugPrint('GeminiWorkoutNotifier: ${history.length} sessions → ${progressHints.length} exercise hints');

      // Generate with catalog-grounded service
      final catalog = LocalExerciseCatalog();
      // Ensure catalog db is populated before generating
      await ExerciseDatabaseHelper().loadExercisesFromJson();
      final service = WorkoutRecommendationService.withFirebase(catalog);
      final Workout? newWorkout = await service.generate(
        userProfile: userInfo,
        progressHints: progressHints,
      );

      if (newWorkout == null) {
        _ref.read(workoutGenerationProvider.notifier)
            .setError('Could not generate workout. Please try again.');
        return;
      }

      debugPrint('GeminiWorkoutNotifier: Generated: ${newWorkout.name} (${newWorkout.exercises.length} exercises)');

      // Update status to processing
      _ref.read(workoutGenerationProvider.notifier).updateProcessingStep();

      state = [
        ...state,
        newWorkout,
      ]; // TODO: might wanna add savedWorkout here instead of newWorkout
      debugPrint('GeminiWorkoutNotifier: State updated with new workout plan.');

      // Update status to handling
      _ref.read(workoutGenerationProvider.notifier).updateHandlingStep();

      // Save to backend (treat unexpected/null responses as non-fatal)
      debugPrint('GeminiWorkoutNotifier: Saving workout plan to backend...');
      try {
        final savedWorkout = await _apiService.saveWorkoutPlan(
          newWorkout,
          userInfo,
        );

        // Defensive handling: savedWorkout may contain nulls or unexpected shapes
        // If parsing or cast errors happen downstream, we prefer to log and continue
        debugPrint(
          'GeminiWorkoutNotifier: Workout plan saved to backend: $savedWorkout',
        );
      } catch (e, st) {
        // If the backend returns null fields or a different shape causing casts,
        // swallow the error as non-fatal: log it and continue to mark generation completed.
        debugPrint(
          'GeminiWorkoutNotifier: Warning - non-fatal error while saving workout plan: $e',
        );
        debugPrint('GeminiWorkoutNotifier: Stacktrace: $st');
        // Optionally, we could notify monitoring here instead of rethrowing.
      }

      // Complete the generation process even if save had minor issues
      _ref.read(workoutGenerationProvider.notifier).completeGeneration();
    } on NoInternetException catch (e) {
      debugPrint(
        'GeminiWorkoutNotifier: No internet connection while generating workout plan: ${e.message}',
      );
      _ref
          .read(workoutGenerationProvider.notifier)
          .setError(
            'No internet connection. Please check your connection and try again.',
          );
      rethrow; // Re-throw to be caught by UI if needed
    } catch (e) {
      // Handle error, e.g., log it or show a user-friendly message
      debugPrint('Error generating workout plan in Notifier: $e');
      _ref
          .read(workoutGenerationProvider.notifier)
          .setError('Failed to generate workout plan: ${e.toString()}');
      rethrow; // Re-throw to be caught by UI if needed
    }
  }

  // You might want methods to clear plans, load saved plans, etc.
  void clearPlans() {
    state = [];
  }

  /// Add a single plan to the in-memory state
  void addPlan(Workout plan) {
    state = [...state, plan];
  }

  /// Add multiple plans (e.g., imported from backend)
  void addPlans(List<Workout> plans) {
    state = [...state, ...plans];
  }

  /// Save a workout plan locally (and optionally to backend). Returns the final Workout used.
  Future<Workout> savePlanLocally(
    Workout plan, {
    bool saveToBackend = false,
    Map<String, dynamic>? prompt,
  }) async {
    // Add to state
    addPlan(plan);

    if (saveToBackend) {
      try {
        await _apiService.saveWorkoutPlan(plan, prompt ?? {});
      } catch (e) {
        debugPrint(
          'GeminiWorkoutNotifier: Warning - failed to save imported plan to backend: $e',
        );
      }
    }
    return plan;
  }
}

final geminiWorkoutPlanProvider =
    StateNotifierProvider<GeminiWorkoutNotifier, List<Workout>>((ref) {
      final notifier = GeminiWorkoutNotifier(
        ref.watch(apiServiceProvider),
        ref,
      );

      // Listen to authProvider to load workout plans once authenticated
      ref.listen<AuthState>(authProvider, (_, authState) {
        if (authState is Authenticated) {
          notifier._loadWorkoutPlans();
        } else {
          notifier.clearPlans(); // Clear plans if user logs out
        }
      });

      return notifier;
    });
