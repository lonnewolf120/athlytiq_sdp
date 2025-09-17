import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/api/API_Services.dart'; // Import ApiService
import 'package:fitnation/api/meal_api_service.dart'; // Import MealApiService
import 'package:fitnation/providers/data_providers.dart'; // For apiServiceProvider and mealApiServiceProvider
import 'package:fitnation/models/meal.dart'; // Import Meal model
import 'package:fitnation/services/database_helper.dart'; // Import DatabaseHelper
import 'package:flutter/foundation.dart';
import 'package:fitnation/services/connectivity_service.dart'; // For NoInternetException

// --- Nutrition State ---
abstract class NutritionState {}

class NutritionInitial extends NutritionState {}

class NutritionLoading extends NutritionState {}

class NutritionLoaded extends NutritionState {
  final List<Meal> meals;
  final List<dynamic> foodLogs; // Added back for overview tab
  final List<dynamic>?
  healthLogs; // Can be List<HealthLog> once model is defined
  final List<dynamic>?
  dietRecommendations; // Can be List<DietRecommendation> once model is defined
  final Map<String, double>? nutritionTargets; // Add nutrition targets
  final Map<String, dynamic>? todayProgress; // Today's nutrition progress

  NutritionLoaded({
    this.meals = const [],
    this.foodLogs = const [], // Initialize as empty list
    this.healthLogs,
    this.dietRecommendations,
    this.nutritionTargets,
    this.todayProgress,
  });
}

class NutritionError extends NutritionState {
  final String message;
  NutritionError(this.message);
}

class MealSaving extends NutritionState {}

class MealSavedSuccess extends NutritionState {}

// --- Nutrition Notifier ---
class NutritionNotifier extends StateNotifier<NutritionState> {
  final ApiService _apiService; // Keep for backward compatibility
  final MealApiService _mealApiService;
  final DatabaseHelper _databaseHelper;

  NutritionNotifier(
    this._apiService,
    this._mealApiService,
    this._databaseHelper,
  ) : super(NutritionInitial());

  Future<void> fetchAllNutritionData() async {
    state = NutritionLoading();
    try {
      // Get the current user ID (you may need to adjust this based on your auth system)
      const String userId = "current_user"; // Replace with actual user ID logic

      // Fetch meals using MealApiService for progress tab
      final fetchedMeals = await _mealApiService.getMealsForUser();
      debugPrint("NutritionNotifier: Fetched meals: ${fetchedMeals.length}");

      // Fetch food logs from database for today
      final today = DateTime.now();
      final fetchedFoodLogs = await _databaseHelper.getFoodLogsByDate(
        userId,
        today,
      );
      debugPrint(
        "NutritionNotifier: Fetched food logs from database: ${fetchedFoodLogs.length}",
      );

      // Fetch nutrition targets from database
      final nutritionTargetsData = await _databaseHelper.getNutritionTargets(
        userId,
      );
      final nutritionTargets =
          nutritionTargetsData != null
              ? {
                'target_calories':
                    nutritionTargetsData['target_calories'] as double,
                'target_protein':
                    nutritionTargetsData['target_protein'] as double,
                'target_carbs': nutritionTargetsData['target_carbs'] as double,
                'target_fat': nutritionTargetsData['target_fat'] as double,
              }
              : {
                'target_calories': 2200.0,
                'target_protein': 130.0,
                'target_carbs': 275.0,
                'target_fat': 80.0,
              };

      state = NutritionLoaded(
        meals: fetchedMeals,
        foodLogs: fetchedFoodLogs,
        healthLogs: [], // Placeholder
        dietRecommendations: [], // Placeholder
        nutritionTargets: nutritionTargets,
        todayProgress: _calculateTodayProgress(fetchedFoodLogs),
      );
    } on NoInternetException catch (e) {
      debugPrint("Nutrition data fetch failed due to no internet: $e");
      state = NutritionError(e.message);
    } catch (e, st) {
      debugPrint("Nutrition data fetch failed: $e\nStackTrace: $st");
      state = NutritionError("Failed to load nutrition data: ${e.toString()}");
    }
  }

  Future<void> addFoodLog(Map<String, dynamic> foodLogData) async {
    state = MealSaving();
    try {
      // Get the current user ID (you may need to adjust this based on your auth system)
      const String userId = "current_user"; // Replace with actual user ID logic

      // Generate a unique ID for the food log
      final String foodLogId =
          'food_log_${DateTime.now().millisecondsSinceEpoch}';

      // Insert food log into database
      await _databaseHelper.insertFoodLog(
        id: foodLogId,
        userId: userId,
        foodName: foodLogData['food_name'] ?? '',
        calories: (foodLogData['calories'] ?? 0).toDouble(),
        protein: (foodLogData['protein'] ?? 0).toDouble(),
        carbs: (foodLogData['carbs'] ?? 0).toDouble(),
        fat: (foodLogData['fat'] ?? 0).toDouble(),
        servingSize: foodLogData['serving_size'],
        mealType: foodLogData['meal_type'] ?? 'other',
        consumedAt: foodLogData['consumed_at'] ?? DateTime.now(),
      );

      state = MealSavedSuccess();
      await fetchAllNutritionData(); // Refresh data after successful save
    } on NoInternetException catch (e) {
      debugPrint("Add food log failed due to no internet: $e");
      state = NutritionError(e.message);
    } catch (e, st) {
      debugPrint("Add food log failed: $e\nStackTrace: $st");
      state = NutritionError("Failed to add food log: ${e.toString()}");
    }
  }

