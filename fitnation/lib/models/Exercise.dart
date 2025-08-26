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
      exerciseId: json['exercise_id'] as String? ?? json['exerciseId'] as String?,
      name: json['name'] as String,
      gifUrl: json['gif_url'] as String? ?? json['gifUrl'] as String?,
      bodyParts:
          (json['body_parts'] as List<dynamic>? ?? json['bodyParts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      equipments:
          (json['equipments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      targetMuscles:
          (json['target_muscles'] as List<dynamic>? ?? json['targetMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      secondaryMuscles:
          (json['secondary_muscles'] as List<dynamic>? ?? json['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      instructions:
          (json['instructions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      // Parse optional fields
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      exerciseType: json['exercise_type'] as String? ?? json['exerciseType'] as String?,
      keywords:
          (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      overview: json['overview'] as String?,
      videoUrl: json['video_url'] as String? ?? json['videoUrl'] as String?,
      exerciseTips:
          (json['exercise_tips'] as List<dynamic>? ?? json['exerciseTips'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      variations:
          (json['variations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      relatedExerciseIds:
          (json['related_exercise_ids'] as List<dynamic>? ?? json['relatedExerciseIds'] as List<dynamic>?)
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
      if (exerciseId != null) 'exercise_id': exerciseId,
      'name': name,
      if (gifUrl != null) 'gif_url': gifUrl,
      'body_parts': bodyParts,
      'equipments': equipments,
      'target_muscles': targetMuscles,
      'secondary_muscles': secondaryMuscles,
      'instructions': instructions,
      // Include optional fields if not null
      if (imageUrl != null) 'image_url': imageUrl,
      if (exerciseType != null) 'exercise_type': exerciseType,
      if (keywords != null) 'keywords': keywords,
      if (overview != null) 'overview': overview,
      if (videoUrl != null) 'video_url': videoUrl,
      if (exerciseTips != null) 'exercise_tips': exerciseTips,
      if (variations != null) 'variations': variations,
      if (relatedExerciseIds != null) 'related_exercise_ids': relatedExerciseIds,
      if (sets != null) 'sets': sets,
      if (reps != null) 'reps': reps,
      if (weight != null) 'weight': weight,
    };
  }
}
