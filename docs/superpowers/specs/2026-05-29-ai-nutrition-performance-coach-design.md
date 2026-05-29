# Smart Coach Insights — AI Nutrition→Performance Coach (v1)

**Date:** 2026-05-29
**Status:** Approved design (pending written-spec review)
**Strategy link:** `athlytiq_strategy.html` §5.1–5.2 — the "nutrition-to-performance bridge," described as Athlytiq's "most defensible competitive advantage."

## 1. Goal

Surface 1–3 proactive, actionable AI insights that correlate the user's recent **nutrition** with their recent **training performance** — e.g. *"Your squat volume dropped 12% over three days of low protein intake. Try these protein-rich meals before your next leg day."*

This is the flagship differentiator: no incumbent connects nutrition logs to lifting performance. v1 proves the bridge with the data the app already collects.

## 2. Scope

**In scope (v1):**
- 14-day rolling window.
- Text insights only (title, body, category, severity, suggested action).
- Reads **existing** data (local completed workouts + backend food logs). **No backend changes.**
- Local-first with offline cache of the last good insight set.
- One UI surface: a `CoachInsightCard` on the Home screen (reused on the nutrition progress screen).

**Out of scope (later slices, per strategy roadmap):**
- Push/proactive notifications (Phase 2 "proactivity").
- Wearable/HRV/sleep recovery inputs.
- Camera form coach, adaptive auto-planning.
- A food-log range endpoint (v1 loops existing per-day endpoint).

**YAGNI:** no new charts, no settings, no multi-window comparison.

## 3. Existing code this builds on

- `services/gemini_service.dart` — `GeminiService` using `firebase_ai` (`FirebaseAI.googleAI()`, `gemini-2.5-flash-preview-05-20`), prompt builder + robust markdown-stripping JSON parse. **Pattern to mirror.**
- `models/CompletedWorkout.dart` — `CompletedWorkout` (startTime, endTime, durationSeconds, intensityScore, exercises→sets with `weight`/`reps` as **strings**, e.g. `"Bodyweight"`).
- `services/database_helper.dart` — `getAllCompletedWorkouts()` / `getCompletedWorkouts()` → `List<CompletedWorkout>` (local sqflite).
- `services/api_service.dart` — `ApiService.getFoodLogsForDate(userId, date)` → `List<FoodLogEntry>` (calories/protein/carbs/fat/quantity/unit/mealType/loggedAt).
- State management: **Riverpod** (`flutter_riverpod` + `StateNotifier`/`AsyncNotifier`), as used in `nutrition_provider.dart`.

**Pre-existing risk (not owned by this slice):** `api_service.dart` contains duplicated `FoodLogEntry.fromJson` and `getFoodLogsForDate` definitions (merge artifact) that will not compile. Our new code depends on food logs only through a narrow interface (`FoodLogSource`), so the aggregator + AI service + tests are unaffected and fully testable regardless. The duplicate is flagged for a separate cleanup; the plan will note it as a build blocker to confirm/fix before wiring the provider into the running app.

## 4. Architecture

Follows the existing **service + Riverpod provider + widget** pattern. New code lives under `fitnation/lib/`:

```
lib/
  models/
    coach_insight.dart          # CoachInsight, CoachInsightCategory, CoachInsightSeverity
    coaching_snapshot.dart      # CoachingSnapshot, DailyMetrics
  services/
    coach/
      performance_nutrition_aggregator.dart   # pure Dart, no I/O  ← main TDD unit
      coach_insight_service.dart               # firebase_ai, mirrors GeminiService
      coach_data_source.dart                   # WorkoutSource + FoodLogSource interfaces
      ai_json.dart                             # shared markdown-strip + JSON-extract helper
  providers/
    coach_insights_provider.dart  # AsyncNotifier orchestrating load→aggregate→AI→cache
  widgets/
    coach/
      coach_insight_card.dart     # loading / empty / error / data states
```

### 4.1 Components & contracts

**`PerformanceNutritionAggregator`** (pure, deterministic, no I/O — the primary unit under test)
- Input: `List<CompletedWorkout> workouts`, `Map<DateTime, DailyMacroTotals> macrosByDay`, `DateTime now`, `int windowDays = 14`.
- Output: `CoachingSnapshot` — list of `DailyMetrics` (date, trainingVolume, intensityScore, calories, protein, carbs, fat, workoutCount) plus derived summary fields (avg protein, volume trend %, rest-day count, low-protein streak).
- Rules:
  - `trainingVolume = Σ exercises Σ sets (parseWeight(set.weight) × parseReps(set.reps))`.
  - `parseWeight`: non-numeric (e.g. `"Bodyweight"`) → treat as 0 for volume (documented; bodyweight contributes via workout count/intensity, not load volume).
  - Days with no workout → volume 0, workoutCount 0. Days with no food log → macros null (distinct from 0; "not logged" ≠ "ate nothing").
  - Window = the `windowDays` calendar days ending on `now` (date-normalized, local tz).

