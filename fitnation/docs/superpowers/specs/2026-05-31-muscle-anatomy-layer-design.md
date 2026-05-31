# Muscle Anatomy Layer — Design (Phase 1 + 2)

**Date:** 2026-05-31
**Status:** Approved for planning
**Branch:** messaging (anatomy work will branch from here)

## Goal

Add a detailed, head-level muscle anatomy layer to Athlytiq that showcases **how
each exercise hits specific muscle heads** (e.g. *Skull Crushers → Triceps Long
Head*), using an interactive human-body diagram. This is the "showcase how
exercises hit" feature requested by the user, seeded from a curated training
reference (`MuscleAnatomy.md`) but authored from established training knowledge.

## Scope

This spec covers **Phase 1 (data foundation)** and **Phase 2 (two read-only
UIs)**, shipped together because the foundation is inert without something
rendering it.

**In scope**
- Curated muscle-head anatomy data asset + models + repository.
- Resolver linking curated exercises ↔ the real bundled catalog, with a reverse
  index (catalog exercise → muscle head(s)).
- **Anatomy Explorer** screen: synced bidirectional navigation between an
  interactive body diagram and a muscle-group/head list.
- **Exercise-detail enrichment**: a "Muscles worked" section in the existing
  exercise detail sheet, with a small highlighted body diagram + head chips.

**Out of scope (deferred to later specs)**
- **Phase 3** — feeding head-coverage into `WorkoutRecommendationService` so
  generated workouts balance all heads of a muscle.
- **Phase 4** — surfacing curated splits (PPL / 4-day) as start-able templates.
- **Backfill task** — online-sourcing head mappings for the ~1,420 catalog
  exercises not in the curated set. Tracked as a follow-up; until done, those
  exercises gracefully degrade to coarse muscle tags.

## Two realities shaping the design

1. **Head-level detail is curated, not universal.** The authored anatomy maps a
   focused set (~80–120) of high-value compound/isolation lifts to specific
   heads. The bundled catalog (1,500 exercises) only has coarse tags
   (`targetMuscles`, `bodyParts`). Exercises outside the curated set degrade
   gracefully to their coarse tags.
2. **`flutter_body_atlas` supports individual heads.** Its `Muscle` enum exposes
   ~206 stable IDs including per-head variants (biceps `caput_longum` /
   `caput_brevis`, the three triceps heads, three deltoid heads, trapezius
   upper/middle/lower, left/right `_l`/`_r`). This makes true per-head
   highlighting possible off-the-shelf — no custom SVG art required.

## Architecture

### Layer 1 — Data foundation

**Asset: `assets/data/muscle_anatomy.json`** (authored, declared in
`pubspec.yaml`). Structure:

```json
{
  "muscle_groups": [
    {
      "id": "triceps",
      "name": "Triceps",
      "atlas_group_ids": ["triceps_brachii_..."],
      "sub_regions": [
        {
          "id": "triceps_long_head",
          "name": "Long Head",
          "notes": "Emphasised with the arm overhead / behind the body.",
          "atlas_muscle_ids": ["triceps_brachii_caput_longum_l",
                               "triceps_brachii_caput_longum_r"],
          "exercise_names": ["Skull Crushers", "Overhead Cable Extension"]
        }
      ]
    }
  ]
}
```

- `atlas_muscle_ids` are **verified** against the package's `MuscleCatalog` at
  implementation time. No guessed IDs ship — a test enforces this (see Testing).
- `exercise_names` are human-readable; they are resolved to catalog entries at
  runtime, not hard-linked to fragile catalog IDs.

**Models** (`lib/models/anatomy/`): plain Dart with `fromJson`:
- `MuscleAnatomy` (root — holds `List<MuscleGroup>`)
- `MuscleGroup` (`id`, `name`, `atlasGroupIds`, `subRegions`)
- `SubRegion` (`id`, `name`, `notes`, `atlasMuscleIds`, `exerciseNames`)

**`AnatomyRepository`** (`lib/services/anatomy/anatomy_repository.dart`):
- Loads + caches `muscle_anatomy.json`.
- Takes an injected asset-loader function so tests run without Flutter asset I/O.
- Exposes `Future<MuscleAnatomy> load()`, cached after first call.

**`ExerciseAnatomyResolver`** (`lib/services/anatomy/exercise_anatomy_resolver.dart`):
- **Forward** (Explorer): `SubRegion.exerciseNames` → real catalog `Exercise`
  via the existing `ExerciseCatalog` interface (`searchByName`), reusing the
  pattern in `lib/services/coach/exercise_resolver.dart`.
- **Reverse** (detail enrichment): builds an index `catalog exercise (id/name
  lower) → List<SubRegion>`. For an arbitrary `Exercise`, returns its curated
  sub-regions, or — when absent — a fallback derived from coarse
  `targetMuscles` / `secondaryMuscles` mapped to atlas group IDs.
