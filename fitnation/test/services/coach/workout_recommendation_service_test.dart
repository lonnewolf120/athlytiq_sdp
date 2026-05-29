import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/models/Exercise.dart' as ex_db;
import 'package:fitnation/services/coach/exercise_resolver.dart';
import 'package:fitnation/services/coach/history/workout_history_summarizer.dart';
import 'package:fitnation/services/coach/workout_recommendation_service.dart';

// Reuse the same FakeCatalog from resolver test
class FakeCatalog implements ExerciseCatalog {
  final List<ex_db.Exercise> exercises;
  FakeCatalog(this.exercises);

  @override
  Future<ex_db.Exercise?> getById(String id) async =>
      exercises.where((e) => e.exerciseId == id).firstOrNull;

  @override
  Future<List<ex_db.Exercise>> searchByName(String name,
      {String? bodyPart, String? equipment, int limit = 5}) async {
    var results = exercises;
    if (name.isNotEmpty) {
      final q = name.toLowerCase();
      results = results.where((e) => e.name.toLowerCase().contains(q)).toList();
    }
    if (bodyPart != null) {
      results = results
          .where((e) => e.bodyParts.any((b) => b.toLowerCase().contains(bodyPart.toLowerCase())))
          .toList();
    }
    return results.take(limit).toList();
  }

  @override
  Future<List<ex_db.Exercise>> getByBodyPart(String bodyPart, {int limit = 5}) async =>
      exercises
          .where((e) => e.bodyParts.any((b) => b.toLowerCase() == bodyPart.toLowerCase()))
          .take(limit)
          .toList();

  @override
  Future<List<String>> getUniqueBodyParts() async =>
      exercises.expand((e) => e.bodyParts).toSet().toList();

  @override
  Future<List<String>> getUniqueEquipments() async =>
      exercises.expand((e) => e.equipments).toSet().toList();
}

class FakeGenerator implements ContentGenerator {
  final String? response;
  String? lastPrompt;
  FakeGenerator({this.response});

  @override
  Future<String?> generate(String prompt) async {
    lastPrompt = prompt;
    return response;
  }
}

ex_db.Exercise _ex({
  required String id,
  required String name,
  List<String> bodyParts = const ['chest'],
}) =>
    ex_db.Exercise(
      exerciseId: id,
      name: name,
      gifUrl: 'https://example.com/$id.gif',
      bodyParts: bodyParts,
      equipments: const ['barbell'],
      targetMuscles: const ['pectorals'],
      secondaryMuscles: const [],
      instructions: const ['Step 1'],
    );

final _catalog = FakeCatalog([
  _ex(id: 'b1', name: 'Bench Press', bodyParts: ['chest']),
  _ex(id: 's1', name: 'Squat', bodyParts: ['upper legs']),
  _ex(id: 'dl1', name: 'Deadlift', bodyParts: ['back']),
]);

String _validResponse(String name, String id) => '''
[{"exercise_id":"$id","exercise_name":"$name","exercise_equipment":["barbell"],"planned_sets":3,"planned_reps":8,"planned_weight":"60 kg"}]
''';

void main() {
  test('returns Workout when model returns valid exercises', () async {
    final service = WorkoutRecommendationService(
      generator: FakeGenerator(response: _validResponse('Bench Press', 'b1')),
      catalog: _catalog,
    );
    final workout = await service.generate(
      userProfile: {'goal': 'Strength', 'experience': 'intermediate'},
      progressHints: {},
    );
    expect(workout, isNotNull);
    expect(workout!.exercises, isNotEmpty);
    expect(workout.exercises.first.exerciseId, 'b1');
    expect(workout.exercises.first.exerciseName, 'Bench Press');
  });

  test('prompt contains catalog names', () async {
    final generator = FakeGenerator(response: _validResponse('Bench Press', 'b1'));
    final service = WorkoutRecommendationService(generator: generator, catalog: _catalog);
    await service.generate(userProfile: {'goal': 'Hypertrophy'}, progressHints: {});
    expect(generator.lastPrompt, contains('Bench Press'));
  });

  test('prompt contains progress history when provided', () async {
    final generator = FakeGenerator(response: _validResponse('Squat', 's1'));
    final service = WorkoutRecommendationService(generator: generator, catalog: _catalog);
    final hints = {
      's1': ExerciseProgressHint(
        exerciseId: 's1',
        exerciseName: 'Squat',
        isBodyweight: false,
        lastTopWeight: 100,
        lastTopReps: 5,
        bestWeight: 110,
        sessionCount: 3,
        suggestedNextWeight: 102.5,
        suggestedNextReps: 5,
      ),
    };
    await service.generate(userProfile: {'goal': 'Strength'}, progressHints: hints);
    expect(generator.lastPrompt, contains('Squat'));
    expect(generator.lastPrompt, contains('100'));
  });

  test('returns null when model returns empty', () async {
    final service = WorkoutRecommendationService(
      generator: FakeGenerator(response: null),
      catalog: _catalog,
    );
    final result = await service.generate(userProfile: {}, progressHints: {});
    expect(result, isNull);
  });

  test('returns null when model returns malformed JSON', () async {
    final service = WorkoutRecommendationService(
      generator: FakeGenerator(response: 'not json at all'),
      catalog: _catalog,
    );
    final result = await service.generate(userProfile: {}, progressHints: {});
    expect(result, isNull);
  });

  test('returns null when no exercises resolve', () async {
    final service = WorkoutRecommendationService(
      generator: FakeGenerator(response: '[{"exercise_id":"zzz","exercise_name":"Fake Unknown Zork Exercise","exercise_equipment":[],"planned_sets":3,"planned_reps":10,"planned_weight":null}]'),
      catalog: FakeCatalog([]), // empty catalog
    );
    final result = await service.generate(userProfile: {}, progressHints: {});
    expect(result, isNull);
  });

  test('strips markdown fences from model response', () async {
    final service = WorkoutRecommendationService(
      generator: FakeGenerator(response: '```json\n${_validResponse('Bench Press', 'b1')}\n```'),
      catalog: _catalog,
    );
    final result = await service.generate(userProfile: {}, progressHints: {});
    expect(result, isNotNull);
  });

  test('workout name contains goal from profile', () async {
    final service = WorkoutRecommendationService(
      generator: FakeGenerator(response: _validResponse('Bench Press', 'b1')),
      catalog: _catalog,
    );
    final result = await service.generate(
      userProfile: {'goal': 'Fat Loss'},
      progressHints: {},
    );
    expect(result!.name, contains('Fat Loss'));
  });
}