**`CoachingSnapshot.toPromptJson()`** — compact JSON the AI consumes (no PII beyond fitness metrics; supports the strategy's privacy stance).

**`CoachInsightService`** (mirrors `GeminiService`)
- Constructor injects a `GenerativeModel` (default `FirebaseAI.googleAI().generativeModel(...)`) so tests pass a fake. *(If `firebase_ai`'s `GenerativeModel` is not cleanly fakeable, wrap it behind a tiny `ContentGenerator` interface — decided in the plan.)*
- `Future<List<CoachInsight>> generate(CoachingSnapshot snapshot)`: build prompt → generate → `AiJson.extract()` → parse list → `CoachInsight.fromJson`.
- Insufficient-data guard (e.g. `<2` workouts or `<3` logged days in window) → returns `[]` without calling the model.

**`AiJson.extract(String raw)`** — the markdown-fence stripping + List/Map/double-decode logic currently inlined in `GeminiService`, extracted to one tested helper. `GeminiService` is refactored to call it (targeted, behavior-preserving; covered by a characterization test).

**`coach_data_source.dart`** — `WorkoutSource` (`getRecentCompletedWorkouts(window)`) and `FoodLogSource` (`getMacrosByDay(userId, window)`). Concrete adapters wrap `DatabaseHelper` and `ApiService` (looping per-day over the window). Interfaces keep the provider testable and insulate us from the `api_service.dart` dup.

**`coachInsightsProvider`** (`AsyncNotifier<List<CoachInsight>>`)
- Load workouts (local) + macros (per-day loop), aggregate, call service, write result + timestamp to a `coach_insights_cache` sqflite table.
- On AI/network error → fall back to cached insights if present, else error state.
- `refresh()` for pull-to-refresh.

**`CoachInsightCard`** — Riverpod `ConsumerWidget`; states: loading (shimmer/spinner), empty ("Log a few more workouts and meals to unlock Smart Coach"), error (retry), data (top insight + count, tap → bottom sheet/detail with all insights). Severity drives accent color; category drives icon.

### 4.2 Data flow

```
Home → coachInsightsProvider
  → WorkoutSource.getRecentCompletedWorkouts(14d)   [local sqflite]
  → FoodLogSource.getMacrosByDay(userId, 14d)        [backend, per-day loop]
  → PerformanceNutritionAggregator → CoachingSnapshot
  → CoachInsightService.generate() → List<CoachInsight>   [firebase_ai]
  → cache to sqflite → CoachInsightCard renders
```

## 5. Error handling

| Condition | Behavior |
|---|---|
| Not authenticated / no userId | Empty state (no fetch). |
| Insufficient data (<2 workouts or <3 logged days) | Empty "unlock" state; model not called. |
| AI call fails / invalid JSON | Serve cached insights if present; else error state with retry. Never crash. |
| Offline | Serve cached insights; card shows "offline — last updated <time>". |
| Partial food-log day fetch failure | Treat that day as "not logged"; continue. |

## 6. Testing (TDD)

Tests written first, red→green per unit.

1. **`PerformanceNutritionAggregator`** (bulk of coverage):
   - volume math across exercises/sets; `"Bodyweight"`/empty/non-numeric weight → 0 load.
   - empty workouts; empty logs; mixed days; window boundary (inclusive/exclusive) and tz normalization.
   - derived metrics: avg protein, volume-trend %, low-protein streak, rest-day count.
2. **`AiJson.extract`** — fenced ```json, bare fences, double-encoded string, List vs Map, empty/invalid → throws; plus a characterization test proving `GeminiService` output is unchanged after refactor.
3. **`CoachInsightService`** — injected fake model returns canned responses: well-formed list, markdown-wrapped, malformed (throws), empty; insufficient-data guard returns `[]` without calling model; prompt contains key snapshot fields.
4. **`CoachInsightCard`** — widget tests for loading/empty/error/data via overridden provider.

Provider orchestration covered via fake `WorkoutSource`/`FoodLogSource` + fake service (cache hit/miss, error fallback).

## 7. Milestones (for the plan)

1. Models (`CoachInsight`, `CoachingSnapshot`, `DailyMetrics`) + json/codegen.
2. `AiJson` extraction + `GeminiService` refactor (characterization test green).
3. `PerformanceNutritionAggregator` (TDD).
4. `CoachInsightService` with injectable model (TDD).
5. Data-source interfaces + adapters; confirm/fix `api_service.dart` dup build blocker.
6. `coachInsightsProvider` + sqflite cache.
7. `CoachInsightCard` + Home wiring.
8. Manual run/verify on Home.

## 8. Open questions resolved
- Food-log source: backend per-day (`ApiService.getFoodLogsForDate`); v1 loops the window client-side; range endpoint deferred.
- Workout source: local sqflite (`DatabaseHelper`).
- State mgmt: Riverpod (matches repo).
- AI: `firebase_ai` Gemini (matches `GeminiService`).
