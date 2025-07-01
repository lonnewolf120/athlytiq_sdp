import 'package:fitnation/models/User.dart';

enum CommunityMemberRole { member, moderator, admin }

class Community {
  final String id;
  final String creatorUserId;
  final User? creator; // Optionally fetch full User object
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<User>? members; // List of users in the community
  final int? memberCount; // Could be fetched or derived

  Community({
    required this.id,
    required this.creatorUserId,
    this.creator,
    required this.name,
    this.description,
    this.imageUrl,
    required this.isPrivate,
    required this.createdAt,
    required this.updatedAt,
    this.members,
    this.memberCount,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String,
      creatorUserId: json['creator_user_id'] as String,
      creator:
          json['creator'] != null
              ? User.fromJson(json['creator'] as Map<String, dynamic>)
              : null,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isPrivate: json['is_private'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      members:
          (json['members'] as List<dynamic>?)
              ?.map((m) => User.fromJson(m as Map<String, dynamic>))
              .toList(),
      memberCount:
          json['member_count'] as int? ??
          (json['members'] as List<dynamic>?)?.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_user_id': creatorUserId,
      'creator': creator?.toJson(),
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'is_private': isPrivate,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'members': members?.map((m) => m.toJson()).toList(),
      'member_count': memberCount,
    };
  }
}
