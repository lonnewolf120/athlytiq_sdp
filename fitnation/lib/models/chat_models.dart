class ChatRoom {
  final String id;
  final String name;
  final String type; // 'direct' or 'group'
  final String? description;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final List<ChatParticipant> participants;

  ChatRoom({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessage,
    this.lastMessageSenderId,
    required this.participants,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      lastMessage: json['last_message'] as String?,
      lastMessageSenderId: json['last_message_sender_id'] as String?,
      participants: (json['participants'] as List<dynamic>)
          .map((p) => ChatParticipant.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'last_message': lastMessage,
      'last_message_sender_id': lastMessageSenderId,
      'participants': participants.map((p) => p.toJson()).toList(),
    };
  }
}

class ChatParticipant {
  final String id;
  final String userId;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final String role;
  final DateTime joinedAt;

  ChatParticipant({
    required this.id,
    required this.userId,
    required this.username,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
    required this.role,
    required this.joinedAt,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'profile_image_url': profileImageUrl,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
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

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderUsername;
  final String? senderFirstName;
  final String? senderLastName;
  final String? senderProfileImageUrl;
  final String content;
  final String messageType;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderUsername,
    this.senderFirstName,
    this.senderLastName,
    this.senderProfileImageUrl,
    required this.content,
    required this.messageType,
    required this.createdAt,
    this.editedAt,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      chatRoomId: json['chat_room_id'] as String,
      senderId: json['sender_id'] as String,
      senderUsername: json['sender_username'] as String,
      senderFirstName: json['sender_first_name'] as String?,
      senderLastName: json['sender_last_name'] as String?,
      senderProfileImageUrl: json['sender_profile_image_url'] as String?,
      content: json['content'] as String,
      messageType: json['message_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'] as String)
          : null,
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'sender_username': senderUsername,
      'sender_first_name': senderFirstName,
      'sender_last_name': senderLastName,
      'sender_profile_image_url': senderProfileImageUrl,
      'content': content,
      'message_type': messageType,
      'created_at': createdAt.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
      'is_read': isRead,
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

class ChatRoomCreate {
  final String name;
  final String type;
  final String? description;
  final List<String> participantIds;

  ChatRoomCreate({
    required this.name,
    required this.type,
    this.description,
    required this.participantIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'description': description,
      'participant_ids': participantIds,
    };
  }
}

class ChatMessageCreate {
  final String content;
  final String messageType;

  ChatMessageCreate({
    required this.content,
    this.messageType = 'text',
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'message_type': messageType,
    };
  }
}
