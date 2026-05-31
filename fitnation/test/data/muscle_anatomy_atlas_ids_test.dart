import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';

void main() {
  test('every atlas_muscle_id in muscle_anatomy.json exists in MuscleCatalog',
      () {
    final file = File('assets/data/muscle_anatomy.json');
    final data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    final groups = data['muscle_groups'] as List<dynamic>;
    expect(groups, isNotEmpty, reason: 'anatomy json should not be empty');

    final unknown = <String>[];
    for (final g in groups.cast<Map<String, dynamic>>()) {
      for (final s in (g['sub_regions'] as List).cast<Map<String, dynamic>>()) {
        for (final id in (s['atlas_muscle_ids'] as List).cast<String>()) {
          if (!MuscleCatalog.byId.containsKey(id)) unknown.add(id);
        }
      }
    }
    expect(unknown, isEmpty, reason: 'unknown atlas ids: $unknown');
  });

  test('every group has at least one sub-region with exercises', () {
    final file = File('assets/data/muscle_anatomy.json');
    final data = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    for (final g in (data['muscle_groups'] as List).cast<Map<String, dynamic>>()) {
      final subs = (g['sub_regions'] as List).cast<Map<String, dynamic>>();
      expect(subs, isNotEmpty, reason: '${g['id']} has no sub-regions');
      final hasExercises =
          subs.any((s) => (s['exercise_names'] as List).isNotEmpty);
      expect(hasExercises, isTrue, reason: '${g['id']} has no exercises');
    }
  });
}
