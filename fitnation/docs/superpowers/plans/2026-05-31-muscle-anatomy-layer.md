# Muscle Anatomy Layer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

> **⚠️ EXECUTION RECONCILIATION (2026-05-31, completed).** This plan was drafted before
> the real `flutter_body_atlas` 0.1.4 catalog source was read. Several muscle IDs in the
> "Verified IDs" section and in Tasks 6/7 below were **wrong** and were corrected during
> execution. What actually shipped (authoritative — see `lib/services/anatomy/coarse_muscle_map.dart`
> and `assets/data/muscle_anatomy.json`, both guarded by passing tests):
> - Deltoids are `anterior_deltoid` / `lateral_deltoid` / `posterior_deltoid` (NOT `deltoid_anterior`).
> - Chest is a single `pectoralis_major_l/r` — there is **no** clavicular/sternal split. Upper/mid/lower
>   chest sub-regions all map to `pectoralis_major`.
> - Traps are `trapezius_upper/middle/lower` (NOT `descendens/transversa/ascendens`).
> - No `brachialis`, `rhomboid_major`, `erector_spinae`, `soleus`, `gastrocnemius_medialis/lateralis`,
>   or `tensor_fasciae_latae` exist. Calves use `gastrocnemius_l/r`; forearm uses
>   `extensor_carpi_radialis_longus` (not `..._radialis`). Brachialis sub-region maps to `brachioradialis`.
> - Abs: `rectus_abdominis_1` (no side) + `_2/_3/_4_l/r`. Glutes/hamstrings carry numbered ids
>   (`gluteus_medius_1_l`, `semimembranosus_1_l`).
> - The coarse map stores **full atlas ids directly** (`kCoarseMuscleToAtlasIds`); the planned
>   `kCoarseMuscleToAtlasBaseIds` + `expandedCoarseMap()` step was dropped as unnecessary.
> - `BodyAtlasView.colorMapping` is nullable (`Map<I, Color?>?`); diagram tests read `colorMapping!`.
> - Task 1 (pubspec asset line) was a no-op: `pubspec.yaml` already globs `assets/data/`.
>
> All 14 tasks are implemented and committed; 18 anatomy tests + 47 total project tests pass.
> The code is the source of truth where it diverges from the task bodies below.

**Goal:** Add a curated head-level muscle anatomy layer with an interactive body-diagram Explorer and exercise-detail enrichment, showing how each exercise targets specific muscle heads.

**Architecture:** A bundled `muscle_anatomy.json` asset (head → atlas-id + exercise-name mapping) is loaded by `AnatomyRepository` and indexed by `ExerciseAnatomyResolver` (forward: curated names → catalog `Exercise`; reverse: catalog `Exercise` → muscle heads, with coarse-tag fallback). Riverpod providers expose these to two UIs: the synced bidirectional `AnatomyExplorerScreen` and an `ExerciseMusclesSection` injected into the existing exercise-detail bottom sheet. Per-head highlighting uses `flutter_body_atlas`'s `BodyAtlasView`.

**Tech Stack:** Flutter 3.44 / Dart 3.12, Riverpod (StateNotifier), `flutter_body_atlas: ^0.1.4`, sqflite (existing catalog), `flutter_test`.

---

## Verified `flutter_body_atlas` 0.1.4 API (do not guess — these are read from source)

```dart 
// Public exports (package:flutter_body_atlas/flutter_body_atlas.dart):
enum AtlasAsset { musclesFront, musclesBack }
enum MuscleGroup { chest, back, shoulders, arms, core, legs, neck, other }

abstract interface class AtlasElementInfo { String get id; }
abstract interface class AtlasResolver<I extends AtlasElementInfo> { I? resolve(String svgId); }

class MuscleInfo implements AtlasElementInfo {
  final String id;            // stable SVG id, e.g. 'biceps_brachii_caput_longum_l'
  final MuscleGroup group;
  final String displayName;   // e.g. 'Biceps Brachii (Long Head)'
  const MuscleInfo({required this.id, required this.group, required this.displayName});
}

class MuscleCatalog {
  static const Map<String, MuscleInfo> byId;     // all known muscles
  static MuscleInfo? resolve(String svgId);
  static const MuscleResolver resolver;
}
class MuscleResolver implements AtlasResolver<MuscleInfo> { const MuscleResolver(); }

class BodyAtlasView<I extends AtlasElementInfo> extends StatefulWidget {
  const BodyAtlasView({
    required AtlasAsset view,
    required AtlasResolver<I> resolver,
    Map<I, Color?> colorMapping = const {},     // highlight: MuscleInfo -> Color
    void Function(I info)? onTapElement,
    void Function(I? info)? onHoverOverElement,
    I? hoveredOver,
    Color Function(Color base)? hoverColor,
    Color? defaultColor,
    Color? strokeColor,
  });
}
```

### The 104 verified muscle IDs (52 muscles × `_l`/`_r`)

Use ONLY these base names (append `_l` and `_r`). This is the complete catalog:

```
neck:      sternocleidomastoid, platysma, sternohyoid
shoulders: deltoid_anterior, deltoid_lateral, deltoid_posterior
chest:     pectoralis_major_clavicular, pectoralis_major_sternal
arms:      biceps_brachii_caput_longum, biceps_brachii_caput_breve, brachialis,
           triceps_brachii_caput_longum, triceps_brachii_caput_laterale, triceps_brachii_caput_mediale,
           brachioradialis, pronator_teres, flexor_carpi_radialis,
           extensor_carpi_radialis, extensor_carpi_ulnaris
core:      rectus_abdominis_upper, rectus_abdominis_lower, external_oblique, serratus_anterior
back:      latissimus_dorsi, trapezius_descendens, trapezius_transversa, trapezius_ascendens,
           infraspinatus, teres_major, rhomboid_major, erector_spinae
legs:      gluteus_maximus, gluteus_medius, rectus_femoris, vastus_lateralis, vastus_medialis,
           biceps_femoris, semitendinosus, semimembranosus, adductor_longus, adductor_magnus,
           gracilis, pectineus, sartorius, tensor_fasciae_latae, gastrocnemius_medialis,
           gastrocnemius_lateralis, soleus, tibialis_anterior, fibularis_longus,
           extensor_digitorum_longus, extensor_hallucis_longus, iliotibial_tract
```

**Package constraints baked into the data:**
- Chest has NO "lower" region: upper chest → `pectoralis_major_clavicular`; mid AND lower chest → `pectoralis_major_sternal`.
- Traps: upper → `trapezius_descendens`, mid → `trapezius_transversa`, lower → `trapezius_ascendens`.

---

## File Structure

**New files:**
- `assets/data/muscle_anatomy.json` — curated head → atlas-id + exercise-name data.
- `lib/models/anatomy/muscle_anatomy.dart` — `MuscleAnatomy`, `AnatomyMuscleGroup`, `SubRegion` models (single file).
- `lib/services/anatomy/anatomy_repository.dart` — loads + caches the asset.
- `lib/services/anatomy/exercise_anatomy_resolver.dart` — forward + reverse + fallback resolution.
- `lib/providers/anatomy_provider.dart` — repository, resolver, and explorer-state providers.
- `lib/widgets/anatomy/anatomy_body_diagram.dart` — thin wrapper over `BodyAtlasView` (highlight by atlas-id set).
- `lib/widgets/anatomy/exercise_muscles_section.dart` — "Muscles worked" section for the detail sheet.
- `lib/Screens/Anatomy/AnatomyExplorerScreen.dart` — synced explorer screen.
- `test/services/anatomy/anatomy_repository_test.dart`
- `test/services/anatomy/exercise_anatomy_resolver_test.dart`
- `test/data/muscle_anatomy_atlas_ids_test.dart` — validity guard.
- `test/widgets/anatomy/anatomy_explorer_test.dart` — selection-sync smoke test.

**Modified files:**
- `pubspec.yaml` — already has `flutter_body_atlas: 0.1.4`; add the asset path.
- `lib/pages/exercise_search_page.dart` — insert `ExerciseMusclesSection` into `_showExerciseDetails` (~line 386, after the muscle detail rows).
- A nav entry point to launch the Explorer (decided in Task 9).

**Naming note (consistency across tasks):** the model class for a muscle group is `AnatomyMuscleGroup` (NOT `MuscleGroup` — that name is taken by the package enum). Always import the package as `import 'package:flutter_body_atlas/flutter_body_atlas.dart';` and our models unprefixed.

---

## Task 1: Add the asset declaration to pubspec

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add the asset path under the existing `assets:` list**

Find the `flutter:` → `assets:` section (it already lists `assets/data/exercises.json` etc.) and add:

