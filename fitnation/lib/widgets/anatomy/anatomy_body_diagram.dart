import 'package:flutter/material.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';

/// Reusable body diagram that highlights a set of atlas muscle ids.
class AnatomyBodyDiagram extends StatelessWidget {
  final AtlasAsset view;
  final Set<String> highlightedIds;
  final Color highlightColor;
  final void Function(String atlasId)? onTapMuscleId;

  const AnatomyBodyDiagram({
    super.key,
    required this.view,
    required this.highlightedIds,
    required this.highlightColor,
    this.onTapMuscleId,
  });

  @override
  Widget build(BuildContext context) {
    final mapping = <MuscleInfo, Color?>{};
    for (final id in highlightedIds) {
      final info = MuscleCatalog.byId[id];
      if (info != null) mapping[info] = highlightColor;
    }
    return BodyAtlasView<MuscleInfo>(
      view: view,
      resolver: const MuscleResolver(),
      colorMapping: mapping,
      onTapElement: onTapMuscleId == null ? null : (m) => onTapMuscleId!(m.id),
    );
  }
}
