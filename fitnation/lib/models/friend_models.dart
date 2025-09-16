class Friend {
  final String id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final DateTime friendshipDate;

  Friend({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
    required this.friendshipDate,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      username: json['username'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      friendshipDate: DateTime.parse(json['friendship_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'profile_image_url': profileImageUrl,
      'friendship_date': friendshipDate.toIso8601String(),
    };
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    }
    return username;
  }
}

class FriendRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderUsername;
  final String receiverUsername;
  final String? senderFirstName;
  final String? senderLastName;
  final String? senderProfileImageUrl;
  final String status;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderUsername,
    required this.receiverUsername,
    this.senderFirstName,
    this.senderLastName,
    this.senderProfileImageUrl,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      senderUsername: json['sender_username'] as String,
      receiverUsername: json['receiver_username'] as String,
      senderFirstName: json['sender_first_name'] as String?,
      senderLastName: json['sender_last_name'] as String?,
      senderProfileImageUrl: json['sender_profile_image_url'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'sender_username': senderUsername,
      'receiver_username': receiverUsername,
      'sender_first_name': senderFirstName,
      'sender_last_name': senderLastName,
      'sender_profile_image_url': senderProfileImageUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get senderDisplayName {
    if (senderFirstName != null && senderLastName != null) {
      return '$senderFirstName $senderLastName';
    } else if (senderFirstName != null) {
      return senderFirstName!;
    }
    return senderUsername;
  }
}

class UserSearchResult {
  final String id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final String friendshipStatus;

  UserSearchResult({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
    required this.friendshipStatus,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'] as String,
      username: json['username'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      friendshipStatus: json['friendship_status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'profile_image_url': profileImageUrl,
      'friendship_status': friendshipStatus,
    };
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    }
    return username;
  }
}

class FriendRequestCreate {
  final String receiverId;

  FriendRequestCreate({required this.receiverId});

  Map<String, dynamic> toJson() {
    return {
      'receiver_id': receiverId,
    };
  }
}

class FriendRequestAction {
  final String action; // 'accepted' or 'rejected'

  FriendRequestAction({required this.action});

  Map<String, dynamic> toJson() {
    return {
      'action': action,
    };
  }
}
