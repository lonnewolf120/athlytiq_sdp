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

/// Links the curated anatomy data to the real exercise catalog.
/// - Reverse: a catalog exercise -> the muscle head(s) it hits (curated, or
///   coarse-tag fallback).
/// - Forward: a sub-region's curated exercise names -> catalog entries.
class ExerciseAnatomyResolver {
  final MuscleAnatomy anatomy;

  /// Maps a coarse target-muscle token (lowercase) to FULL atlas ids.
  final Map<String, List<String>> coarseMuscleToAtlasIds;

  // Reverse index: lowercase exercise name -> owning (group, subRegion).
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
}

class _Owner {
  final AnatomyMuscleGroup group;
  final SubRegion sub;
  const _Owner(this.group, this.sub);
}
