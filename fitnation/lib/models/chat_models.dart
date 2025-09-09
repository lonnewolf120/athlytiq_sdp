// Enums
enum ChatRoomType { direct, group }

enum MessageType { text, image, video, audio, file, location, workout, system }

enum FriendRequestStatus { pending, accepted, rejected, blocked }

enum WebSocketMessageType {
  connectionEstablished,
  newMessage,
  messageSent,
  messageReadReceipt,
  typingIndicator,
  userStatusChange,
  friendRequestReceived,
  friendRequestResponded,
  roomJoined,
  roomLeft,
  error,
  ping,
  pong
}

// Chat Models
class ChatRoom {
  final String id;
  final ChatRoomType type;
  final String? name;
  final String? description;
  final String? imageUrl;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;
  final String? lastMessageContent;
  final String? lastMessageSenderId;
  final bool isArchived;
  final int unreadCount;
  final bool isMuted;
  final bool isPinned;
  final int participantCount;
  final List<ChatParticipant>? participants;

  ChatRoom({
    required this.id,
    required this.type,
    this.name,
    this.description,
    this.imageUrl,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.isArchived = false,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
    this.participantCount = 0,
    this.participants,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      type: ChatRoomType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ChatRoomType.direct,
      ),
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      lastMessageContent: json['last_message_content'],
      lastMessageSenderId: json['last_message_sender_id'],
      isArchived: json['is_archived'] ?? false,
      unreadCount: json['unread_count'] ?? 0,
      isMuted: json['is_muted'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      participantCount: json['participant_count'] ?? 0,
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((p) => ChatParticipant.fromJson(p))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'last_message_content': lastMessageContent,
      'last_message_sender_id': lastMessageSenderId,
      'is_archived': isArchived,
      'unread_count': unreadCount,
      'is_muted': isMuted,
      'is_pinned': isPinned,
      'participant_count': participantCount,
      'participants': participants?.map((p) => p.toJson()).toList(),
    };
  }

  ChatRoom copyWith({
    String? id,
    ChatRoomType? type,
    String? name,
    String? description,
    String? imageUrl,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastMessageAt,
    String? lastMessageContent,
    String? lastMessageSenderId,
    bool? isArchived,
    int? unreadCount,
    bool? isMuted,
    bool? isPinned,
    int? participantCount,
    List<ChatParticipant>? participants,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      isArchived: isArchived ?? this.isArchived,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
      participantCount: participantCount ?? this.participantCount,
      participants: participants ?? this.participants,
    );
  }

  // Helper methods
  String getDisplayName(String currentUserId) {
    if (type == ChatRoomType.direct) {
      // For direct chats, show the other user's name
      final otherParticipant = participants?.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => participants!.first,
      );
      return otherParticipant?.displayName ?? otherParticipant?.username ?? name ?? 'Direct Chat';
    }
    return name ?? 'Group Chat';
  }

  String? getDisplayImage(String currentUserId) {
    if (type == ChatRoomType.direct) {
      final otherParticipant = participants?.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => participants!.first,
      );
      return otherParticipant?.avatarUrl;
    }
    return imageUrl;
  }
}

