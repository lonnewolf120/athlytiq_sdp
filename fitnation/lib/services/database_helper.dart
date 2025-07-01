import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fitnation/models/CompletedWorkout.dart';
import 'package:fitnation/models/MealPlan.dart'; // Import MealPlan
// import 'package:fitnation/models/CompletedWorkoutExercise.dart'; // Now in CompletedWorkout.dart
// import 'package:fitnation/models/CompletedWorkoutSet.dart'; // Now in CompletedWorkout.dart
import 'dart:async';

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
  static const String tableCompletedWorkoutExercises = 'completed_workout_exercises';
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
    }
    // Add more upgrade paths as needed for future versions
  }

  // --- CRUD for CompletedWorkout ---

  Future<int> insertCompletedWorkout(CompletedWorkout workout, {bool synced = false}) async {
    final db = await database;
    int workoutRowId = -1;

    await db.transaction((txn) async {
      // Insert workout
      if (workout.userId.isEmpty) { // Ensure userId is available
        throw Exception("User ID is required to save workout locally.");
      }

      // Prepare map specifically for the completed_workouts table
      // This ensures only columns defined in tableCompletedWorkouts are included.
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
        // Assuming workout.createdAt is a DateTime object.
        // The table schema defines created_at TEXT NOT NULL.
        'created_at': workout.createdAt.toIso8601String(),
        'synced': synced ? 1 : 0,
      };

      workoutRowId = await txn.insert(tableCompletedWorkouts, workoutDataForDb, conflictAlgorithm: ConflictAlgorithm.replace);

      // Insert exercises and their sets
      for (var exercise in workout.exercises) {
        Map<String, dynamic> exerciseMap = exercise.toMap();
        exerciseMap['completed_workout_id'] = workout.id; // Link to parent workout
        await txn.insert(tableCompletedWorkoutExercises, exerciseMap, conflictAlgorithm: ConflictAlgorithm.replace);

        for (var setEntry in exercise.sets) {
          Map<String, dynamic> setMap = setEntry.toMap();
          setMap['completed_workout_exercise_id'] = exercise.id; // Link to parent exercise
          await txn.insert(tableCompletedWorkoutSets, setMap, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
    return workoutRowId; // Returns the row ID of the inserted workout, or -1 if transaction failed before insert.
  }

  Future<List<CompletedWorkout>> getCompletedWorkouts(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> workoutMaps = await db.query(
      tableCompletedWorkouts,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_time DESC',
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
        List<CompletedWorkoutSet> sets = setMaps.map((s) => CompletedWorkoutSet.fromMap(s)).toList();
        // Create CompletedWorkoutExercise from map and add loaded sets
        CompletedWorkoutExercise exercise = CompletedWorkoutExercise.fromMap(exerciseMap).copyWith(sets: sets);
        exercises.add(exercise);
      }
      // Create CompletedWorkout from map and add loaded exercises
      CompletedWorkout workout = CompletedWorkout.fromMap(workoutMap).copyWith(exercises: exercises);
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
        List<CompletedWorkoutSet> sets = setMaps.map((s) => CompletedWorkoutSet.fromMap(s)).toList();
        exercises.add(CompletedWorkoutExercise.fromMap(exerciseMap).copyWith(sets: sets));
      }
      workouts.add(CompletedWorkout.fromMap(workoutMap).copyWith(exercises: exercises));
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

}
