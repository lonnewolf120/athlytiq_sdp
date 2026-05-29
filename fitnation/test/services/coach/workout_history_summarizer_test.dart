import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/models/CompletedWorkout.dart';
import 'package:fitnation/services/coach/history/workout_history_summarizer.dart';

CompletedWorkout _workout({
  required DateTime start,
  required List<CompletedWorkoutExercise> exercises,
}) =>
    CompletedWorkout(
      workoutName: 'W',
      startTime: start,
      endTime: start.add(const Duration(minutes: 30)),
      durationSeconds: 1800,
      intensityScore: 7,
      exercises: exercises,
    );

CompletedWorkoutExercise _ex({
  required String id,
  required String name,
  required List<(String, String)> sets,
}) =>
    CompletedWorkoutExercise(
      exerciseId: id,
      exerciseName: name,
      sets: sets.map((s) => CompletedWorkoutSet(weight: s.$1, reps: s.$2)).toList(),
    );

void main() {
  const summarizer = WorkoutHistorySummarizer();

  test('empty history returns empty map', () {
    expect(summarizer.summarize([]), isEmpty);
  });

  test('single weighted session: suggests +2.5kg same reps', () {
    final hints = summarizer.summarize([
      _workout(start: DateTime(2026, 5, 1), exercises: [
        _ex(id: 'bench', name: 'Bench Press', sets: [('60', '8'), ('60', '8')]),
      ]),
    ]);
    final h = hints['bench']!;
    expect(h.exerciseName, 'Bench Press');
    expect(h.isBodyweight, isFalse);
    expect(h.lastTopWeight, 60);
    expect(h.lastTopReps, 8);
    expect(h.bestWeight, 60);
    expect(h.sessionCount, 1);
    expect(h.suggestedNextWeight, 62.5);
    expect(h.suggestedNextReps, 8);
  });

  test('bodyweight: suggests +1 rep', () {
    final hints = summarizer.summarize([
      _workout(start: DateTime(2026, 5, 1), exercises: [
        _ex(id: 'pushup', name: 'Push Up', sets: [('Bodyweight', '12')]),
      ]),
    ]);
    final h = hints['pushup']!;
    expect(h.isBodyweight, isTrue);
    expect(h.lastTopWeight, isNull);
    expect(h.lastTopReps, 12);
    expect(h.suggestedNextWeight, isNull);
    expect(h.suggestedNextReps, 13);
  });

  test('top set is the heaviest within a session', () {
    final hints = summarizer.summarize([
      _workout(start: DateTime(2026, 5, 1), exercises: [
        _ex(id: 'squat', name: 'Squat', sets: [
          ('80', '10'), ('100', '5'), ('90', '8'),
        ]),
      ]),
    ]);
    final h = hints['squat']!;
    expect(h.lastTopWeight, 100);
    expect(h.lastTopReps, 5);
  });

  test('most recent session for last, best across all for bestWeight', () {
    final hints = summarizer.summarize([
      _workout(start: DateTime(2026, 5, 10), exercises: [
        _ex(id: 'dl', name: 'Deadlift', sets: [('120', '5')]),
      ]),
      _workout(start: DateTime(2026, 5, 1), exercises: [
        _ex(id: 'dl', name: 'Deadlift', sets: [('140', '3')]),
      ]),
    ]);
    final h = hints['dl']!;
    expect(h.lastTopWeight, 120);
    expect(h.bestWeight, 140);
    expect(h.sessionCount, 2);
    expect(h.suggestedNextWeight, 122.5);
  });

  test('empty/non-numeric weight treated as bodyweight', () {
    final hints = summarizer.summarize([
      _workout(start: DateTime(2026, 5, 1), exercises: [
        _ex(id: 'plank', name: 'Plank', sets: [('', '30'), ('n/a', '30')]),
      ]),
    ]);
    final h = hints['plank']!;
    expect(h.isBodyweight, isTrue);
    expect(h.lastTopWeight, isNull);
    expect(h.suggestedNextReps, 31);
  });

  test('parses weight with kg suffix', () {
    final hints = summarizer.summarize([
      _workout(start: DateTime(2026, 5, 1), exercises: [
        _ex(id: 'ohp', name: 'OHP', sets: [('62.5 kg', '6')]),
      ]),
    ]);
    final h = hints['ohp']!;
    expect(h.lastTopWeight, 62.5);
    expect(h.suggestedNextWeight, 65.0);
  });

  test('exercise with zero reps is still tracked', () {
    final hints = summarizer.summarize([
      _workout(start: DateTime(2026, 5, 1), exercises: [
        _ex(id: 'ex1', name: 'Ex', sets: [('50', '0')]),
      ]),
    ]);
    expect(hints['ex1'], isNotNull);
    expect(hints['ex1']!.lastTopReps, 0);
  });
}