class ChatParticipant {
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String role; // 'admin' or 'member'
  final DateTime joinedAt;
  final DateTime? leftAt;
  final DateTime? lastReadAt;
  final int unreadCount;
  final bool isMuted;
  final bool isPinned;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatParticipant({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.role = 'member',
    required this.joinedAt,
    this.leftAt,
    this.lastReadAt,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
    this.isOnline = false,
    this.lastSeen,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      userId: json['user_id'],
      username: json['username'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'member',
      joinedAt: DateTime.parse(json['joined_at']),
      leftAt: json['left_at'] != null ? DateTime.parse(json['left_at']) : null,
      lastReadAt: json['last_read_at'] != null
          ? DateTime.parse(json['last_read_at'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      isMuted: json['is_muted'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'left_at': leftAt?.toIso8601String(),
      'last_read_at': lastReadAt?.toIso8601String(),
      'unread_count': unreadCount,
      'is_muted': isMuted,
      'is_pinned': isPinned,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderDisplayName;
  final String? senderAvatar;
  final MessageType messageType;
  final String? content;
  final List<String>? mediaUrls;
  final Map<String, dynamic>? metadata;
  final String? replyToId;
  final ChatMessage? replyToMessage;
  final String? forwardedFromId;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final bool isReadByCurrentUser;
  final List<MessageReaction> reactions;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderDisplayName,
    this.senderAvatar,
    required this.messageType,
    this.content,
    this.mediaUrls,
    this.metadata,
    this.replyToId,
    this.replyToMessage,
    this.forwardedFromId,
    required this.createdAt,
    this.editedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.isReadByCurrentUser = false,
    this.reactions = const [],
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      senderDisplayName: json['sender_display_name'],
      senderAvatar: json['sender_avatar'],
      messageType: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['message_type'],
        orElse: () => MessageType.text,
      ),
      content: json['content'],
      mediaUrls: json['media_urls']?.cast<String>(),
      metadata: json['metadata'],
      replyToId: json['reply_to_id'],
      replyToMessage: json['reply_to_message'] != null
          ? ChatMessage.fromJson(json['reply_to_message'])
          : null,
      forwardedFromId: json['forwarded_from_id'],
      createdAt: DateTime.parse(json['created_at']),
      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'])
          : null,
      isDeleted: json['is_deleted'] ?? false,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      isReadByCurrentUser: json['is_read_by_current_user'] ?? false,
      reactions: json['reactions'] != null
          ? (json['reactions'] as List)
              .map((r) => MessageReaction.fromJson(r))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_display_name': senderDisplayName,
      'sender_avatar': senderAvatar,
      'message_type': messageType.toString().split('.').last,
      'content': content,
      'media_urls': mediaUrls,
      'metadata': metadata,
      'reply_to_id': replyToId,
      'reply_to_message': replyToMessage?.toJson(),
      'forwarded_from_id': forwardedFromId,
      'created_at': createdAt.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'deleted_at': deletedAt?.toIso8601String(),
      'is_read_by_current_user': isReadByCurrentUser,
      'reactions': reactions.map((r) => r.toJson()).toList(),
    };
  }

  // Helper methods
  bool get isFromCurrentUser => false; // Will be set by the provider based on current user

  String get displayContent {
    if (isDeleted) return 'Message deleted';
    if (content?.isNotEmpty == true) return content!;
    
    switch (messageType) {
      case MessageType.image:
        return '📷 Photo';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.audio:
        return '🎵 Audio';
      case MessageType.file:
        return '📄 File';
      case MessageType.location:
        return '📍 Location';
      case MessageType.workout:
        return '💪 Workout';
      default:
        return content ?? '';
    }
  }
}

class MessageReaction {
  final String id;
  final String messageId;
  final String userId;
  final String username;
  final String emoji;
  final DateTime createdAt;

  MessageReaction({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.username,
    required this.emoji,
    required this.createdAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      id: json['id'],
      messageId: json['message_id'],
      userId: json['user_id'],
      username: json['username'],
      emoji: json['emoji'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_id': messageId,
      'user_id': userId,
      'username': username,
      'emoji': emoji,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Friends Models
class Friend {
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime friendshipSince;
  final String? directChatRoomId;

  Friend({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.isOnline = false,
    this.lastSeen,
    required this.friendshipSince,
    this.directChatRoomId,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      userId: json['user_id'],
      username: json['username'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'])
          : null,
      friendshipSince: DateTime.parse(json['friendship_since']),
      directChatRoomId: json['direct_chat_room_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'friendship_since': friendshipSince.toIso8601String(),
      'direct_chat_room_id': directChatRoomId,
    };
  }

  String get displayNameOrUsername => displayName ?? username;
}

class FriendRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String? message;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final UserSearchResult otherUser;
  final bool isSentByCurrentUser;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    required this.otherUser,
    required this.isSentByCurrentUser,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => FriendRequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at']),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'])
          : null,
      otherUser: UserSearchResult.fromJson(json['other_user']),
      isSentByCurrentUser: json['is_sent_by_current_user'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'other_user': otherUser.toJson(),
      'is_sent_by_current_user': isSentByCurrentUser,
    };
  }
}

class UserSearchResult {
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final bool isOnline;
  final DateTime? lastSeen;
  final String relationshipStatus; // 'friends', 'request_sent', 'request_received', 'blocked', 'none'

  UserSearchResult({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.isOnline = false,
    this.lastSeen,
    this.relationshipStatus = 'none',
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      userId: json['user_id'],
      username: json['username'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'])
          : null,
      relationshipStatus: json['relationship_status'] ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'relationship_status': relationshipStatus,
    };
  }

  String get displayNameOrUsername => displayName ?? username;
}

// WebSocket Models
class WebSocketMessage {
  final WebSocketMessageType type;
  final Map<String, dynamic> data;

  WebSocketMessage({
    required this.type,
    required this.data,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: WebSocketMessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => WebSocketMessageType.error,
      ),
      data: json['data'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'data': data,
    };
  }
}

// Create Message Request Models
class CreateMessageRequest {
  final String roomId;
  final String? content;
  final MessageType messageType;
  final List<String>? mediaUrls;
  final String? replyToId;
  final Map<String, dynamic>? metadata;

  CreateMessageRequest({
    required this.roomId,
    this.content,
    this.messageType = MessageType.text,
    this.mediaUrls,
    this.replyToId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'content': content,
      'message_type': messageType.toString().split('.').last,
      'media_urls': mediaUrls,
      'reply_to_id': replyToId,
      'metadata': metadata,
    };
  }
}

class CreateChatRoomRequest {
  final String? name;
  final String? description;
  final String? imageUrl;
  final List<String> participantIds;

  CreateChatRoomRequest({
    this.name,
    this.description,
    this.imageUrl,
    this.participantIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'participant_ids': participantIds,
    };
  }
}
