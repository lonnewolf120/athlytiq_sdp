import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';
import 'package:fitnation/widgets/anatomy/anatomy_body_diagram.dart';

void main() {
  testWidgets('builds colorMapping from highlighted ids and renders BodyAtlasView',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AnatomyBodyDiagram(
          view: AtlasAsset.musclesFront,
          highlightedIds: const {'biceps_brachii_caput_longum_l'},
          highlightColor: Colors.red,
        ),
      ),
    ));
    expect(find.byType(BodyAtlasView<MuscleInfo>), findsOneWidget);
    final widget =
        tester.widget<BodyAtlasView<MuscleInfo>>(find.byType(BodyAtlasView<MuscleInfo>));
    final ids = widget.colorMapping!.keys.map((m) => m.id).toSet();
    expect(ids, contains('biceps_brachii_caput_longum_l'));
  });

  testWidgets('ignores unknown atlas ids without crashing', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AnatomyBodyDiagram(
          view: AtlasAsset.musclesFront,
          highlightedIds: const {'totally_fake_id'},
          highlightColor: Colors.red,
        ),
      ),
    ));
    final widget =
        tester.widget<BodyAtlasView<MuscleInfo>>(find.byType(BodyAtlasView<MuscleInfo>));
    expect(widget.colorMapping, isEmpty);
  });
}
