# AI Workout Recommendation — Real-Catalog Integration (Option A)

**Date:** 2026-05-30
**Status:** Approved scope (Option A); spec pending user review
**Supersedes:** `2026-05-29-ai-nutrition-performance-coach-design.md` (deferred — depended on nutrition data that is not yet real; see memory `athlytiq-feature-reality`).

## 1. Problem

The AI workout generator exists but is broken in three concrete ways:

1. **Invented exercises.** `GeminiService._buildWorkoutPrompt` instructs Gemini to create `exercise_id` as arbitrary unique strings. Generated `PlannedExercise`s therefore never correspond to a real exercise in the app's 1500-exercise catalog (`assets/data/exercises.db`). Results: broken GIFs, no muscle/instruction data, no exercise detail.
2. **Lossy START path.** `WorkoutDetailScreen` (~line 391) converts each `PlannedExercise` → `exercise_db.Exercise` with **empty** `bodyParts`/`targetMuscles`/`instructions` and the invented id. So even when you start a generated plan, the active session has no real exercise data.
3. **No progressive overload.** The prompt uses only the profile form (age/sex/goal/experience/equipment) and ignores `CompletedWorkout` history entirely, so it cannot suggest "next" weights/reps based on what the user actually lifted.

## 2. Goal

Make AI-generated workouts consist of **real catalog exercises**, informed by the user's **completed-workout history**, and start them in the active-session flow with **full** exercise data (gif, muscles, instructions) — no lossy placeholder conversion.

## 3. Scope

**In scope (v1):**
- Ground generation in the real local catalog (`ExerciseDatabaseHelper`, 1500 exercises, offline).
- Feed recent `CompletedWorkout` history into the prompt for progressive-overload suggestions (per-exercise last weight/reps → suggested next).
- Resolve every AI-suggested exercise to a real `exercise_db.Exercise` before it reaches the UI; drop/replace unresolved ones.
- Fix the START path to use the resolved real exercises (full data), removing the empty-placeholder workaround.

**Out of scope (later):**
- Nutrition inputs (deferred coach slice).
- Backend `/exercise-library` model unification (we use the local bundled db that the working search already uses).
- Redesigning `WorkoutScreen` UI; replacing the hardcoded "Push Ups" dummy FAB is a small cleanup, not a redesign.
- Wearables, recovery/HRV.

**YAGNI:** no new exercise source, no embeddings/semantic search — name/muscle/equipment matching against the local db is sufficient and testable.

## 4. Key constraint: 1500 exercises can't all go in the prompt

Two-stage **generate-then-resolve** (chosen over stuffing the catalog into the prompt or full RAG):

1. **Constrain the prompt** with a *compact menu* — distinct body parts + equipment (from `getBodyParts()`/`getEquipment()`), the user's available equipment, and a shortlist of candidate exercise **names** drawn from the catalog filtered by the user's goal/equipment (e.g. top-N by relevance per target body part). Gemini selects from real names rather than inventing.
2. **Resolve** each returned exercise against the local db (`getExerciseById` if the id is real; else `searchExercises(query: name)` best-match by normalized name, then by target-muscle/equipment overlap). Unresolved → dropped (logged) or replaced by a catalog fallback for that body part. Output is `PlannedExercise`s whose `exerciseId` is guaranteed real.

This keeps the prompt small, makes the AI's job "pick + prescribe sets/reps/weight," and guarantees catalog-valid output regardless of model behavior.

## 5. Architecture (service + provider + screen; matches repo, Riverpod)

```
lib/
  services/coach/
    ai_json.dart                         # shared markdown-strip+JSON extract (lifted from GeminiService)
    exercise_resolver.dart               # pure-ish: match AI items -> exercise_db.Exercise via ExerciseDatabaseHelper
    workout_recommendation_service.dart  # builds catalog-constrained prompt (+history), calls model, returns resolved Workout
  services/coach/history/
    workout_history_summarizer.dart      # pure Dart: CompletedWorkout[] -> per-exercise last/best sets + progression hints
  providers/
    ai_workout_recommendation_provider.dart  # orchestrates: profile + history + catalog -> service -> Workout
  (edit) Screens/Activities/WorkoutDetailScreen.dart   # START uses resolved real exercises
  (edit) services/gemini_service.dart                  # prompt grounded; reuse ai_json
  (edit) providers/gemini_workout_provider.dart        # call new service / pass history
```

