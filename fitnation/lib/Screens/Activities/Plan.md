# Workout History SQLite Integration and Sync Plan

This document outlines the plan for integrating SQLite for workout history persistence and a future synchronization mechanism with an online database (PostgreSQL/Supabase).

## Phase 1: SQLite Integration for Workout History

**Goal:** Implement local persistence for completed workout data using SQLite.

**1. Add Dependencies:**
   *   **File:** `pubspec.yaml`
   *   **Changes:** Add `sqflite` and `path_provider` under `dependencies:`.

     ```yaml
     dependencies:
       flutter:
         sdk: flutter
       sqflite: ^latest_version
       path_provider: ^latest_version
     ```

**2. Create Database Helper:**
   *   **File:** `lib/services/database_helper.dart` (new file)
   *   **Changes:**
     *   Define a `DatabaseHelper` class with a singleton pattern.
     *   Implement `initDb()` method:
         *   Get the database path using `path_provider`.
         *   Open the database.
         *   Execute `CREATE TABLE` statements for `users`, `completed_workouts`, `completed_workout_exercises`, and `completed_workout_sets` based on the provided SQLite schema. (Note: Other tables from the schema are not directly related to workout history saving, so they can be added as needed for other features or omitted if not used by the app).
     *   Implement `insertCompletedWorkout(CompletedWorkout workout)` method:
         *   Convert `CompletedWorkout` object to a `Map<String, dynamic>`.
         *   Insert into `completed_workouts` table.
         *   Iterate through `workout.exercises`:
             *   Convert `CompletedWorkoutExercise` to `Map<String, dynamic>`.
             *   Insert into `completed_workout_exercises` table, linking to the `completed_workout_id`.
             *   Iterate through `exercise.sets`:
                 *   Convert `CompletedWorkoutSet` to `Map<String, dynamic>`.
                 *   Insert into `completed_workout_sets` table, linking to the `completed_workout_exercise_id`.
     *   Implement `Future<List<CompletedWorkout>> getCompletedWorkouts({String? typeFilter, String? timeFilter})` method:
         *   Query `completed_workouts` table.
         *   Join with `completed_workout_exercises` and `completed_workout_sets` to retrieve nested data.
         *   Apply `WHERE` clauses based on `typeFilter` and `timeFilter` (e.g., `WHERE workoutName = ?` for type, `WHERE start_time BETWEEN ? AND ?` for time range).
         *   Reconstruct `CompletedWorkout` objects with their nested exercises and sets from the query results.

**3. Update Models for Database Compatibility:**
   *   **Files:**
     *   `lib/models/CompletedWorkout.dart`
     *   `lib/models/CompletedWorkoutExercise.dart`
     *   `lib/models/CompletedWorkoutSet.dart`
   *   **Changes:**
     *   Add `toMap()` methods to convert model instances to `Map<String, dynamic>` for database insertion.
     *   Add `fromMap()` factory constructors or static methods to create model instances from `Map<String, dynamic>` (database query results).
     *   Ensure UUIDs are handled as `TEXT` in the database and `String` in Dart.
     *   Ensure `DateTime` objects are converted to `DATETIME` (ISO 8601 string) for storage and parsed back.

**4. Integrate with `WorkoutHistoryScreen.dart`:**
   *   **File:** `lib/Screens/Activities/WorkoutHistoryScreen.dart`
   *   **Changes:**
     *   Modify `userCompletedWorkoutsProvider` to use `DatabaseHelper.getCompletedWorkouts`.
     *   Remove or comment out the `_dummyCompletedWorkouts` list.
     *   Ensure the `currentUserProvider` is correctly providing a user ID for fetching user-specific workouts.

**5. Implement Workout Saving Logic:**
   *   **Potential Files:**
     *   `lib/Screens/Activities/ActiveWorkoutScreen.dart` (most likely place where a workout session concludes)
     *   `lib/Screens/Activities/WorkoutDetailScreen.dart` (if there's a "start workout" button that leads to a completion flow)
   *   **Changes:**
     *   Identify the point where a workout is marked as "completed."
     *   Create a `CompletedWorkout` object (and its nested exercises/sets) from the active workout data.
     *   Call `DatabaseHelper.instance.insertCompletedWorkout(completedWorkout)`.
     *   Consider adding a `FutureProvider` or `StateNotifierProvider` for managing the saving process and providing feedback to the user.

This `plan.md` will serve as a detailed roadmap for the implementation.
