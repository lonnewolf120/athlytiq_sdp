class Challenge {
  final String id;
  final String title;
  final String description;
  final String? brand;
  final String? brandLogo;
  final String? backgroundImage;
  final double? distance;
  final int? duration;
  final DateTime startDate;
  final DateTime endDate;
  final String activityType;
  final String status;
  final String? brandColor;
  final int? maxParticipants;
  final bool isPublic;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int friendsJoined;
  final bool isJoined;
  final String? creatorUsername;
  final List<ChallengeParticipant>? participants;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    this.brand,
    this.brandLogo,
    this.backgroundImage,
    this.distance,
    this.duration,
    required this.startDate,
    required this.endDate,
    required this.activityType,
    required this.status,
    this.brandColor,
    this.maxParticipants,
    required this.isPublic,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.friendsJoined,
    required this.isJoined,
    this.creatorUsername,
    this.participants,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      brand: json['brand'],
      brandLogo: json['brand_logo'],
      backgroundImage: json['background_image'],
      distance: _parseDistance(json['distance']),
      duration: _parseDuration(json['duration']),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      activityType: json['activity_type'],
      status: json['status'],
      brandColor: json['brand_color'],
      maxParticipants: json['max_participants'],
      isPublic: json['is_public'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      friendsJoined: json['friends_joined'] ?? 0,
      isJoined: json['is_joined'] ?? false,
      creatorUsername: json['creator_username'],
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((p) => ChallengeParticipant.fromJson(p))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'brand': brand,
      'brand_logo': brandLogo,
      'background_image': backgroundImage,
      'distance': distance,
      'duration': duration,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'activity_type': activityType,
      'status': status,
      'brand_color': brandColor,
      'max_participants': maxParticipants,
      'is_public': isPublic,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'friends_joined': friendsJoined,
      'is_joined': isJoined,
      'creator_username': creatorUsername,
      'participants': participants?.map((p) => p.toJson()).toList(),
    };
  }

  
  static double? _parseDistance(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      
      String cleanValue = value.toLowerCase()
          .replaceAll('km', '')
          .replaceAll('mi', '')
          .replaceAll('miles', '')
          .replaceAll('kilometers', '')
          .trim();
      return double.tryParse(cleanValue);
    }
    return null;
  }

  
  static int? _parseDuration(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) {
      
      String cleanValue = value.toLowerCase()
          .replaceAll('days', '')
          .replaceAll('day', '')
          .replaceAll('weeks', '')
          .replaceAll('week', '')
          .trim();
      return int.tryParse(cleanValue);
    }
    return null;
  }
}

class ChallengeParticipant {
  final String id;
  final String challengeId;
  final String userId;
  final String status;
  final double progress;
  final double progressPercentage;
  final String? completionProofUrl;
  final DateTime joinedAt;
  final DateTime? completedAt;
  final String? notes;
  final String? username;

  ChallengeParticipant({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.status,
    required this.progress,
    required this.progressPercentage,
    this.completionProofUrl,
    required this.joinedAt,
    this.completedAt,
    this.notes,
    this.username,
  });

  factory ChallengeParticipant.fromJson(Map<String, dynamic> json) {
    return ChallengeParticipant(
      id: json['id'],
      challengeId: json['challenge_id'],
      userId: json['user_id'],
      status: json['status'],
      progress: json['progress']?.toDouble() ?? 0.0,
      progressPercentage: json['progress_percentage']?.toDouble() ?? 0.0,
      completionProofUrl: json['completion_proof_url'],
      joinedAt: DateTime.parse(json['joined_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      notes: json['notes'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challenge_id': challengeId,
      'user_id': userId,
      'status': status,
      'progress': progress,
      'progress_percentage': progressPercentage,
      'completion_proof_url': completionProofUrl,
      'joined_at': joinedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
      'username': username,
    };
  }
}

class ChallengeListResponse {
  final List<Challenge> challenges;
  final int total;
  final int page;
  final int size;
  final bool hasNext;
  final bool hasPrev;

  ChallengeListResponse({
    required this.challenges,
    required this.total,
    required this.page,
    required this.size,
    required this.hasNext,
    required this.hasPrev,
  });

  factory ChallengeListResponse.fromJson(Map<String, dynamic> json) {
    return ChallengeListResponse(
      challenges: (json['challenges'] as List)
          .map((c) => Challenge.fromJson(c))
          .toList(),
      total: json['total'],
      page: json['page'],
      size: json['size'],
      hasNext: json['has_next'],
      hasPrev: json['has_prev'],
    );
  }
}

class ChallengeCreate {
  final String title;
  final String description;
  final String brand;
  final String? brandLogo;
  final String? backgroundImage;
  final String distance;
  final String duration;
  final DateTime startDate;
  final DateTime endDate;
  final String activityType;
  final String? brandColor;
  final int? maxParticipants;
  final bool isPublic;

  ChallengeCreate({
    required this.title,
    required this.description,
    required this.brand,
    this.brandLogo,
    this.backgroundImage,
    required this.distance,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.activityType,
    this.brandColor,
    this.maxParticipants,
    this.isPublic = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'brand': brand,
      'brand_logo': brandLogo,
      'background_image': backgroundImage,
      'distance': distance,
      'duration': duration,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'activity_type': activityType,
      'brand_color': brandColor,
      'max_participants': maxParticipants,
      'is_public': isPublic,
    };
  }
}


enum ActivityTypeEnum {
  run('run'),
  ride('ride'),
  swim('swim'),
  walk('walk'),
  hike('hike'),
  workout('workout');

  const ActivityTypeEnum(this.value);
  final String value;
}

enum ChallengeStatusEnum {
  draft('draft'),
  active('active'),
  completed('completed'),
  cancelled('cancelled');

  const ChallengeStatusEnum(this.value);
  final String value;
}

enum ParticipantStatusEnum {
  joined('joined'),
  completed('completed'),
  left('left');

  const ParticipantStatusEnum(this.value);
  final String value;
}
