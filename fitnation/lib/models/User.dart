import 'package:fitnation/models/ProfileModel.dart'; // We'll create this next
import 'package:flutter/foundation.dart'; // Import for debugPrint

enum UserRole { user, trainer, admin }

class User {
  final String id;
  final String username;
  final String email;
  // passwordHash should not be in the client-side model
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Profile? profile; // User's profile can be fetched alongside

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
  });

  // Convenience getter for display
  String get displayName => profile?.displayName ?? username;
  String get avatarUrl =>
      profile?.profilePictureUrl ??
      'https://avatar.iran.liara.run/public'; // Provide a default

  factory User.fromJson(Map<String, dynamic> json) {
    // Safe extraction for User fields
    String? userId = json['id'] as String?;
    String? userName = json['username'] as String?;
    String? userEmail = json['email'] as String?;
    String? userRoleString = json['role'] as String?;
    String? userCreatedAtString = json['created_at'] as String?;
    String? userUpdatedAtString = json['updated_at'] as String?;

    Profile? parsedProfile;
    if (json['profile'] != null && json['profile'] is Map<String, dynamic>) {
      parsedProfile = Profile.fromJson(json['profile'] as Map<String, dynamic>);
    } else if (json.containsKey('display_name') || json.containsKey('profile_picture_url')) {
      // Handle flat structure from public feed author
      // These profile fields are derived from the main json map, which represents the author.
      // So, json['id'] here refers to the author's id, json['created_at'] to author's created_at.
      
      String? profileDisplayName = json['display_name'] as String?;
      String? profilePicture = json['profile_picture_url'] as String?;
      double? profileHeightCm = (json['height_cm'] as num?)?.toDouble();
      double? profileWeightKg = (json['weight_kg'] as num?)?.toDouble();
      int? profileAge = json['age'] as int?;
      String? profileGender = json['gender'] as String?;
      String? profileActivityLevel = json['activity_level'] as String?;
      
      // For Profile's own id and userId, we use the author's id.
      // Profile's createdAt/updatedAt can also be derived from author's if not distinct.
      String? profileCreatedAtString = userCreatedAtString; // Assuming profile shares user's creation time
      String? profileUpdatedAtString = userUpdatedAtString; // Assuming profile shares user's update time

      parsedProfile = Profile(
        // Use the already extracted and potentially defaulted user ID for profile's ID fields
        id: userId ?? 'default_profile_id_from_user_${userId ?? "unknown"}', 
        userId: userId ?? 'default_user_id_for_profile_${userId ?? "unknown"}',
        displayName: profileDisplayName, // Already String?
        bio: json['bio'] as String?, // Assuming bio might also be flat
        profilePictureUrl: profilePicture, // Already String?
        fitnessGoals: json['fitness_goals'] as String?, // Assuming fitness_goals might also be flat
        height_cm: profileHeightCm,
        weight_kg: profileWeightKg,
        age: profileAge,
        gender: profileGender,
        activity_level: profileActivityLevel,
        createdAt: (profileCreatedAtString != null && profileCreatedAtString.isNotEmpty)
            ? DateTime.parse(profileCreatedAtString)
            : DateTime.now(), // Default for profile
        updatedAt: (profileUpdatedAtString != null && profileUpdatedAtString.isNotEmpty)
            ? DateTime.parse(profileUpdatedAtString)
            : (profileCreatedAtString != null && profileCreatedAtString.isNotEmpty)
                ? DateTime.parse(profileCreatedAtString) // Fallback to profile's created_at
                : DateTime.now(), // Default for profile
      );
    }

    UserRole role = UserRole.user; // Default role
    if (userRoleString != null && userRoleString.isNotEmpty) {
      try {
        // Attempt to match by name (e.g., "user", "trainer", "admin")
        role = UserRole.values.byName(userRoleString.toLowerCase());
      } catch (e) {
        print('Invalid user role string: $userRoleString. Defaulting to "user". Error: $e');
        // Keep default role UserRole.user
      }
    }

    return User(
      id: userId ?? 'default_user_id',
      username: userName ?? 'default_username',
      email: userEmail ?? 'default_email@example.com',
      role: role,
      createdAt: (userCreatedAtString != null && userCreatedAtString.isNotEmpty)
          ? DateTime.parse(userCreatedAtString)
          : DateTime.now(), // Default for user
      updatedAt: (userUpdatedAtString != null && userUpdatedAtString.isNotEmpty)
          ? DateTime.parse(userUpdatedAtString)
          : (userCreatedAtString != null && userCreatedAtString.isNotEmpty)
              ? DateTime.parse(userCreatedAtString) // Fallback to user's created_at
              : DateTime.now(), // Default for user
      profile: parsedProfile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'profile': profile?.toJson(),
    };
  }
}
