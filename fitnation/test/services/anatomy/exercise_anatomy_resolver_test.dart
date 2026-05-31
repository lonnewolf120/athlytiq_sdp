import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/models/Exercise.dart' as ex_db;
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';
import 'package:fitnation/services/anatomy/exercise_anatomy_resolver.dart';
import 'package:fitnation/services/coach/exercise_resolver.dart';

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
        atlasMuscleIds: [
          'triceps_brachii_caput_longum_l',
          'triceps_brachii_caput_longum_r'
        ],
        exerciseNames: ['Skull Crushers'],
      ),
    ],
  ),
]);

// Maps a coarse target-muscle token to FULL atlas ids for fallback.
const _coarseMap = {
  'pectorals': ['pectoralis_major_l', 'pectoralis_major_r'],
};

ex_db.Exercise _ex(String name, {List<String> targets = const []}) =>
    ex_db.Exercise(
      exerciseId: name,
      name: name,
      bodyParts: const [],
      equipments: const [],
      targetMuscles: targets,
      secondaryMuscles: const [],
      instructions: const [],
    );

class _FakeCatalog implements ExerciseCatalog {
  final List<ex_db.Exercise> _items;
  _FakeCatalog(this._items);
  @override
  Future<ex_db.Exercise?> getById(String id) async {
    for (final e in _items) {
      if (e.exerciseId == id) return e;
    }
    return null;
  }

  @override
  Future<List<ex_db.Exercise>> searchByName(String name,
      {String? bodyPart, String? equipment, int limit = 5}) async {
    final q = name.toLowerCase();
    return _items
        .where((e) => e.name.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }

  @override
  Future<List<ex_db.Exercise>> getByBodyPart(String bodyPart,
          {int limit = 5}) async =>
      const [];
  @override
  Future<List<String>> getUniqueBodyParts() async => const [];
  @override
  Future<List<String>> getUniqueEquipments() async => const [];
}

void main() {
  late ExerciseAnatomyResolver resolver;
  setUp(() => resolver = ExerciseAnatomyResolver(
        anatomy: _anatomy,
        coarseMuscleToAtlasIds: _coarseMap,
      ));

  test('reverse: curated exercise resolves to its head (case-insensitive)', () {
    final result = resolver.musclesForExercise(_ex('skull crushers'));
    expect(result.hits.length, 1);
    final hit = result.hits.first;
    expect(hit.subRegionId, 'triceps_long_head');
    expect(hit.isCurated, isTrue);
    expect(hit.atlasMuscleIds, contains('triceps_brachii_caput_longum_l'));
  });

  test('reverse: uncurated exercise falls back to coarse target muscles', () {
    final result = resolver
        .musclesForExercise(_ex('Machine Chest Press', targets: ['pectorals']));
    expect(result.hits.length, 1);
    final hit = result.hits.first;
    expect(hit.isCurated, isFalse);
    expect(hit.subRegionName.toLowerCase(), 'pectorals');
    expect(hit.atlasMuscleIds, contains('pectoralis_major_l'));
  });

  test('reverse: unknown exercise with unmapped target returns empty', () {
    final result = resolver
        .musclesForExercise(_ex('Mystery Move', targets: ['unknownus maximus']));
    expect(result.isEmpty, isTrue);
  });

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
}
