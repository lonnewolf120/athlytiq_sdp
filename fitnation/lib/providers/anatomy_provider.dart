import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';
import 'package:fitnation/services/anatomy/anatomy_repository.dart';
import 'package:fitnation/services/anatomy/coarse_muscle_map.dart';
import 'package:fitnation/services/anatomy/exercise_anatomy_resolver.dart';

final anatomyRepositoryProvider =
    Provider<AnatomyRepository>((ref) => AnatomyRepository());

final anatomyProvider = FutureProvider<MuscleAnatomy>((ref) {
  return ref.watch(anatomyRepositoryProvider).load();
});

final exerciseAnatomyResolverProvider =
    FutureProvider<ExerciseAnatomyResolver>((ref) async {
  final anatomy = await ref.watch(anatomyProvider.future);
  return ExerciseAnatomyResolver(
    anatomy: anatomy,
    coarseMuscleToAtlasIds: kCoarseMuscleToAtlasIds,
  );
});

class AnatomyExplorerState {
  final String? selectedGroupId;
  final String? selectedSubRegionId;
  const AnatomyExplorerState({this.selectedGroupId, this.selectedSubRegionId});
}

class AnatomyExplorerNotifier extends StateNotifier<AnatomyExplorerState> {
  final MuscleAnatomy anatomy;
  AnatomyExplorerNotifier(this.anatomy) : super(const AnatomyExplorerState());

  void selectGroup(String groupId) {
    final g = _group(groupId);
    state = AnatomyExplorerState(
      selectedGroupId: groupId,
      selectedSubRegionId:
          g != null && g.subRegions.isNotEmpty ? g.subRegions.first.id : null,
    );
  }

  void selectSubRegion(String groupId, String subRegionId) {
    state = AnatomyExplorerState(
        selectedGroupId: groupId, selectedSubRegionId: subRegionId);
  }

  /// Reverse: find the group + sub-region that owns an atlas id.
  void selectByAtlasId(String atlasId) {
    for (final g in anatomy.groups) {
      for (final s in g.subRegions) {
        if (s.atlasMuscleIds.contains(atlasId)) {
          state = AnatomyExplorerState(
              selectedGroupId: g.id, selectedSubRegionId: s.id);
          return;
        }
      }
    }
    // unknown id: no change
  }

  Set<String> get highlightedIds {
    final g = _group(state.selectedGroupId);
    if (g == null) return <String>{};
    for (final s in g.subRegions) {
      if (s.id == state.selectedSubRegionId) return s.atlasMuscleIds.toSet();
    }
    return <String>{};
  }

  AnatomyMuscleGroup? _group(String? id) {
    if (id == null) return null;
    for (final g in anatomy.groups) {
      if (g.id == id) return g;
    }
    return null;
  }
}

final anatomyExplorerProvider = StateNotifierProvider.family<
    AnatomyExplorerNotifier, AnatomyExplorerState, MuscleAnatomy>(
  (ref, anatomy) => AnatomyExplorerNotifier(anatomy),
);
