class ChallengePostData {
  final String title;
  final String description;
  final DateTime startDate;
  final int durationDays;
  final String? coverImageUrl;
  final int participantCount; // Maybe fetched or derived
  // final List<String>? invitedUserIds; // If storing invites

  ChallengePostData({
    required this.title,
    required this.description,
    required this.startDate,
    required this.durationDays,
    this.coverImageUrl,
    this.participantCount = 0, // Default or fetch
    // this.invitedUserIds,
  });

  factory ChallengePostData.fromJson(Map<String, dynamic> json) {
    return ChallengePostData(
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      durationDays: json['duration_days'] as int,
      coverImageUrl: json['cover_image_url'] as String?,
      participantCount: json['participant_count'] as int? ?? 0,
      // invitedUserIds: (json['invited_user_ids'] as List<dynamic>?)?.map((id) => id as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'duration_days': durationDays,
      'cover_image_url': coverImageUrl,
      'participant_count': participantCount,
      // 'invited_user_ids': invitedUserIds,
    };
  }
}
