class MuscleAnatomy {
  final List<AnatomyMuscleGroup> groups;
  const MuscleAnatomy(this.groups);

  factory MuscleAnatomy.fromJson(Map<String, dynamic> json) {
    final raw = (json['muscle_groups'] as List<dynamic>? ?? const []);
    return MuscleAnatomy(
      raw
          .whereType<Map<String, dynamic>>()
          .map(AnatomyMuscleGroup.fromJson)
          .toList(),
    );
  }
}

class AnatomyMuscleGroup {
  final String id;
  final String name;
  final List<String> atlasGroupIds;
  final List<SubRegion> subRegions;

  const AnatomyMuscleGroup({
    required this.id,
    required this.name,
    required this.atlasGroupIds,
    required this.subRegions,
  });

  factory AnatomyMuscleGroup.fromJson(Map<String, dynamic> json) {
    return AnatomyMuscleGroup(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      atlasGroupIds: _stringList(json['atlas_group_ids']),
      subRegions: (json['sub_regions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SubRegion.fromJson)
          .toList(),
    );
  }
}

class SubRegion {
  final String id;
  final String name;
  final String notes;
  final List<String> atlasMuscleIds;
  final List<String> exerciseNames;

  const SubRegion({
    required this.id,
    required this.name,
    required this.notes,
    required this.atlasMuscleIds,
    required this.exerciseNames,
  });

  factory SubRegion.fromJson(Map<String, dynamic> json) {
    return SubRegion(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      atlasMuscleIds: _stringList(json['atlas_muscle_ids']),
      exerciseNames: _stringList(json['exercise_names']),
    );
  }
}

List<String> _stringList(dynamic v) =>
    (v as List<dynamic>? ?? const []).map((e) => e.toString()).toList();
