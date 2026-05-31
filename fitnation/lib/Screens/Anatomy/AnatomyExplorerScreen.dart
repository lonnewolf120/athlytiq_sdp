import 'package:flutter/material.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/models/Exercise.dart' as ex_db;
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';
import 'package:fitnation/providers/anatomy_provider.dart';
import 'package:fitnation/services/coach/exercise_resolver.dart';
import 'package:fitnation/services/coach/local_exercise_catalog.dart';
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
            onPressed: () => setState(() => _view = _view == AtlasAsset.musclesFront
                ? AtlasAsset.musclesBack
                : AtlasAsset.musclesFront),
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

    AnatomyMuscleGroup? selectedGroup;
    for (final g in anatomy.groups) {
      if (g.id == state.selectedGroupId) selectedGroup = g;
    }
    // Default the display to the first group when nothing is selected yet.
    selectedGroup ??= anatomy.groups.isNotEmpty ? anatomy.groups.first : null;

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
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final sub in selectedGroup.subRegions)
              _SubRegionTile(
                sub: sub,
                selected: sub.id == state.selectedSubRegionId,
                onTap: () => notifier.selectSubRegion(selectedGroup!.id, sub.id),
              ),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('Tap a muscle or pick a group to explore.'),
            ),
        ],
      ),
    );
  }
}

class _SubRegionTile extends ConsumerWidget {
  final SubRegion sub;
  final bool selected;
  final VoidCallback onTap;
  const _SubRegionTile(
      {required this.sub, required this.selected, required this.onTap});

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
      loading: () =>
          const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (resolver) => FutureBuilder<List<ex_db.Exercise>>(
        future: resolver.exercisesForSubRegion(sub, _catalog()),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(
                padding: EdgeInsets.all(12), child: LinearProgressIndicator());
          }
          final exercises = snap.data ?? const <ex_db.Exercise>[];
          // Fall back to raw curated names if catalog resolution found nothing.
          final names = exercises.isNotEmpty
              ? exercises.map((e) => e.name).toList()
              : sub.exerciseNames;
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

ExerciseCatalog _catalog() => LocalExerciseCatalog();
