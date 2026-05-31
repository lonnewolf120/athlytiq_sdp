import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/models/Exercise.dart' as ex_db;
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';
import 'package:fitnation/providers/anatomy_provider.dart';
import 'package:fitnation/services/anatomy/exercise_anatomy_resolver.dart';
import 'package:fitnation/widgets/anatomy/exercise_muscles_section.dart';

final _anatomy = MuscleAnatomy([
  AnatomyMuscleGroup(id: 'triceps', name: 'Triceps', atlasGroupIds: const [], subRegions: const [
    SubRegion(
        id: 'long_head',
        name: 'Long Head',
        notes: '',
        atlasMuscleIds: ['triceps_brachii_caput_longum_l', 'triceps_brachii_caput_longum_r'],
        exerciseNames: ['Skull Crusher']),
  ]),
]);

ex_db.Exercise _ex(String name) => ex_db.Exercise(
    exerciseId: name,
    name: name,
    bodyParts: const [],
    equipments: const [],
    targetMuscles: const [],
    secondaryMuscles: const [],
    instructions: const []);

void main() {
  testWidgets('renders Muscles worked section with head chip for curated exercise',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        exerciseAnatomyResolverProvider
            .overrideWith((ref) async => ExerciseAnatomyResolver(anatomy: _anatomy)),
      ],
      child: MaterialApp(
          home: Scaffold(body: ExerciseMusclesSection(exercise: _ex('Skull Crusher')))),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Muscles worked'), findsOneWidget);
    expect(find.textContaining('Long Head'), findsOneWidget);
  });

  testWidgets('renders nothing for exercise with no hits', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        exerciseAnatomyResolverProvider
            .overrideWith((ref) async => ExerciseAnatomyResolver(anatomy: _anatomy)),
      ],
      child: MaterialApp(
          home: Scaffold(body: ExerciseMusclesSection(exercise: _ex('Unknown Move')))),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Muscles worked'), findsNothing);
  });
}
