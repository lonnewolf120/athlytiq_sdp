import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_models.freezed.dart';
part 'chat_models.g.dart';

// Enums
enum ChatRoomType {
  @JsonValue('direct')
  direct,
  @JsonValue('group')
  group,
}

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('file')
  file,
  @JsonValue('location')
  location,
  @JsonValue('system')
  system,
}

enum ParticipantRole {
  @JsonValue('admin')
  admin,
  @JsonValue('member')
  member,
}

enum FriendRequestStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('declined')
  declined,
  @JsonValue('blocked')
  blocked,
}

enum ReactionType {
  @JsonValue('like')
  like,
  @JsonValue('love')
  love,
  @JsonValue('laugh')
  laugh,
  @JsonValue('angry')
  angry,
  @JsonValue('sad')
  sad,
  @JsonValue('wow')
  wow,
}

// Chat Room Models
@freezed
class ChatRoom with _$ChatRoom {
  const factory ChatRoom({
    required String id,
    required ChatRoomType type,
    String? name,
    String? description,
    String? imageUrl,
    String? createdBy,
    DateTime? lastMessageAt,
    String? lastMessageContent,
    String? lastMessageSenderId,
    @Default([]) List<ChatParticipant> participants,
    @Default(0) int unreadCount,
    @Default(false) bool isArchived,
    @Default(0) int totalMessages,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _ChatRoom;

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);
}

@freezed
class ChatParticipant with _$ChatParticipant {
  const factory ChatParticipant({
    required String userId,
    required String username,
    String? displayName,
    String? avatarUrl,
    required ParticipantRole role,
    required DateTime joinedAt,
    DateTime? leftAt,
    DateTime? lastReadAt,
    @Default(0) int unreadCount,
    @Default(false) bool isMuted,
    @Default(false) bool isPinned,
    @Default(false) bool isOnline,
    DateTime? lastSeen,
  }) = _ChatParticipant;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantFromJson(json);
}

@freezed
class ChatRoomCreate with _$ChatRoomCreate {
  const factory ChatRoomCreate({
    required ChatRoomType type,
    String? name,
    String? description,
    String? imageUrl,
    required List<String> participantIds,
  }) = _ChatRoomCreate;

  factory ChatRoomCreate.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomCreateFromJson(json);
}

// Message Models
@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String roomId,
    required String senderId,
    required String senderName,
    String? senderDisplayName,
    String? senderAvatar,
    required MessageType messageType,
    String? content,
    @Default([]) List<String> mediaUrls,
    Map<String, dynamic>? metadata,
    String? replyToId,
    ChatMessage? replyToMessage,
    String? forwardedFromId,
    @Default([]) List<MessageReaction> reactions,
    @Default([]) List<MessageReadReceipt> readReceipts,
    required DateTime createdAt,
    DateTime? editedAt,
    @Default(false) bool isDeleted,
    DateTime? deletedAt,
    @Default(false) bool isReadByCurrentUser,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
class MessageReaction with _$MessageReaction {
  const factory MessageReaction({
    required String id,
    required String userId,
    required String username,
    String? displayName,
    required ReactionType reactionType,
    required String emoji,
    required DateTime createdAt,
  }) = _MessageReaction;

  factory MessageReaction.fromJson(Map<String, dynamic> json) =>
      _$MessageReactionFromJson(json);
}

@freezed
class MessageReadReceipt with _$MessageReadReceipt {
  const factory MessageReadReceipt({
    required String userId,
    required String username,
    String? displayName,
    required DateTime readAt,
  }) = _MessageReadReceipt;

  factory MessageReadReceipt.fromJson(Map<String, dynamic> json) =>
      _$MessageReadReceiptFromJson(json);
}

@freezed
class MessageCreate with _$MessageCreate {
  const factory MessageCreate({
    String? content,
    @Default(MessageType.text) MessageType messageType,
    @Default([]) List<String> mediaUrls,
    Map<String, dynamic>? metadata,
    String? replyToId,
    String? forwardedFromId,
  }) = _MessageCreate;

  factory MessageCreate.fromJson(Map<String, dynamic> json) =>
      _$MessageCreateFromJson(json);
}

// Friend Models
@freezed
class FriendRequest with _$FriendRequest {
  const factory FriendRequest({
    required String id,
    required String requesterId,
    required String requesterUsername,
    String? requesterDisplayName,
    String? requesterAvatar,
    required String requesteeId,
    required String requesteeUsername,
    String? requesteeDisplayName,
    String? requesteeAvatar,
    required FriendRequestStatus status,
    String? message,
    required DateTime createdAt,
    DateTime? respondedAt,
  }) = _FriendRequest;

