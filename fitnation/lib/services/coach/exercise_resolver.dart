import 'package:fitnation/models/Exercise.dart' as ex_db;

class AiExerciseItem {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final String weight;

  const AiExerciseItem({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
  });
}

class ResolvedExercise {
  final ex_db.Exercise exercise;
  final int plannedSets;
  final int plannedReps;
  final String plannedWeight;

  const ResolvedExercise({
    required this.exercise,
    required this.plannedSets,
    required this.plannedReps,
    required this.plannedWeight,
  });
}

class ResolveResult {
  final List<ResolvedExercise> resolved;
  final List<AiExerciseItem> unresolved;

  const ResolveResult({required this.resolved, required this.unresolved});
}

/// Interface over ExerciseDatabaseHelper — testable without sqflite.
abstract class ExerciseCatalog {
  Future<ex_db.Exercise?> getById(String id);
  Future<List<ex_db.Exercise>> searchByName(
    String name, {
    String? bodyPart,
    String? equipment,
    int limit = 5,
  });
  Future<List<ex_db.Exercise>> getByBodyPart(String bodyPart, {int limit = 5});
  Future<List<String>> getUniqueBodyParts();
  Future<List<String>> getUniqueEquipments();
}

/// Matches AI-generated exercise items against the real local catalog.
/// Strategy: exact id → name fuzzy search → fallback by body part → unresolved.
class ExerciseResolver {
  final ExerciseCatalog _catalog;

  const ExerciseResolver(this._catalog);

  Future<ResolveResult> resolve({
    required List<AiExerciseItem> aiItems,
    required List<String> fallbackBodyParts,
  }) async {
    final resolved = <ResolvedExercise>[];
    final unresolved = <AiExerciseItem>[];

    for (final item in aiItems) {
      final exercise = await _findExercise(item, fallbackBodyParts);
      if (exercise != null) {
        resolved.add(ResolvedExercise(
          exercise: exercise,
          plannedSets: item.sets,
          plannedReps: item.reps,
          plannedWeight: item.weight,
        ));
      } else {
        unresolved.add(item);
      }
    }

    return ResolveResult(resolved: resolved, unresolved: unresolved);
  }

  Future<ex_db.Exercise?> _findExercise(
    AiExerciseItem item,
    List<String> fallbackBodyParts,
  ) async {
    // 1. Exact id
    if (item.id.isNotEmpty) {
      final byId = await _catalog.getById(item.id);
      if (byId != null) return byId;
    }

    // 2. Name fuzzy search
    if (item.name.isNotEmpty) {
      final byName = await _catalog.searchByName(item.name);
      if (byName.isNotEmpty) return byName.first;
    }

    // 3. Body-part fallback
    for (final bp in fallbackBodyParts) {
      final byBp = await _catalog.getByBodyPart(bp);
      if (byBp.isNotEmpty) return byBp.first;
    }

    return null;
  }
}
