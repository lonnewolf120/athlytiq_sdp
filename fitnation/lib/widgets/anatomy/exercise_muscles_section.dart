import 'package:flutter/material.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/models/Exercise.dart' as ex_db;
import 'package:fitnation/providers/anatomy_provider.dart';
import 'package:fitnation/widgets/anatomy/anatomy_body_diagram.dart';

/// "Muscles worked" section for the exercise detail sheet. Highlights the
/// exercise's resolved muscle head(s) on a body diagram, with chips.
/// Renders nothing when there are no hits — never blocks the sheet.
class ExerciseMusclesSection extends ConsumerWidget {
  final ex_db.Exercise exercise;
  const ExerciseMusclesSection({super.key, required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(exerciseAnatomyResolverProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
              width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
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
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
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