- Depends only on `AnatomyRepository` + `ExerciseCatalog` (both injectable).

### Layer 2 — UI

**Anatomy Explorer** (`lib/Screens/Anatomy/AnatomyExplorerScreen.dart`):
- Hero: `flutter_body_atlas` `BodyAtlasView` with a front/back toggle.
- **Synced bidirectional** (user-chosen): one `StateNotifier`
  (`anatomyExplorerProvider`) owns `selectedSubRegion` (+ derived selected
  group). Both inputs write the same state:
  - Tap a muscle on the body → `onTapElement` resolves the atlas ID → owning
    sub-region → updates state → list scrolls/expands to it.
  - Pick a group/head from the list → updates state → `colorMapping` highlights
    the sub-region's `atlasMuscleIds`.
- Below the diagram: muscle-group list → expand to sub-regions (heads) → curated
  exercises (resolved). Tapping an exercise opens the existing detail sheet.

**Exercise-detail enrichment** (existing sheet at
`lib/pages/exercise_search_page.dart` `_showExerciseDetails`, ~line 306):
- New **"Muscles worked"** section: a compact `BodyAtlasView` highlighting the
  exercise's resolved head(s) + chips ("Triceps — Long Head").
- Graceful degradation: no curated mapping → highlight coarse
  `targetMuscles`/`secondaryMuscles` at group level, chips show muscle names.
- Section is self-contained (`ExerciseMusclesSection` widget) so it can be reused
  if a dedicated exercise-detail screen is built later.

### Data flow

```
muscle_anatomy.json ──load──> AnatomyRepository ──> MuscleAnatomy (cached)
                                     │
        ┌────────────────────────────┴────────────────────────┐
        ▼                                                       ▼
ExerciseAnatomyResolver (forward)                ExerciseAnatomyResolver (reverse)
   exerciseNames → catalog Exercise                catalog Exercise → SubRegion(s)
        │                                                       │
        ▼                                                       ▼
AnatomyExplorerScreen (list + BodyAtlasView)     ExerciseMusclesSection (detail sheet)
        ▲           ▲                                           │
        └─ synced ──┘ (anatomyExplorerProvider)                ▼
                                                     highlighted BodyAtlasView + chips
```

## Error handling & edge cases

- **Missing/corrupt asset** — repository surfaces a clear error; Explorer shows
  an error state with retry; detail enrichment silently falls back to coarse
  tags (never blocks the sheet).
- **Unresolvable curated exercise name** — omitted from the Explorer list for
  that sub-region; logged in debug. Does not crash the screen.
- **Atlas ID not found at runtime** — skipped in `colorMapping` (defensive);
  the validity test prevents this from shipping.
- **Exercise with no curated mapping** — reverse resolver returns coarse-tag
  fallback; chips/diagram still render.

## Testing

Pure-Dart, mock-backed where possible (mirrors existing `test/services/coach/`):
- `AnatomyRepository` — parse + cache via injected loader (no asset I/O).
- `ExerciseAnatomyResolver` — forward resolution, reverse lookup, coarse
  fallback, unresolvable name handling (mock `ExerciseCatalog`).
- **Atlas-ID validity** — every `atlas_muscle_ids` value in
  `muscle_anatomy.json` exists in `flutter_body_atlas`'s `MuscleCatalog`. Guards
  against typos and asset/package drift.
- Widget smoke tests: Explorer selection sync (tap ↔ list) and the detail
  enrichment section renders for both curated and fallback exercises.

## New dependency

- `flutter_body_atlas: ^0.1.4`

## File inventory

New:
- `assets/data/muscle_anatomy.json`
- `lib/models/anatomy/muscle_anatomy.dart` (+ `muscle_group.dart`, `sub_region.dart` or single file)
- `lib/services/anatomy/anatomy_repository.dart`
- `lib/services/anatomy/exercise_anatomy_resolver.dart`
- `lib/providers/anatomy_provider.dart` (repository + resolver + explorer state)
- `lib/Screens/Anatomy/AnatomyExplorerScreen.dart`
- `lib/widgets/anatomy/exercise_muscles_section.dart`
- `test/services/anatomy/anatomy_repository_test.dart`
- `test/services/anatomy/exercise_anatomy_resolver_test.dart`
- `test/data/muscle_anatomy_atlas_ids_test.dart`

Modified:
- `pubspec.yaml` (asset + dependency)
- `lib/pages/exercise_search_page.dart` (insert enrichment section)
- entry point to launch Explorer (nav/menu — decided in plan)

## Phasing recap

1. **Phase 1+2 (this spec)** — data foundation + Explorer + detail enrichment.
2. **Phase 3 (later)** — AI head-coverage in workout generation.
3. **Phase 4 (later)** — curated splits as start-able templates.
4. **Backfill (later)** — head mappings for the remaining ~1,420 exercises.