  Future<void> addHealthLog(Map<String, dynamic> healthLogData) async {
    state = MealSaving(); // Reusing for health log, could be more specific
    try {
      await _apiService.createHealthLog(
        healthLogData,
      ); // Use ApiService for creating health logs
      state = MealSavedSuccess();
      await fetchAllNutritionData(); // Refresh data after successful save
    } on NoInternetException catch (e) {
      debugPrint("Add health log failed due to no internet: $e");
      state = NutritionError(e.message);
    } catch (e, st) {
      debugPrint("Add health log failed: $e\nStackTrace: $st");
      state = NutritionError("Failed to add health log: ${e.toString()}");
    }
  }

  // You can add more methods for updating, deleting, and specific queries
  // e.g., getFoodLogsForDate(DateTime date), getDailyMacrosSummary()

  Map<String, dynamic> _calculateTodayProgress(List<dynamic> foodLogs) {
    // Since we're already fetching today's logs from database, no need to filter again
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final log in foodLogs) {
      if (log is Map<String, dynamic>) {
        totalCalories += (log['calories'] as num?)?.toDouble() ?? 0;
        totalProtein += (log['protein'] as num?)?.toDouble() ?? 0;
        totalCarbs += (log['carbs'] as num?)?.toDouble() ?? 0;
        totalFat += (log['fat'] as num?)?.toDouble() ?? 0;
      }
    }

    return {
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_carbs': totalCarbs,
      'total_fat': totalFat,
      'entries_count': foodLogs.length,
    };
  }

  Future<void> saveNutritionTargets(Map<String, double> targets) async {
    try {
      // Get the current user ID (you may need to adjust this based on your auth system)
      const String userId = "current_user"; // Replace with actual user ID logic

      // Save to database using DatabaseHelper
      await _databaseHelper.insertOrUpdateNutritionTargets(
        userId: userId,
        targetCalories: targets['target_calories'] ?? 0.0,
        targetProtein: targets['target_protein'] ?? 0.0,
        targetCarbs: targets['target_carbs'] ?? 0.0,
        targetFat: targets['target_fat'] ?? 0.0,
      );

      // Update state directly
      if (state is NutritionLoaded) {
        final currentState = state as NutritionLoaded;
        state = NutritionLoaded(
          meals: currentState.meals,
          foodLogs: currentState.foodLogs,
          healthLogs: currentState.healthLogs,
          dietRecommendations: currentState.dietRecommendations,
          nutritionTargets: targets,
          todayProgress: currentState.todayProgress,
        );
      }
      debugPrint('Nutrition targets saved: $targets');
    } catch (e) {
      debugPrint('Error saving nutrition targets: $e');
      state = NutritionError(
        "Failed to save nutrition targets: ${e.toString()}",
      );
    }
  }
}

// --- Nutrition Provider ---
final nutritionProvider =
    StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
      final apiService = ref.watch(apiServiceProvider); // Get ApiService
      final mealApiService = ref.watch(
        mealApiServiceProvider,
      ); // Get MealApiService
      final databaseHelper = DatabaseHelper(); // Get DatabaseHelper instance
      return NutritionNotifier(apiService, mealApiService, databaseHelper);
    });

// Optional: Providers for specific data types if needed for direct consumption
final foodLogsListProvider = Provider<List<dynamic>>((ref) {
  // Changed back to List<dynamic>
  final nutritionState = ref.watch(nutritionProvider);
  if (nutritionState is NutritionLoaded) {
    return nutritionState.foodLogs; // Return foodLogs
  }
  return [];
});

final healthLogsListProvider = Provider<List<dynamic>>((ref) {
  final nutritionState = ref.watch(nutritionProvider);
  if (nutritionState is NutritionLoaded && nutritionState.healthLogs != null) {
    return nutritionState.healthLogs!;
  }
  return [];
});

final dietRecommendationsListProvider = Provider<List<dynamic>>((ref) {
  final nutritionState = ref.watch(nutritionProvider);
  if (nutritionState is NutritionLoaded &&
      nutritionState.dietRecommendations != null) {
    return nutritionState.dietRecommendations!;
  }
  return [];
});

// Nutrition targets provider
final nutritionTargetsProvider = Provider<Map<String, double>?>((ref) {
  final nutritionState = ref.watch(nutritionProvider);
  if (nutritionState is NutritionLoaded) {
    return nutritionState.nutritionTargets;
  }
  return null;
});

// Today's progress provider
final todayProgressProvider = Provider<Map<String, dynamic>?>((ref) {
  final nutritionState = ref.watch(nutritionProvider);
  if (nutritionState is NutritionLoaded) {
    return nutritionState.todayProgress;
  }
  return null;
});
