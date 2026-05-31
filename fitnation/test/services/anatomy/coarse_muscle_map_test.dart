import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart';
import 'package:fitnation/services/anatomy/coarse_muscle_map.dart';

void main() {
  test('every mapped atlas id exists in the package catalog', () {
    final unknown = <String>[];
    for (final entry in kCoarseMuscleToAtlasIds.entries) {
      for (final id in entry.value) {
        if (!MuscleCatalog.byId.containsKey(id)) {
          unknown.add('${entry.key} -> $id');
        }
      }
    }
    expect(unknown, isEmpty, reason: 'unknown atlas ids: $unknown');
  });

  test('covers common catalog target tokens', () {
    for (final token in [
      'pectorals',
      'biceps',
      'triceps',
      'quads',
      'lats',
      'glutes',
      'hamstrings',
      'abs',
      'delts',
      'calves'
    ]) {
      expect(kCoarseMuscleToAtlasIds.containsKey(token), isTrue,
          reason: 'missing token: $token');
    }
  });
}
