import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/services/anatomy/anatomy_repository.dart';

void main() {
  const sample = '''
  {"muscle_groups":[
    {"id":"biceps","name":"Biceps","atlas_group_ids":[],
     "sub_regions":[
       {"id":"long","name":"Long Head","notes":"",
        "atlas_muscle_ids":["biceps_brachii_caput_longum_l"],
        "exercise_names":["Incline Dumbbell Curl"]}
     ]}
  ]}''';

  test('loads and parses anatomy from injected loader', () async {
    final repo = AnatomyRepository(loadAsset: (_) async => sample);
    final anatomy = await repo.load();
    expect(anatomy.groups.single.id, 'biceps');
    expect(anatomy.groups.single.subRegions.single.id, 'long');
  });

  test('caches result — loader called once across multiple loads', () async {
    var calls = 0;
    final repo = AnatomyRepository(loadAsset: (_) async {
      calls++;
      return sample;
    });
    await repo.load();
    await repo.load();
    expect(calls, 1);
  });

  test('throws a clear error on invalid json', () async {
    final repo = AnatomyRepository(loadAsset: (_) async => 'not json');
    expect(repo.load(), throwsA(isA<FormatException>()));
  });
}