```yaml
    - assets/data/muscle_anatomy.json
```

- [ ] **Step 2: Create a minimal placeholder asset so pub get succeeds**

Create `assets/data/muscle_anatomy.json` with valid empty structure (real content lands in Task 7):

```json
{ "muscle_groups": [] }
```

- [ ] **Step 3: Run pub get**

Run: `flutter pub get`
Expected: `Got dependencies!` with no asset errors.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml assets/data/muscle_anatomy.json
git commit -m "chore: declare muscle_anatomy.json asset"
```

---

## Task 2: Anatomy models

**Files:**
- Create: `lib/models/anatomy/muscle_anatomy.dart`
- Test: `test/models/anatomy/muscle_anatomy_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';

void main() {
  const json = {
    'muscle_groups': [
      {
        'id': 'triceps',
        'name': 'Triceps',
        'atlas_group_ids': ['triceps_brachii_caput_longum_l'],
        'sub_regions': [
          {
            'id': 'triceps_long_head',
            'name': 'Long Head',
            'notes': 'Overhead emphasis.',
            'atlas_muscle_ids': [
              'triceps_brachii_caput_longum_l',
              'triceps_brachii_caput_longum_r'
            ],
            'exercise_names': ['Skull Crushers', 'Overhead Cable Extension']
          }
        ]
      }
    ]
  };

  test('parses nested muscle anatomy from json', () {
    final anatomy = MuscleAnatomy.fromJson(json);
    expect(anatomy.groups.length, 1);
    final g = anatomy.groups.first;
    expect(g.id, 'triceps');
    expect(g.name, 'Triceps');
    expect(g.atlasGroupIds, ['triceps_brachii_caput_longum_l']);
    expect(g.subRegions.length, 1);
    final s = g.subRegions.first;
    expect(s.id, 'triceps_long_head');
    expect(s.name, 'Long Head');
    expect(s.notes, 'Overhead emphasis.');
    expect(s.atlasMuscleIds.length, 2);
    expect(s.exerciseNames, contains('Skull Crushers'));
  });

  test('handles missing optional fields with safe defaults', () {
    final anatomy = MuscleAnatomy.fromJson({
      'muscle_groups': [
        {'id': 'x', 'name': 'X', 'sub_regions': []}
      ]
    });
    final g = anatomy.groups.first;
    expect(g.atlasGroupIds, isEmpty);
    expect(g.subRegions, isEmpty);
  });

  test('empty root parses to empty groups', () {
    final anatomy = MuscleAnatomy.fromJson({'muscle_groups': []});
    expect(anatomy.groups, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/models/anatomy/muscle_anatomy_test.dart`
Expected: FAIL — `muscle_anatomy.dart` does not exist.

- [ ] **Step 3: Write minimal implementation**

```dart
class MuscleAnatomy {
  final List<AnatomyMuscleGroup> groups;
  const MuscleAnatomy(this.groups);

  factory MuscleAnatomy.fromJson(Map<String, dynamic> json) {
    final raw = (json['muscle_groups'] as List<dynamic>? ?? const []);
    return MuscleAnatomy(
      raw
          .whereType<Map<String, dynamic>>()
          .map(AnatomyMuscleGroup.fromJson)
          .toList(),
    );
  }
}

class AnatomyMuscleGroup {
  final String id;
  final String name;
  final List<String> atlasGroupIds;
  final List<SubRegion> subRegions;

  const AnatomyMuscleGroup({
    required this.id,
    required this.name,
    required this.atlasGroupIds,
    required this.subRegions,
  });

  factory AnatomyMuscleGroup.fromJson(Map<String, dynamic> json) {
    return AnatomyMuscleGroup(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      atlasGroupIds: _stringList(json['atlas_group_ids']),
      subRegions: (json['sub_regions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SubRegion.fromJson)
          .toList(),
    );
  }
}

class SubRegion {
  final String id;
  final String name;
  final String notes;
  final List<String> atlasMuscleIds;
  final List<String> exerciseNames;

  const SubRegion({
    required this.id,
    required this.name,
    required this.notes,
    required this.atlasMuscleIds,
    required this.exerciseNames,
  });

  factory SubRegion.fromJson(Map<String, dynamic> json) {
    return SubRegion(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      atlasMuscleIds: _stringList(json['atlas_muscle_ids']),
      exerciseNames: _stringList(json['exercise_names']),
    );
  }
}

List<String> _stringList(dynamic v) =>
    (v as List<dynamic>? ?? const []).map((e) => e.toString()).toList();
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/models/anatomy/muscle_anatomy_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/models/anatomy/muscle_anatomy.dart test/models/anatomy/muscle_anatomy_test.dart
git commit -m "feat: add muscle anatomy models"
```

---

## Task 3: AnatomyRepository (load + cache)

**Files:**
- Create: `lib/services/anatomy/anatomy_repository.dart`
- Test: `test/services/anatomy/anatomy_repository_test.dart`

The repository takes an injected async asset-loader `Future<String> Function(String key)` so tests avoid Flutter asset I/O. The production default uses `rootBundle.loadString`.

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/services/anatomy/anatomy_repository.dart';

void main() {
  const sample = '''
  {"muscle_groups":[
    {"id":"biceps","name":"Biceps","atlas_group_ids":[],
     "sub_regions":[
       {"id":"long","name":"Long Head","notes":"",
        "atlas_muscle_ids":["biceps_brachii_caput_longum_l"],
        "exercise_names":["Incline Dumbbell Curl"]}
     ]}
  ]}''';

  test('loads and parses anatomy from injected loader', () async {
    final repo = AnatomyRepository(loadAsset: (_) async => sample);
    final anatomy = await repo.load();
    expect(anatomy.groups.single.id, 'biceps');
    expect(anatomy.groups.single.subRegions.single.id, 'long');
  });

  test('caches result — loader called once across multiple loads', () async {
    var calls = 0;
    final repo = AnatomyRepository(loadAsset: (_) async {
      calls++;
      return sample;
    });
    await repo.load();
    await repo.load();
    expect(calls, 1);
  });

  test('throws a clear error on invalid json', () async {
    final repo = AnatomyRepository(loadAsset: (_) async => 'not json');
    expect(repo.load(), throwsA(isA<FormatException>()));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/anatomy/anatomy_repository_test.dart`
Expected: FAIL — `anatomy_repository.dart` does not exist.

- [ ] **Step 3: Write minimal implementation**

```dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';

typedef AssetLoader = Future<String> Function(String key);

class AnatomyRepository {
  static const assetKey = 'assets/data/muscle_anatomy.json';

  final AssetLoader _loadAsset;
  MuscleAnatomy? _cache;

  AnatomyRepository({AssetLoader? loadAsset})
      : _loadAsset = loadAsset ?? rootBundle.loadString;

  Future<MuscleAnatomy> load() async {
    if (_cache != null) return _cache!;
    final raw = await _loadAsset(assetKey);
    final decoded = json.decode(raw); // throws FormatException on bad json
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('muscle_anatomy.json root is not an object');
    }
    return _cache = MuscleAnatomy.fromJson(decoded);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/anatomy/anatomy_repository_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/services/anatomy/anatomy_repository.dart test/services/anatomy/anatomy_repository_test.dart
git commit -m "feat: add AnatomyRepository with injected asset loader"
```

---

## Task 4: ExerciseAnatomyResolver — reverse lookup (catalog exercise → heads)

**Files:**
- Create: `lib/services/anatomy/exercise_anatomy_resolver.dart`
- Test: `test/services/anatomy/exercise_anatomy_resolver_test.dart`

Reuses the existing `ExerciseCatalog` interface from `lib/services/coach/exercise_resolver.dart`. This task implements the reverse direction (used by detail enrichment) plus the coarse fallback. Forward direction is Task 5.

Result types:

```dart
class MuscleHit {
  final String groupId;       // e.g. 'triceps'
  final String groupName;     // 'Triceps'
  final String subRegionId;   // 'triceps_long_head'  (empty for coarse fallback)
  final String subRegionName; // 'Long Head'          (or coarse muscle name)
  final List<String> atlasMuscleIds;
  final bool isCurated;       // true = head-level; false = coarse-tag fallback
}

class ExerciseMuscleResult {
  final List<MuscleHit> hits;
  bool get isEmpty => hits.isEmpty;
}
```

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/models/Exercise.dart' as ex_db;
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';
import 'package:fitnation/services/anatomy/exercise_anatomy_resolver.dart';

final _anatomy = MuscleAnatomy([
  AnatomyMuscleGroup(
    id: 'triceps',
    name: 'Triceps',
    atlasGroupIds: const [],
    subRegions: const [
      SubRegion(
        id: 'triceps_long_head',
        name: 'Long Head',
        notes: '',
        atlasMuscleIds: ['triceps_brachii_caput_longum_l', 'triceps_brachii_caput_longum_r'],
        exerciseNames: ['Skull Crushers'],
      ),
    ],
  ),
]);

// Maps a coarse target-muscle token to atlas ids for fallback.
const _coarseMap = {
  'pectorals': ['pectoralis_major_sternal_l', 'pectoralis_major_sternal_r'],
};

ex_db.Exercise _ex(String name, {List<String> targets = const []}) => ex_db.Exercise(
      exerciseId: name,
      name: name,
      bodyParts: const [],
      equipments: const [],
      targetMuscles: targets,
      secondaryMuscles: const [],
      instructions: const [],
    );

void main() {
  late ExerciseAnatomyResolver resolver;
  setUp(() => resolver = ExerciseAnatomyResolver(anatomy: _anatomy, coarseMuscleToAtlasIds: _coarseMap));

  test('reverse: curated exercise resolves to its head (case-insensitive)', () {
    final result = resolver.musclesForExercise(_ex('skull crushers'));
    expect(result.hits.length, 1);
    final hit = result.hits.first;
    expect(hit.subRegionId, 'triceps_long_head');
    expect(hit.isCurated, isTrue);
    expect(hit.atlasMuscleIds, contains('triceps_brachii_caput_longum_l'));
  });

  test('reverse: uncurated exercise falls back to coarse target muscles', () {
    final result = resolver.musclesForExercise(_ex('Machine Chest Press', targets: ['pectorals']));
    expect(result.hits.length, 1);
    final hit = result.hits.first;
    expect(hit.isCurated, isFalse);
    expect(hit.subRegionName.toLowerCase(), 'pectorals');
    expect(hit.atlasMuscleIds, contains('pectoralis_major_sternal_l'));
  });

  test('reverse: unknown exercise with unmapped target returns empty', () {
    final result = resolver.musclesForExercise(_ex('Mystery Move', targets: ['unknownus maximus']));
    expect(result.isEmpty, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/anatomy/exercise_anatomy_resolver_test.dart`
Expected: FAIL — `exercise_anatomy_resolver.dart` does not exist.

- [ ] **Step 3: Write minimal implementation**

```dart
import 'package:fitnation/models/Exercise.dart' as ex_db;
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';
import 'package:fitnation/services/coach/exercise_resolver.dart';

class MuscleHit {
  final String groupId;
  final String groupName;
  final String subRegionId;
  final String subRegionName;
  final List<String> atlasMuscleIds;
  final bool isCurated;
  const MuscleHit({
    required this.groupId,
    required this.groupName,
    required this.subRegionId,
    required this.subRegionName,
    required this.atlasMuscleIds,
    required this.isCurated,
  });
}

class ExerciseMuscleResult {
  final List<MuscleHit> hits;
  const ExerciseMuscleResult(this.hits);
  bool get isEmpty => hits.isEmpty;
}

class ExerciseAnatomyResolver {
  final MuscleAnatomy anatomy;
  final Map<String, List<String>> coarseMuscleToAtlasIds;

  // Reverse index: lowercase exercise name -> (group, subRegion).
  final Map<String, _Owner> _byExerciseName = {};

  ExerciseAnatomyResolver({
    required this.anatomy,
    this.coarseMuscleToAtlasIds = const {},
  }) {
    for (final g in anatomy.groups) {
      for (final s in g.subRegions) {
        for (final name in s.exerciseNames) {
          _byExerciseName[name.toLowerCase().trim()] = _Owner(g, s);
        }
      }
    }
  }

  /// Reverse: which muscle head(s) does this catalog exercise hit?
  ExerciseMuscleResult musclesForExercise(ex_db.Exercise exercise) {
    final owner = _byExerciseName[exercise.name.toLowerCase().trim()];
    if (owner != null) {
      return ExerciseMuscleResult([
        MuscleHit(
          groupId: owner.group.id,
          groupName: owner.group.name,
          subRegionId: owner.sub.id,
          subRegionName: owner.sub.name,
          atlasMuscleIds: owner.sub.atlasMuscleIds,
          isCurated: true,
        ),
      ]);
    }
    // Coarse fallback from the exercise's target muscles.
    final hits = <MuscleHit>[];
    for (final m in exercise.targetMuscles) {
      final ids = coarseMuscleToAtlasIds[m.toLowerCase().trim()];
      if (ids != null && ids.isNotEmpty) {
        hits.add(MuscleHit(
          groupId: '',
          groupName: '',
          subRegionId: '',
          subRegionName: m,
          atlasMuscleIds: ids,
          isCurated: false,
        ));
      }
    }
    return ExerciseMuscleResult(hits);
  }
}

class _Owner {
  final AnatomyMuscleGroup group;
  final SubRegion sub;
  const _Owner(this.group, this.sub);
}
```

(Note: `ExerciseCatalog` import is added in Task 5 when the forward method needs it. Leaving it out now keeps this task's analyzer clean — do NOT import unused.)

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/anatomy/exercise_anatomy_resolver_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/services/anatomy/exercise_anatomy_resolver.dart test/services/anatomy/exercise_anatomy_resolver_test.dart
git commit -m "feat: add ExerciseAnatomyResolver reverse lookup + coarse fallback"
```

---

## Task 5: ExerciseAnatomyResolver — forward resolution (head → catalog exercises)

**Files:**
- Modify: `lib/services/anatomy/exercise_anatomy_resolver.dart`
- Modify: `test/services/anatomy/exercise_anatomy_resolver_test.dart`

Forward direction for the Explorer: given a `SubRegion`, resolve its `exerciseNames` to real catalog `Exercise` objects via the injected `ExerciseCatalog` (async). Reuse the `FakeCatalog` shape from `test/services/coach/exercise_resolver_test.dart`.

- [ ] **Step 1: Add the failing test (append to existing test file)**

Add this `FakeCatalog` (copy of the coach one) and test group at the bottom of `test/services/anatomy/exercise_anatomy_resolver_test.dart`, and add the import `import 'package:fitnation/services/coach/exercise_resolver.dart';` at the top:

```dart
class _FakeCatalog implements ExerciseCatalog {
  final List<ex_db.Exercise> _items;
  _FakeCatalog(this._items);
  @override
  Future<ex_db.Exercise?> getById(String id) async =>
      _items.where((e) => e.exerciseId == id).cast<ex_db.Exercise?>().firstWhere((_) => true, orElse: () => null);
  @override
  Future<List<ex_db.Exercise>> searchByName(String name, {String? bodyPart, String? equipment, int limit = 5}) async {
    final q = name.toLowerCase();
    return _items.where((e) => e.name.toLowerCase().contains(q)).take(limit).toList();
  }
  @override
  Future<List<ex_db.Exercise>> getByBodyPart(String bodyPart, {int limit = 5}) async => const [];
  @override
  Future<List<String>> getUniqueBodyParts() async => const [];
  @override
  Future<List<String>> getUniqueEquipments() async => const [];
}

// inside main():
  group('forward resolution', () {
    test('resolves a sub-region exercise names to catalog exercises', () async {
      final catalog = _FakeCatalog([_ex('Skull Crushers', targets: ['triceps'])]);
      final sub = _anatomy.groups.first.subRegions.first;
      final exercises = await resolver.exercisesForSubRegion(sub, catalog);
      expect(exercises.length, 1);
      expect(exercises.first.name, 'Skull Crushers');
    });

    test('skips names with no catalog match', () async {
      final catalog = _FakeCatalog(const []);
      final sub = _anatomy.groups.first.subRegions.first;
      final exercises = await resolver.exercisesForSubRegion(sub, catalog);
      expect(exercises, isEmpty);
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/anatomy/exercise_anatomy_resolver_test.dart`
Expected: FAIL — `exercisesForSubRegion` not defined.

- [ ] **Step 3: Add the method to `ExerciseAnatomyResolver`**

Add the import at the top of `exercise_anatomy_resolver.dart` (it is now used):

```dart
import 'package:fitnation/services/coach/exercise_resolver.dart';
```

Add this method inside the class:

```dart
  /// Forward: resolve a sub-region's curated exercise names to catalog entries.
  Future<List<ex_db.Exercise>> exercisesForSubRegion(
    SubRegion sub,
    ExerciseCatalog catalog,
  ) async {
    final out = <ex_db.Exercise>[];
    for (final name in sub.exerciseNames) {
      final matches = await catalog.searchByName(name, limit: 1);
      if (matches.isNotEmpty) out.add(matches.first);
    }
    return out;
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/anatomy/exercise_anatomy_resolver_test.dart`
Expected: PASS (5 tests total).

- [ ] **Step 5: Commit**

```bash
git add lib/services/anatomy/exercise_anatomy_resolver.dart test/services/anatomy/exercise_anatomy_resolver_test.dart
git commit -m "feat: add forward sub-region -> catalog exercise resolution"
```

---

## Task 6: Coarse muscle → atlas-id map (shared constant)

**Files:**
- Create: `lib/services/anatomy/coarse_muscle_map.dart`
- Test: `test/services/anatomy/coarse_muscle_map_test.dart`

The catalog's coarse `targetMuscles` use tokens like `pectorals`, `biceps`, `quads`, `lats`. Map each to atlas group ids for fallback highlighting. Keys are lowercase; values are base ids WITHOUT `_l`/`_r` — the diagram widget (Task 8) expands to both sides.

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';
import 'package:fitnation/services/anatomy/coarse_muscle_map.dart';

void main() {
  test('every mapped atlas base id (with _l) exists in the package catalog', () {
    for (final entry in kCoarseMuscleToAtlasBaseIds.entries) {
      for (final base in entry.value) {
        expect(
          MuscleCatalog.byId.containsKey('${base}_l'),
          isTrue,
          reason: 'coarse "${entry.key}" -> "$base" has no _l in MuscleCatalog',
        );
      }
    }
  });

  test('covers common catalog target tokens', () {
    for (final token in ['pectorals', 'biceps', 'triceps', 'quads', 'lats', 'glutes', 'hamstrings', 'abs', 'delts', 'calves']) {
      expect(kCoarseMuscleToAtlasBaseIds.containsKey(token), isTrue, reason: 'missing token: $token');
    }
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/anatomy/coarse_muscle_map_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Write the map**

```dart
/// Maps coarse catalog target-muscle tokens (lowercase) to atlas BASE ids
/// (append `_l` / `_r` to use). Used for fallback highlighting when an
/// exercise has no curated head-level mapping.
const Map<String, List<String>> kCoarseMuscleToAtlasBaseIds = {
  'pectorals': ['pectoralis_major_clavicular', 'pectoralis_major_sternal'],
  'chest': ['pectoralis_major_clavicular', 'pectoralis_major_sternal'],
  'biceps': ['biceps_brachii_caput_longum', 'biceps_brachii_caput_breve', 'brachialis'],
  'triceps': [
    'triceps_brachii_caput_longum',
    'triceps_brachii_caput_laterale',
    'triceps_brachii_caput_mediale',
  ],
  'delts': ['deltoid_anterior', 'deltoid_lateral', 'deltoid_posterior'],
  'deltoids': ['deltoid_anterior', 'deltoid_lateral', 'deltoid_posterior'],
  'shoulders': ['deltoid_anterior', 'deltoid_lateral', 'deltoid_posterior'],
  'lats': ['latissimus_dorsi'],
  'upper back': ['trapezius_descendens', 'trapezius_transversa', 'rhomboid_major'],
  'traps': ['trapezius_descendens', 'trapezius_transversa', 'trapezius_ascendens'],
  'spine': ['erector_spinae'],
  'abs': ['rectus_abdominis_upper', 'rectus_abdominis_lower'],
  'abductors': ['gluteus_medius'],
  'adductors': ['adductor_longus', 'adductor_magnus', 'gracilis', 'pectineus'],
  'quads': ['rectus_femoris', 'vastus_lateralis', 'vastus_medialis'],
  'hamstrings': ['biceps_femoris', 'semitendinosus', 'semimembranosus'],
  'glutes': ['gluteus_maximus', 'gluteus_medius'],
  'calves': ['gastrocnemius_medialis', 'gastrocnemius_lateralis', 'soleus'],
  'forearms': ['brachioradialis', 'flexor_carpi_radialis', 'extensor_carpi_radialis'],
};
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/anatomy/coarse_muscle_map_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/services/anatomy/coarse_muscle_map.dart test/services/anatomy/coarse_muscle_map_test.dart
git commit -m "feat: add coarse muscle -> atlas id map with catalog validity test"
```

---

## Task 7: Author the real muscle_anatomy.json + validity guard test

**Files:**
- Modify: `assets/data/muscle_anatomy.json`
- Create: `test/data/muscle_anatomy_atlas_ids_test.dart`

Write the curated content for these 8 groups: Shoulders, Chest, Back, Biceps, Triceps, Legs, Abs, Forearms. Every `atlas_muscle_ids` entry MUST be a real id from the package catalog (base name + `_l`/`_r`). Use the verified ID list at the top of this plan. Exercise names should be common catalog names (e.g. "Incline Dumbbell Curl", "Lateral Raise", "Romanian Deadlift").

- [ ] **Step 1: Write the validity guard test FIRST (red)**

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';

void main() {
  test('every atlas_muscle_id in muscle_anatomy.json exists in MuscleCatalog', () {
    final file = File('assets/data/muscle_anatomy.json');
    final data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    final groups = data['muscle_groups'] as List<dynamic>;
    expect(groups, isNotEmpty, reason: 'anatomy json should not be empty');

    final unknown = <String>[];
    for (final g in groups.cast<Map<String, dynamic>>()) {
      for (final s in (g['sub_regions'] as List).cast<Map<String, dynamic>>()) {
        for (final id in (s['atlas_muscle_ids'] as List).cast<String>()) {
          if (!MuscleCatalog.byId.containsKey(id)) unknown.add(id);
        }
      }
    }
    expect(unknown, isEmpty, reason: 'unknown atlas ids: $unknown');
  });

  test('every group has at least one sub-region with exercises', () {
    final file = File('assets/data/muscle_anatomy.json');
    final data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    for (final g in (data['muscle_groups'] as List).cast<Map<String, dynamic>>()) {
      final subs = (g['sub_regions'] as List).cast<Map<String, dynamic>>();
      expect(subs, isNotEmpty, reason: '${g['id']} has no sub-regions');
      final hasExercises = subs.any((s) => (s['exercise_names'] as List).isNotEmpty);
      expect(hasExercises, isTrue, reason: '${g['id']} has no exercises');
    }
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/muscle_anatomy_atlas_ids_test.dart`
Expected: FAIL — current json has empty `muscle_groups`.

- [ ] **Step 3: Author the full asset**

Replace `assets/data/muscle_anatomy.json` with the curated 8-group dataset. Below is the complete content to write (IDs verified against the catalog; chest lower→sternal and traps split applied):

```json
{
  "muscle_groups": [
    {
      "id": "shoulders", "name": "Shoulders",
      "atlas_group_ids": ["deltoid_anterior_l","deltoid_lateral_l","deltoid_posterior_l"],
      "sub_regions": [
        {"id":"front_delt","name":"Front Delt","notes":"Pressing overhead emphasises the anterior head.",
         "atlas_muscle_ids":["deltoid_anterior_l","deltoid_anterior_r"],
         "exercise_names":["Dumbbell Shoulder Press","Barbell Shoulder Press","Machine Shoulder Press"]},
        {"id":"side_delt","name":"Side Delt","notes":"Abduction (raising arm to the side) targets the lateral head.",
         "atlas_muscle_ids":["deltoid_lateral_l","deltoid_lateral_r"],
         "exercise_names":["Dumbbell Lateral Raise","Cable Lateral Raise"]},
        {"id":"rear_delt","name":"Rear Delt","notes":"Horizontal abduction targets the posterior head.",
         "atlas_muscle_ids":["deltoid_posterior_l","deltoid_posterior_r"],
         "exercise_names":["Reverse Cable Fly","Reverse Pec Deck Fly","Face Pull"]}
      ]
    },
    {
      "id": "chest", "name": "Chest",
      "atlas_group_ids": ["pectoralis_major_clavicular_l","pectoralis_major_sternal_l"],
      "sub_regions": [
        {"id":"upper_chest","name":"Upper Chest","notes":"Incline angles bias the clavicular head.",
         "atlas_muscle_ids":["pectoralis_major_clavicular_l","pectoralis_major_clavicular_r"],
         "exercise_names":["Incline Barbell Bench Press","Incline Dumbbell Press","Smith Machine Incline Press"]},
        {"id":"mid_chest","name":"Mid Chest","notes":"Flat pressing and flyes hit the sternal head.",
         "atlas_muscle_ids":["pectoralis_major_sternal_l","pectoralis_major_sternal_r"],
         "exercise_names":["Barbell Bench Press","Dumbbell Bench Press","Machine Chest Press","Cable Fly"]},
        {"id":"lower_chest","name":"Lower Chest","notes":"Decline and dips emphasise the lower sternal fibres.",
         "atlas_muscle_ids":["pectoralis_major_sternal_l","pectoralis_major_sternal_r"],
         "exercise_names":["Decline Bench Press","High to Low Cable Fly","Chest Dip"]}
      ]
    },
    {
      "id": "back", "name": "Back",
      "atlas_group_ids": ["latissimus_dorsi_l","trapezius_descendens_l","erector_spinae_l"],
      "sub_regions": [
        {"id":"lats","name":"Lats","notes":"Vertical pulls develop width.",
         "atlas_muscle_ids":["latissimus_dorsi_l","latissimus_dorsi_r"],
         "exercise_names":["Lat Pulldown","Pull Up","Single Arm Lat Pulldown"]},
        {"id":"mid_back","name":"Mid Back","notes":"Horizontal rows build thickness.",
         "atlas_muscle_ids":["rhomboid_major_l","rhomboid_major_r","trapezius_transversa_l","trapezius_transversa_r"],
         "exercise_names":["T-Bar Row","Chest Supported Dumbbell Row","Seated Cable Row"]},
        {"id":"traps","name":"Traps","notes":"Shrugs target the upper traps.",
         "atlas_muscle_ids":["trapezius_descendens_l","trapezius_descendens_r"],
         "exercise_names":["Barbell Shrug","Dumbbell Shrug"]},
        {"id":"lower_back","name":"Lower Back","notes":"Spinal extension trains the erectors.",
         "atlas_muscle_ids":["erector_spinae_l","erector_spinae_r"],
         "exercise_names":["Back Extension","Romanian Deadlift"]}
      ]
    },
    {
      "id": "biceps", "name": "Biceps",
      "atlas_group_ids": ["biceps_brachii_caput_longum_l","biceps_brachii_caput_breve_l","brachialis_l"],
      "sub_regions": [
        {"id":"long_head","name":"Long Head","notes":"Arm behind the body stretches the long (outer) head.",
         "atlas_muscle_ids":["biceps_brachii_caput_longum_l","biceps_brachii_caput_longum_r"],
         "exercise_names":["Incline Dumbbell Curl","Cable Curl"]},
        {"id":"short_head","name":"Short Head","notes":"Supinated curls with elbow forward bias the short (inner) head.",
         "atlas_muscle_ids":["biceps_brachii_caput_breve_l","biceps_brachii_caput_breve_r"],
         "exercise_names":["Preacher Curl","Barbell Curl","Concentration Curl"]},
        {"id":"brachialis","name":"Brachialis","notes":"Neutral/pronated grip targets the brachialis under the biceps.",
         "atlas_muscle_ids":["brachialis_l","brachialis_r"],
         "exercise_names":["Hammer Curl","Reverse Barbell Curl"]}
      ]
    },
    {
      "id": "triceps", "name": "Triceps",
      "atlas_group_ids": ["triceps_brachii_caput_longum_l","triceps_brachii_caput_laterale_l","triceps_brachii_caput_mediale_l"],
      "sub_regions": [
        {"id":"long_head","name":"Long Head","notes":"Overhead positions stretch the long head.",
         "atlas_muscle_ids":["triceps_brachii_caput_longum_l","triceps_brachii_caput_longum_r"],
         "exercise_names":["Overhead Cable Extension","Skull Crusher"]},
        {"id":"lateral_head","name":"Lateral Head","notes":"Pushdowns with arms at the side bias the lateral head.",
         "atlas_muscle_ids":["triceps_brachii_caput_laterale_l","triceps_brachii_caput_laterale_r"],
         "exercise_names":["Triceps Pushdown","Rope Pushdown"]},
        {"id":"medial_head","name":"Medial Head","notes":"Reverse-grip pushdowns recruit the medial head.",
         "atlas_muscle_ids":["triceps_brachii_caput_mediale_l","triceps_brachii_caput_mediale_r"],
         "exercise_names":["Reverse Grip Triceps Pushdown","Close Grip Bench Press"]}
      ]
    },
    {
      "id": "legs", "name": "Legs",
      "atlas_group_ids": ["rectus_femoris_l","biceps_femoris_l","gluteus_maximus_l","gastrocnemius_medialis_l"],
      "sub_regions": [
        {"id":"quads","name":"Quads","notes":"Knee extension under load.",
         "atlas_muscle_ids":["rectus_femoris_l","rectus_femoris_r","vastus_lateralis_l","vastus_lateralis_r","vastus_medialis_l","vastus_medialis_r"],
         "exercise_names":["Barbell Squat","Leg Press","Leg Extension"]},
        {"id":"hamstrings","name":"Hamstrings","notes":"Hip hinge and knee flexion.",
         "atlas_muscle_ids":["biceps_femoris_l","biceps_femoris_r","semitendinosus_l","semitendinosus_r","semimembranosus_l","semimembranosus_r"],
         "exercise_names":["Romanian Deadlift","Lying Leg Curl","Seated Leg Curl"]},
        {"id":"glutes","name":"Glutes","notes":"Hip extension.",
         "atlas_muscle_ids":["gluteus_maximus_l","gluteus_maximus_r","gluteus_medius_l","gluteus_medius_r"],
         "exercise_names":["Hip Thrust","Bulgarian Split Squat"]},
        {"id":"adductors","name":"Adductors","notes":"Bringing the thigh toward the midline.",
         "atlas_muscle_ids":["adductor_longus_l","adductor_longus_r","adductor_magnus_l","adductor_magnus_r"],
         "exercise_names":["Hip Adduction Machine","Sumo Squat"]},
        {"id":"calves","name":"Calves","notes":"Plantar flexion of the ankle.",
         "atlas_muscle_ids":["gastrocnemius_medialis_l","gastrocnemius_medialis_r","gastrocnemius_lateralis_l","gastrocnemius_lateralis_r","soleus_l","soleus_r"],
         "exercise_names":["Standing Calf Raise","Seated Calf Raise"]}
      ]
    },
    {
      "id": "abs", "name": "Abs",
      "atlas_group_ids": ["rectus_abdominis_upper_l","rectus_abdominis_lower_l","external_oblique_l"],
      "sub_regions": [
        {"id":"upper_abs","name":"Upper Abs","notes":"Trunk flexion (bringing ribs to pelvis).",
         "atlas_muscle_ids":["rectus_abdominis_upper_l","rectus_abdominis_upper_r"],
         "exercise_names":["Cable Crunch","Decline Crunch"]},
        {"id":"lower_abs","name":"Lower Abs","notes":"Posterior pelvic tilt / leg raises.",
         "atlas_muscle_ids":["rectus_abdominis_lower_l","rectus_abdominis_lower_r"],
         "exercise_names":["Hanging Leg Raise","Lying Leg Raise"]},
        {"id":"obliques","name":"Obliques","notes":"Rotation and lateral flexion.",
         "atlas_muscle_ids":["external_oblique_l","external_oblique_r"],
         "exercise_names":["Cable Woodchop","Russian Twist"]}
      ]
    },
    {
      "id": "forearms", "name": "Forearms",
      "atlas_group_ids": ["brachioradialis_l","flexor_carpi_radialis_l","extensor_carpi_radialis_l"],
      "sub_regions": [
        {"id":"brachioradialis","name":"Brachioradialis","notes":"Reverse / neutral grip curls.",
         "atlas_muscle_ids":["brachioradialis_l","brachioradialis_r"],
         "exercise_names":["Reverse Barbell Curl","Hammer Curl"]},
        {"id":"wrist_flexors","name":"Wrist Flexors","notes":"Supinated wrist curls.",
         "atlas_muscle_ids":["flexor_carpi_radialis_l","flexor_carpi_radialis_r"],
         "exercise_names":["Dumbbell Wrist Curl"]},
        {"id":"wrist_extensors","name":"Wrist Extensors","notes":"Pronated reverse wrist curls.",
         "atlas_muscle_ids":["extensor_carpi_radialis_l","extensor_carpi_radialis_r","extensor_carpi_ulnaris_l","extensor_carpi_ulnaris_r"],
         "exercise_names":["Reverse Wrist Curl"]}
      ]
    }
  ]
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/muscle_anatomy_atlas_ids_test.dart`
Expected: PASS (2 tests). If any id is reported unknown, fix it against the verified list at the top of this plan.

- [ ] **Step 5: Commit**

```bash
git add assets/data/muscle_anatomy.json test/data/muscle_anatomy_atlas_ids_test.dart
git commit -m "feat: author curated muscle_anatomy.json (8 groups) with validity guard"
```

---

## Task 8: AnatomyBodyDiagram widget (highlight by atlas-id set)

**Files:**
- Create: `lib/widgets/anatomy/anatomy_body_diagram.dart`
- Test: `test/widgets/anatomy/anatomy_body_diagram_test.dart`

A thin, reusable wrapper over `BodyAtlasView`. Inputs: a set of atlas ids to highlight, a highlight color, the view (front/back), and an optional `onTapMuscleId` callback. It builds the `colorMapping` by resolving each id through `MuscleCatalog` and rendering only known ones.

- [ ] **Step 1: Write the failing widget test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';
import 'package:fitnation/widgets/anatomy/anatomy_body_diagram.dart';

void main() {
  testWidgets('builds colorMapping from highlighted ids and renders BodyAtlasView', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AnatomyBodyDiagram(
          view: AtlasAsset.musclesFront,
          highlightedIds: const {'biceps_brachii_caput_longum_l'},
          highlightColor: Colors.red,
        ),
      ),
    ));
    expect(find.byType(BodyAtlasView<MuscleInfo>), findsOneWidget);
    final widget = tester.widget<BodyAtlasView<MuscleInfo>>(find.byType(BodyAtlasView<MuscleInfo>));
    final ids = widget.colorMapping.keys.map((m) => m.id).toSet();
    expect(ids, contains('biceps_brachii_caput_longum_l'));
  });

  testWidgets('ignores unknown atlas ids without crashing', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AnatomyBodyDiagram(
          view: AtlasAsset.musclesFront,
          highlightedIds: const {'totally_fake_id'},
          highlightColor: Colors.red,
        ),
      ),
    ));
    final widget = tester.widget<BodyAtlasView<MuscleInfo>>(find.byType(BodyAtlasView<MuscleInfo>));
    expect(widget.colorMapping, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/anatomy/anatomy_body_diagram_test.dart`
Expected: FAIL — widget does not exist.

- [ ] **Step 3: Write the widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';

/// Reusable body diagram that highlights a set of atlas muscle ids.
class AnatomyBodyDiagram extends StatelessWidget {
  final AtlasAsset view;
  final Set<String> highlightedIds;
  final Color highlightColor;
  final void Function(String atlasId)? onTapMuscleId;

  const AnatomyBodyDiagram({
    super.key,
    required this.view,
    required this.highlightedIds,
    required this.highlightColor,
    this.onTapMuscleId,
  });

  @override
  Widget build(BuildContext context) {
    final mapping = <MuscleInfo, Color?>{};
    for (final id in highlightedIds) {
      final info = MuscleCatalog.byId[id];
      if (info != null) mapping[info] = highlightColor;
    }
    return BodyAtlasView<MuscleInfo>(
      view: view,
      resolver: const MuscleResolver(),
      colorMapping: mapping,
      onTapElement: onTapMuscleId == null ? null : (m) => onTapMuscleId!(m.id),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/anatomy/anatomy_body_diagram_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/anatomy/anatomy_body_diagram.dart test/widgets/anatomy/anatomy_body_diagram_test.dart
git commit -m "feat: add AnatomyBodyDiagram highlight wrapper"
```

---

## Task 9: Anatomy providers

**Files:**
- Create: `lib/providers/anatomy_provider.dart`
- Test: `test/providers/anatomy_provider_test.dart`

Providers:
- `anatomyRepositoryProvider` → `AnatomyRepository()` (production loader).
- `anatomyProvider` → `FutureProvider<MuscleAnatomy>` calling `repo.load()`.
- `exerciseAnatomyResolverProvider` → `FutureProvider<ExerciseAnatomyResolver>` building from loaded anatomy + `kCoarseMuscleToAtlasBaseIds` expanded to `_l`/`_r`.
- `AnatomyExplorerState` + `anatomyExplorerProvider` (`StateNotifierProvider`) holding `selectedGroupId` and `selectedSubRegionId`, with `selectGroup`, `selectSubRegion`, and `selectByAtlasId` (reverse: atlas id → owning sub-region).

The coarse map values are base ids; expand to `_l`/`_r` here so the resolver gets full ids.

- [ ] **Step 1: Write the failing test (state notifier logic only — no Flutter assets)**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';
import 'package:fitnation/providers/anatomy_provider.dart';

final _anatomy = MuscleAnatomy([
  AnatomyMuscleGroup(
    id: 'biceps', name: 'Biceps', atlasGroupIds: const [],
    subRegions: const [
      SubRegion(id: 'long_head', name: 'Long Head', notes: '',
        atlasMuscleIds: ['biceps_brachii_caput_longum_l', 'biceps_brachii_caput_longum_r'],
        exerciseNames: ['Incline Dumbbell Curl']),
      SubRegion(id: 'short_head', name: 'Short Head', notes: '',
        atlasMuscleIds: ['biceps_brachii_caput_breve_l'], exerciseNames: ['Preacher Curl']),
    ],
  ),
]);

void main() {
  test('selectByAtlasId selects the owning group and sub-region', () {
    final notifier = AnatomyExplorerNotifier(_anatomy);
    notifier.selectByAtlasId('biceps_brachii_caput_longum_r');
    expect(notifier.state.selectedGroupId, 'biceps');
    expect(notifier.state.selectedSubRegionId, 'long_head');
  });

  test('selectSubRegion updates both ids', () {
    final notifier = AnatomyExplorerNotifier(_anatomy);
    notifier.selectSubRegion('biceps', 'short_head');
    expect(notifier.state.selectedGroupId, 'biceps');
    expect(notifier.state.selectedSubRegionId, 'short_head');
  });

  test('highlightedIds reflects the selected sub-region', () {
    final notifier = AnatomyExplorerNotifier(_anatomy);
    notifier.selectSubRegion('biceps', 'long_head');
    expect(notifier.highlightedIds, containsAll(['biceps_brachii_caput_longum_l', 'biceps_brachii_caput_longum_r']));
  });

  test('unknown atlas id leaves state unchanged', () {
    final notifier = AnatomyExplorerNotifier(_anatomy);
    notifier.selectSubRegion('biceps', 'long_head');
    notifier.selectByAtlasId('not_a_real_id');
    expect(notifier.state.selectedSubRegionId, 'long_head');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/anatomy_provider_test.dart`
Expected: FAIL — `anatomy_provider.dart` does not exist.

- [ ] **Step 3: Write the providers + notifier**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';
import 'package:fitnation/services/anatomy/anatomy_repository.dart';
import 'package:fitnation/services/anatomy/coarse_muscle_map.dart';
import 'package:fitnation/services/anatomy/exercise_anatomy_resolver.dart';

final anatomyRepositoryProvider = Provider<AnatomyRepository>((ref) => AnatomyRepository());

final anatomyProvider = FutureProvider<MuscleAnatomy>((ref) {
  return ref.watch(anatomyRepositoryProvider).load();
});

/// Coarse map with base ids expanded to _l/_r full atlas ids.
Map<String, List<String>> expandedCoarseMap() {
  return {
    for (final e in kCoarseMuscleToAtlasBaseIds.entries)
      e.key: [for (final base in e.value) ...['${base}_l', '${base}_r']],
  };
}

final exerciseAnatomyResolverProvider = FutureProvider<ExerciseAnatomyResolver>((ref) async {
  final anatomy = await ref.watch(anatomyProvider.future);
  return ExerciseAnatomyResolver(
    anatomy: anatomy,
    coarseMuscleToAtlasIds: expandedCoarseMap(),
  );
});

class AnatomyExplorerState {
  final String? selectedGroupId;
  final String? selectedSubRegionId;
  const AnatomyExplorerState({this.selectedGroupId, this.selectedSubRegionId});

  AnatomyExplorerState copyWith({String? selectedGroupId, String? selectedSubRegionId}) =>
      AnatomyExplorerState(
        selectedGroupId: selectedGroupId ?? this.selectedGroupId,
        selectedSubRegionId: selectedSubRegionId ?? this.selectedSubRegionId,
      );
}

class AnatomyExplorerNotifier extends StateNotifier<AnatomyExplorerState> {
  final MuscleAnatomy anatomy;
  AnatomyExplorerNotifier(this.anatomy) : super(const AnatomyExplorerState());

  void selectGroup(String groupId) {
    final g = _group(groupId);
    state = AnatomyExplorerState(
      selectedGroupId: groupId,
      selectedSubRegionId: g?.subRegions.isNotEmpty == true ? g!.subRegions.first.id : null,
    );
  }

  void selectSubRegion(String groupId, String subRegionId) {
    state = AnatomyExplorerState(selectedGroupId: groupId, selectedSubRegionId: subRegionId);
  }

  /// Reverse: find the group+sub-region that owns an atlas id.
  void selectByAtlasId(String atlasId) {
    for (final g in anatomy.groups) {
      for (final s in g.subRegions) {
        if (s.atlasMuscleIds.contains(atlasId)) {
          state = AnatomyExplorerState(selectedGroupId: g.id, selectedSubRegionId: s.id);
          return;
        }
      }
    }
    // unknown id: no change
  }

  Set<String> get highlightedIds {
    final g = _group(state.selectedGroupId);
    final s = g?.subRegions.where((s) => s.id == state.selectedSubRegionId).cast<SubRegion?>().firstWhere((_) => true, orElse: () => null);
    return s?.atlasMuscleIds.toSet() ?? <String>{};
  }

  AnatomyMuscleGroup? _group(String? id) {
    if (id == null) return null;
    for (final g in anatomy.groups) {
      if (g.id == id) return g;
    }
    return null;
  }
}

final anatomyExplorerProvider =
    StateNotifierProvider.family<AnatomyExplorerNotifier, AnatomyExplorerState, MuscleAnatomy>(
  (ref, anatomy) => AnatomyExplorerNotifier(anatomy),
);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/providers/anatomy_provider_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/providers/anatomy_provider.dart test/providers/anatomy_provider_test.dart
git commit -m "feat: add anatomy providers + explorer state notifier"
```

---

## Task 10: ExerciseMusclesSection (detail-sheet enrichment)

**Files:**
- Create: `lib/widgets/anatomy/exercise_muscles_section.dart`
- Test: `test/widgets/anatomy/exercise_muscles_section_test.dart`

A `ConsumerWidget` taking an `Exercise`. It watches `exerciseAnatomyResolverProvider`, computes `musclesForExercise`, and renders a "Muscles worked" header + `AnatomyBodyDiagram` (front) highlighting all hit atlas ids + chips per hit (curated chips show "Group — Head"; fallback chips show the coarse muscle name). When the resolver is loading, show a small spinner; when there are no hits, render `SizedBox.shrink()` (never block the sheet).

- [ ] **Step 1: Write the failing widget test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/models/Exercise.dart' as ex_db;
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';
import 'package:fitnation/providers/anatomy_provider.dart';
import 'package:fitnation/services/anatomy/exercise_anatomy_resolver.dart';
import 'package:fitnation/widgets/anatomy/exercise_muscles_section.dart';

final _anatomy = MuscleAnatomy([
  AnatomyMuscleGroup(id: 'triceps', name: 'Triceps', atlasGroupIds: const [], subRegions: const [
    SubRegion(id: 'long_head', name: 'Long Head', notes: '',
      atlasMuscleIds: ['triceps_brachii_caput_longum_l', 'triceps_brachii_caput_longum_r'],
      exerciseNames: ['Skull Crusher']),
  ]),
]);

ex_db.Exercise _ex(String name) => ex_db.Exercise(
  exerciseId: name, name: name, bodyParts: const [], equipments: const [],
  targetMuscles: const [], secondaryMuscles: const [], instructions: const []);

void main() {
  testWidgets('renders Muscles worked section with head chip for curated exercise', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        exerciseAnatomyResolverProvider.overrideWith(
          (ref) async => ExerciseAnatomyResolver(anatomy: _anatomy),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: ExerciseMusclesSection(exercise: _ex('Skull Crusher')))),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Muscles worked'), findsOneWidget);
    expect(find.textContaining('Long Head'), findsOneWidget);
  });

  testWidgets('renders nothing for exercise with no hits', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        exerciseAnatomyResolverProvider.overrideWith(
          (ref) async => ExerciseAnatomyResolver(anatomy: _anatomy),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: ExerciseMusclesSection(exercise: _ex('Unknown Move')))),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Muscles worked'), findsNothing);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/anatomy/exercise_muscles_section_test.dart`
Expected: FAIL — widget does not exist.

- [ ] **Step 3: Write the widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/models/Exercise.dart' as ex_db;
import 'package:fitnation/providers/anatomy_provider.dart';
import 'package:fitnation/widgets/anatomy/anatomy_body_diagram.dart';

class ExerciseMusclesSection extends ConsumerWidget {
  final ex_db.Exercise exercise;
  const ExerciseMusclesSection({super.key, required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(exerciseAnatomyResolverProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (resolver) {
        final result = resolver.musclesForExercise(exercise);
        if (result.isEmpty) return const SizedBox.shrink();

        final ids = <String>{for (final h in result.hits) ...h.atlasMuscleIds};
        final cs = Theme.of(context).colorScheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Muscles worked',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: AnatomyBodyDiagram(
                view: AtlasAsset.musclesFront,
                highlightedIds: ids,
                highlightColor: cs.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final h in result.hits)
                  Chip(
                    label: Text(
                      h.isCurated ? '${h.groupName} — ${h.subRegionName}' : h.subRegionName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/anatomy/exercise_muscles_section_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/anatomy/exercise_muscles_section.dart test/widgets/anatomy/exercise_muscles_section_test.dart
git commit -m "feat: add ExerciseMusclesSection detail enrichment widget"
```

---

## Task 11: Wire enrichment into the exercise detail sheet

**Files:**
- Modify: `lib/pages/exercise_search_page.dart`

The detail sheet is built in `_showExerciseDetails` (~line 306). The muscle detail rows end around line 391 (after the Secondary Muscles `_buildDetailRow`). Insert the section there. NOTE: the page is a `ConsumerStatefulWidget`, so `ProviderScope` already exists up the tree — `ExerciseMusclesSection` (a `ConsumerWidget`) works directly.

- [ ] **Step 1: Add the import**

At the top of `lib/pages/exercise_search_page.dart`, add:

```dart
import '../widgets/anatomy/exercise_muscles_section.dart';
```

- [ ] **Step 2: Insert the section after the Secondary Muscles row**

Find this block (around line 387-391):

```dart
                        if (exercise.secondaryMuscles.isNotEmpty)
                          _buildDetailRow(
                            'Secondary Muscles',
                            exercise.secondaryMuscles,
                          ),
```

Immediately after it (before the `if (exercise.instructions.isNotEmpty)` block), add:

```dart
                        ExerciseMusclesSection(exercise: exercise),
```

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/pages/exercise_search_page.dart`
Expected: No errors (warnings about pre-existing code are acceptable).

- [ ] **Step 4: Commit**

```bash
git add lib/pages/exercise_search_page.dart
git commit -m "feat: show Muscles worked section in exercise detail sheet"
```

---

## Task 12: AnatomyExplorerScreen (synced bidirectional)

**Files:**
- Create: `lib/Screens/Anatomy/AnatomyExplorerScreen.dart`
- Test: `test/widgets/anatomy/anatomy_explorer_test.dart`

Layout: front/back toggle + `AnatomyBodyDiagram` on top (tap → `selectByAtlasId`), a horizontally scrollable group selector, an expandable sub-region (head) list for the selected group, and the resolved exercise list for the selected sub-region. Selecting from the list updates the same notifier, so the diagram re-highlights — synced both ways.

The screen watches `anatomyProvider` (FutureProvider) for the data, then reads `anatomyExplorerProvider(anatomy)` for selection state and `exerciseAnatomyResolverProvider` for forward exercise resolution.

- [ ] **Step 1: Write the failing smoke test (selection sync)**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';
import 'package:fitnation/providers/anatomy_provider.dart';
import 'package:fitnation/services/anatomy/exercise_anatomy_resolver.dart';
import 'package:fitnation/Screens/Anatomy/AnatomyExplorerScreen.dart';

final _anatomy = MuscleAnatomy([
  AnatomyMuscleGroup(id: 'biceps', name: 'Biceps', atlasGroupIds: const [], subRegions: const [
    SubRegion(id: 'long_head', name: 'Long Head', notes: '', atlasMuscleIds: ['biceps_brachii_caput_longum_l'], exerciseNames: ['Incline Dumbbell Curl']),
    SubRegion(id: 'short_head', name: 'Short Head', notes: '', atlasMuscleIds: ['biceps_brachii_caput_breve_l'], exerciseNames: ['Preacher Curl']),
  ]),
]);

void main() {
  testWidgets('renders groups and sub-regions; tapping a head selects it', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        anatomyProvider.overrideWith((ref) async => _anatomy),
        exerciseAnatomyResolverProvider.overrideWith((ref) async => ExerciseAnatomyResolver(anatomy: _anatomy)),
      ],
      child: const MaterialApp(home: AnatomyExplorerScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Biceps'), findsWidgets);
    expect(find.text('Long Head'), findsOneWidget);
    expect(find.text('Short Head'), findsOneWidget);

    await tester.tap(find.text('Short Head'));
    await tester.pumpAndSettle();
    // selecting Short Head shows its curated exercise
    expect(find.text('Preacher Curl'), findsWidgets);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/anatomy/anatomy_explorer_test.dart`
Expected: FAIL — screen does not exist.

- [ ] **Step 3: Write the screen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/models/Exercise.dart' as ex_db;
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';
import 'package:fitnation/providers/anatomy_provider.dart';
import 'package:fitnation/widgets/anatomy/anatomy_body_diagram.dart';

class AnatomyExplorerScreen extends ConsumerStatefulWidget {
  const AnatomyExplorerScreen({super.key});
  @override
  ConsumerState<AnatomyExplorerScreen> createState() => _AnatomyExplorerScreenState();
}

class _AnatomyExplorerScreenState extends ConsumerState<AnatomyExplorerScreen> {
  AtlasAsset _view = AtlasAsset.musclesFront;

  @override
  Widget build(BuildContext context) {
    final anatomyAsync = ref.watch(anatomyProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muscle Anatomy'),
        actions: [
          IconButton(
            tooltip: _view == AtlasAsset.musclesFront ? 'Show back' : 'Show front',
            icon: const Icon(Icons.flip),
            onPressed: () => setState(() => _view =
                _view == AtlasAsset.musclesFront ? AtlasAsset.musclesBack : AtlasAsset.musclesFront),
          ),
        ],
      ),
      body: anatomyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load anatomy: $e')),
        data: (anatomy) => _Body(anatomy: anatomy, view: _view),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final MuscleAnatomy anatomy;
  final AtlasAsset view;
  const _Body({required this.anatomy, required this.view});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(anatomyExplorerProvider(anatomy));
    final notifier = ref.read(anatomyExplorerProvider(anatomy).notifier);
    final cs = Theme.of(context).colorScheme;

    final selectedGroup = anatomy.groups
        .where((g) => g.id == state.selectedGroupId)
        .cast<AnatomyMuscleGroup?>()
        .firstWhere((_) => true, orElse: () => null);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 280,
            child: AnatomyBodyDiagram(
              view: view,
              highlightedIds: notifier.highlightedIds,
              highlightColor: cs.primary,
              onTapMuscleId: notifier.selectByAtlasId,
            ),
          ),
          const SizedBox(height: 12),
          // Group selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final g in anatomy.groups)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(g.name),
                      selected: g.id == state.selectedGroupId,
                      onSelected: (_) => notifier.selectGroup(g.id),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (selectedGroup != null) ...[
            Text(selectedGroup.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final sub in selectedGroup.subRegions)
              _SubRegionTile(
                groupId: selectedGroup.id,
                sub: sub,
                selected: sub.id == state.selectedSubRegionId,
                onTap: () => notifier.selectSubRegion(selectedGroup.id, sub.id),
              ),
          ] else
            const Text('Tap a muscle or pick a group to explore.'),
        ],
      ),
    );
  }
}

class _SubRegionTile extends ConsumerWidget {
  final String groupId;
  final SubRegion sub;
  final bool selected;
  final VoidCallback onTap;
  const _SubRegionTile({required this.groupId, required this.sub, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: selected ? cs.primaryContainer : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: sub.notes.isEmpty ? null : Text(sub.notes),
            onTap: onTap,
            selected: selected,
          ),
          if (selected) _ExerciseList(sub: sub),
        ],
      ),
    );
  }
}

class _ExerciseList extends ConsumerWidget {
  final SubRegion sub;
  const _ExerciseList({required this.sub});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolverAsync = ref.watch(exerciseAnatomyResolverProvider);
    return resolverAsync.when(
      loading: () => const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (resolver) => FutureBuilder<List<ex_db.Exercise>>(
        future: resolver.exercisesForSubRegion(sub, _catalog(ref)),
        builder: (context, snap) {
          final exercises = snap.data ?? const <ex_db.Exercise>[];
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator());
          }
          // Fall back to raw curated names if catalog resolution found nothing.
          final names = exercises.isNotEmpty ? exercises.map((e) => e.name).toList() : sub.exerciseNames;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final n in names)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      const Icon(Icons.fitness_center, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(n)),
                    ]),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

Add this helper at the bottom of the file (the catalog used for forward resolution):

```dart
import 'package:fitnation/services/coach/exercise_resolver.dart';
import 'package:fitnation/services/coach/local_exercise_catalog.dart';

ExerciseCatalog _catalog(WidgetRef ref) => LocalExerciseCatalog();
```

(Place the two imports at the top with the others; `_catalog` near the bottom.)

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/anatomy/anatomy_explorer_test.dart`
Expected: PASS. The test overrides the resolver with an anatomy-only `ExerciseAnatomyResolver` whose `exercisesForSubRegion` returns empty (FakeCatalog not provided), so the screen falls back to `sub.exerciseNames` → "Preacher Curl" renders.

- [ ] **Step 5: Commit**

```bash
git add lib/Screens/Anatomy/AnatomyExplorerScreen.dart test/widgets/anatomy/anatomy_explorer_test.dart
git commit -m "feat: add synced bidirectional Anatomy Explorer screen"
```

---

## Task 13: Add a nav entry point to the Explorer

**Files:**
- Modify: one navigation surface (determine which by reading the file first)

The app's primary nav is `lib/Screens/NavPages.dart` and there's a `lib/Screens/HomeScreen.dart`. Add an entry that pushes `AnatomyExplorerScreen`. Pick the least invasive working surface — a tile/button on `HomeScreen` is preferred over restructuring the bottom nav.

- [ ] **Step 1: Read the chosen nav file**

Run (read, don't guess): open `lib/Screens/HomeScreen.dart` and locate a list/grid of feature entry points (cards/tiles). Identify the widget pattern used for an existing tile.

- [ ] **Step 2: Add the import**

```dart
import 'package:fitnation/Screens/Anatomy/AnatomyExplorerScreen.dart';
```

- [ ] **Step 3: Add a tile/button matching the existing pattern**

Add an entry following the SAME widget pattern already used in that file (do not invent a new style). Its `onTap`/`onPressed` must be:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const AnatomyExplorerScreen()),
);
```

Label it "Muscle Anatomy" with an anatomy-appropriate icon (e.g. `Icons.accessibility_new`).

- [ ] **Step 4: Verify it compiles**

Run: `flutter analyze lib/Screens/HomeScreen.dart`
Expected: No new errors.

- [ ] **Step 5: Commit**

```bash
git add lib/Screens/HomeScreen.dart
git commit -m "feat: add Muscle Anatomy entry point to home"
```

---

## Task 14: Full test sweep + analyzer + final commit

**Files:** none (verification)

- [ ] **Step 1: Run the full anatomy test suite**

Run: `flutter test test/models/anatomy test/services/anatomy test/providers/anatomy_provider_test.dart test/widgets/anatomy test/data/muscle_anatomy_atlas_ids_test.dart`
Expected: ALL PASS.

- [ ] **Step 2: Run the whole project test suite (catch regressions)**

Run: `flutter test`
Expected: All previously-passing tests still pass (the coach suite + new anatomy suite).

- [ ] **Step 3: Analyze the new/modified files**

Run: `flutter analyze lib/models/anatomy lib/services/anatomy lib/providers/anatomy_provider.dart lib/widgets/anatomy lib/Screens/Anatomy lib/pages/exercise_search_page.dart`
Expected: No errors. Fix any analyzer errors before finishing.

- [ ] **Step 4: Final commit (only if Step 3 required fixes)**

```bash
git add -A
git commit -m "chore: anatomy layer analyzer cleanup"
```

---

## Self-Review Notes (verification done while writing)

- **Spec coverage:** data foundation (Tasks 2,3,7) ✓; resolver forward+reverse+fallback (Tasks 4,5,6) ✓; Explorer synced bidirectional (Tasks 9,12) ✓; detail enrichment (Tasks 10,11) ✓; atlas-id validity guard (Tasks 6,7) ✓; graceful degradation (Task 4 fallback, Task 10 empty→shrink, Task 12 name fallback) ✓; new dependency (already added) ✓; nav entry (Task 13) ✓.
- **Type consistency:** `AnatomyMuscleGroup` (never the package's `MuscleGroup`), `SubRegion`, `MuscleHit`, `ExerciseMuscleResult`, `AnatomyExplorerNotifier.highlightedIds`, `exercisesForSubRegion`, `musclesForExercise`, `kCoarseMuscleToAtlasBaseIds`, `expandedCoarseMap()` used identically across tasks.
- **Atlas API:** `BodyAtlasView<MuscleInfo>`, `MuscleResolver()` const, `MuscleCatalog.byId`, `AtlasAsset.musclesFront/Back`, `colorMapping: Map<MuscleInfo, Color?>`, `onTapElement: (MuscleInfo)` — all match the verified 0.1.4 source.
- **Deferred (out of scope, per spec):** Phase 3 AI head-coverage, Phase 4 splits-as-templates, 1,420-exercise backfill.
```
