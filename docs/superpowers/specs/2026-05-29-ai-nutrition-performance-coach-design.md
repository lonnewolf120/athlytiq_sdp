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
- Reads **existing local** data (completed workouts + food logs, both in sqflite). **No backend changes.** Fully offline-capable except the AI call itself.
- Local-first with offline cache of the last good insight set.
- One UI surface: a `CoachInsightCard` on the Home screen (reused on the nutrition progress screen).

**Out of scope (later slices, per strategy roadmap):**
- Push/proactive notifications (Phase 2 "proactivity").
- Wearable/HRV/sleep recovery inputs.
- Camera form coach, adaptive auto-planning.

**YAGNI:** no new charts, no settings, no multi-window comparison.

## 3. Existing code this builds on

- `services/gemini_service.dart` — `GeminiService` using `firebase_ai` (`FirebaseAI.googleAI()`, `gemini-2.5-flash-preview-05-20`), prompt builder + robust markdown-stripping JSON parse. **Pattern to mirror.**
- `models/CompletedWorkout.dart` — `CompletedWorkout` (startTime, endTime, durationSeconds, intensityScore, exercises→sets with `weight`/`reps` as **strings**, e.g. `"Bodyweight"`).
- `services/database_helper.dart` — sqflite store. `getAllCompletedWorkouts()` / `getCompletedWorkouts()` → `List<CompletedWorkout>`; `food_logs` table with `getFoodLogsByDate(userId, date)` → `List<Map>` (food_name, calories, protein, carbs, fat, serving_size, meal_type, consumed_at) and `insertFoodLog(...)`. **Both inputs are local** ⇒ aggregation is fully offline.
- `providers/nutrition_provider.dart` — Riverpod `StateNotifier` reading food logs from `DatabaseHelper.getFoodLogsByDate`. Note: it currently passes a placeholder `userId = "current_user"`; our provider must use the **real authenticated userId** from `auth_provider`.
- State management: **Riverpod** (`flutter_riverpod` + `StateNotifier`/`AsyncNotifier`).

**Note:** v1 reads the 14-day window from sqflite. We will add `DatabaseHelper.getFoodLogsInRange(userId, start, end)` (or loop `getFoodLogsByDate` over the window) — a small, additive local query, no schema change.

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

**`coach_data_source.dart`** — `WorkoutSource` (`getRecentCompletedWorkouts(window)`) and `FoodLogSource` (`getMacrosByDay(userId, window)`). Both concrete adapters wrap `DatabaseHelper` (workouts via `getAllCompletedWorkouts`, macros via the new local range query). Interfaces keep the provider unit-testable with fakes.

**`coachInsightsProvider`** (`AsyncNotifier<List<CoachInsight>>`)
- Load workouts (local) + macros (per-day loop), aggregate, call service, write result + timestamp to a `coach_insights_cache` sqflite table.
- On AI/network error → fall back to cached insights if present, else error state.
- `refresh()` for pull-to-refresh.

**`CoachInsightCard`** — Riverpod `ConsumerWidget`; states: loading (shimmer/spinner), empty ("Log a few more workouts and meals to unlock Smart Coach"), error (retry), data (top insight + count, tap → bottom sheet/detail with all insights). Severity drives accent color; category drives icon.

### 4.2 Data flow

```
Home → coachInsightsProvider
  → WorkoutSource.getRecentCompletedWorkouts(14d)   [local sqflite]
  → FoodLogSource.getMacrosByDay(userId, 14d)        [local sqflite]
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
| Offline (AI unreachable) | Serve cached insights; card shows "offline — last updated <time>". Data load itself is local and always succeeds. |

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
5. Data-source interfaces + adapters; add `DatabaseHelper.getFoodLogsInRange` (local range query).
6. `coachInsightsProvider` (real auth userId) + sqflite insight cache.
7. `CoachInsightCard` + Home wiring.
8. Manual run/verify on Home.

## 8. Open questions resolved
- Food-log source: **local sqflite** (`DatabaseHelper`, `food_logs` table); add a local range query for the window.
- Workout source: local sqflite (`DatabaseHelper.getAllCompletedWorkouts`).
- userId: real authenticated id from `auth_provider` (not the `"current_user"` placeholder seen in `nutrition_provider`).
- State mgmt: Riverpod (matches repo).
- AI: `firebase_ai` Gemini (matches `GeminiService`).
