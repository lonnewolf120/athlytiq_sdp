import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';
import 'package:fitnation/providers/anatomy_provider.dart';

final _anatomy = MuscleAnatomy([
  AnatomyMuscleGroup(
    id: 'biceps',
    name: 'Biceps',
    atlasGroupIds: const [],
    subRegions: const [
      SubRegion(
          id: 'long_head',
          name: 'Long Head',
          notes: '',
          atlasMuscleIds: [
            'biceps_brachii_caput_longum_l',
            'biceps_brachii_caput_longum_r'
          ],
          exerciseNames: ['Incline Dumbbell Curl']),
      SubRegion(
          id: 'short_head',
          name: 'Short Head',
          notes: '',
          atlasMuscleIds: ['biceps_brachii_caput_breve_l'],
          exerciseNames: ['Preacher Curl']),
    ],
  ),
]);

void main() {
  test('selectByAtlasId selects the owning group and sub-region', () {
    final notifier = AnatomyExplorerNotifier(_anatomy);
    notifier.selectByAtlasId('biceps_brachii_caput_longum_r');
    expect(notifier.state.selectedGroupId, 'biceps');
    expect(notifier.state.selectedSubRegionId, 'long_head');
  });

  test('selectSubRegion updates both ids', () {
    final notifier = AnatomyExplorerNotifier(_anatomy);
    notifier.selectSubRegion('biceps', 'short_head');
    expect(notifier.state.selectedGroupId, 'biceps');
    expect(notifier.state.selectedSubRegionId, 'short_head');
  });

  test('highlightedIds reflects the selected sub-region', () {
    final notifier = AnatomyExplorerNotifier(_anatomy);
    notifier.selectSubRegion('biceps', 'long_head');
    expect(notifier.highlightedIds,
        containsAll(['biceps_brachii_caput_longum_l', 'biceps_brachii_caput_longum_r']));
  });

  test('unknown atlas id leaves state unchanged', () {
    final notifier = AnatomyExplorerNotifier(_anatomy);
    notifier.selectSubRegion('biceps', 'long_head');
    notifier.selectByAtlasId('not_a_real_id');
    expect(notifier.state.selectedSubRegionId, 'long_head');
  });
}
