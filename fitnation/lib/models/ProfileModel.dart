class Profile {
  final String id;
  final String userId;
  final String? displayName; // Added field
  final String? bio;
  final String? profilePictureUrl;
  final String? fitnessGoals;
  final double? height_cm;
  final double? weight_kg;
  final int? age;
  final String? gender;
  final String? activity_level; // New field for activity level
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.userId,
    this.displayName,
    this.bio,
    this.profilePictureUrl,
    this.fitnessGoals,
    this.height_cm,
    this.weight_kg,
    this.age,
    this.gender,
    this.activity_level,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    // Safe extraction for Profile fields
    String? profileId = json['id'] as String?;
    String? profileUserId = json['user_id'] as String?;
    String? profileDisplayName = json['display_name'] as String?;
    String? profileBio = json['bio'] as String?;
    String? profilePicture = json['profile_picture_url'] as String?;
    String? profileFitnessGoals = json['fitness_goals'] as String?;
    double? profileHeightCm = (json['height_cm'] as num?)?.toDouble();
    double? profileWeightKg = (json['weight_kg'] as num?)?.toDouble();
    int? profileAge = json['age'] as int?;
    String? profileGender = json['gender'] as String?;
    String? profileActivityLevel = json['activity_level'] as String?;
    String? profileCreatedAtString = json['created_at'] as String?;
    String? profileUpdatedAtString = json['updated_at'] as String?;

    return Profile(
      id: profileId ?? 'default_profile_id',
      userId: profileUserId ?? 'default_user_id_for_profile',
      displayName: profileDisplayName, // Already String?
      bio: profileBio, // Already String?
      profilePictureUrl: profilePicture, // Already String?
      fitnessGoals: profileFitnessGoals, // Already String?
      height_cm: profileHeightCm,
      weight_kg: profileWeightKg,
      age: profileAge,
      gender: profileGender,
      activity_level: profileActivityLevel,
      createdAt: (profileCreatedAtString != null && profileCreatedAtString.isNotEmpty)
          ? DateTime.parse(profileCreatedAtString)
          : DateTime.now(), // Default for profile createdAt
      updatedAt: (profileUpdatedAtString != null && profileUpdatedAtString.isNotEmpty)
          ? DateTime.parse(profileUpdatedAtString)
          : (profileCreatedAtString != null && profileCreatedAtString.isNotEmpty)
              ? DateTime.parse(profileCreatedAtString) // Fallback to profile's created_at
              : DateTime.now(), // Default for profile updatedAt
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'display_name': displayName,
      'bio': bio,
      'profile_picture_url': profilePictureUrl,
      'fitness_goals': fitnessGoals,
      'height_cm': height_cm,
      'weight_kg': weight_kg,
      'age': age,
      'gender': gender,
      'activity_level': activity_level,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
