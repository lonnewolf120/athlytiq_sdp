import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/models/anatomy/muscle_anatomy.dart';

void main() {
  const json = {
    'muscle_groups': [
      {
        'id': 'triceps',
        'name': 'Triceps',
        'atlas_group_ids': ['triceps_brachii_caput_longum_l'],
        'sub_regions': [
          {
            'id': 'triceps_long_head',
            'name': 'Long Head',
            'notes': 'Overhead emphasis.',
            'atlas_muscle_ids': [
              'triceps_brachii_caput_longum_l',
              'triceps_brachii_caput_longum_r'
            ],
            'exercise_names': ['Skull Crushers', 'Overhead Cable Extension']
          }
        ]
      }
    ]
  };

  test('parses nested muscle anatomy from json', () {
    final anatomy = MuscleAnatomy.fromJson(json);
    expect(anatomy.groups.length, 1);
    final g = anatomy.groups.first;
    expect(g.id, 'triceps');
    expect(g.name, 'Triceps');
    expect(g.atlasGroupIds, ['triceps_brachii_caput_longum_l']);
    expect(g.subRegions.length, 1);
    final s = g.subRegions.first;
    expect(s.id, 'triceps_long_head');
    expect(s.name, 'Long Head');
    expect(s.notes, 'Overhead emphasis.');
    expect(s.atlasMuscleIds.length, 2);
    expect(s.exerciseNames, contains('Skull Crushers'));
  });

  test('handles missing optional fields with safe defaults', () {
    final anatomy = MuscleAnatomy.fromJson({
      'muscle_groups': [
        {'id': 'x', 'name': 'X', 'sub_regions': []}
      ]
    });
    final g = anatomy.groups.first;
    expect(g.atlasGroupIds, isEmpty);
    expect(g.subRegions, isEmpty);
  });

  test('empty root parses to empty groups', () {
    final anatomy = MuscleAnatomy.fromJson({'muscle_groups': []});
    expect(anatomy.groups, isEmpty);
  });
}
