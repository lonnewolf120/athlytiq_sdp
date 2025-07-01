// lib/models/recommended_community.dart
class RecommendedCommunity {
  final String id;
  final String name;
  final String? iconUrl; // URL for the community icon, can be null for placeholders
  final String initials; // Fallback if iconUrl is null
  final String memberCount;
  final String description;
  bool isJoined; // To manage the state of the "Join" button

  RecommendedCommunity({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.initials,
    required this.memberCount,
    required this.description,
    this.isJoined = false,
  });
}