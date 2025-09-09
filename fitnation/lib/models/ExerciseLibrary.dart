// Enhanced Exercise Library Models for Fitnation App

class ExerciseCategory {
  final String id;
  final String name;
  final String? description;
  final String? colorCode;
  final String? iconName;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExerciseCategory({
    required this.id,
    required this.name,
    this.description,
    this.colorCode,
    this.iconName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExerciseCategory.fromJson(Map<String, dynamic> json) {
    return ExerciseCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      colorCode: json['color_code'] as String?,
      iconName: json['icon_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (colorCode != null) 'color_code': colorCode,
      if (iconName != null) 'icon_name': iconName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class MuscleGroup {
  final String id;
  final String name;
  final String groupType; // primary, secondary, stabilizer
  final String? parentId;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MuscleGroup> children;

  MuscleGroup({
    required this.id,
    required this.name,
    required this.groupType,
    this.parentId,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.children = const [],
  });

  factory MuscleGroup.fromJson(Map<String, dynamic> json) {
    return MuscleGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      groupType: json['group_type'] as String,
      parentId: json['parent_id'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      children:
          (json['children'] as List<dynamic>?)
              ?.map(
                (child) => MuscleGroup.fromJson(child as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'group_type': groupType,
      if (parentId != null) 'parent_id': parentId,
      if (description != null) 'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'children': children.map((child) => child.toJson()).toList(),
    };
  }
}

class EquipmentType {
  final String id;
  final String name;
  final String? category;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  EquipmentType({
    required this.id,
    required this.name,
    this.category,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EquipmentType.fromJson(Map<String, dynamic> json) {
    return EquipmentType(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ExerciseMuscleGroup {
  final String id;
  final String muscleGroupId;
  final bool isPrimary;
  final int? activationLevel; // 1-5 scale
  final MuscleGroup muscleGroup;

  ExerciseMuscleGroup({
    required this.id,
    required this.muscleGroupId,
    required this.isPrimary,
    this.activationLevel,
    required this.muscleGroup,
  });

  factory ExerciseMuscleGroup.fromJson(Map<String, dynamic> json) {
    return ExerciseMuscleGroup(
      id: json['id'] as String,
      muscleGroupId: json['muscle_group_id'] as String,
      isPrimary: json['is_primary'] as bool,
      activationLevel: json['activation_level'] as int?,
      muscleGroup: MuscleGroup.fromJson(
        json['muscle_group'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'muscle_group_id': muscleGroupId,
      'is_primary': isPrimary,
      if (activationLevel != null) 'activation_level': activationLevel,
      'muscle_group': muscleGroup.toJson(),
    };
  }
}

class ExerciseEquipment {
  final String id;
  final String equipmentId;
  final bool isRequired;
  final bool isAlternative;
  final EquipmentType equipment;

  ExerciseEquipment({
    required this.id,
    required this.equipmentId,
    required this.isRequired,
    required this.isAlternative,
    required this.equipment,
  });

  factory ExerciseEquipment.fromJson(Map<String, dynamic> json) {
    return ExerciseEquipment(
      id: json['id'] as String,
      equipmentId: json['equipment_id'] as String,
      isRequired: json['is_required'] as bool,
      isAlternative: json['is_alternative'] as bool,
      equipment: EquipmentType.fromJson(
        json['equipment'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipment_id': equipmentId,
      'is_required': isRequired,
      'is_alternative': isAlternative,
      'equipment': equipment.toJson(),
    };
  }
}

class ExerciseVariation {
  final String id;
  final String variationExerciseId;
  final String? variationType; // easier, harder, alternative, progression
  final String? notes;
  final ExerciseLibrary variationExercise;

  ExerciseVariation({
    required this.id,
    required this.variationExerciseId,
    this.variationType,
    this.notes,
    required this.variationExercise,
  });

  factory ExerciseVariation.fromJson(Map<String, dynamic> json) {
    return ExerciseVariation(
      id: json['id'] as String,
      variationExerciseId: json['variation_exercise_id'] as String,
      variationType: json['variation_type'] as String?,
      notes: json['notes'] as String?,
      variationExercise: ExerciseLibrary.fromJson(
        json['variation_exercise'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'variation_exercise_id': variationExerciseId,
      if (variationType != null) 'variation_type': variationType,
      if (notes != null) 'notes': notes,
      'variation_exercise': variationExercise.toJson(),
    };
  }
}

class ExerciseLibrary {
  final String id;
  final String name;
  final String? description;
  final String? instructions;
  final String? formTips;
  final String? gifUrl;
  final String? videoUrl;
  final String? categoryId;
  final int? difficultyLevel; // 1-5 scale
  final double popularityScore; // 0.0-5.0
  final bool isCompound;
  final bool isUnilateral;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relationships
  final ExerciseCategory? category;
  final List<ExerciseMuscleGroup> muscleGroups;
  final List<ExerciseEquipment> equipment;
  final List<ExerciseVariation> variationsAsBase;

  ExerciseLibrary({
    required this.id,
    required this.name,
    this.description,
    this.instructions,
    this.formTips,
    this.gifUrl,
    this.videoUrl,
    this.categoryId,
    this.difficultyLevel,
    this.popularityScore = 0.0,
    this.isCompound = false,
    this.isUnilateral = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.muscleGroups = const [],
    this.equipment = const [],
    this.variationsAsBase = const [],
  });

  factory ExerciseLibrary.fromJson(Map<String, dynamic> json) {
    return ExerciseLibrary(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      instructions: json['instructions'] as String?,
      formTips: json['form_tips'] as String?,
      gifUrl: json['gif_url'] as String?,
      videoUrl: json['video_url'] as String?,
      categoryId: json['category_id'] as String?,
      difficultyLevel: json['difficulty_level'] as int?,
      popularityScore: (json['popularity_score'] as num?)?.toDouble() ?? 0.0,
      isCompound: json['is_compound'] as bool? ?? false,
      isUnilateral: json['is_unilateral'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category:
          json['category'] != null
              ? ExerciseCategory.fromJson(
                json['category'] as Map<String, dynamic>,
              )
              : null,
      muscleGroups:
          (json['muscle_groups'] as List<dynamic>?)
              ?.map(
                (mg) =>
                    ExerciseMuscleGroup.fromJson(mg as Map<String, dynamic>),
              )
              .toList() ??
          [],
      equipment:
          (json['equipment'] as List<dynamic>?)
              ?.map(
                (eq) => ExerciseEquipment.fromJson(eq as Map<String, dynamic>),
              )
              .toList() ??
          [],
      variationsAsBase:
          (json['variations_as_base'] as List<dynamic>?)
              ?.map(
                (variation) => ExerciseVariation.fromJson(
                  variation as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (instructions != null) 'instructions': instructions,
      if (formTips != null) 'form_tips': formTips,
      if (gifUrl != null) 'gif_url': gifUrl,
      if (videoUrl != null) 'video_url': videoUrl,
      if (categoryId != null) 'category_id': categoryId,
      if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
      'popularity_score': popularityScore,
      'is_compound': isCompound,
      'is_unilateral': isUnilateral,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (category != null) 'category': category!.toJson(),
      'muscle_groups': muscleGroups.map((mg) => mg.toJson()).toList(),
      'equipment': equipment.map((eq) => eq.toJson()).toList(),
      'variations_as_base':
          variationsAsBase.map((variation) => variation.toJson()).toList(),
    };
  }

  // Helper methods for UI
  List<String> get primaryMuscleGroupNames {
    return muscleGroups
        .where((mg) => mg.isPrimary)
        .map((mg) => mg.muscleGroup.name)
        .toList();
  }

  List<String> get secondaryMuscleGroupNames {
    return muscleGroups
        .where((mg) => !mg.isPrimary)
        .map((mg) => mg.muscleGroup.name)
        .toList();
  }

  List<String> get requiredEquipmentNames {
    return equipment
        .where((eq) => eq.isRequired)
        .map((eq) => eq.equipment.name)
        .toList();
  }

  List<String> get alternativeEquipmentNames {
    return equipment
        .where((eq) => eq.isAlternative)
        .map((eq) => eq.equipment.name)
        .toList();
  }

  String get difficultyText {
    switch (difficultyLevel) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Easy';
      case 3:
        return 'Intermediate';
      case 4:
        return 'Hard';
      case 5:
        return 'Expert';
      default:
        return 'Unknown';
    }
  }

  String get categoryName => category?.name ?? 'Uncategorized';

  String get displayName => name;

  String get primaryEquipment =>
      requiredEquipmentNames.isNotEmpty
          ? requiredEquipmentNames.first
          : 'Body Weight';
}

// --- Search and Filter Models ---

class ExerciseSearchFilters {
  final String? searchQuery;
  final List<String> categoryIds;
  final List<String> muscleGroupIds;
  final List<String> equipmentIds;
  final List<int> difficultyLevels;
  final bool? isCompound;
  final bool? isUnilateral;
  final double? minPopularity;
  final bool equipmentRequiredOnly;

  ExerciseSearchFilters({
    this.searchQuery,
    this.categoryIds = const [],
    this.muscleGroupIds = const [],
    this.equipmentIds = const [],
    this.difficultyLevels = const [],
    this.isCompound,
    this.isUnilateral,
    this.minPopularity,
    this.equipmentRequiredOnly = false,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['q'] = searchQuery;
    }

    if (categoryIds.isNotEmpty) {
      params['categories'] = categoryIds;
    }

    if (muscleGroupIds.isNotEmpty) {
      params['muscle_groups'] = muscleGroupIds;
    }

    if (equipmentIds.isNotEmpty) {
      params['equipment'] = equipmentIds;
    }

    if (difficultyLevels.isNotEmpty) {
      params['difficulty'] = difficultyLevels;
    }

    if (isCompound != null) {
      params['compound'] = isCompound;
    }

    if (isUnilateral != null) {
      params['unilateral'] = isUnilateral;
    }

    if (minPopularity != null) {
      params['min_popularity'] = minPopularity;
    }

    return params;
  }

  ExerciseSearchFilters copyWith({
    String? searchQuery,
    List<String>? categoryIds,
    List<String>? muscleGroupIds,
    List<String>? equipmentIds,
    List<int>? difficultyLevels,
    bool? isCompound,
    bool? isUnilateral,
    double? minPopularity,
    bool? equipmentRequiredOnly,
  }) {
    return ExerciseSearchFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryIds: categoryIds ?? this.categoryIds,
      muscleGroupIds: muscleGroupIds ?? this.muscleGroupIds,
      equipmentIds: equipmentIds ?? this.equipmentIds,
      difficultyLevels: difficultyLevels ?? this.difficultyLevels,
      isCompound: isCompound ?? this.isCompound,
      isUnilateral: isUnilateral ?? this.isUnilateral,
      minPopularity: minPopularity ?? this.minPopularity,
      equipmentRequiredOnly:
          equipmentRequiredOnly ?? this.equipmentRequiredOnly,
    );
  }
}

class ExerciseSearchResponse {
  final List<ExerciseLibrary> exercises;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  ExerciseSearchResponse({
    required this.exercises,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory ExerciseSearchResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseSearchResponse(
      exercises:
          (json['exercises'] as List<dynamic>)
              .map((ex) => ExerciseLibrary.fromJson(ex as Map<String, dynamic>))
              .toList(),
      totalCount: json['total_count'] as int,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      totalPages: json['total_pages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercises': exercises.map((ex) => ex.toJson()).toList(),
      'total_count': totalCount,
      'page': page,
      'page_size': pageSize,
      'total_pages': totalPages,
    };
  }
}

// --- Quick Selection Models for Workout Creation ---

class ExerciseQuickSelect {
  final String id;
  final String name;
  final String? category;
  final int? difficultyLevel;
  final List<String> primaryMuscleGroups;
  final List<String> equipmentRequired;
  final bool isCompound;

  ExerciseQuickSelect({
    required this.id,
    required this.name,
    this.category,
    this.difficultyLevel,
    this.primaryMuscleGroups = const [],
    this.equipmentRequired = const [],
    this.isCompound = false,
  });

  factory ExerciseQuickSelect.fromJson(Map<String, dynamic> json) {
    return ExerciseQuickSelect(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      difficultyLevel: json['difficulty_level'] as int?,
      primaryMuscleGroups:
          (json['primary_muscle_groups'] as List<dynamic>?)
              ?.map((mg) => mg as String)
              .toList() ??
          [],
      equipmentRequired:
          (json['equipment_required'] as List<dynamic>?)
              ?.map((eq) => eq as String)
              .toList() ??
          [],
      isCompound: json['is_compound'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (category != null) 'category': category,
      if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
      'primary_muscle_groups': primaryMuscleGroups,
      'equipment_required': equipmentRequired,
      'is_compound': isCompound,
    };
  }
}

class ExerciseQuickSelectResponse {
  final List<ExerciseQuickSelect> exercises;
  final List<ExerciseCategory> categories;
  final List<MuscleGroup> muscleGroups;
  final List<EquipmentType> equipmentTypes;

  ExerciseQuickSelectResponse({
    required this.exercises,
    required this.categories,
    required this.muscleGroups,
    required this.equipmentTypes,
  });

  factory ExerciseQuickSelectResponse.fromJson(Map<String, dynamic> json) {
    return ExerciseQuickSelectResponse(
      exercises:
          (json['exercises'] as List<dynamic>)
              .map(
                (ex) =>
                    ExerciseQuickSelect.fromJson(ex as Map<String, dynamic>),
              )
              .toList(),
      categories:
          (json['categories'] as List<dynamic>)
              .map(
                (cat) => ExerciseCategory.fromJson(cat as Map<String, dynamic>),
              )
              .toList(),
      muscleGroups:
          (json['muscle_groups'] as List<dynamic>)
              .map((mg) => MuscleGroup.fromJson(mg as Map<String, dynamic>))
              .toList(),
      equipmentTypes:
          (json['equipment_types'] as List<dynamic>)
              .map((et) => EquipmentType.fromJson(et as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercises': exercises.map((ex) => ex.toJson()).toList(),
      'categories': categories.map((cat) => cat.toJson()).toList(),
      'muscle_groups': muscleGroups.map((mg) => mg.toJson()).toList(),
      'equipment_types': equipmentTypes.map((et) => et.toJson()).toList(),
    };
  }
}
