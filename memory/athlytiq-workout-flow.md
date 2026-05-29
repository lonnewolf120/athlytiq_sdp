---
name: athlytiq-workout-flow
description: How Athlytiq's working workout/exercise + AI-generation flow is wired (key types and the integration gap)
metadata:
  type: project
---

The ONE working pillar — workout/exercise tracking — and the AI gap (Option A target). All paths `fitnation/lib/`.

**Real exercise catalog (the grounding source):** 1500 exercises bundled at `assets/data/exercises.db` (+ `exercises.json`), copied to app docs dir on first run by `helpers/exercise_database_helper.dart` → `ExerciseDatabaseHelper` (singleton). API: `getExercises({limit,offset})`, `searchExercises({query,bodyPart,equipment,targetMuscle,...})`, `getExerciseById(id)`, `getBodyParts()`, `getEquipment()`, `getExerciseCount()` → all return `models/Exercise.dart` (`exercise_db.Exercise`: exerciseId,name,gifUrl,bodyParts[],equipments[],targetMuscles[],secondaryMuscles[],instructions[]). The working exercise search (`providers/exercise_search_provider.dart`) uses THIS local db. (Note: there is ALSO a backend `/exercise-library` API + `exercise_library_provider.dart` using the richer `ExerciseLibrary` model — separate, used by `pages/`. And ExerciseDB RapidAPI in `api/API_Services.dart`. Three exercise sources exist; the LOCAL bundled db is the reliable offline one.)

**Active workout (works):** `providers/active_workout_provider.dart` — `ActiveWorkoutNotifier`/`activeWorkoutProvider`. Consumes `exercise_db.Exercise` as `baseExercise`. `ActiveWorkoutState`(workoutName, startTime, endTime, exercises[ActiveWorkoutExercise{baseExercise, sets[ActiveWorkoutSet{weight,reps,isCompleted}]}], intensityScore). Methods: initializeNewWorkout, loadState, startWorkout, addExercise (adds 3 empty sets), finishWorkout(rpe), generateCompletedWorkoutData→`CompletedWorkout`, saveCompletedWorkout(api+sqflite). `ActiveWorkoutScreen(initialState:)`.

**AI generation (incomplete, NOT integrated):** `services/gemini_service.dart` `GeminiService.generateWorkoutPlan(userInfo)` (firebase_ai). `providers/gemini_workout_provider.dart` `geminiWorkoutPlanProvider`. Returns `Workout`(models/Workout.dart) with `List<PlannedExercise>`(exerciseId,exerciseName,exerciseEquipments,exerciseGifUrl,plannedSets,plannedReps,plannedWeight).

**THE GAP (Option A fixes):** (1) `_buildWorkoutPrompt` tells Gemini to invent `exercise_id` as arbitrary unique strings → never match the 1500-catalog → broken gifs/muscles. (2) START path in `Screens/Activities/WorkoutDetailScreen.dart` (~line 391) rebuilds `exercise_db.Exercise` from `PlannedExercise` with EMPTY bodyParts/targetMuscles/instructions + invented id — lossy workaround. (3) Prompt ignores `CompletedWorkout` history → no progressive overload. `WorkoutScreen.dart` "Start New Workout" FAB even adds a hardcoded dummy "Push Ups".

**Plan dirs:** Screens/Activities/{WorkoutScreen(1860 lines, 3 tabs PLANS/TRAINER/SESSION),WorkoutDetailScreen,WorkoutPlanGeneratorScreen(input form),ActiveWorkoutScreen,WorkoutHistoryScreen}. See [[athlytiq-feature-reality]], [[athlytiq-architecture]].
