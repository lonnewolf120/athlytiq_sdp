import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fitnation/models/CompletedWorkout.dart';
// MealPlan import removed (unused in this file)
// import 'package:fitnation/models/CompletedWorkoutExercise.dart'; // Now in CompletedWorkout.dart
// import 'package:fitnation/models/CompletedWorkoutSet.dart'; // Now in CompletedWorkout.dart
import 'dart:async';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:fitnation/models/Workout.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static const String dbName = 'fitnation_app.db';
  static const int dbVersion = 2; // Incremented to 2

  // Table names
  static const String tableCompletedWorkouts = 'completed_workouts';
  static const String tableCompletedWorkoutExercises =
      'completed_workout_exercises';
  static const String tableCompletedWorkoutSets = 'completed_workout_sets';
  static const String tableMealPlans = 'meal_plans'; // New table name

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Enable onUpgrade for schema migrations
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCompletedWorkouts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        original_workout_id TEXT,
        workout_name TEXT NOT NULL,
        workout_icon_url TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        intensity_score REAL NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0 NOT NULL 
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCompletedWorkoutExercises (
        id TEXT PRIMARY KEY,
        completed_workout_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        exercise_name TEXT NOT NULL,
        exercise_equipments TEXT, 
        exercise_gif_url TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (completed_workout_id) REFERENCES $tableCompletedWorkouts (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCompletedWorkoutSets (
        id TEXT PRIMARY KEY,
        completed_workout_exercise_id TEXT NOT NULL,
        weight TEXT NOT NULL,
        reps TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (completed_workout_exercise_id) REFERENCES $tableCompletedWorkoutExercises (id) ON DELETE CASCADE
      )
    ''');

    // Create meal_plans table
    await db.execute('''
      CREATE TABLE $tableMealPlans (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        user_goals TEXT,
        linked_workout_plan_id TEXT,
        meals_json TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create nutrition_targets table
    await db.execute('''
      CREATE TABLE nutrition_targets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        target_calories REAL NOT NULL,
        target_protein REAL NOT NULL,
        target_carbs REAL NOT NULL,
        target_fat REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create food_logs table
    await db.execute('''
      CREATE TABLE food_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        food_name TEXT NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        serving_size TEXT,
        meal_type TEXT NOT NULL,
        consumed_at TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create user_preferences table
    await db.execute('''
      CREATE TABLE user_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id, key)
      )
    ''');

    // Create workout_plans table for locally storing workout plans
    await db.execute('''
      CREATE TABLE workout_plans (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        data_json TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // For future schema migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create meal_plans table if upgrading from a version less than 2
      await db.execute('''
        CREATE TABLE $tableMealPlans (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          user_goals TEXT,
          linked_workout_plan_id TEXT,
          meals_json TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      // Create nutrition_targets table
      await db.execute('''
        CREATE TABLE nutrition_targets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          target_calories REAL NOT NULL,
          target_protein REAL NOT NULL,
          target_carbs REAL NOT NULL,
          target_fat REAL NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // Create food_logs table
      await db.execute('''
        CREATE TABLE food_logs (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          food_name TEXT NOT NULL,
          calories REAL NOT NULL,
          protein REAL NOT NULL,
          carbs REAL NOT NULL,
          fat REAL NOT NULL,
          serving_size TEXT,
          meal_type TEXT NOT NULL,
          consumed_at TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      // Create user_preferences table
      await db.execute('''
        CREATE TABLE user_preferences (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          key TEXT NOT NULL,
          value TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          UNIQUE(user_id, key)
        )
      ''');
    }
    // Ensure workout_plans exists on upgrade
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS workout_plans (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          data_json TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }
    // Add more upgrade paths as needed for future versions
  }

  // --- CRUD for local workout plans ---

  Future<int> insertLocalWorkoutPlan(Workout plan) async {
    final db = await database;
    final map = {
      'id': plan.id,
      'name': plan.name,
      'data_json': jsonEncode(plan.toJson()),
      'created_at': DateTime.now().toIso8601String(),
    };
    return await db.insert(
      'workout_plans',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Workout>> getLocalWorkoutPlans() async {
    final db = await database;
    final rows = await db.query('workout_plans', orderBy: 'created_at DESC');
    List<Workout> plans = [];
    for (var r in rows) {
      try {
        final String rawJson = r['data_json']?.toString() ?? '{}';
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          jsonDecode(rawJson),
        );
        plans.add(Workout.fromJson(data));
      } catch (e) {
        debugPrint('DatabaseHelper: Failed to parse local workout plan: $e');
      }
    }
    return plans;
  }

  Future<int> deleteLocalWorkoutPlan(String id) async {
    final db = await database;
    return await db.delete('workout_plans', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD for CompletedWorkout ---

  Future<int> insertCompletedWorkout(
    CompletedWorkout workout, {
    bool synced = false,
  }) async {
    final db = await database;
    int workoutRowId = -1;

    await db.transaction((txn) async {
      // Insert workout
      if (workout.userId.isEmpty) {
        // Ensure userId is available
        debugPrint(
          'DatabaseHelper: insertCompletedWorkout failed, userId is empty!',
        );
        throw Exception("User ID is required to save workout locally.");
      }

      debugPrint(
        'DatabaseHelper: Inserting completed workout for userId=${workout.userId}, workoutId=${workout.id}',
      );

      // Prepare map specifically for the completed_workouts table
      Map<String, dynamic> workoutDataForDb = {
        'id': workout.id,
        'user_id': workout.userId,
        'original_workout_id': workout.originalWorkoutId, // Allowed to be null
        'workout_name': workout.workoutName,
        'workout_icon_url': workout.workoutIconUrl, // Allowed to be null
        'start_time': workout.startTime.toIso8601String(),
        'end_time': workout.endTime.toIso8601String(),
        'duration_seconds': workout.durationSeconds,
        'intensity_score': workout.intensityScore,
        'created_at': workout.createdAt.toIso8601String(),
        'synced': synced ? 1 : 0,
      };

      workoutRowId = await txn.insert(
        tableCompletedWorkouts,
        workoutDataForDb,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert exercises and their sets
      for (var exercise in workout.exercises) {
        Map<String, dynamic> exerciseMap = exercise.toMap();
        exerciseMap['completed_workout_id'] = workout.id;
        await txn.insert(
          tableCompletedWorkoutExercises,
          exerciseMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        for (var setEntry in exercise.sets) {
          Map<String, dynamic> setMap = setEntry.toMap();
          setMap['completed_workout_exercise_id'] = exercise.id;
          await txn.insert(
            tableCompletedWorkoutSets,
            setMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
    debugPrint(
      'DatabaseHelper: Finished inserting workoutId=${workout.id} for userId=${workout.userId}',
    );
    return workoutRowId;
  }

  Future<List<CompletedWorkout>> getCompletedWorkouts(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> workoutMaps = await db.query(
      tableCompletedWorkouts,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_time DESC',
    );

    debugPrint(
      'DatabaseHelper: getCompletedWorkouts for userId=$userId returned ${workoutMaps.length} workouts',
    );

    List<CompletedWorkout> workouts = [];
    for (var workoutMap in workoutMaps) {
      final List<Map<String, dynamic>> exerciseMaps = await db.query(
        tableCompletedWorkoutExercises,
        where: 'completed_workout_id = ?',
        whereArgs: [workoutMap['id']],
      );

      List<CompletedWorkoutExercise> exercises = [];
      for (var exerciseMap in exerciseMaps) {
        final List<Map<String, dynamic>> setMaps = await db.query(
          tableCompletedWorkoutSets,
          where: 'completed_workout_exercise_id = ?',
          whereArgs: [exerciseMap['id']],
        );
        List<CompletedWorkoutSet> sets =
            setMaps.map((s) => CompletedWorkoutSet.fromMap(s)).toList();
        // Create CompletedWorkoutExercise from map and add loaded sets
        CompletedWorkoutExercise exercise = CompletedWorkoutExercise.fromMap(
          exerciseMap,
        ).copyWith(sets: sets);
        exercises.add(exercise);
      }
      // Create CompletedWorkout from map and add loaded exercises
      CompletedWorkout workout = CompletedWorkout.fromMap(
        workoutMap,
      ).copyWith(exercises: exercises);
      workouts.add(workout);
    }
    return workouts;
  }

  Future<List<String>> getDistinctWorkoutNames() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      tableCompletedWorkouts,
      distinct: true,
      columns: ['workout_name'],
      orderBy: 'workout_name ASC',
    );
    return result.map((map) => map['workout_name'] as String).toList();
  }

  Future<List<CompletedWorkout>> getUnsyncedWorkouts(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> workoutMaps = await db.query(
      tableCompletedWorkouts,
      where: 'user_id = ? AND synced = ?',
      whereArgs: [userId, 0],
      orderBy: 'start_time ASC', // Process older ones first
    );

    List<CompletedWorkout> workouts = [];
    for (var workoutMap in workoutMaps) {
      // Similar logic to getCompletedWorkouts to fetch exercises and sets
      final List<Map<String, dynamic>> exerciseMaps = await db.query(
        tableCompletedWorkoutExercises,
        where: 'completed_workout_id = ?',
        whereArgs: [workoutMap['id']],
      );
      List<CompletedWorkoutExercise> exercises = [];
      for (var exerciseMap in exerciseMaps) {
        final List<Map<String, dynamic>> setMaps = await db.query(
          tableCompletedWorkoutSets,
          where: 'completed_workout_exercise_id = ?',
          whereArgs: [exerciseMap['id']],
        );
        List<CompletedWorkoutSet> sets =
            setMaps.map((s) => CompletedWorkoutSet.fromMap(s)).toList();
        exercises.add(
          CompletedWorkoutExercise.fromMap(exerciseMap).copyWith(sets: sets),
        );
      }
      workouts.add(
        CompletedWorkout.fromMap(workoutMap).copyWith(exercises: exercises),
      );
    }
    return workouts;
  }

  Future<int> updateWorkoutSyncedStatus(String workoutId, bool synced) async {
    final db = await database;
    return await db.update(
      tableCompletedWorkouts,
      {'synced': synced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [workoutId],
    );
  }

  Future<int> deleteWorkout(String workoutId) async {
    final db = await database;
    // Cascading delete should handle exercises and sets due to FOREIGN KEY ON DELETE CASCADE
    return await db.delete(
      tableCompletedWorkouts,
      where: 'id = ?',
      whereArgs: [workoutId],
    );
  }

  // Optional: Method to clear all synced workouts older than a certain date for cache cleanup
  Future<void> clearOldSyncedWorkouts(String userId, DateTime olderThan) async {
    final db = await database;
    await db.delete(
      tableCompletedWorkouts,
      where: 'user_id = ? AND synced = ? AND start_time < ?',
      whereArgs: [userId, 1, olderThan.toIso8601String()],
    );
  }

  // --- CRUD for Meal Plans ---

  Future<int> insertMealPlan(
    String userId,
    Map<String, dynamic> mealPlanData,
  ) async {
    final db = await database;

    // Prepare data for insertion
    final data = {
      'id': mealPlanData['id'] ?? '',
      'user_id': userId,
      'name': mealPlanData['name'] ?? '',
      'description': mealPlanData['description'] ?? '',
      'user_goals': mealPlanData['userGoals'] ?? '',
      'linked_workout_plan_id': mealPlanData['linkedWorkoutPlanId'],
      'meals_json': jsonEncode(mealPlanData['meals'] ?? []),
      'created_at':
          mealPlanData['createdAt'] ?? DateTime.now().toIso8601String(),
    };

    debugPrint(
      'DatabaseHelper: Inserting meal plan for userId=$userId, planId=${data['id']}',
    );

    return await db.insert(
      tableMealPlans,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMealPlans(String userId) async {
    final db = await database;

    debugPrint('DatabaseHelper: Getting meal plans for userId=$userId');

    final List<Map<String, dynamic>> maps = await db.query(
      tableMealPlans,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    debugPrint(
      'DatabaseHelper: Found ${maps.length} meal plans for userId=$userId',
    );

    // Convert meals_json back to List<dynamic>
    List<Map<String, dynamic>> mealPlans = [];
    for (var map in maps) {
      try {
        final mealPlanData = Map<String, dynamic>.from(map);
        final mealsJson = map['meals_json'] as String?;
        if (mealsJson != null && mealsJson.isNotEmpty) {
          mealPlanData['meals'] = jsonDecode(mealsJson);
        } else {
          mealPlanData['meals'] = [];
        }
        // Remove the JSON string version since we've parsed it
        mealPlanData.remove('meals_json');
        mealPlans.add(mealPlanData);
      } catch (e) {
        debugPrint('DatabaseHelper: Failed to parse meal plan: $e');
      }
    }

    return mealPlans;
  }

  Future<Map<String, dynamic>?> getMealPlan(
    String userId,
    String mealPlanId,
  ) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      tableMealPlans,
      where: 'user_id = ? AND id = ?',
      whereArgs: [userId, mealPlanId],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    try {
      final mealPlanData = Map<String, dynamic>.from(maps.first);
      final mealsJson = maps.first['meals_json'] as String?;
      if (mealsJson != null && mealsJson.isNotEmpty) {
        mealPlanData['meals'] = jsonDecode(mealsJson);
      } else {
        mealPlanData['meals'] = [];
      }
      mealPlanData.remove('meals_json');
      return mealPlanData;
    } catch (e) {
      debugPrint('DatabaseHelper: Failed to parse meal plan: $e');
      return null;
    }
  }

  Future<int> updateMealPlan(
    String userId,
    String mealPlanId,
    Map<String, dynamic> mealPlanData,
  ) async {
    final db = await database;

    final data = {
      'name': mealPlanData['name'] ?? '',
      'description': mealPlanData['description'] ?? '',
      'user_goals': mealPlanData['userGoals'] ?? '',
      'linked_workout_plan_id': mealPlanData['linkedWorkoutPlanId'],
      'meals_json': jsonEncode(mealPlanData['meals'] ?? []),
    };

    debugPrint(
      'DatabaseHelper: Updating meal plan for userId=$userId, planId=$mealPlanId',
    );

    return await db.update(
      tableMealPlans,
      data,
      where: 'user_id = ? AND id = ?',
      whereArgs: [userId, mealPlanId],
    );
  }

  Future<int> deleteMealPlan(String userId, String mealPlanId) async {
    final db = await database;

    debugPrint(
      'DatabaseHelper: Deleting meal plan for userId=$userId, planId=$mealPlanId',
    );

    return await db.delete(
      tableMealPlans,
      where: 'user_id = ? AND id = ?',
      whereArgs: [userId, mealPlanId],
    );
  }

  Future<int> deleteAllMealPlans(String userId) async {
    final db = await database;

    debugPrint('DatabaseHelper: Deleting all meal plans for userId=$userId');

    return await db.delete(
      tableMealPlans,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // =========================
  // NUTRITION TARGETS CRUD
  // =========================

  // Insert or update nutrition targets
  Future<void> insertOrUpdateNutritionTargets({
    required String userId,
    required double targetCalories,
    required double targetProtein,
    required double targetCarbs,
    required double targetFat,
  }) async {
    final db = await database;

    final now = DateTime.now().toIso8601String();

    await db.execute(
      '''
      INSERT OR REPLACE INTO nutrition_targets 
      (user_id, target_calories, target_protein, target_carbs, target_fat, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, 
        COALESCE((SELECT created_at FROM nutrition_targets WHERE user_id = ?), ?),
        ?)
    ''',
      [
        userId,
        targetCalories,
        targetProtein,
        targetCarbs,
        targetFat,
        userId,
        now,
        now,
      ],
    );
  }

  // Get nutrition targets for a user
  Future<Map<String, dynamic>?> getNutritionTargets(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'nutrition_targets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // =========================
  // FOOD LOGS CRUD
  // =========================

  // Insert food log entry
  Future<void> insertFoodLog({
    required String id,
    required String userId,
    required String foodName,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    String? servingSize,
    required String mealType,
    required DateTime consumedAt,
  }) async {
    final db = await database;

    await db.insert('food_logs', {
      'id': id,
      'user_id': userId,
      'food_name': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'serving_size': servingSize,
      'meal_type': mealType,
      'consumed_at': consumedAt.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get food logs for a user on a specific date
  Future<List<Map<String, dynamic>>> getFoodLogsByDate(
    String userId,
    DateTime date,
  ) async {
    final db = await database;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      'food_logs',
      where: 'user_id = ? AND consumed_at >= ? AND consumed_at <= ?',
      whereArgs: [
        userId,
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ],
      orderBy: 'consumed_at ASC',
    );

    return maps;
  }

  // Get food logs for a user within a date range
  Future<List<Map<String, dynamic>>> getFoodLogsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'food_logs',
      where: 'user_id = ? AND consumed_at >= ? AND consumed_at <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'consumed_at ASC',
    );

    return maps;
  }

  // Update food log entry
  Future<void> updateFoodLog({
    required String id,
    required String foodName,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    String? servingSize,
    required String mealType,
    required DateTime consumedAt,
  }) async {
    final db = await database;

    await db.update(
      'food_logs',
      {
        'food_name': foodName,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'serving_size': servingSize,
        'meal_type': mealType,
        'consumed_at': consumedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete food log entry
  Future<void> deleteFoodLog(String id) async {
    final db = await database;
    await db.delete('food_logs', where: 'id = ?', whereArgs: [id]);
  }

  // =========================
  // USER PREFERENCES CRUD
  // =========================

  // Set user preference
  Future<void> setUserPreference(
    String userId,
    String key,
    String value,
  ) async {
    final db = await database;

    await db.execute(
      '''
      INSERT OR REPLACE INTO user_preferences 
      (user_id, key, value, updated_at)
      VALUES (?, ?, ?, ?)
    ''',
      [userId, key, value, DateTime.now().toIso8601String()],
    );
  }

  // Get user preference
  Future<String?> getUserPreference(String userId, String key) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'user_preferences',
      columns: ['value'],
      where: 'user_id = ? AND key = ?',
      whereArgs: [userId, key],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }

  // Get all user preferences
  Future<Map<String, String>> getAllUserPreferences(String userId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final Map<String, String> preferences = {};
    for (final map in maps) {
      preferences[map['key'] as String] = map['value'] as String;
    }

    return preferences;
  }

  // Delete user preference
  Future<void> deleteUserPreference(String userId, String key) async {
    final db = await database;
    await db.delete(
      'user_preferences',
      where: 'user_id = ? AND key = ?',
      whereArgs: [userId, key],
    );
  }
}
