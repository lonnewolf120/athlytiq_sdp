// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatRoomImpl _$$ChatRoomImplFromJson(Map<String, dynamic> json) =>
    _$ChatRoomImpl(
      id: json['id'] as String,
      type: $enumDecode(_$ChatRoomTypeEnumMap, json['type']),
      name: json['name'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdBy: json['createdBy'] as String?,
      lastMessageAt:
          json['lastMessageAt'] == null
              ? null
              : DateTime.parse(json['lastMessageAt'] as String),
      lastMessageContent: json['lastMessageContent'] as String?,
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((e) => ChatParticipant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isArchived: json['isArchived'] as bool? ?? false,
      totalMessages: (json['totalMessages'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ChatRoomImplToJson(_$ChatRoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ChatRoomTypeEnumMap[instance.type]!,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'createdBy': instance.createdBy,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'lastMessageContent': instance.lastMessageContent,
      'lastMessageSenderId': instance.lastMessageSenderId,
      'participants': instance.participants,
      'unreadCount': instance.unreadCount,
      'isArchived': instance.isArchived,
      'totalMessages': instance.totalMessages,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$ChatRoomTypeEnumMap = {
  ChatRoomType.direct: 'direct',
  ChatRoomType.group: 'group',
};

_$ChatParticipantImpl _$$ChatParticipantImplFromJson(
  Map<String, dynamic> json,
) => _$ChatParticipantImpl(
  userId: json['userId'] as String,
  username: json['username'] as String,
  displayName: json['displayName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  role: $enumDecode(_$ParticipantRoleEnumMap, json['role']),
  joinedAt: DateTime.parse(json['joinedAt'] as String),
  leftAt:
      json['leftAt'] == null ? null : DateTime.parse(json['leftAt'] as String),
  lastReadAt:
      json['lastReadAt'] == null
          ? null
          : DateTime.parse(json['lastReadAt'] as String),
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  isMuted: json['isMuted'] as bool? ?? false,
  isPinned: json['isPinned'] as bool? ?? false,
  isOnline: json['isOnline'] as bool? ?? false,
  lastSeen:
      json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
);

Map<String, dynamic> _$$ChatParticipantImplToJson(
  _$ChatParticipantImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'displayName': instance.displayName,
  'avatarUrl': instance.avatarUrl,
  'role': _$ParticipantRoleEnumMap[instance.role]!,
  'joinedAt': instance.joinedAt.toIso8601String(),
  'leftAt': instance.leftAt?.toIso8601String(),
  'lastReadAt': instance.lastReadAt?.toIso8601String(),
  'unreadCount': instance.unreadCount,
  'isMuted': instance.isMuted,
  'isPinned': instance.isPinned,
  'isOnline': instance.isOnline,
  'lastSeen': instance.lastSeen?.toIso8601String(),
};

const _$ParticipantRoleEnumMap = {
  ParticipantRole.admin: 'admin',
  ParticipantRole.member: 'member',
};

_$ChatRoomCreateImpl _$$ChatRoomCreateImplFromJson(Map<String, dynamic> json) =>
    _$ChatRoomCreateImpl(
      type: $enumDecode(_$ChatRoomTypeEnumMap, json['type']),
      name: json['name'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      participantIds:
          (json['participantIds'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$$ChatRoomCreateImplToJson(
  _$ChatRoomCreateImpl instance,
) => <String, dynamic>{
  'type': _$ChatRoomTypeEnumMap[instance.type]!,
  'name': instance.name,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'participantIds': instance.participantIds,
};

_$ChatMessageImpl _$$ChatMessageImplFromJson(
  Map<String, dynamic> json,
) => _$ChatMessageImpl(
  id: json['id'] as String,
  roomId: json['roomId'] as String,
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  senderDisplayName: json['senderDisplayName'] as String?,
  senderAvatar: json['senderAvatar'] as String?,
  messageType: $enumDecode(_$MessageTypeEnumMap, json['messageType']),
  content: json['content'] as String?,
  mediaUrls:
      (json['mediaUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  metadata: json['metadata'] as Map<String, dynamic>?,
  replyToId: json['replyToId'] as String?,
  replyToMessage:
      json['replyToMessage'] == null
          ? null
          : ChatMessage.fromJson(
            json['replyToMessage'] as Map<String, dynamic>,
          ),
  forwardedFromId: json['forwardedFromId'] as String?,
  reactions:
      (json['reactions'] as List<dynamic>?)
          ?.map((e) => MessageReaction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  readReceipts:
      (json['readReceipts'] as List<dynamic>?)
          ?.map((e) => MessageReadReceipt.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  editedAt:
      json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
  deletedAt:
      json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
  isReadByCurrentUser: json['isReadByCurrentUser'] as bool? ?? false,
);

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderDisplayName': instance.senderDisplayName,
      'senderAvatar': instance.senderAvatar,
      'messageType': _$MessageTypeEnumMap[instance.messageType]!,
      'content': instance.content,
      'mediaUrls': instance.mediaUrls,
      'metadata': instance.metadata,
      'replyToId': instance.replyToId,
      'replyToMessage': instance.replyToMessage,
      'forwardedFromId': instance.forwardedFromId,
      'reactions': instance.reactions,
      'readReceipts': instance.readReceipts,
      'createdAt': instance.createdAt.toIso8601String(),
      'editedAt': instance.editedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'isReadByCurrentUser': instance.isReadByCurrentUser,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.file: 'file',
  MessageType.location: 'location',
  MessageType.system: 'system',
};

_$MessageReactionImpl _$$MessageReactionImplFromJson(
  Map<String, dynamic> json,
) => _$MessageReactionImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  username: json['username'] as String,
  displayName: json['displayName'] as String?,
  reactionType: $enumDecode(_$ReactionTypeEnumMap, json['reactionType']),
  emoji: json['emoji'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$MessageReactionImplToJson(
  _$MessageReactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'username': instance.username,
  'displayName': instance.displayName,
  'reactionType': _$ReactionTypeEnumMap[instance.reactionType]!,
  'emoji': instance.emoji,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$ReactionTypeEnumMap = {
  ReactionType.like: 'like',
  ReactionType.love: 'love',
  ReactionType.laugh: 'laugh',
  ReactionType.angry: 'angry',
  ReactionType.sad: 'sad',
  ReactionType.wow: 'wow',
};

_$MessageReadReceiptImpl _$$MessageReadReceiptImplFromJson(
  Map<String, dynamic> json,
) => _$MessageReadReceiptImpl(
  userId: json['userId'] as String,
  username: json['username'] as String,
  displayName: json['displayName'] as String?,
  readAt: DateTime.parse(json['readAt'] as String),
);

Map<String, dynamic> _$$MessageReadReceiptImplToJson(
  _$MessageReadReceiptImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'displayName': instance.displayName,
  'readAt': instance.readAt.toIso8601String(),
};

_$MessageCreateImpl _$$MessageCreateImplFromJson(Map<String, dynamic> json) =>
    _$MessageCreateImpl(
      content: json['content'] as String?,
      messageType:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['messageType']) ??
          MessageType.text,
      mediaUrls:
          (json['mediaUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>?,
      replyToId: json['replyToId'] as String?,
      forwardedFromId: json['forwardedFromId'] as String?,
    );

Map<String, dynamic> _$$MessageCreateImplToJson(_$MessageCreateImpl instance) =>
    <String, dynamic>{
      'content': instance.content,
      'messageType': _$MessageTypeEnumMap[instance.messageType]!,
      'mediaUrls': instance.mediaUrls,
      'metadata': instance.metadata,
      'replyToId': instance.replyToId,
      'forwardedFromId': instance.forwardedFromId,
    };

_$FriendRequestImpl _$$FriendRequestImplFromJson(Map<String, dynamic> json) =>
    _$FriendRequestImpl(
      id: json['id'] as String,
      requesterId: json['requesterId'] as String,
      requesterUsername: json['requesterUsername'] as String,
      requesterDisplayName: json['requesterDisplayName'] as String?,
      requesterAvatar: json['requesterAvatar'] as String?,
      requesteeId: json['requesteeId'] as String,
      requesteeUsername: json['requesteeUsername'] as String,
      requesteeDisplayName: json['requesteeDisplayName'] as String?,
      requesteeAvatar: json['requesteeAvatar'] as String?,
      status: $enumDecode(_$FriendRequestStatusEnumMap, json['status']),
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt:
          json['respondedAt'] == null
              ? null
              : DateTime.parse(json['respondedAt'] as String),
    );

Map<String, dynamic> _$$FriendRequestImplToJson(_$FriendRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requesterId': instance.requesterId,
      'requesterUsername': instance.requesterUsername,
      'requesterDisplayName': instance.requesterDisplayName,
      'requesterAvatar': instance.requesterAvatar,
      'requesteeId': instance.requesteeId,
      'requesteeUsername': instance.requesteeUsername,
      'requesteeDisplayName': instance.requesteeDisplayName,
      'requesteeAvatar': instance.requesteeAvatar,
      'status': _$FriendRequestStatusEnumMap[instance.status]!,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
      'respondedAt': instance.respondedAt?.toIso8601String(),
    };

const _$FriendRequestStatusEnumMap = {
  FriendRequestStatus.pending: 'pending',
  FriendRequestStatus.accepted: 'accepted',
  FriendRequestStatus.declined: 'declined',
  FriendRequestStatus.blocked: 'blocked',
};

_$FriendImpl _$$FriendImplFromJson(Map<String, dynamic> json) => _$FriendImpl(
  id: json['id'] as String,
  username: json['username'] as String,
  displayName: json['displayName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  isOnline: json['isOnline'] as bool? ?? false,
  lastSeen:
      json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
  friendsSince: DateTime.parse(json['friendsSince'] as String),
  mutualFriendsCount: (json['mutualFriendsCount'] as num?)?.toInt() ?? 0,
  canMessage: json['canMessage'] as bool? ?? true,
);

Map<String, dynamic> _$$FriendImplToJson(_$FriendImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'isOnline': instance.isOnline,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'friendsSince': instance.friendsSince.toIso8601String(),
      'mutualFriendsCount': instance.mutualFriendsCount,
      'canMessage': instance.canMessage,
    };

_$UserSearchResultImpl _$$UserSearchResultImplFromJson(
  Map<String, dynamic> json,
) => _$UserSearchResultImpl(
  id: json['id'] as String,
  username: json['username'] as String,
  displayName: json['displayName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  isOnline: json['isOnline'] as bool? ?? false,
  mutualFriendsCount: (json['mutualFriendsCount'] as num?)?.toInt() ?? 0,
  friendshipStatus: json['friendshipStatus'] as String?,
  canSendRequest: json['canSendRequest'] as bool? ?? true,
);

Map<String, dynamic> _$$UserSearchResultImplToJson(
  _$UserSearchResultImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'displayName': instance.displayName,
  'avatarUrl': instance.avatarUrl,
  'isOnline': instance.isOnline,
  'mutualFriendsCount': instance.mutualFriendsCount,
  'friendshipStatus': instance.friendshipStatus,
  'canSendRequest': instance.canSendRequest,
};

_$WebSocketMessageImpl _$$WebSocketMessageImplFromJson(
  Map<String, dynamic> json,
) => _$WebSocketMessageImpl(
  type: json['type'] as String,
  data: json['data'] as Map<String, dynamic>,
  roomId: json['roomId'] as String?,
  userId: json['userId'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$WebSocketMessageImplToJson(
  _$WebSocketMessageImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'data': instance.data,
  'roomId': instance.roomId,
  'userId': instance.userId,
  'timestamp': instance.timestamp.toIso8601String(),
};

_$TypingIndicatorImpl _$$TypingIndicatorImplFromJson(
  Map<String, dynamic> json,
) => _$TypingIndicatorImpl(
  roomId: json['roomId'] as String,
  userId: json['userId'] as String,
  username: json['username'] as String,
  displayName: json['displayName'] as String?,
  startedAt: DateTime.parse(json['startedAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$$TypingIndicatorImplToJson(
  _$TypingIndicatorImpl instance,
) => <String, dynamic>{
  'roomId': instance.roomId,
  'userId': instance.userId,
  'username': instance.username,
  'displayName': instance.displayName,
  'startedAt': instance.startedAt.toIso8601String(),
  'expiresAt': instance.expiresAt.toIso8601String(),
};

_$UserOnlineStatusImpl _$$UserOnlineStatusImplFromJson(
  Map<String, dynamic> json,
) => _$UserOnlineStatusImpl(
  userId: json['userId'] as String,
  isOnline: json['isOnline'] as bool,
  lastSeen:
      json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
  lastActivity:
      json['lastActivity'] == null
          ? null
          : DateTime.parse(json['lastActivity'] as String),
);

Map<String, dynamic> _$$UserOnlineStatusImplToJson(
  _$UserOnlineStatusImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'isOnline': instance.isOnline,
  'lastSeen': instance.lastSeen?.toIso8601String(),
  'lastActivity': instance.lastActivity?.toIso8601String(),
};

_$ChatRoomListResponseImpl _$$ChatRoomListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ChatRoomListResponseImpl(
  rooms:
      (json['rooms'] as List<dynamic>?)
          ?.map((e) => ChatRoom.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  total: (json['total'] as num?)?.toInt() ?? 0,
  page: (json['page'] as num?)?.toInt() ?? 1,
  pages: (json['pages'] as num?)?.toInt() ?? 0,
  hasNext: json['hasNext'] as bool? ?? false,
  hasPrev: json['hasPrev'] as bool? ?? false,
);

Map<String, dynamic> _$$ChatRoomListResponseImplToJson(
  _$ChatRoomListResponseImpl instance,
) => <String, dynamic>{
  'rooms': instance.rooms,
  'total': instance.total,
  'page': instance.page,
  'pages': instance.pages,
  'hasNext': instance.hasNext,
  'hasPrev': instance.hasPrev,
};

_$MessageListResponseImpl _$$MessageListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$MessageListResponseImpl(
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  total: (json['total'] as num?)?.toInt() ?? 0,
  page: (json['page'] as num?)?.toInt() ?? 1,
  pages: (json['pages'] as num?)?.toInt() ?? 0,
  hasNext: json['hasNext'] as bool? ?? false,
  hasPrev: json['hasPrev'] as bool? ?? false,
);

Map<String, dynamic> _$$MessageListResponseImplToJson(
  _$MessageListResponseImpl instance,
) => <String, dynamic>{
  'messages': instance.messages,
  'total': instance.total,
  'page': instance.page,
  'pages': instance.pages,
  'hasNext': instance.hasNext,
  'hasPrev': instance.hasPrev,
};

_$UserSearchResponseImpl _$$UserSearchResponseImplFromJson(
  Map<String, dynamic> json,
) => _$UserSearchResponseImpl(
  users:
      (json['users'] as List<dynamic>?)
          ?.map((e) => UserSearchResult.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
  page: (json['page'] as num?)?.toInt() ?? 1,
  perPage: (json['perPage'] as num?)?.toInt() ?? 20,
  hasNext: json['hasNext'] as bool? ?? false,
);

Map<String, dynamic> _$$UserSearchResponseImplToJson(
  _$UserSearchResponseImpl instance,
) => <String, dynamic>{
  'users': instance.users,
  'totalCount': instance.totalCount,
  'page': instance.page,
  'perPage': instance.perPage,
  'hasNext': instance.hasNext,
};

_$ChatErrorImpl _$$ChatErrorImplFromJson(Map<String, dynamic> json) =>
    _$ChatErrorImpl(
      errorCode: json['errorCode'] as String,
      message: json['message'] as String,
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ChatErrorImplToJson(_$ChatErrorImpl instance) =>
    <String, dynamic>{
      'errorCode': instance.errorCode,
      'message': instance.message,
      'details': instance.details,
    };

_$CreateChatRoomRequestImpl _$$CreateChatRoomRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateChatRoomRequestImpl(
  name: json['name'] as String,
  description: json['description'] as String?,
  type: $enumDecode(_$ChatRoomTypeEnumMap, json['type']),
  participantIds:
      (json['participantIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  avatarUrl: json['avatarUrl'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$CreateChatRoomRequestImplToJson(
  _$CreateChatRoomRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'type': _$ChatRoomTypeEnumMap[instance.type]!,
  'participantIds': instance.participantIds,
  'avatarUrl': instance.avatarUrl,
  'metadata': instance.metadata,
};

_$CreateMessageRequestImpl _$$CreateMessageRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateMessageRequestImpl(
  content: json['content'] as String,
  type: $enumDecode(_$MessageTypeEnumMap, json['type']),
  imageUrl: json['imageUrl'] as String?,
  fileUrl: json['fileUrl'] as String?,
  fileName: json['fileName'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  replyToMessageId: json['replyToMessageId'] as String?,
);

Map<String, dynamic> _$$CreateMessageRequestImplToJson(
  _$CreateMessageRequestImpl instance,
) => <String, dynamic>{
  'content': instance.content,
  'type': _$MessageTypeEnumMap[instance.type]!,
  'imageUrl': instance.imageUrl,
  'fileUrl': instance.fileUrl,
  'fileName': instance.fileName,
  'metadata': instance.metadata,
  'replyToMessageId': instance.replyToMessageId,
};
