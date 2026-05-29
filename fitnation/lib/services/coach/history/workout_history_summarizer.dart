import 'package:fitnation/models/CompletedWorkout.dart';

class ExerciseProgressHint {
  final String exerciseId;
  final String exerciseName;
  final bool isBodyweight;
  final double? lastTopWeight;
  final int lastTopReps;
  final double? bestWeight;
  final int sessionCount;
  final double? suggestedNextWeight;
  final int suggestedNextReps;

  const ExerciseProgressHint({
    required this.exerciseId,
    required this.exerciseName,
    required this.isBodyweight,
    required this.lastTopWeight,
    required this.lastTopReps,
    required this.bestWeight,
    required this.sessionCount,
    required this.suggestedNextWeight,
    required this.suggestedNextReps,
  });
}

/// Pure Dart — no I/O. Summarises completed workout history into per-exercise
/// progression hints (last weight/reps, personal best, suggested next step).
class WorkoutHistorySummarizer {
  const WorkoutHistorySummarizer();

  Map<String, ExerciseProgressHint> summarize(List<CompletedWorkout> history) {
    if (history.isEmpty) return {};

    // Sort newest first
    final sorted = List<CompletedWorkout>.from(history)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    final Map<String, _Accumulator> acc = {};

    for (final workout in sorted) {
      for (final ex in workout.exercises) {
        final id = ex.exerciseId;
        acc.putIfAbsent(id, () => _Accumulator(id, ex.exerciseName));
        acc[id]!.addSession(workout.startTime, ex.sets);
      }
    }

    return acc.map((id, a) => MapEntry(id, a.toHint()));
  }

  static double? _parseWeight(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.isEmpty || s == 'bodyweight' || s == 'bw' || s == 'n/a') return null;
    // strip unit suffixes like "kg", "lbs", "lb"
    final digits = s.replaceAll(RegExp(r'[a-z\s]+$'), '').trim();
    return double.tryParse(digits);
  }

  static int _parseReps(String raw) => int.tryParse(raw.trim()) ?? 0;
}

class _Accumulator {
  final String id;
  final String name;

  // Most recent session data (newest first, so first session added is most recent)
  bool _hasRecent = false;
  double? _lastTopWeight;
  int _lastTopReps = 0;

  double? _bestWeight;
  int _sessionCount = 0;

  _Accumulator(this.id, this.name);

  void addSession(DateTime date, List<CompletedWorkoutSet> sets) {
    _sessionCount++;

    // Find the top set for this session (heaviest weight, or most reps if BW)
    double? topWeight;
    int topReps = 0;
    bool anyWeighted = false;

    for (final s in sets) {
      final w = WorkoutHistorySummarizer._parseWeight(s.weight);
      final r = WorkoutHistorySummarizer._parseReps(s.reps);

      if (w != null) {
        anyWeighted = true;
        if (topWeight == null || w > topWeight) {
          topWeight = w;
          topReps = r;
        }
      } else {
        if (!anyWeighted && r > topReps) {
          topReps = r;
        }
      }
    }

    // Only the most recent session sets "last" values
    if (!_hasRecent) {
      _hasRecent = true;
      _lastTopWeight = topWeight;
      _lastTopReps = topReps;
    }

    // Track best across all sessions
    if (topWeight != null && (_bestWeight == null || topWeight > _bestWeight!)) {
      _bestWeight = topWeight;
    }
  }

  ExerciseProgressHint toHint() {
    final bw = _lastTopWeight == null;
    double? nextWeight;
    int nextReps;

    if (!bw && _lastTopWeight != null) {
      // Linear load progression: +2.5 kg
      nextWeight = _lastTopWeight! + 2.5;
      nextReps = _lastTopReps;
    } else {
      // Bodyweight progression: +1 rep
      nextWeight = null;
      nextReps = _lastTopReps + 1;
    }

    return ExerciseProgressHint(
      exerciseId: id,
      exerciseName: name,
      isBodyweight: bw,
      lastTopWeight: _lastTopWeight,
      lastTopReps: _lastTopReps,
      bestWeight: _bestWeight,
      sessionCount: _sessionCount,
      suggestedNextWeight: nextWeight,
      suggestedNextReps: nextReps,
    );
  }
}