### 4 testable units (TDD targets)

1. **`WorkoutHistorySummarizer`** (pure): `List<CompletedWorkout>` → `Map<exerciseId, ExerciseProgressHint>` (last weight/reps, best set, simple next-step suggestion). Handles `"Bodyweight"`/non-numeric weight, missing history, multiple sessions per exercise.
2. **`ExerciseResolver`**: given AI items + an injected catalog gateway (interface over `ExerciseDatabaseHelper`), return resolved `exercise_db.Exercise` + unresolved list. Deterministic match rules; fully unit-tested with a fake catalog.
3. **`AiJson.extract`**: the markdown-fence/JSON logic lifted from `GeminiService`, with a characterization test proving `GeminiService` output is unchanged after refactor.
4. **`WorkoutRecommendationService`**: with an injected fake model + fake catalog — prompt contains catalog menu + history; well-formed/markdown/malformed/empty responses; every output exercise is catalog-valid; progression hints flow into `plannedWeight`/`plannedReps`.

Provider tested with fakes (history source + service). START-path change verified by a widget test asserting the active state's exercises carry real `bodyParts`/`targetMuscles`/`instructions`.

## 6. Data flow

```
Generator form (profile) + CompletedWorkout history (sqflite, getCompletedWorkouts)
  → WorkoutHistorySummarizer → progression hints
  → WorkoutRecommendationService.build prompt(profile + hints + catalog menu)
  → Gemini → raw items → ExerciseResolver(local catalog) → Workout(real PlannedExercises)
  → WorkoutScreen PLANS tab → WorkoutDetailScreen START
  → resolve PlannedExercise.exerciseId → ExerciseDatabaseHelper.getExerciseById → full exercise_db.Exercise
  → ActiveWorkoutState (full data) → ActiveWorkoutScreen
```

## 7. Error handling

| Condition | Behavior |
|---|---|
| No history | Generate from profile only; no progression hints (cold-start). |
| AI returns unknown exercise | Resolver drops it; if a plan section ends empty, fill with catalog fallback for that body part. |
| AI call fails / invalid JSON | Surface existing `WorkoutGenerationNotifier.setError`; no plan added. |
| Offline | Catalog + history are local; only the Gemini call needs network → clear error, retry. |
| START with a legacy/invented id | Resolver falls back to name search; if still unresolved, keep name-only exercise (current behavior) rather than crash. |

## 8. Milestones (for the plan)

1. `AiJson` extraction + `GeminiService` refactor (characterization test green) — no behavior change.
2. `WorkoutHistorySummarizer` (TDD).
3. `ExerciseResolver` + catalog gateway interface over `ExerciseDatabaseHelper` (TDD).
4. `WorkoutRecommendationService` (catalog-constrained prompt + history; injectable model; TDD).
5. `aiWorkoutRecommendationProvider` wiring (history from `getCompletedWorkouts`, real auth userId).
6. Fix `WorkoutDetailScreen` START to resolve real exercises (+ widget test); remove dummy "Push Ups" FAB path.
7. Manual run/verify: generate → plan shows real exercises w/ gifs → START → active session has muscles/instructions.

## 9. Open questions resolved
- Catalog source: local bundled `assets/data/exercises.db` via `ExerciseDatabaseHelper` (same as working search; offline).
- History source: `DatabaseHelper.getCompletedWorkouts(userId)` (local sqflite).
- Grounding strategy: generate-then-resolve with a compact prompt menu (not full-catalog prompt, not RAG).
- AI: firebase_ai Gemini (existing `GeminiService` model id).
- State mgmt: Riverpod.
