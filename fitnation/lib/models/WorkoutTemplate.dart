import 'package:uuid/uuid.dart';

class WorkoutTemplateExercise {
  final String id;
  final String templateId;
  final String exerciseId;
  final String exerciseName;
  final List<String> exerciseEquipments;
  final String? exerciseGifUrl;
  final int exerciseOrder;
  final int defaultSets;
  final String defaultReps;
  final String? defaultWeight;
  final int? restTimeSeconds;
  final String? notes;
  final DateTime createdAt;

  WorkoutTemplateExercise({
    String? id,
    required this.templateId,
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseEquipments = const [],
    this.exerciseGifUrl,
    required this.exerciseOrder,
    required this.defaultSets,
    required this.defaultReps,
    this.defaultWeight,
    this.restTimeSeconds = 60,
    this.notes,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory WorkoutTemplateExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplateExercise(
      id: json['id'] as String,
      templateId: json['template_id'] as String,
      exerciseId: json['exercise_id'] as String,
      exerciseName: json['exercise_name'] as String,
      exerciseEquipments: List<String>.from(json['exercise_equipments'] ?? []),
      exerciseGifUrl: json['exercise_gif_url'] as String?,
      exerciseOrder: json['exercise_order'] as int,
      defaultSets: json['default_sets'] as int,
      defaultReps: json['default_reps'] as String,
      defaultWeight: json['default_weight'] as String?,
      restTimeSeconds: json['rest_time_seconds'] as int?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template_id': templateId,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'exercise_equipments': exerciseEquipments,
      'exercise_gif_url': exerciseGifUrl,
      'exercise_order': exerciseOrder,
      'default_sets': defaultSets,
      'default_reps': defaultReps,
      'default_weight': defaultWeight,
      'rest_time_seconds': restTimeSeconds,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  WorkoutTemplateExercise copyWith({
    String? id,
    String? templateId,
    String? exerciseId,
    String? exerciseName,
    List<String>? exerciseEquipments,
    String? exerciseGifUrl,
    int? exerciseOrder,
    int? defaultSets,
    String? defaultReps,
    String? defaultWeight,
    int? restTimeSeconds,
    String? notes,
    DateTime? createdAt,
  }) {
    return WorkoutTemplateExercise(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseEquipments: exerciseEquipments ?? this.exerciseEquipments,
      exerciseGifUrl: exerciseGifUrl ?? this.exerciseGifUrl,
      exerciseOrder: exerciseOrder ?? this.exerciseOrder,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultWeight: defaultWeight ?? this.defaultWeight,
      restTimeSeconds: restTimeSeconds ?? this.restTimeSeconds,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class WorkoutTemplate {
  final String id;
  final String name;
  final String? description;
  final String author;
  final String difficultyLevel;
  final List<String> primaryMuscleGroups;
  final int? estimatedDurationMinutes;
  final List<String> equipmentRequired;
  final List<String> tags;
  final String? iconUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<WorkoutTemplateExercise> exercises;
  final int? exerciseCount;

  WorkoutTemplate({
    String? id,
    required this.name,
    this.description,
    required this.author,
    required this.difficultyLevel,
    this.primaryMuscleGroups = const [],
    this.estimatedDurationMinutes,
    this.equipmentRequired = const [],
    this.tags = const [],
    this.iconUrl,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.exercises = const [],
    this.exerciseCount,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    var exercisesList = <WorkoutTemplateExercise>[];
    if (json['exercises'] != null) {
      exercisesList =
          (json['exercises'] as List)
              .map(
                (e) =>
                    WorkoutTemplateExercise.fromJson(e as Map<String, dynamic>),
              )
              .toList();
    }

    return WorkoutTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      author: json['author'] as String,
      difficultyLevel: json['difficulty_level'] as String,
      primaryMuscleGroups: List<String>.from(
        json['primary_muscle_groups'] ?? [],
      ),
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int?,
      equipmentRequired: List<String>.from(json['equipment_required'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      iconUrl: json['icon_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      exercises: exercisesList,
      exerciseCount: json['exercise_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'author': author,
      'difficulty_level': difficultyLevel,
      'primary_muscle_groups': primaryMuscleGroups,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'equipment_required': equipmentRequired,
      'tags': tags,
      'icon_url': iconUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'exercise_count': exerciseCount,
    };
  }

  WorkoutTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? author,
    String? difficultyLevel,
    List<String>? primaryMuscleGroups,
    int? estimatedDurationMinutes,
    List<String>? equipmentRequired,
    List<String>? tags,
    String? iconUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<WorkoutTemplateExercise>? exercises,
    int? exerciseCount,
  }) {
    return WorkoutTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      author: author ?? this.author,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      primaryMuscleGroups: primaryMuscleGroups ?? this.primaryMuscleGroups,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      equipmentRequired: equipmentRequired ?? this.equipmentRequired,
      tags: tags ?? this.tags,
      iconUrl: iconUrl ?? this.iconUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      exercises: exercises ?? this.exercises,
      exerciseCount: exerciseCount ?? this.exerciseCount,
    );
  }

  // Computed properties
  String get displayDuration {
    if (estimatedDurationMinutes == null) return 'Unknown duration';
    if (estimatedDurationMinutes! < 60) return '${estimatedDurationMinutes}min';
    final hours = estimatedDurationMinutes! ~/ 60;
    final minutes = estimatedDurationMinutes! % 60;
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}min';
  }

  String get difficultyEmoji {
    switch (difficultyLevel.toLowerCase()) {
      case 'beginner':
        return '🟢';
      case 'intermediate':
        return '🟡';
      case 'advanced':
        return '🔴';
      default:
        return '⚪';
    }
  }

  String get primaryMuscleGroupsDisplay {
    if (primaryMuscleGroups.isEmpty) return 'Full Body';
    if (primaryMuscleGroups.length == 1)
      return primaryMuscleGroups.first.toUpperCase();
    if (primaryMuscleGroups.length <= 3) {
      return primaryMuscleGroups.map((mg) => mg.toUpperCase()).join(', ');
    }
    return '${primaryMuscleGroups.take(2).map((mg) => mg.toUpperCase()).join(', ')} +${primaryMuscleGroups.length - 2}';
  }
}

class WorkoutTemplateListResponse {
  final List<WorkoutTemplate> templates;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  WorkoutTemplateListResponse({
    required this.templates,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory WorkoutTemplateListResponse.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplateListResponse(
      templates:
          (json['templates'] as List)
              .map((e) => WorkoutTemplate.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalCount: json['total_count'] as int,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      totalPages: json['total_pages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'templates': templates.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
      'page': page,
      'page_size': pageSize,
      'total_pages': totalPages,
    };
  }
}

class TemplateFilters {
  final String? author;
  final String? difficultyLevel;
  final String? muscleGroups; // Comma-separated string for API
  final String? tags; // Comma-separated string for API
  final String? search;
  final int skip;
  final int limit;

  TemplateFilters({
    this.author,
    this.difficultyLevel,
    this.muscleGroups,
    this.tags,
    this.search,
    this.skip = 0,
    this.limit = 20,
  });

  factory TemplateFilters.fromJson(Map<String, dynamic> json) {
    return TemplateFilters(
      author: json['author'] as String?,
      difficultyLevel: json['difficulty_level'] as String?,
      muscleGroups: json['muscle_groups'] as String?,
      tags: json['tags'] as String?,
      search: json['search'] as String?,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'difficulty_level': difficultyLevel,
      'muscle_groups': muscleGroups,
      'tags': tags,
      'search': search,
      'skip': skip,
      'limit': limit,
    };
  }

  TemplateFilters copyWith({
    String? author,
    String? difficultyLevel,
    String? muscleGroups,
    String? tags,
    String? search,
    int? skip,
    int? limit,
  }) {
    return TemplateFilters(
      author: author ?? this.author,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      tags: tags ?? this.tags,
      search: search ?? this.search,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (author != null) params['author'] = author;
    if (difficultyLevel != null) params['difficulty_level'] = difficultyLevel;
    if (muscleGroups != null) params['muscle_groups'] = muscleGroups;
    if (tags != null) params['tags'] = tags;
    if (search != null) params['search'] = search;
    params['skip'] = skip;
    params['limit'] = limit;
    return params;
  }
}

class ImportTemplateRequest {
  final String? customName;

  ImportTemplateRequest({this.customName});

  factory ImportTemplateRequest.fromJson(Map<String, dynamic> json) {
    return ImportTemplateRequest(customName: json['custom_name'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'custom_name': customName};
  }
}

class ImportTemplateResponse {
  final bool success;
  final String message;
  final String importedWorkoutId;
  final String importedWorkoutName;

  ImportTemplateResponse({
    required this.success,
    required this.message,
    required this.importedWorkoutId,
    required this.importedWorkoutName,
  });

  factory ImportTemplateResponse.fromJson(Map<String, dynamic> json) {
    return ImportTemplateResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      importedWorkoutId: json['imported_workout_id'] as String,
      importedWorkoutName: json['imported_workout_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'imported_workout_id': importedWorkoutId,
      'imported_workout_name': importedWorkoutName,
    };
  }
}
