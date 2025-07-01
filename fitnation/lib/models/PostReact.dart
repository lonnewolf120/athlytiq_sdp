class PostReact {
  final String postId;
  final String userId;
  final DateTime createdAt;
  final String reactType;
  final String? emoji;

  PostReact({
    required this.postId,
    required this.userId,
    required this.createdAt,
    required this.reactType,
    this.emoji,
  });

  factory PostReact.fromJson(Map<String, dynamic> json) {
    return PostReact(
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      reactType: json['react_type'] as String,
      emoji: json['emoji'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'react_type': reactType,
      'emoji': emoji,
    };
  }

  @override
  String toString() {
    return 'PostReact{postId: $postId, userId: $userId, createdAt: $createdAt, reactType: $reactType, emoji: $emoji}';
  }
}