import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/models/Exercise.dart' as ex_db;
import 'package:fitnation/services/coach/exercise_resolver.dart';

class FakeCatalog implements ExerciseCatalog {
  final List<ex_db.Exercise> _exercises;
  FakeCatalog(this._exercises);

  @override
  Future<ex_db.Exercise?> getById(String id) async =>
      _exercises.where((e) => e.exerciseId == id).firstOrNull;

  @override
  Future<List<ex_db.Exercise>> searchByName(
    String name, {
    String? bodyPart,
    String? equipment,
    int limit = 5,
  }) async {
    var results = _exercises;
    if (name.isNotEmpty) {
      final q = name.toLowerCase();
      results = results.where((e) => e.name.toLowerCase().contains(q)).toList();
    }
    if (bodyPart != null) {
      results = results
          .where((e) => e.bodyParts.any((b) => b.toLowerCase().contains(bodyPart.toLowerCase())))
          .toList();
    }
    if (equipment != null) {
      results = results
          .where((e) => e.equipments.any((eq) => eq.toLowerCase().contains(equipment.toLowerCase())))
          .toList();
    }
    return results.take(limit).toList();
  }

  @override
  Future<List<ex_db.Exercise>> getByBodyPart(String bodyPart, {int limit = 5}) async =>
      _exercises
          .where((e) => e.bodyParts.any((b) => b.toLowerCase().contains(bodyPart.toLowerCase())))
          .take(limit)
          .toList();

  @override
  Future<List<String>> getUniqueBodyParts() async =>
      _exercises.expand((e) => e.bodyParts).toSet().toList();

  @override
  Future<List<String>> getUniqueEquipments() async =>
      _exercises.expand((e) => e.equipments).toSet().toList();
}

ex_db.Exercise _fakeEx({
  required String id,
  required String name,
  List<String> bodyParts = const [],
  List<String> equipments = const [],
  List<String> targetMuscles = const [],
}) =>
    ex_db.Exercise(
      exerciseId: id,
      name: name,
      gifUrl: 'https://example.com/$id.gif',
      bodyParts: bodyParts,
      equipments: equipments,
      targetMuscles: targetMuscles,
      secondaryMuscles: const [],
      instructions: ['Step 1'],
    );

final _fakeCatalog = FakeCatalog([
  _fakeEx(id: 'abc123', name: 'Barbell Bench Press', bodyParts: ['chest'], equipments: ['barbell'], targetMuscles: ['pectorals']),
  _fakeEx(id: 'def456', name: 'Squat', bodyParts: ['upper legs'], equipments: ['barbell'], targetMuscles: ['quadriceps']),
  _fakeEx(id: 'ghi789', name: 'Push-Up', bodyParts: ['chest'], equipments: ['body weight']),
]);

void main() {
  late ExerciseResolver resolver;
  setUp(() => resolver = ExerciseResolver(_fakeCatalog));

  test('resolves by exact id', () async {
    final result = await resolver.resolve(
      aiItems: [AiExerciseItem(id: 'abc123', name: 'Bench Press', sets: 3, reps: 8, weight: '60')],
      fallbackBodyParts: [],
    );
    expect(result.resolved.length, 1);
    expect(result.resolved.first.exercise.exerciseId, 'abc123');
    expect(result.resolved.first.exercise.gifUrl, isNotEmpty);
    expect(result.unresolved, isEmpty);
  });

  test('falls back to name search when id is fake', () async {
    final result = await resolver.resolve(
      aiItems: [AiExerciseItem(id: 'fake_id_999', name: 'barbell bench press', sets: 3, reps: 8, weight: '80')],
      fallbackBodyParts: [],
    );
    expect(result.resolved.length, 1);
    expect(result.resolved.first.exercise.exerciseId, 'abc123');
  });

  test('name match is case-insensitive', () async {
    final result = await resolver.resolve(
      aiItems: [AiExerciseItem(id: 'bad_id', name: 'SQUAT', sets: 4, reps: 5, weight: '100')],
      fallbackBodyParts: [],
    );
    expect(result.resolved.length, 1);
    expect(result.resolved.first.exercise.exerciseId, 'def456');
  });

  test('unresolvable item with no fallback goes to unresolved', () async {
    final result = await resolver.resolve(
      aiItems: [AiExerciseItem(id: 'fake', name: 'Totally Unknown Zork Exercise', sets: 3, reps: 10, weight: '0')],
      fallbackBodyParts: [],
    );
    expect(result.resolved, isEmpty);
    expect(result.unresolved.length, 1);
  });

  test('uses fallback body part when item unresolvable', () async {
    final result = await resolver.resolve(
      aiItems: [AiExerciseItem(id: 'fake', name: 'Unknown XYZ', sets: 3, reps: 10, weight: '0')],
      fallbackBodyParts: ['chest'],
    );
    expect(result.resolved.length, 1);
    expect(result.resolved.first.exercise.bodyParts, contains('chest'));
  });

  test('preserves planned sets/reps/weight', () async {
    final result = await resolver.resolve(
      aiItems: [AiExerciseItem(id: 'abc123', name: 'Bench', sets: 4, reps: 6, weight: '80 kg')],
      fallbackBodyParts: [],
    );
    final item = result.resolved.first;
    expect(item.plannedSets, 4);
    expect(item.plannedReps, 6);
    expect(item.plannedWeight, '80 kg');
  });

  test('empty ai items returns empty lists', () async {
    final result = await resolver.resolve(aiItems: [], fallbackBodyParts: []);
    expect(result.resolved, isEmpty);
    expect(result.unresolved, isEmpty);
  });
}
