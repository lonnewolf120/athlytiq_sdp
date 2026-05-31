import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';
import 'package:fitnation/providers/anatomy_provider.dart';
import 'package:fitnation/services/anatomy/exercise_anatomy_resolver.dart';
import 'package:fitnation/Screens/Anatomy/AnatomyExplorerScreen.dart';

final _anatomy = MuscleAnatomy([
  AnatomyMuscleGroup(id: 'biceps', name: 'Biceps', atlasGroupIds: const [], subRegions: const [
    SubRegion(
        id: 'long_head',
        name: 'Long Head',
        notes: '',
        atlasMuscleIds: ['biceps_brachii_caput_longum_l'],
        exerciseNames: ['Incline Dumbbell Curl']),
    SubRegion(
        id: 'short_head',
        name: 'Short Head',
        notes: '',
        atlasMuscleIds: ['biceps_brachii_caput_breve_l'],
        exerciseNames: ['Preacher Curl']),
  ]),
]);

void main() {
  testWidgets('renders groups and sub-regions; tapping a head selects it',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        anatomyProvider.overrideWith((ref) async => _anatomy),
        exerciseAnatomyResolverProvider
            .overrideWith((ref) async => ExerciseAnatomyResolver(anatomy: _anatomy)),
      ],
      child: const MaterialApp(home: AnatomyExplorerScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Biceps'), findsWidgets);
    expect(find.text('Long Head'), findsOneWidget);
    expect(find.text('Short Head'), findsOneWidget);

    await tester.tap(find.text('Short Head'));
    await tester.pumpAndSettle();
    // selecting Short Head shows its curated exercise (catalog returns empty,
    // so the screen falls back to the curated name)
    expect(find.text('Preacher Curl'), findsWidgets);
  });
}