  factory FriendRequest.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestFromJson(json);
}

@freezed
class Friend with _$Friend {
  const factory Friend({
    required String id,
    required String username,
    String? displayName,
    String? avatarUrl,
    @Default(false) bool isOnline,
    DateTime? lastSeen,
    required DateTime friendsSince,
    @Default(0) int mutualFriendsCount,
    @Default(true) bool canMessage,
  }) = _Friend;

  factory Friend.fromJson(Map<String, dynamic> json) => _$FriendFromJson(json);
}

@freezed
class UserSearchResult with _$UserSearchResult {
  const factory UserSearchResult({
    required String id,
    required String username,
    String? displayName,
    String? avatarUrl,
    @Default(false) bool isOnline,
    @Default(0) int mutualFriendsCount,
    String? friendshipStatus,
    @Default(true) bool canSendRequest,
  }) = _UserSearchResult;

  factory UserSearchResult.fromJson(Map<String, dynamic> json) =>
      _$UserSearchResultFromJson(json);
}

// WebSocket Models
@freezed
class WebSocketMessage with _$WebSocketMessage {
  const factory WebSocketMessage({
    required String type,
    required Map<String, dynamic> data,
    String? roomId,
    String? userId,
    required DateTime timestamp,
  }) = _WebSocketMessage;

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) =>
      _$WebSocketMessageFromJson(json);
}

@freezed
class TypingIndicator with _$TypingIndicator {
  const factory TypingIndicator({
    required String roomId,
    required String userId,
    required String username,
    String? displayName,
    required DateTime startedAt,
    required DateTime expiresAt,
  }) = _TypingIndicator;

  factory TypingIndicator.fromJson(Map<String, dynamic> json) =>
      _$TypingIndicatorFromJson(json);
}

@freezed
class UserOnlineStatus with _$UserOnlineStatus {
  const factory UserOnlineStatus({
    required String userId,
    required bool isOnline,
    DateTime? lastSeen,
    DateTime? lastActivity,
  }) = _UserOnlineStatus;

  factory UserOnlineStatus.fromJson(Map<String, dynamic> json) =>
      _$UserOnlineStatusFromJson(json);
}

// API Response Models
@freezed
class ChatRoomListResponse with _$ChatRoomListResponse {
  const factory ChatRoomListResponse({
    @Default([]) List<ChatRoom> rooms,
    @Default(0) int total,
    @Default(1) int page,
    @Default(0) int pages,
    @Default(false) bool hasNext,
    @Default(false) bool hasPrev,
  }) = _ChatRoomListResponse;

  factory ChatRoomListResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomListResponseFromJson(json);
}

@freezed
class MessageListResponse with _$MessageListResponse {
  const factory MessageListResponse({
    @Default([]) List<ChatMessage> messages,
    @Default(0) int total,
    @Default(1) int page,
    @Default(0) int pages,
    @Default(false) bool hasNext,
    @Default(false) bool hasPrev,
  }) = _MessageListResponse;

  factory MessageListResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageListResponseFromJson(json);
}

@freezed
class UserSearchResponse with _$UserSearchResponse {
  const factory UserSearchResponse({
    @Default([]) List<UserSearchResult> users,
    @Default(0) int totalCount,
    @Default(1) int page,
    @Default(20) int perPage,
    @Default(false) bool hasNext,
  }) = _UserSearchResponse;

  factory UserSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$UserSearchResponseFromJson(json);
}

// Error Models
@freezed
class ChatError with _$ChatError {
  const factory ChatError({
    required String errorCode,
    required String message,
    Map<String, dynamic>? details,
  }) = _ChatError;

  factory ChatError.fromJson(Map<String, dynamic> json) =>
      _$ChatErrorFromJson(json);
}

// Request Models for API
@freezed
class CreateChatRoomRequest with _$CreateChatRoomRequest {
  const factory CreateChatRoomRequest({
    required String name,
    String? description,
    required ChatRoomType type,
    required List<String> participantIds,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) = _CreateChatRoomRequest;

  factory CreateChatRoomRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateChatRoomRequestFromJson(json);
}

@freezed
class CreateMessageRequest with _$CreateMessageRequest {
  const factory CreateMessageRequest({
    required String content,
    required MessageType type,
    String? imageUrl,
    String? fileUrl,
    String? fileName,
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
  }) = _CreateMessageRequest;

  factory CreateMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMessageRequestFromJson(json);
}
