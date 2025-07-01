class Exercise {
  final String? exerciseId; // Use exerciseId from the API
  final String name;
  final String? gifUrl; // URL to the exercise GIF
  final List<String> bodyParts; // Now a list
  final List<String> equipments; // Now a list
  final List<String> targetMuscles; // Target muscles (primary)
  final List<String> secondaryMuscles; // Secondary muscles
  final List<String> instructions; // Step-by-step instructions

  // Optional fields based on the *first* example object you provided (might not be in all responses)
  final String? imageUrl; // Static image URL?
  final String? exerciseType; // e.g., "weight_reps"
  final List<String>? keywords;
  final String? overview;
  final String? videoUrl;
  final List<String>? exerciseTips;
  final List<String>? variations;
  final List<String>? relatedExerciseIds;
  String? sets;
  String? reps;
  String? weight;

  Exercise({
    this.exerciseId,
    required this.name,
    this.gifUrl,
    required this.bodyParts,
    required this.equipments,
    required this.targetMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    // Include optional fields
    this.imageUrl,
    this.exerciseType,
    this.keywords,
    this.overview,
    this.videoUrl,
    this.exerciseTips,
    this.variations,
    this.relatedExerciseIds,
    this.sets,
    this.reps,
    this.weight,
  });

  // Factory constructor to create an Exercise object from JSON
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exerciseId'] as String?, // Use exerciseId
      name: json['name'] as String,
      gifUrl: json['gifUrl'] as String?, // Use gifUrl
      bodyParts:
          (json['bodyParts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      equipments:
          (json['equipments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      targetMuscles:
          (json['targetMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      secondaryMuscles:
          (json['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      instructions:
          (json['instructions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      // Parse optional fields
      imageUrl: json['imageUrl'] as String?,
      exerciseType: json['exerciseType'] as String?,
      keywords:
          (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      overview: json['overview'] as String?,
      videoUrl: json['videoUrl'] as String?,
      exerciseTips:
          (json['exerciseTips'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      variations:
          (json['variations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      relatedExerciseIds:
          (json['relatedExerciseIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      sets: json['sets'] as String?,
      reps: json['reps'] as String?,
      weight: json['weight'] as String?,
    );
  }

  // Optional: toJson method
  Map<String, dynamic> toJson() {
    return {
      if (exerciseId != null) 'exerciseId': exerciseId,
      'name': name,
      if (gifUrl != null) 'gifUrl': gifUrl,
      'bodyParts': bodyParts,
      'equipments': equipments,
      'targetMuscles': targetMuscles,
      'secondaryMuscles': secondaryMuscles,
      'instructions': instructions,
      // Include optional fields if not null
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (exerciseType != null) 'exerciseType': exerciseType,
      if (keywords != null) 'keywords': keywords,
      if (overview != null) 'overview': overview,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (exerciseTips != null) 'exerciseTips': exerciseTips,
      if (variations != null) 'variations': variations,
      if (relatedExerciseIds != null) 'relatedExerciseIds': relatedExerciseIds,
      if (sets != null) 'sets': sets,
      if (reps != null) 'reps': reps,
      if (weight != null) 'weight': weight,
    };
  }
}
