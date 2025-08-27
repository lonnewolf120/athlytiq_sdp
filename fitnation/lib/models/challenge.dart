import 'package:flutter/material.dart';

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
  final Color? brandColor;
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
      brandColor: json['brand_color'] != null ? _parseHexColor(json['brand_color']) : null,
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
      'brand_color': brandColor != null ? _colorToHex(brandColor!) : null,
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

  // Factory method to create Challenge from backend data (similar to old Challenge)
  factory Challenge.fromBackendChallenge(Challenge backendChallenge) {
    return Challenge(
      id: backendChallenge.id,
      title: backendChallenge.title,
      description: backendChallenge.description,
      brand: backendChallenge.brand ?? 'FitNation',
      brandLogo: _getActivityEmoji(backendChallenge.activityType),
      backgroundImage: backendChallenge.backgroundImage ?? 'https://images.unsplash.com/photo-1590333748338-d629e4564ad9?q=80&w=1249&auto=format&fit=crop',
      distance: backendChallenge.distance,
      duration: backendChallenge.duration,
      startDate: backendChallenge.startDate,
      endDate: backendChallenge.endDate,
      activityType: backendChallenge.activityType,
      status: backendChallenge.status,
      brandColor: _getActivityColor(backendChallenge.activityType),
      maxParticipants: backendChallenge.maxParticipants,
      isPublic: backendChallenge.isPublic,
      createdBy: backendChallenge.createdBy,
      createdAt: backendChallenge.createdAt,
      updatedAt: backendChallenge.updatedAt,
      friendsJoined: backendChallenge.friendsJoined,
      isJoined: backendChallenge.isJoined,
      creatorUsername: backendChallenge.creatorUsername,
      participants: backendChallenge.participants,
    );
  }

  // Factory method to create Challenge with Color object (converts to hex for storage)
  factory Challenge.withColor({
    required String id,
    required String title,
    required String description,
    String? brand,
    String? brandLogo,
    String? backgroundImage,
    double? distance,
    int? duration,
    required DateTime startDate,
    required DateTime endDate,
    required String activityType,
    required String status,
    Color? brandColorObject, // Accept Color object
    int? maxParticipants,
    required bool isPublic,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int friendsJoined,
    required bool isJoined,
    String? creatorUsername,
    List<ChallengeParticipant>? participants,
  }) {
    return Challenge(
      id: id,
      title: title,
      description: description,
      brand: brand,
      brandLogo: brandLogo,
      backgroundImage: backgroundImage,
      distance: distance,
      duration: duration,
      startDate: startDate,
      endDate: endDate,
      activityType: activityType,
      status: status,
      brandColor: brandColorObject,
      maxParticipants: maxParticipants,
      isPublic: isPublic,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      friendsJoined: friendsJoined,
      isJoined: isJoined,
      creatorUsername: creatorUsername,
      participants: participants,
    );
  }

  // Computed properties for UI display (similar to old Challenge)
  String get formattedDistance => distance != null ? '${distance!.toStringAsFixed(1)} km' : '0 km';
  
  String get formattedDuration => '${_formatDate(startDate)} to ${_formatDate(endDate)}';
  
  Color get brandColorAsColor => brandColor ?? _getActivityColor(activityType);
  
  String get activityEmoji => _getActivityEmoji(activityType);
  
  String get capitalizedActivityType => _capitalizeFirst(activityType);

  // Get hex string representation of brand color
  String? get brandColorHex => brandColor != null ? _colorToHex(brandColor!) : null;

  // Method to create a copy with updated brand color from Color object
  Challenge copyWithBrandColor(Color color) {
    return Challenge(
      id: id,
      title: title,
      description: description,
      brand: brand,
      brandLogo: brandLogo,
      backgroundImage: backgroundImage,
      distance: distance,
      duration: duration,
      startDate: startDate,
      endDate: endDate,
      activityType: activityType,
      status: status,
      brandColor: color,
      maxParticipants: maxParticipants,
      isPublic: isPublic,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      friendsJoined: friendsJoined,
      isJoined: isJoined,
      creatorUsername: creatorUsername,
      participants: participants,
    );
  }

  // Helper methods from old Challenge class
  static String _getActivityEmoji(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'run': return '🏃';
      case 'ride': return '🚴';
      case 'swim': return '🏊';
      case 'walk': return '🚶';
      case 'hike': return '⛰️';
      case 'workout': return '💪';
      default: return '🏃';
    }
  }

  static Color _getActivityColor(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'run': return Colors.orange;
      case 'ride': return Colors.blue;
      case 'swim': return Colors.cyan;
      case 'walk': return Colors.purple;
      case 'hike': return Colors.green;
      case 'workout': return Colors.red;
      default: return Colors.orange;
    }
  }

  // Helper methods for hex color conversion
  static Color _parseHexColor(String hexColor) {
    String hex = hexColor.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha channel if not present
    }
    return Color(int.parse(hex, radix: 16));
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  static String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  static String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
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
  final double distance;
  final int duration;
  final DateTime startDate;
  final DateTime endDate;
  final String activityType;
  final Color? brandColor;
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
      'brand_color': brandColor != null ? Challenge._colorToHex(brandColor!) : null,
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
