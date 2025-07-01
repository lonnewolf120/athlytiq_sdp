import 'package:fitnation/models/Community.dart'; // For CommunityMemberRole enum

class CommunityMember {
  final String communityId;
  final String userId;
  final CommunityMemberRole role;
  final DateTime joinedAt;

  CommunityMember({
    required this.communityId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    return CommunityMember(
      communityId: json['community_id'] as String,
      userId: json['user_id'] as String,
      role: CommunityMemberRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => CommunityMemberRole.member,
      ),
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'community_id': communityId,
      'user_id': userId,
      'role': role.toString().split('.').last,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
