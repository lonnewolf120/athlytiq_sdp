// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) {
  return _ChatRoom.fromJson(json);
}

/// @nodoc
mixin _$ChatRoom {
  String get id => throw _privateConstructorUsedError;
  ChatRoomType get type => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  String? get lastMessageContent => throw _privateConstructorUsedError;
  String? get lastMessageSenderId => throw _privateConstructorUsedError;
  List<ChatParticipant> get participants => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError;
  int get totalMessages => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ChatRoom to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatRoomCopyWith<ChatRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRoomCopyWith<$Res> {
  factory $ChatRoomCopyWith(ChatRoom value, $Res Function(ChatRoom) then) =
      _$ChatRoomCopyWithImpl<$Res, ChatRoom>;
  @useResult
  $Res call({
    String id,
    ChatRoomType type,
    String? name,
    String? description,
    String? imageUrl,
    String? createdBy,
    DateTime? lastMessageAt,
    String? lastMessageContent,
    String? lastMessageSenderId,
    List<ChatParticipant> participants,
    int unreadCount,
    bool isArchived,
    int totalMessages,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$ChatRoomCopyWithImpl<$Res, $Val extends ChatRoom>
    implements $ChatRoomCopyWith<$Res> {
  _$ChatRoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? name = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? createdBy = freezed,
    Object? lastMessageAt = freezed,
    Object? lastMessageContent = freezed,
    Object? lastMessageSenderId = freezed,
    Object? participants = null,
    Object? unreadCount = null,
    Object? isArchived = null,
    Object? totalMessages = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as ChatRoomType,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            imageUrl:
                freezed == imageUrl
                    ? _value.imageUrl
                    : imageUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            createdBy:
                freezed == createdBy
                    ? _value.createdBy
                    : createdBy // ignore: cast_nullable_to_non_nullable
                        as String?,
            lastMessageAt:
                freezed == lastMessageAt
                    ? _value.lastMessageAt
                    : lastMessageAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            lastMessageContent:
                freezed == lastMessageContent
                    ? _value.lastMessageContent
                    : lastMessageContent // ignore: cast_nullable_to_non_nullable
                        as String?,
            lastMessageSenderId:
                freezed == lastMessageSenderId
                    ? _value.lastMessageSenderId
                    : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
                        as String?,
            participants:
                null == participants
                    ? _value.participants
                    : participants // ignore: cast_nullable_to_non_nullable
                        as List<ChatParticipant>,
            unreadCount:
                null == unreadCount
                    ? _value.unreadCount
                    : unreadCount // ignore: cast_nullable_to_non_nullable
                        as int,
            isArchived:
                null == isArchived
                    ? _value.isArchived
                    : isArchived // ignore: cast_nullable_to_non_nullable
                        as bool,
            totalMessages:
                null == totalMessages
                    ? _value.totalMessages
                    : totalMessages // ignore: cast_nullable_to_non_nullable
                        as int,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                freezed == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatRoomImplCopyWith<$Res>
    implements $ChatRoomCopyWith<$Res> {
  factory _$$ChatRoomImplCopyWith(
    _$ChatRoomImpl value,
    $Res Function(_$ChatRoomImpl) then,
  ) = __$$ChatRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    ChatRoomType type,
    String? name,
    String? description,
    String? imageUrl,
    String? createdBy,
    DateTime? lastMessageAt,
    String? lastMessageContent,
    String? lastMessageSenderId,
    List<ChatParticipant> participants,
    int unreadCount,
    bool isArchived,
    int totalMessages,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$ChatRoomImplCopyWithImpl<$Res>
    extends _$ChatRoomCopyWithImpl<$Res, _$ChatRoomImpl>
    implements _$$ChatRoomImplCopyWith<$Res> {
  __$$ChatRoomImplCopyWithImpl(
    _$ChatRoomImpl _value,
    $Res Function(_$ChatRoomImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? name = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? createdBy = freezed,
    Object? lastMessageAt = freezed,
    Object? lastMessageContent = freezed,
    Object? lastMessageSenderId = freezed,
    Object? participants = null,
    Object? unreadCount = null,
    Object? isArchived = null,
    Object? totalMessages = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ChatRoomImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as ChatRoomType,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        imageUrl:
            freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        createdBy:
            freezed == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                    as String?,
        lastMessageAt:
            freezed == lastMessageAt
                ? _value.lastMessageAt
                : lastMessageAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        lastMessageContent:
            freezed == lastMessageContent
                ? _value.lastMessageContent
                : lastMessageContent // ignore: cast_nullable_to_non_nullable
                    as String?,
        lastMessageSenderId:
            freezed == lastMessageSenderId
                ? _value.lastMessageSenderId
                : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
                    as String?,
        participants:
            null == participants
                ? _value._participants
                : participants // ignore: cast_nullable_to_non_nullable
                    as List<ChatParticipant>,
        unreadCount:
            null == unreadCount
                ? _value.unreadCount
                : unreadCount // ignore: cast_nullable_to_non_nullable
                    as int,
        isArchived:
            null == isArchived
                ? _value.isArchived
                : isArchived // ignore: cast_nullable_to_non_nullable
                    as bool,
        totalMessages:
            null == totalMessages
                ? _value.totalMessages
                : totalMessages // ignore: cast_nullable_to_non_nullable
                    as int,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRoomImpl implements _ChatRoom {
  const _$ChatRoomImpl({
    required this.id,
    required this.type,
    this.name,
    this.description,
    this.imageUrl,
    this.createdBy,
    this.lastMessageAt,
    this.lastMessageContent,
    this.lastMessageSenderId,
    final List<ChatParticipant> participants = const [],
    this.unreadCount = 0,
    this.isArchived = false,
    this.totalMessages = 0,
    required this.createdAt,
    this.updatedAt,
  }) : _participants = participants;

  factory _$ChatRoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatRoomImplFromJson(json);

  @override
  final String id;
  @override
  final ChatRoomType type;
  @override
  final String? name;
  @override
  final String? description;
  @override
  final String? imageUrl;
  @override
  final String? createdBy;
  @override
  final DateTime? lastMessageAt;
  @override
  final String? lastMessageContent;
  @override
  final String? lastMessageSenderId;
  final List<ChatParticipant> _participants;
  @override
  @JsonKey()
  List<ChatParticipant> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  @JsonKey()
  final int unreadCount;
  @override
  @JsonKey()
  final bool isArchived;
  @override
  @JsonKey()
  final int totalMessages;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ChatRoom(id: $id, type: $type, name: $name, description: $description, imageUrl: $imageUrl, createdBy: $createdBy, lastMessageAt: $lastMessageAt, lastMessageContent: $lastMessageContent, lastMessageSenderId: $lastMessageSenderId, participants: $participants, unreadCount: $unreadCount, isArchived: $isArchived, totalMessages: $totalMessages, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.lastMessageContent, lastMessageContent) ||
                other.lastMessageContent == lastMessageContent) &&
            (identical(other.lastMessageSenderId, lastMessageSenderId) ||
                other.lastMessageSenderId == lastMessageSenderId) &&
            const DeepCollectionEquality().equals(
              other._participants,
              _participants,
            ) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.totalMessages, totalMessages) ||
                other.totalMessages == totalMessages) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    name,
    description,
    imageUrl,
    createdBy,
    lastMessageAt,
    lastMessageContent,
    lastMessageSenderId,
    const DeepCollectionEquality().hash(_participants),
    unreadCount,
    isArchived,
    totalMessages,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRoomImplCopyWith<_$ChatRoomImpl> get copyWith =>
      __$$ChatRoomImplCopyWithImpl<_$ChatRoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatRoomImplToJson(this);
  }
}

abstract class _ChatRoom implements ChatRoom {
  const factory _ChatRoom({
    required final String id,
    required final ChatRoomType type,
    final String? name,
    final String? description,
    final String? imageUrl,
    final String? createdBy,
    final DateTime? lastMessageAt,
    final String? lastMessageContent,
    final String? lastMessageSenderId,
    final List<ChatParticipant> participants,
    final int unreadCount,
    final bool isArchived,
    final int totalMessages,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$ChatRoomImpl;

  factory _ChatRoom.fromJson(Map<String, dynamic> json) =
      _$ChatRoomImpl.fromJson;

  @override
  String get id;
  @override
  ChatRoomType get type;
  @override
  String? get name;
  @override
  String? get description;
  @override
  String? get imageUrl;
  @override
  String? get createdBy;
  @override
  DateTime? get lastMessageAt;
  @override
  String? get lastMessageContent;
  @override
  String? get lastMessageSenderId;
  @override
  List<ChatParticipant> get participants;
  @override
  int get unreadCount;
  @override
  bool get isArchived;
  @override
  int get totalMessages;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of ChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatRoomImplCopyWith<_$ChatRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatParticipant _$ChatParticipantFromJson(Map<String, dynamic> json) {
  return _ChatParticipant.fromJson(json);
}

/// @nodoc
mixin _$ChatParticipant {
  String get userId => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  ParticipantRole get role => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  DateTime? get leftAt => throw _privateConstructorUsedError;
  DateTime? get lastReadAt => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  bool get isMuted => throw _privateConstructorUsedError;
  bool get isPinned => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;
  DateTime? get lastSeen => throw _privateConstructorUsedError;

  /// Serializes this ChatParticipant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatParticipantCopyWith<ChatParticipant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatParticipantCopyWith<$Res> {
  factory $ChatParticipantCopyWith(
    ChatParticipant value,
    $Res Function(ChatParticipant) then,
  ) = _$ChatParticipantCopyWithImpl<$Res, ChatParticipant>;
  @useResult
  $Res call({
    String userId,
    String username,
    String? displayName,
    String? avatarUrl,
    ParticipantRole role,
    DateTime joinedAt,
    DateTime? leftAt,
    DateTime? lastReadAt,
    int unreadCount,
    bool isMuted,
    bool isPinned,
    bool isOnline,
    DateTime? lastSeen,
  });
}

/// @nodoc
class _$ChatParticipantCopyWithImpl<$Res, $Val extends ChatParticipant>
    implements $ChatParticipantCopyWith<$Res> {
  _$ChatParticipantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? role = null,
    Object? joinedAt = null,
    Object? leftAt = freezed,
    Object? lastReadAt = freezed,
    Object? unreadCount = null,
    Object? isMuted = null,
    Object? isPinned = null,
    Object? isOnline = null,
    Object? lastSeen = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            username:
                null == username
                    ? _value.username
                    : username // ignore: cast_nullable_to_non_nullable
                        as String,
            displayName:
                freezed == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String?,
            avatarUrl:
                freezed == avatarUrl
                    ? _value.avatarUrl
                    : avatarUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            role:
                null == role
                    ? _value.role
                    : role // ignore: cast_nullable_to_non_nullable
                        as ParticipantRole,
            joinedAt:
                null == joinedAt
                    ? _value.joinedAt
                    : joinedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            leftAt:
                freezed == leftAt
                    ? _value.leftAt
                    : leftAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            lastReadAt:
                freezed == lastReadAt
                    ? _value.lastReadAt
                    : lastReadAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            unreadCount:
                null == unreadCount
                    ? _value.unreadCount
                    : unreadCount // ignore: cast_nullable_to_non_nullable
                        as int,
            isMuted:
                null == isMuted
                    ? _value.isMuted
                    : isMuted // ignore: cast_nullable_to_non_nullable
                        as bool,
            isPinned:
                null == isPinned
                    ? _value.isPinned
                    : isPinned // ignore: cast_nullable_to_non_nullable
                        as bool,
            isOnline:
                null == isOnline
                    ? _value.isOnline
                    : isOnline // ignore: cast_nullable_to_non_nullable
                        as bool,
            lastSeen:
                freezed == lastSeen
                    ? _value.lastSeen
                    : lastSeen // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatParticipantImplCopyWith<$Res>
    implements $ChatParticipantCopyWith<$Res> {
  factory _$$ChatParticipantImplCopyWith(
    _$ChatParticipantImpl value,
    $Res Function(_$ChatParticipantImpl) then,
  ) = __$$ChatParticipantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String username,
    String? displayName,
    String? avatarUrl,
    ParticipantRole role,
    DateTime joinedAt,
    DateTime? leftAt,
    DateTime? lastReadAt,
    int unreadCount,
    bool isMuted,
    bool isPinned,
    bool isOnline,
    DateTime? lastSeen,
  });
}

/// @nodoc
class __$$ChatParticipantImplCopyWithImpl<$Res>
    extends _$ChatParticipantCopyWithImpl<$Res, _$ChatParticipantImpl>
    implements _$$ChatParticipantImplCopyWith<$Res> {
  __$$ChatParticipantImplCopyWithImpl(
    _$ChatParticipantImpl _value,
    $Res Function(_$ChatParticipantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? role = null,
    Object? joinedAt = null,
    Object? leftAt = freezed,
    Object? lastReadAt = freezed,
    Object? unreadCount = null,
    Object? isMuted = null,
    Object? isPinned = null,
    Object? isOnline = null,
    Object? lastSeen = freezed,
  }) {
    return _then(
      _$ChatParticipantImpl(
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        username:
            null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                    as String,
        displayName:
            freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String?,
        avatarUrl:
            freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        role:
            null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                    as ParticipantRole,
        joinedAt:
            null == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        leftAt:
            freezed == leftAt
                ? _value.leftAt
                : leftAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        lastReadAt:
            freezed == lastReadAt
                ? _value.lastReadAt
                : lastReadAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        unreadCount:
            null == unreadCount
                ? _value.unreadCount
                : unreadCount // ignore: cast_nullable_to_non_nullable
                    as int,
        isMuted:
            null == isMuted
                ? _value.isMuted
                : isMuted // ignore: cast_nullable_to_non_nullable
                    as bool,
        isPinned:
            null == isPinned
                ? _value.isPinned
                : isPinned // ignore: cast_nullable_to_non_nullable
                    as bool,
        isOnline:
            null == isOnline
                ? _value.isOnline
                : isOnline // ignore: cast_nullable_to_non_nullable
                    as bool,
        lastSeen:
            freezed == lastSeen
                ? _value.lastSeen
                : lastSeen // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatParticipantImpl implements _ChatParticipant {
  const _$ChatParticipantImpl({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    required this.role,
    required this.joinedAt,
    this.leftAt,
    this.lastReadAt,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
    this.isOnline = false,
    this.lastSeen,
  });

  factory _$ChatParticipantImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatParticipantImplFromJson(json);

  @override
  final String userId;
  @override
  final String username;
  @override
  final String? displayName;
  @override
  final String? avatarUrl;
  @override
  final ParticipantRole role;
  @override
  final DateTime joinedAt;
  @override
  final DateTime? leftAt;
  @override
  final DateTime? lastReadAt;
  @override
  @JsonKey()
  final int unreadCount;
  @override
  @JsonKey()
  final bool isMuted;
  @override
  @JsonKey()
  final bool isPinned;
  @override
  @JsonKey()
  final bool isOnline;
  @override
  final DateTime? lastSeen;

  @override
  String toString() {
    return 'ChatParticipant(userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, role: $role, joinedAt: $joinedAt, leftAt: $leftAt, lastReadAt: $lastReadAt, unreadCount: $unreadCount, isMuted: $isMuted, isPinned: $isPinned, isOnline: $isOnline, lastSeen: $lastSeen)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatParticipantImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.leftAt, leftAt) || other.leftAt == leftAt) &&
            (identical(other.lastReadAt, lastReadAt) ||
                other.lastReadAt == lastReadAt) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.isMuted, isMuted) || other.isMuted == isMuted) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    username,
    displayName,
    avatarUrl,
    role,
    joinedAt,
    leftAt,
    lastReadAt,
    unreadCount,
    isMuted,
    isPinned,
    isOnline,
    lastSeen,
  );

  /// Create a copy of ChatParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatParticipantImplCopyWith<_$ChatParticipantImpl> get copyWith =>
      __$$ChatParticipantImplCopyWithImpl<_$ChatParticipantImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatParticipantImplToJson(this);
  }
}

abstract class _ChatParticipant implements ChatParticipant {
  const factory _ChatParticipant({
    required final String userId,
    required final String username,
    final String? displayName,
    final String? avatarUrl,
    required final ParticipantRole role,
    required final DateTime joinedAt,
    final DateTime? leftAt,
    final DateTime? lastReadAt,
    final int unreadCount,
    final bool isMuted,
    final bool isPinned,
    final bool isOnline,
    final DateTime? lastSeen,
  }) = _$ChatParticipantImpl;

  factory _ChatParticipant.fromJson(Map<String, dynamic> json) =
      _$ChatParticipantImpl.fromJson;

  @override
  String get userId;
  @override
  String get username;
  @override
  String? get displayName;
  @override
  String? get avatarUrl;
  @override
  ParticipantRole get role;
  @override
  DateTime get joinedAt;
  @override
  DateTime? get leftAt;
  @override
  DateTime? get lastReadAt;
  @override
  int get unreadCount;
  @override
  bool get isMuted;
  @override
  bool get isPinned;
  @override
  bool get isOnline;
  @override
  DateTime? get lastSeen;

  /// Create a copy of ChatParticipant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatParticipantImplCopyWith<_$ChatParticipantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatRoomCreate _$ChatRoomCreateFromJson(Map<String, dynamic> json) {
  return _ChatRoomCreate.fromJson(json);
}

/// @nodoc
mixin _$ChatRoomCreate {
  ChatRoomType get type => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String> get participantIds => throw _privateConstructorUsedError;

  /// Serializes this ChatRoomCreate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatRoomCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatRoomCreateCopyWith<ChatRoomCreate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRoomCreateCopyWith<$Res> {
  factory $ChatRoomCreateCopyWith(
    ChatRoomCreate value,
    $Res Function(ChatRoomCreate) then,
  ) = _$ChatRoomCreateCopyWithImpl<$Res, ChatRoomCreate>;
  @useResult
  $Res call({
    ChatRoomType type,
    String? name,
    String? description,
    String? imageUrl,
    List<String> participantIds,
  });
}

/// @nodoc
class _$ChatRoomCreateCopyWithImpl<$Res, $Val extends ChatRoomCreate>
    implements $ChatRoomCreateCopyWith<$Res> {
  _$ChatRoomCreateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatRoomCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? name = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? participantIds = null,
  }) {
    return _then(
      _value.copyWith(
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as ChatRoomType,
            name:
                freezed == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String?,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            imageUrl:
                freezed == imageUrl
                    ? _value.imageUrl
                    : imageUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            participantIds:
                null == participantIds
                    ? _value.participantIds
                    : participantIds // ignore: cast_nullable_to_non_nullable
                        as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatRoomCreateImplCopyWith<$Res>
    implements $ChatRoomCreateCopyWith<$Res> {
  factory _$$ChatRoomCreateImplCopyWith(
    _$ChatRoomCreateImpl value,
    $Res Function(_$ChatRoomCreateImpl) then,
  ) = __$$ChatRoomCreateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ChatRoomType type,
    String? name,
    String? description,
    String? imageUrl,
    List<String> participantIds,
  });
}

/// @nodoc
class __$$ChatRoomCreateImplCopyWithImpl<$Res>
    extends _$ChatRoomCreateCopyWithImpl<$Res, _$ChatRoomCreateImpl>
    implements _$$ChatRoomCreateImplCopyWith<$Res> {
  __$$ChatRoomCreateImplCopyWithImpl(
    _$ChatRoomCreateImpl _value,
    $Res Function(_$ChatRoomCreateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatRoomCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? name = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? participantIds = null,
  }) {
    return _then(
      _$ChatRoomCreateImpl(
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as ChatRoomType,
        name:
            freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String?,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        imageUrl:
            freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        participantIds:
            null == participantIds
                ? _value._participantIds
                : participantIds // ignore: cast_nullable_to_non_nullable
                    as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRoomCreateImpl implements _ChatRoomCreate {
  const _$ChatRoomCreateImpl({
    required this.type,
    this.name,
    this.description,
    this.imageUrl,
    required final List<String> participantIds,
  }) : _participantIds = participantIds;

  factory _$ChatRoomCreateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatRoomCreateImplFromJson(json);

  @override
  final ChatRoomType type;
  @override
  final String? name;
  @override
  final String? description;
  @override
  final String? imageUrl;
  final List<String> _participantIds;
  @override
  List<String> get participantIds {
    if (_participantIds is EqualUnmodifiableListView) return _participantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantIds);
  }

  @override
  String toString() {
    return 'ChatRoomCreate(type: $type, name: $name, description: $description, imageUrl: $imageUrl, participantIds: $participantIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRoomCreateImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(
              other._participantIds,
              _participantIds,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    name,
    description,
    imageUrl,
    const DeepCollectionEquality().hash(_participantIds),
  );

  /// Create a copy of ChatRoomCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRoomCreateImplCopyWith<_$ChatRoomCreateImpl> get copyWith =>
      __$$ChatRoomCreateImplCopyWithImpl<_$ChatRoomCreateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatRoomCreateImplToJson(this);
  }
}

abstract class _ChatRoomCreate implements ChatRoomCreate {
  const factory _ChatRoomCreate({
    required final ChatRoomType type,
    final String? name,
    final String? description,
    final String? imageUrl,
    required final List<String> participantIds,
  }) = _$ChatRoomCreateImpl;

  factory _ChatRoomCreate.fromJson(Map<String, dynamic> json) =
      _$ChatRoomCreateImpl.fromJson;

  @override
  ChatRoomType get type;
  @override
  String? get name;
  @override
  String? get description;
  @override
  String? get imageUrl;
  @override
  List<String> get participantIds;

  /// Create a copy of ChatRoomCreate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatRoomCreateImplCopyWith<_$ChatRoomCreateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get roomId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get senderName => throw _privateConstructorUsedError;
  String? get senderDisplayName => throw _privateConstructorUsedError;
  String? get senderAvatar => throw _privateConstructorUsedError;
  MessageType get messageType => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  List<String> get mediaUrls => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  String? get replyToId => throw _privateConstructorUsedError;
  ChatMessage? get replyToMessage => throw _privateConstructorUsedError;
  String? get forwardedFromId => throw _privateConstructorUsedError;
  List<MessageReaction> get reactions => throw _privateConstructorUsedError;
  List<MessageReadReceipt> get readReceipts =>
      throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get editedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  bool get isReadByCurrentUser => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    String id,
    String roomId,
    String senderId,
    String senderName,
    String? senderDisplayName,
    String? senderAvatar,
    MessageType messageType,
    String? content,
    List<String> mediaUrls,
    Map<String, dynamic>? metadata,
    String? replyToId,
    ChatMessage? replyToMessage,
    String? forwardedFromId,
    List<MessageReaction> reactions,
    List<MessageReadReceipt> readReceipts,
    DateTime createdAt,
    DateTime? editedAt,
    bool isDeleted,
    DateTime? deletedAt,
    bool isReadByCurrentUser,
  });

  $ChatMessageCopyWith<$Res>? get replyToMessage;
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? senderId = null,
    Object? senderName = null,
    Object? senderDisplayName = freezed,
    Object? senderAvatar = freezed,
    Object? messageType = null,
    Object? content = freezed,
    Object? mediaUrls = null,
    Object? metadata = freezed,
    Object? replyToId = freezed,
    Object? replyToMessage = freezed,
    Object? forwardedFromId = freezed,
    Object? reactions = null,
    Object? readReceipts = null,
    Object? createdAt = null,
    Object? editedAt = freezed,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? isReadByCurrentUser = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            roomId:
                null == roomId
                    ? _value.roomId
                    : roomId // ignore: cast_nullable_to_non_nullable
                        as String,
            senderId:
                null == senderId
                    ? _value.senderId
                    : senderId // ignore: cast_nullable_to_non_nullable
                        as String,
            senderName:
                null == senderName
                    ? _value.senderName
                    : senderName // ignore: cast_nullable_to_non_nullable
                        as String,
            senderDisplayName:
                freezed == senderDisplayName
                    ? _value.senderDisplayName
                    : senderDisplayName // ignore: cast_nullable_to_non_nullable
                        as String?,
            senderAvatar:
                freezed == senderAvatar
                    ? _value.senderAvatar
                    : senderAvatar // ignore: cast_nullable_to_non_nullable
                        as String?,
            messageType:
                null == messageType
                    ? _value.messageType
                    : messageType // ignore: cast_nullable_to_non_nullable
                        as MessageType,
            content:
                freezed == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String?,
            mediaUrls:
                null == mediaUrls
                    ? _value.mediaUrls
                    : mediaUrls // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            metadata:
                freezed == metadata
                    ? _value.metadata
                    : metadata // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
            replyToId:
                freezed == replyToId
                    ? _value.replyToId
                    : replyToId // ignore: cast_nullable_to_non_nullable
                        as String?,
            replyToMessage:
                freezed == replyToMessage
                    ? _value.replyToMessage
                    : replyToMessage // ignore: cast_nullable_to_non_nullable
                        as ChatMessage?,
            forwardedFromId:
                freezed == forwardedFromId
                    ? _value.forwardedFromId
                    : forwardedFromId // ignore: cast_nullable_to_non_nullable
                        as String?,
            reactions:
                null == reactions
                    ? _value.reactions
                    : reactions // ignore: cast_nullable_to_non_nullable
                        as List<MessageReaction>,
            readReceipts:
                null == readReceipts
                    ? _value.readReceipts
                    : readReceipts // ignore: cast_nullable_to_non_nullable
                        as List<MessageReadReceipt>,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            editedAt:
                freezed == editedAt
                    ? _value.editedAt
                    : editedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            isDeleted:
                null == isDeleted
                    ? _value.isDeleted
                    : isDeleted // ignore: cast_nullable_to_non_nullable
                        as bool,
            deletedAt:
                freezed == deletedAt
                    ? _value.deletedAt
                    : deletedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            isReadByCurrentUser:
                null == isReadByCurrentUser
                    ? _value.isReadByCurrentUser
                    : isReadByCurrentUser // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatMessageCopyWith<$Res>? get replyToMessage {
    if (_value.replyToMessage == null) {
      return null;
    }

    return $ChatMessageCopyWith<$Res>(_value.replyToMessage!, (value) {
      return _then(_value.copyWith(replyToMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String roomId,
    String senderId,
    String senderName,
    String? senderDisplayName,
    String? senderAvatar,
    MessageType messageType,
    String? content,
    List<String> mediaUrls,
    Map<String, dynamic>? metadata,
    String? replyToId,
    ChatMessage? replyToMessage,
    String? forwardedFromId,
    List<MessageReaction> reactions,
    List<MessageReadReceipt> readReceipts,
    DateTime createdAt,
    DateTime? editedAt,
    bool isDeleted,
    DateTime? deletedAt,
    bool isReadByCurrentUser,
  });

  @override
  $ChatMessageCopyWith<$Res>? get replyToMessage;
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? senderId = null,
    Object? senderName = null,
    Object? senderDisplayName = freezed,
    Object? senderAvatar = freezed,
    Object? messageType = null,
    Object? content = freezed,
    Object? mediaUrls = null,
    Object? metadata = freezed,
    Object? replyToId = freezed,
    Object? replyToMessage = freezed,
    Object? forwardedFromId = freezed,
    Object? reactions = null,
    Object? readReceipts = null,
    Object? createdAt = null,
    Object? editedAt = freezed,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? isReadByCurrentUser = null,
  }) {
    return _then(
      _$ChatMessageImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        roomId:
            null == roomId
                ? _value.roomId
                : roomId // ignore: cast_nullable_to_non_nullable
                    as String,
        senderId:
            null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                    as String,
        senderName:
            null == senderName
                ? _value.senderName
                : senderName // ignore: cast_nullable_to_non_nullable
                    as String,
        senderDisplayName:
            freezed == senderDisplayName
                ? _value.senderDisplayName
                : senderDisplayName // ignore: cast_nullable_to_non_nullable
                    as String?,
        senderAvatar:
            freezed == senderAvatar
                ? _value.senderAvatar
                : senderAvatar // ignore: cast_nullable_to_non_nullable
                    as String?,
        messageType:
            null == messageType
                ? _value.messageType
                : messageType // ignore: cast_nullable_to_non_nullable
                    as MessageType,
        content:
            freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String?,
        mediaUrls:
            null == mediaUrls
                ? _value._mediaUrls
                : mediaUrls // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        metadata:
            freezed == metadata
                ? _value._metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
        replyToId:
            freezed == replyToId
                ? _value.replyToId
                : replyToId // ignore: cast_nullable_to_non_nullable
                    as String?,
        replyToMessage:
            freezed == replyToMessage
                ? _value.replyToMessage
                : replyToMessage // ignore: cast_nullable_to_non_nullable
                    as ChatMessage?,
        forwardedFromId:
            freezed == forwardedFromId
                ? _value.forwardedFromId
                : forwardedFromId // ignore: cast_nullable_to_non_nullable
                    as String?,
        reactions:
            null == reactions
                ? _value._reactions
                : reactions // ignore: cast_nullable_to_non_nullable
                    as List<MessageReaction>,
        readReceipts:
            null == readReceipts
                ? _value._readReceipts
                : readReceipts // ignore: cast_nullable_to_non_nullable
                    as List<MessageReadReceipt>,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        editedAt:
            freezed == editedAt
                ? _value.editedAt
                : editedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        isDeleted:
            null == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                    as bool,
        deletedAt:
            freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        isReadByCurrentUser:
            null == isReadByCurrentUser
                ? _value.isReadByCurrentUser
                : isReadByCurrentUser // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderDisplayName,
    this.senderAvatar,
    required this.messageType,
    this.content,
    final List<String> mediaUrls = const [],
    final Map<String, dynamic>? metadata,
    this.replyToId,
    this.replyToMessage,
    this.forwardedFromId,
    final List<MessageReaction> reactions = const [],
    final List<MessageReadReceipt> readReceipts = const [],
    required this.createdAt,
    this.editedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.isReadByCurrentUser = false,
  }) : _mediaUrls = mediaUrls,
       _metadata = metadata,
       _reactions = reactions,
       _readReceipts = readReceipts;

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String roomId;
  @override
  final String senderId;
  @override
  final String senderName;
  @override
  final String? senderDisplayName;
  @override
  final String? senderAvatar;
  @override
  final MessageType messageType;
  @override
  final String? content;
  final List<String> _mediaUrls;
  @override
  @JsonKey()
  List<String> get mediaUrls {
    if (_mediaUrls is EqualUnmodifiableListView) return _mediaUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mediaUrls);
  }

  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? replyToId;
  @override
  final ChatMessage? replyToMessage;
  @override
  final String? forwardedFromId;
  final List<MessageReaction> _reactions;
  @override
  @JsonKey()
  List<MessageReaction> get reactions {
    if (_reactions is EqualUnmodifiableListView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reactions);
  }

  final List<MessageReadReceipt> _readReceipts;
  @override
  @JsonKey()
  List<MessageReadReceipt> get readReceipts {
    if (_readReceipts is EqualUnmodifiableListView) return _readReceipts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_readReceipts);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? editedAt;
  @override
  @JsonKey()
  final bool isDeleted;
  @override
  final DateTime? deletedAt;
  @override
  @JsonKey()
  final bool isReadByCurrentUser;

  @override
  String toString() {
    return 'ChatMessage(id: $id, roomId: $roomId, senderId: $senderId, senderName: $senderName, senderDisplayName: $senderDisplayName, senderAvatar: $senderAvatar, messageType: $messageType, content: $content, mediaUrls: $mediaUrls, metadata: $metadata, replyToId: $replyToId, replyToMessage: $replyToMessage, forwardedFromId: $forwardedFromId, reactions: $reactions, readReceipts: $readReceipts, createdAt: $createdAt, editedAt: $editedAt, isDeleted: $isDeleted, deletedAt: $deletedAt, isReadByCurrentUser: $isReadByCurrentUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderDisplayName, senderDisplayName) ||
                other.senderDisplayName == senderDisplayName) &&
            (identical(other.senderAvatar, senderAvatar) ||
                other.senderAvatar == senderAvatar) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(
              other._mediaUrls,
              _mediaUrls,
            ) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.replyToId, replyToId) ||
                other.replyToId == replyToId) &&
            (identical(other.replyToMessage, replyToMessage) ||
                other.replyToMessage == replyToMessage) &&
            (identical(other.forwardedFromId, forwardedFromId) ||
                other.forwardedFromId == forwardedFromId) &&
            const DeepCollectionEquality().equals(
              other._reactions,
              _reactions,
            ) &&
            const DeepCollectionEquality().equals(
              other._readReceipts,
              _readReceipts,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.isReadByCurrentUser, isReadByCurrentUser) ||
                other.isReadByCurrentUser == isReadByCurrentUser));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    roomId,
    senderId,
    senderName,
    senderDisplayName,
    senderAvatar,
    messageType,
    content,
    const DeepCollectionEquality().hash(_mediaUrls),
    const DeepCollectionEquality().hash(_metadata),
    replyToId,
    replyToMessage,
    forwardedFromId,
    const DeepCollectionEquality().hash(_reactions),
    const DeepCollectionEquality().hash(_readReceipts),
    createdAt,
    editedAt,
    isDeleted,
    deletedAt,
    isReadByCurrentUser,
  ]);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage({
    required final String id,
    required final String roomId,
    required final String senderId,
    required final String senderName,
    final String? senderDisplayName,
    final String? senderAvatar,
    required final MessageType messageType,
    final String? content,
    final List<String> mediaUrls,
    final Map<String, dynamic>? metadata,
    final String? replyToId,
    final ChatMessage? replyToMessage,
    final String? forwardedFromId,
    final List<MessageReaction> reactions,
    final List<MessageReadReceipt> readReceipts,
    required final DateTime createdAt,
    final DateTime? editedAt,
    final bool isDeleted,
    final DateTime? deletedAt,
    final bool isReadByCurrentUser,
  }) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get roomId;
  @override
  String get senderId;
  @override
  String get senderName;
  @override
  String? get senderDisplayName;
  @override
  String? get senderAvatar;
  @override
  MessageType get messageType;
  @override
  String? get content;
  @override
  List<String> get mediaUrls;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String? get replyToId;
  @override
  ChatMessage? get replyToMessage;
  @override
  String? get forwardedFromId;
  @override
  List<MessageReaction> get reactions;
  @override
  List<MessageReadReceipt> get readReceipts;
  @override
  DateTime get createdAt;
  @override
  DateTime? get editedAt;
  @override
  bool get isDeleted;
  @override
  DateTime? get deletedAt;
  @override
  bool get isReadByCurrentUser;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageReaction _$MessageReactionFromJson(Map<String, dynamic> json) {
  return _MessageReaction.fromJson(json);
}

/// @nodoc
mixin _$MessageReaction {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  ReactionType get reactionType => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MessageReaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageReactionCopyWith<MessageReaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageReactionCopyWith<$Res> {
  factory $MessageReactionCopyWith(
    MessageReaction value,
    $Res Function(MessageReaction) then,
  ) = _$MessageReactionCopyWithImpl<$Res, MessageReaction>;
  @useResult
  $Res call({
    String id,
    String userId,
    String username,
    String? displayName,
    ReactionType reactionType,
    String emoji,
    DateTime createdAt,
  });
}

/// @nodoc
class _$MessageReactionCopyWithImpl<$Res, $Val extends MessageReaction>
    implements $MessageReactionCopyWith<$Res> {
  _$MessageReactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? reactionType = null,
    Object? emoji = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            username:
                null == username
                    ? _value.username
                    : username // ignore: cast_nullable_to_non_nullable
                        as String,
            displayName:
                freezed == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String?,
            reactionType:
                null == reactionType
                    ? _value.reactionType
                    : reactionType // ignore: cast_nullable_to_non_nullable
                        as ReactionType,
            emoji:
                null == emoji
                    ? _value.emoji
                    : emoji // ignore: cast_nullable_to_non_nullable
                        as String,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageReactionImplCopyWith<$Res>
    implements $MessageReactionCopyWith<$Res> {
  factory _$$MessageReactionImplCopyWith(
    _$MessageReactionImpl value,
    $Res Function(_$MessageReactionImpl) then,
  ) = __$$MessageReactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String username,
    String? displayName,
    ReactionType reactionType,
    String emoji,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$MessageReactionImplCopyWithImpl<$Res>
    extends _$MessageReactionCopyWithImpl<$Res, _$MessageReactionImpl>
    implements _$$MessageReactionImplCopyWith<$Res> {
  __$$MessageReactionImplCopyWithImpl(
    _$MessageReactionImpl _value,
    $Res Function(_$MessageReactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? reactionType = null,
    Object? emoji = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$MessageReactionImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        username:
            null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                    as String,
        displayName:
            freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String?,
        reactionType:
            null == reactionType
                ? _value.reactionType
                : reactionType // ignore: cast_nullable_to_non_nullable
                    as ReactionType,
        emoji:
            null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                    as String,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageReactionImpl implements _MessageReaction {
  const _$MessageReactionImpl({
    required this.id,
    required this.userId,
    required this.username,
    this.displayName,
    required this.reactionType,
    required this.emoji,
    required this.createdAt,
  });

  factory _$MessageReactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageReactionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String username;
  @override
  final String? displayName;
  @override
  final ReactionType reactionType;
  @override
  final String emoji;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'MessageReaction(id: $id, userId: $userId, username: $username, displayName: $displayName, reactionType: $reactionType, emoji: $emoji, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageReactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.reactionType, reactionType) ||
                other.reactionType == reactionType) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    username,
    displayName,
    reactionType,
    emoji,
    createdAt,
  );

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageReactionImplCopyWith<_$MessageReactionImpl> get copyWith =>
      __$$MessageReactionImplCopyWithImpl<_$MessageReactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageReactionImplToJson(this);
  }
}

abstract class _MessageReaction implements MessageReaction {
  const factory _MessageReaction({
    required final String id,
    required final String userId,
    required final String username,
    final String? displayName,
    required final ReactionType reactionType,
    required final String emoji,
    required final DateTime createdAt,
  }) = _$MessageReactionImpl;

  factory _MessageReaction.fromJson(Map<String, dynamic> json) =
      _$MessageReactionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get username;
  @override
  String? get displayName;
  @override
  ReactionType get reactionType;
  @override
  String get emoji;
  @override
  DateTime get createdAt;

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageReactionImplCopyWith<_$MessageReactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageReadReceipt _$MessageReadReceiptFromJson(Map<String, dynamic> json) {
  return _MessageReadReceipt.fromJson(json);
}

/// @nodoc
mixin _$MessageReadReceipt {
  String get userId => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  DateTime get readAt => throw _privateConstructorUsedError;

  /// Serializes this MessageReadReceipt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageReadReceipt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageReadReceiptCopyWith<MessageReadReceipt> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageReadReceiptCopyWith<$Res> {
  factory $MessageReadReceiptCopyWith(
    MessageReadReceipt value,
    $Res Function(MessageReadReceipt) then,
  ) = _$MessageReadReceiptCopyWithImpl<$Res, MessageReadReceipt>;
  @useResult
  $Res call({
    String userId,
    String username,
    String? displayName,
    DateTime readAt,
  });
}

/// @nodoc
class _$MessageReadReceiptCopyWithImpl<$Res, $Val extends MessageReadReceipt>
    implements $MessageReadReceiptCopyWith<$Res> {
  _$MessageReadReceiptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageReadReceipt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? readAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            username:
                null == username
                    ? _value.username
                    : username // ignore: cast_nullable_to_non_nullable
                        as String,
            displayName:
                freezed == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String?,
            readAt:
                null == readAt
                    ? _value.readAt
                    : readAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageReadReceiptImplCopyWith<$Res>
    implements $MessageReadReceiptCopyWith<$Res> {
  factory _$$MessageReadReceiptImplCopyWith(
    _$MessageReadReceiptImpl value,
    $Res Function(_$MessageReadReceiptImpl) then,
  ) = __$$MessageReadReceiptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String username,
    String? displayName,
    DateTime readAt,
  });
}

/// @nodoc
class __$$MessageReadReceiptImplCopyWithImpl<$Res>
    extends _$MessageReadReceiptCopyWithImpl<$Res, _$MessageReadReceiptImpl>
    implements _$$MessageReadReceiptImplCopyWith<$Res> {
  __$$MessageReadReceiptImplCopyWithImpl(
    _$MessageReadReceiptImpl _value,
    $Res Function(_$MessageReadReceiptImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageReadReceipt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? readAt = null,
  }) {
    return _then(
      _$MessageReadReceiptImpl(
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        username:
            null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                    as String,
        displayName:
            freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String?,
        readAt:
            null == readAt
                ? _value.readAt
                : readAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageReadReceiptImpl implements _MessageReadReceipt {
  const _$MessageReadReceiptImpl({
    required this.userId,
    required this.username,
    this.displayName,
    required this.readAt,
  });

  factory _$MessageReadReceiptImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageReadReceiptImplFromJson(json);

  @override
  final String userId;
  @override
  final String username;
  @override
  final String? displayName;
  @override
  final DateTime readAt;

  @override
  String toString() {
    return 'MessageReadReceipt(userId: $userId, username: $username, displayName: $displayName, readAt: $readAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageReadReceiptImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.readAt, readAt) || other.readAt == readAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, username, displayName, readAt);

  /// Create a copy of MessageReadReceipt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageReadReceiptImplCopyWith<_$MessageReadReceiptImpl> get copyWith =>
      __$$MessageReadReceiptImplCopyWithImpl<_$MessageReadReceiptImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageReadReceiptImplToJson(this);
  }
}

abstract class _MessageReadReceipt implements MessageReadReceipt {
  const factory _MessageReadReceipt({
    required final String userId,
    required final String username,
    final String? displayName,
    required final DateTime readAt,
  }) = _$MessageReadReceiptImpl;

  factory _MessageReadReceipt.fromJson(Map<String, dynamic> json) =
      _$MessageReadReceiptImpl.fromJson;

  @override
  String get userId;
  @override
  String get username;
  @override
  String? get displayName;
  @override
  DateTime get readAt;

  /// Create a copy of MessageReadReceipt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageReadReceiptImplCopyWith<_$MessageReadReceiptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageCreate _$MessageCreateFromJson(Map<String, dynamic> json) {
  return _MessageCreate.fromJson(json);
}

/// @nodoc
mixin _$MessageCreate {
  String? get content => throw _privateConstructorUsedError;
  MessageType get messageType => throw _privateConstructorUsedError;
  List<String> get mediaUrls => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  String? get replyToId => throw _privateConstructorUsedError;
  String? get forwardedFromId => throw _privateConstructorUsedError;

  /// Serializes this MessageCreate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageCreateCopyWith<MessageCreate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCreateCopyWith<$Res> {
  factory $MessageCreateCopyWith(
    MessageCreate value,
    $Res Function(MessageCreate) then,
  ) = _$MessageCreateCopyWithImpl<$Res, MessageCreate>;
  @useResult
  $Res call({
    String? content,
    MessageType messageType,
    List<String> mediaUrls,
    Map<String, dynamic>? metadata,
    String? replyToId,
    String? forwardedFromId,
  });
}

/// @nodoc
class _$MessageCreateCopyWithImpl<$Res, $Val extends MessageCreate>
    implements $MessageCreateCopyWith<$Res> {
  _$MessageCreateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = freezed,
    Object? messageType = null,
    Object? mediaUrls = null,
    Object? metadata = freezed,
    Object? replyToId = freezed,
    Object? forwardedFromId = freezed,
  }) {
    return _then(
      _value.copyWith(
            content:
                freezed == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String?,
            messageType:
                null == messageType
                    ? _value.messageType
                    : messageType // ignore: cast_nullable_to_non_nullable
                        as MessageType,
            mediaUrls:
                null == mediaUrls
                    ? _value.mediaUrls
                    : mediaUrls // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            metadata:
                freezed == metadata
                    ? _value.metadata
                    : metadata // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
            replyToId:
                freezed == replyToId
                    ? _value.replyToId
                    : replyToId // ignore: cast_nullable_to_non_nullable
                        as String?,
            forwardedFromId:
                freezed == forwardedFromId
                    ? _value.forwardedFromId
                    : forwardedFromId // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageCreateImplCopyWith<$Res>
    implements $MessageCreateCopyWith<$Res> {
  factory _$$MessageCreateImplCopyWith(
    _$MessageCreateImpl value,
    $Res Function(_$MessageCreateImpl) then,
  ) = __$$MessageCreateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? content,
    MessageType messageType,
    List<String> mediaUrls,
    Map<String, dynamic>? metadata,
    String? replyToId,
    String? forwardedFromId,
  });
}

/// @nodoc
class __$$MessageCreateImplCopyWithImpl<$Res>
    extends _$MessageCreateCopyWithImpl<$Res, _$MessageCreateImpl>
    implements _$$MessageCreateImplCopyWith<$Res> {
  __$$MessageCreateImplCopyWithImpl(
    _$MessageCreateImpl _value,
    $Res Function(_$MessageCreateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = freezed,
    Object? messageType = null,
    Object? mediaUrls = null,
    Object? metadata = freezed,
    Object? replyToId = freezed,
    Object? forwardedFromId = freezed,
  }) {
    return _then(
      _$MessageCreateImpl(
        content:
            freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String?,
        messageType:
            null == messageType
                ? _value.messageType
                : messageType // ignore: cast_nullable_to_non_nullable
                    as MessageType,
        mediaUrls:
            null == mediaUrls
                ? _value._mediaUrls
                : mediaUrls // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        metadata:
            freezed == metadata
                ? _value._metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
        replyToId:
            freezed == replyToId
                ? _value.replyToId
                : replyToId // ignore: cast_nullable_to_non_nullable
                    as String?,
        forwardedFromId:
            freezed == forwardedFromId
                ? _value.forwardedFromId
                : forwardedFromId // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageCreateImpl implements _MessageCreate {
  const _$MessageCreateImpl({
    this.content,
    this.messageType = MessageType.text,
    final List<String> mediaUrls = const [],
    final Map<String, dynamic>? metadata,
    this.replyToId,
    this.forwardedFromId,
  }) : _mediaUrls = mediaUrls,
       _metadata = metadata;

  factory _$MessageCreateImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageCreateImplFromJson(json);

  @override
  final String? content;
  @override
  @JsonKey()
  final MessageType messageType;
  final List<String> _mediaUrls;
  @override
  @JsonKey()
  List<String> get mediaUrls {
    if (_mediaUrls is EqualUnmodifiableListView) return _mediaUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mediaUrls);
  }

  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? replyToId;
  @override
  final String? forwardedFromId;

  @override
  String toString() {
    return 'MessageCreate(content: $content, messageType: $messageType, mediaUrls: $mediaUrls, metadata: $metadata, replyToId: $replyToId, forwardedFromId: $forwardedFromId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageCreateImpl &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            const DeepCollectionEquality().equals(
              other._mediaUrls,
              _mediaUrls,
            ) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.replyToId, replyToId) ||
                other.replyToId == replyToId) &&
            (identical(other.forwardedFromId, forwardedFromId) ||
                other.forwardedFromId == forwardedFromId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    content,
    messageType,
    const DeepCollectionEquality().hash(_mediaUrls),
    const DeepCollectionEquality().hash(_metadata),
    replyToId,
    forwardedFromId,
  );

  /// Create a copy of MessageCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageCreateImplCopyWith<_$MessageCreateImpl> get copyWith =>
      __$$MessageCreateImplCopyWithImpl<_$MessageCreateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageCreateImplToJson(this);
  }
}

abstract class _MessageCreate implements MessageCreate {
  const factory _MessageCreate({
    final String? content,
    final MessageType messageType,
    final List<String> mediaUrls,
    final Map<String, dynamic>? metadata,
    final String? replyToId,
    final String? forwardedFromId,
  }) = _$MessageCreateImpl;

  factory _MessageCreate.fromJson(Map<String, dynamic> json) =
      _$MessageCreateImpl.fromJson;

  @override
  String? get content;
  @override
  MessageType get messageType;
  @override
  List<String> get mediaUrls;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String? get replyToId;
  @override
  String? get forwardedFromId;

  /// Create a copy of MessageCreate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageCreateImplCopyWith<_$MessageCreateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FriendRequest _$FriendRequestFromJson(Map<String, dynamic> json) {
  return _FriendRequest.fromJson(json);
}

/// @nodoc
mixin _$FriendRequest {
  String get id => throw _privateConstructorUsedError;
  String get requesterId => throw _privateConstructorUsedError;
  String get requesterUsername => throw _privateConstructorUsedError;
  String? get requesterDisplayName => throw _privateConstructorUsedError;
  String? get requesterAvatar => throw _privateConstructorUsedError;
  String get requesteeId => throw _privateConstructorUsedError;
  String get requesteeUsername => throw _privateConstructorUsedError;
  String? get requesteeDisplayName => throw _privateConstructorUsedError;
  String? get requesteeAvatar => throw _privateConstructorUsedError;
  FriendRequestStatus get status => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get respondedAt => throw _privateConstructorUsedError;

  /// Serializes this FriendRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FriendRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendRequestCopyWith<FriendRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendRequestCopyWith<$Res> {
  factory $FriendRequestCopyWith(
    FriendRequest value,
    $Res Function(FriendRequest) then,
  ) = _$FriendRequestCopyWithImpl<$Res, FriendRequest>;
  @useResult
  $Res call({
    String id,
    String requesterId,
    String requesterUsername,
    String? requesterDisplayName,
    String? requesterAvatar,
    String requesteeId,
    String requesteeUsername,
    String? requesteeDisplayName,
    String? requesteeAvatar,
    FriendRequestStatus status,
    String? message,
    DateTime createdAt,
    DateTime? respondedAt,
  });
}

/// @nodoc
class _$FriendRequestCopyWithImpl<$Res, $Val extends FriendRequest>
    implements $FriendRequestCopyWith<$Res> {
  _$FriendRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requesterId = null,
    Object? requesterUsername = null,
    Object? requesterDisplayName = freezed,
    Object? requesterAvatar = freezed,
    Object? requesteeId = null,
    Object? requesteeUsername = null,
    Object? requesteeDisplayName = freezed,
    Object? requesteeAvatar = freezed,
    Object? status = null,
    Object? message = freezed,
    Object? createdAt = null,
    Object? respondedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            requesterId:
                null == requesterId
                    ? _value.requesterId
                    : requesterId // ignore: cast_nullable_to_non_nullable
                        as String,
            requesterUsername:
                null == requesterUsername
                    ? _value.requesterUsername
                    : requesterUsername // ignore: cast_nullable_to_non_nullable
                        as String,
            requesterDisplayName:
                freezed == requesterDisplayName
                    ? _value.requesterDisplayName
                    : requesterDisplayName // ignore: cast_nullable_to_non_nullable
                        as String?,
            requesterAvatar:
                freezed == requesterAvatar
                    ? _value.requesterAvatar
                    : requesterAvatar // ignore: cast_nullable_to_non_nullable
                        as String?,
            requesteeId:
                null == requesteeId
                    ? _value.requesteeId
                    : requesteeId // ignore: cast_nullable_to_non_nullable
                        as String,
            requesteeUsername:
                null == requesteeUsername
                    ? _value.requesteeUsername
                    : requesteeUsername // ignore: cast_nullable_to_non_nullable
                        as String,
            requesteeDisplayName:
                freezed == requesteeDisplayName
                    ? _value.requesteeDisplayName
                    : requesteeDisplayName // ignore: cast_nullable_to_non_nullable
                        as String?,
            requesteeAvatar:
                freezed == requesteeAvatar
                    ? _value.requesteeAvatar
                    : requesteeAvatar // ignore: cast_nullable_to_non_nullable
                        as String?,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as FriendRequestStatus,
            message:
                freezed == message
                    ? _value.message
                    : message // ignore: cast_nullable_to_non_nullable
                        as String?,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            respondedAt:
                freezed == respondedAt
                    ? _value.respondedAt
                    : respondedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FriendRequestImplCopyWith<$Res>
    implements $FriendRequestCopyWith<$Res> {
  factory _$$FriendRequestImplCopyWith(
    _$FriendRequestImpl value,
    $Res Function(_$FriendRequestImpl) then,
  ) = __$$FriendRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String requesterId,
    String requesterUsername,
    String? requesterDisplayName,
    String? requesterAvatar,
    String requesteeId,
    String requesteeUsername,
    String? requesteeDisplayName,
    String? requesteeAvatar,
    FriendRequestStatus status,
    String? message,
    DateTime createdAt,
    DateTime? respondedAt,
  });
}

/// @nodoc
class __$$FriendRequestImplCopyWithImpl<$Res>
    extends _$FriendRequestCopyWithImpl<$Res, _$FriendRequestImpl>
    implements _$$FriendRequestImplCopyWith<$Res> {
  __$$FriendRequestImplCopyWithImpl(
    _$FriendRequestImpl _value,
    $Res Function(_$FriendRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requesterId = null,
    Object? requesterUsername = null,
    Object? requesterDisplayName = freezed,
    Object? requesterAvatar = freezed,
    Object? requesteeId = null,
    Object? requesteeUsername = null,
    Object? requesteeDisplayName = freezed,
    Object? requesteeAvatar = freezed,
    Object? status = null,
    Object? message = freezed,
    Object? createdAt = null,
    Object? respondedAt = freezed,
  }) {
    return _then(
      _$FriendRequestImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        requesterId:
            null == requesterId
                ? _value.requesterId
                : requesterId // ignore: cast_nullable_to_non_nullable
                    as String,
        requesterUsername:
            null == requesterUsername
                ? _value.requesterUsername
                : requesterUsername // ignore: cast_nullable_to_non_nullable
                    as String,
        requesterDisplayName:
            freezed == requesterDisplayName
                ? _value.requesterDisplayName
                : requesterDisplayName // ignore: cast_nullable_to_non_nullable
                    as String?,
        requesterAvatar:
            freezed == requesterAvatar
                ? _value.requesterAvatar
                : requesterAvatar // ignore: cast_nullable_to_non_nullable
                    as String?,
        requesteeId:
            null == requesteeId
                ? _value.requesteeId
                : requesteeId // ignore: cast_nullable_to_non_nullable
                    as String,
        requesteeUsername:
            null == requesteeUsername
                ? _value.requesteeUsername
                : requesteeUsername // ignore: cast_nullable_to_non_nullable
                    as String,
        requesteeDisplayName:
            freezed == requesteeDisplayName
                ? _value.requesteeDisplayName
                : requesteeDisplayName // ignore: cast_nullable_to_non_nullable
                    as String?,
        requesteeAvatar:
            freezed == requesteeAvatar
                ? _value.requesteeAvatar
                : requesteeAvatar // ignore: cast_nullable_to_non_nullable
                    as String?,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as FriendRequestStatus,
        message:
            freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                    as String?,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        respondedAt:
            freezed == respondedAt
                ? _value.respondedAt
                : respondedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendRequestImpl implements _FriendRequest {
  const _$FriendRequestImpl({
    required this.id,
    required this.requesterId,
    required this.requesterUsername,
    this.requesterDisplayName,
    this.requesterAvatar,
    required this.requesteeId,
    required this.requesteeUsername,
    this.requesteeDisplayName,
    this.requesteeAvatar,
    required this.status,
    this.message,
    required this.createdAt,
    this.respondedAt,
  });

  factory _$FriendRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String requesterId;
  @override
  final String requesterUsername;
  @override
  final String? requesterDisplayName;
  @override
  final String? requesterAvatar;
  @override
  final String requesteeId;
  @override
  final String requesteeUsername;
  @override
  final String? requesteeDisplayName;
  @override
  final String? requesteeAvatar;
  @override
  final FriendRequestStatus status;
  @override
  final String? message;
  @override
  final DateTime createdAt;
  @override
  final DateTime? respondedAt;

  @override
  String toString() {
    return 'FriendRequest(id: $id, requesterId: $requesterId, requesterUsername: $requesterUsername, requesterDisplayName: $requesterDisplayName, requesterAvatar: $requesterAvatar, requesteeId: $requesteeId, requesteeUsername: $requesteeUsername, requesteeDisplayName: $requesteeDisplayName, requesteeAvatar: $requesteeAvatar, status: $status, message: $message, createdAt: $createdAt, respondedAt: $respondedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.requesterId, requesterId) ||
                other.requesterId == requesterId) &&
            (identical(other.requesterUsername, requesterUsername) ||
                other.requesterUsername == requesterUsername) &&
            (identical(other.requesterDisplayName, requesterDisplayName) ||
                other.requesterDisplayName == requesterDisplayName) &&
            (identical(other.requesterAvatar, requesterAvatar) ||
                other.requesterAvatar == requesterAvatar) &&
            (identical(other.requesteeId, requesteeId) ||
                other.requesteeId == requesteeId) &&
            (identical(other.requesteeUsername, requesteeUsername) ||
                other.requesteeUsername == requesteeUsername) &&
            (identical(other.requesteeDisplayName, requesteeDisplayName) ||
                other.requesteeDisplayName == requesteeDisplayName) &&
            (identical(other.requesteeAvatar, requesteeAvatar) ||
                other.requesteeAvatar == requesteeAvatar) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.respondedAt, respondedAt) ||
                other.respondedAt == respondedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    requesterId,
    requesterUsername,
    requesterDisplayName,
    requesterAvatar,
    requesteeId,
    requesteeUsername,
    requesteeDisplayName,
    requesteeAvatar,
    status,
    message,
    createdAt,
    respondedAt,
  );

  /// Create a copy of FriendRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendRequestImplCopyWith<_$FriendRequestImpl> get copyWith =>
      __$$FriendRequestImplCopyWithImpl<_$FriendRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendRequestImplToJson(this);
  }
}

abstract class _FriendRequest implements FriendRequest {
  const factory _FriendRequest({
    required final String id,
    required final String requesterId,
    required final String requesterUsername,
    final String? requesterDisplayName,
    final String? requesterAvatar,
    required final String requesteeId,
    required final String requesteeUsername,
    final String? requesteeDisplayName,
    final String? requesteeAvatar,
    required final FriendRequestStatus status,
    final String? message,
    required final DateTime createdAt,
    final DateTime? respondedAt,
  }) = _$FriendRequestImpl;

  factory _FriendRequest.fromJson(Map<String, dynamic> json) =
      _$FriendRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get requesterId;
  @override
  String get requesterUsername;
  @override
  String? get requesterDisplayName;
  @override
  String? get requesterAvatar;
  @override
  String get requesteeId;
  @override
  String get requesteeUsername;
  @override
  String? get requesteeDisplayName;
  @override
  String? get requesteeAvatar;
  @override
  FriendRequestStatus get status;
  @override
  String? get message;
  @override
  DateTime get createdAt;
  @override
  DateTime? get respondedAt;

  /// Create a copy of FriendRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendRequestImplCopyWith<_$FriendRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Friend _$FriendFromJson(Map<String, dynamic> json) {
  return _Friend.fromJson(json);
}

/// @nodoc
mixin _$Friend {
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;
  DateTime? get lastSeen => throw _privateConstructorUsedError;
  DateTime get friendsSince => throw _privateConstructorUsedError;
  int get mutualFriendsCount => throw _privateConstructorUsedError;
  bool get canMessage => throw _privateConstructorUsedError;

  /// Serializes this Friend to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Friend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendCopyWith<Friend> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendCopyWith<$Res> {
  factory $FriendCopyWith(Friend value, $Res Function(Friend) then) =
      _$FriendCopyWithImpl<$Res, Friend>;
  @useResult
  $Res call({
    String id,
    String username,
    String? displayName,
    String? avatarUrl,
    bool isOnline,
    DateTime? lastSeen,
    DateTime friendsSince,
    int mutualFriendsCount,
    bool canMessage,
  });
}

/// @nodoc
class _$FriendCopyWithImpl<$Res, $Val extends Friend>
    implements $FriendCopyWith<$Res> {
  _$FriendCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Friend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? isOnline = null,
    Object? lastSeen = freezed,
    Object? friendsSince = null,
    Object? mutualFriendsCount = null,
    Object? canMessage = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            username:
                null == username
                    ? _value.username
                    : username // ignore: cast_nullable_to_non_nullable
                        as String,
            displayName:
                freezed == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String?,
            avatarUrl:
                freezed == avatarUrl
                    ? _value.avatarUrl
                    : avatarUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            isOnline:
                null == isOnline
                    ? _value.isOnline
                    : isOnline // ignore: cast_nullable_to_non_nullable
                        as bool,
            lastSeen:
                freezed == lastSeen
                    ? _value.lastSeen
                    : lastSeen // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            friendsSince:
                null == friendsSince
                    ? _value.friendsSince
                    : friendsSince // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            mutualFriendsCount:
                null == mutualFriendsCount
                    ? _value.mutualFriendsCount
                    : mutualFriendsCount // ignore: cast_nullable_to_non_nullable
                        as int,
            canMessage:
                null == canMessage
                    ? _value.canMessage
                    : canMessage // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FriendImplCopyWith<$Res> implements $FriendCopyWith<$Res> {
  factory _$$FriendImplCopyWith(
    _$FriendImpl value,
    $Res Function(_$FriendImpl) then,
  ) = __$$FriendImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String username,
    String? displayName,
    String? avatarUrl,
    bool isOnline,
    DateTime? lastSeen,
    DateTime friendsSince,
    int mutualFriendsCount,
    bool canMessage,
  });
}

/// @nodoc
class __$$FriendImplCopyWithImpl<$Res>
    extends _$FriendCopyWithImpl<$Res, _$FriendImpl>
    implements _$$FriendImplCopyWith<$Res> {
  __$$FriendImplCopyWithImpl(
    _$FriendImpl _value,
    $Res Function(_$FriendImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Friend
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? isOnline = null,
    Object? lastSeen = freezed,
    Object? friendsSince = null,
    Object? mutualFriendsCount = null,
    Object? canMessage = null,
  }) {
    return _then(
      _$FriendImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        username:
            null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                    as String,
        displayName:
            freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String?,
        avatarUrl:
            freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        isOnline:
            null == isOnline
                ? _value.isOnline
                : isOnline // ignore: cast_nullable_to_non_nullable
                    as bool,
        lastSeen:
            freezed == lastSeen
                ? _value.lastSeen
                : lastSeen // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        friendsSince:
            null == friendsSince
                ? _value.friendsSince
                : friendsSince // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        mutualFriendsCount:
            null == mutualFriendsCount
                ? _value.mutualFriendsCount
                : mutualFriendsCount // ignore: cast_nullable_to_non_nullable
                    as int,
        canMessage:
            null == canMessage
                ? _value.canMessage
                : canMessage // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendImpl implements _Friend {
  const _$FriendImpl({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.isOnline = false,
    this.lastSeen,
    required this.friendsSince,
    this.mutualFriendsCount = 0,
    this.canMessage = true,
  });

  factory _$FriendImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendImplFromJson(json);

  @override
  final String id;
  @override
  final String username;
  @override
  final String? displayName;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final bool isOnline;
  @override
  final DateTime? lastSeen;
  @override
  final DateTime friendsSince;
  @override
  @JsonKey()
  final int mutualFriendsCount;
  @override
  @JsonKey()
  final bool canMessage;

  @override
  String toString() {
    return 'Friend(id: $id, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, isOnline: $isOnline, lastSeen: $lastSeen, friendsSince: $friendsSince, mutualFriendsCount: $mutualFriendsCount, canMessage: $canMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.friendsSince, friendsSince) ||
                other.friendsSince == friendsSince) &&
            (identical(other.mutualFriendsCount, mutualFriendsCount) ||
                other.mutualFriendsCount == mutualFriendsCount) &&
            (identical(other.canMessage, canMessage) ||
                other.canMessage == canMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    username,
    displayName,
    avatarUrl,
    isOnline,
    lastSeen,
    friendsSince,
    mutualFriendsCount,
    canMessage,
  );

  /// Create a copy of Friend
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendImplCopyWith<_$FriendImpl> get copyWith =>
      __$$FriendImplCopyWithImpl<_$FriendImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendImplToJson(this);
  }
}

abstract class _Friend implements Friend {
  const factory _Friend({
    required final String id,
    required final String username,
    final String? displayName,
    final String? avatarUrl,
    final bool isOnline,
    final DateTime? lastSeen,
    required final DateTime friendsSince,
    final int mutualFriendsCount,
    final bool canMessage,
  }) = _$FriendImpl;

  factory _Friend.fromJson(Map<String, dynamic> json) = _$FriendImpl.fromJson;

  @override
  String get id;
  @override
  String get username;
  @override
  String? get displayName;
  @override
  String? get avatarUrl;
  @override
  bool get isOnline;
  @override
  DateTime? get lastSeen;
  @override
  DateTime get friendsSince;
  @override
  int get mutualFriendsCount;
  @override
  bool get canMessage;

  /// Create a copy of Friend
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendImplCopyWith<_$FriendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserSearchResult _$UserSearchResultFromJson(Map<String, dynamic> json) {
  return _UserSearchResult.fromJson(json);
}

/// @nodoc
mixin _$UserSearchResult {
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;
  int get mutualFriendsCount => throw _privateConstructorUsedError;
  String? get friendshipStatus => throw _privateConstructorUsedError;
  bool get canSendRequest => throw _privateConstructorUsedError;

  /// Serializes this UserSearchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSearchResultCopyWith<UserSearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSearchResultCopyWith<$Res> {
  factory $UserSearchResultCopyWith(
    UserSearchResult value,
    $Res Function(UserSearchResult) then,
  ) = _$UserSearchResultCopyWithImpl<$Res, UserSearchResult>;
  @useResult
  $Res call({
    String id,
    String username,
    String? displayName,
    String? avatarUrl,
    bool isOnline,
    int mutualFriendsCount,
    String? friendshipStatus,
    bool canSendRequest,
  });
}

/// @nodoc
class _$UserSearchResultCopyWithImpl<$Res, $Val extends UserSearchResult>
    implements $UserSearchResultCopyWith<$Res> {
  _$UserSearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? isOnline = null,
    Object? mutualFriendsCount = null,
    Object? friendshipStatus = freezed,
    Object? canSendRequest = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            username:
                null == username
                    ? _value.username
                    : username // ignore: cast_nullable_to_non_nullable
                        as String,
            displayName:
                freezed == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String?,
            avatarUrl:
                freezed == avatarUrl
                    ? _value.avatarUrl
                    : avatarUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            isOnline:
                null == isOnline
                    ? _value.isOnline
                    : isOnline // ignore: cast_nullable_to_non_nullable
                        as bool,
            mutualFriendsCount:
                null == mutualFriendsCount
                    ? _value.mutualFriendsCount
                    : mutualFriendsCount // ignore: cast_nullable_to_non_nullable
                        as int,
            friendshipStatus:
                freezed == friendshipStatus
                    ? _value.friendshipStatus
                    : friendshipStatus // ignore: cast_nullable_to_non_nullable
                        as String?,
            canSendRequest:
                null == canSendRequest
                    ? _value.canSendRequest
                    : canSendRequest // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserSearchResultImplCopyWith<$Res>
    implements $UserSearchResultCopyWith<$Res> {
  factory _$$UserSearchResultImplCopyWith(
    _$UserSearchResultImpl value,
    $Res Function(_$UserSearchResultImpl) then,
  ) = __$$UserSearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String username,
    String? displayName,
    String? avatarUrl,
    bool isOnline,
    int mutualFriendsCount,
    String? friendshipStatus,
    bool canSendRequest,
  });
}

/// @nodoc
class __$$UserSearchResultImplCopyWithImpl<$Res>
    extends _$UserSearchResultCopyWithImpl<$Res, _$UserSearchResultImpl>
    implements _$$UserSearchResultImplCopyWith<$Res> {
  __$$UserSearchResultImplCopyWithImpl(
    _$UserSearchResultImpl _value,
    $Res Function(_$UserSearchResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? isOnline = null,
    Object? mutualFriendsCount = null,
    Object? friendshipStatus = freezed,
    Object? canSendRequest = null,
  }) {
    return _then(
      _$UserSearchResultImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        username:
            null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                    as String,
        displayName:
            freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String?,
        avatarUrl:
            freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        isOnline:
            null == isOnline
                ? _value.isOnline
                : isOnline // ignore: cast_nullable_to_non_nullable
                    as bool,
        mutualFriendsCount:
            null == mutualFriendsCount
                ? _value.mutualFriendsCount
                : mutualFriendsCount // ignore: cast_nullable_to_non_nullable
                    as int,
        friendshipStatus:
            freezed == friendshipStatus
                ? _value.friendshipStatus
                : friendshipStatus // ignore: cast_nullable_to_non_nullable
                    as String?,
        canSendRequest:
            null == canSendRequest
                ? _value.canSendRequest
                : canSendRequest // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSearchResultImpl implements _UserSearchResult {
  const _$UserSearchResultImpl({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.isOnline = false,
    this.mutualFriendsCount = 0,
    this.friendshipStatus,
    this.canSendRequest = true,
  });

  factory _$UserSearchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSearchResultImplFromJson(json);

  @override
  final String id;
  @override
  final String username;
  @override
  final String? displayName;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final bool isOnline;
  @override
  @JsonKey()
  final int mutualFriendsCount;
  @override
  final String? friendshipStatus;
  @override
  @JsonKey()
  final bool canSendRequest;

  @override
  String toString() {
    return 'UserSearchResult(id: $id, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, isOnline: $isOnline, mutualFriendsCount: $mutualFriendsCount, friendshipStatus: $friendshipStatus, canSendRequest: $canSendRequest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSearchResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.mutualFriendsCount, mutualFriendsCount) ||
                other.mutualFriendsCount == mutualFriendsCount) &&
            (identical(other.friendshipStatus, friendshipStatus) ||
                other.friendshipStatus == friendshipStatus) &&
            (identical(other.canSendRequest, canSendRequest) ||
                other.canSendRequest == canSendRequest));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    username,
    displayName,
    avatarUrl,
    isOnline,
    mutualFriendsCount,
    friendshipStatus,
    canSendRequest,
  );

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSearchResultImplCopyWith<_$UserSearchResultImpl> get copyWith =>
      __$$UserSearchResultImplCopyWithImpl<_$UserSearchResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSearchResultImplToJson(this);
  }
}

abstract class _UserSearchResult implements UserSearchResult {
  const factory _UserSearchResult({
    required final String id,
    required final String username,
    final String? displayName,
    final String? avatarUrl,
    final bool isOnline,
    final int mutualFriendsCount,
    final String? friendshipStatus,
    final bool canSendRequest,
  }) = _$UserSearchResultImpl;

  factory _UserSearchResult.fromJson(Map<String, dynamic> json) =
      _$UserSearchResultImpl.fromJson;

  @override
  String get id;
  @override
  String get username;
  @override
  String? get displayName;
  @override
  String? get avatarUrl;
  @override
  bool get isOnline;
  @override
  int get mutualFriendsCount;
  @override
  String? get friendshipStatus;
  @override
  bool get canSendRequest;

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSearchResultImplCopyWith<_$UserSearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WebSocketMessage _$WebSocketMessageFromJson(Map<String, dynamic> json) {
  return _WebSocketMessage.fromJson(json);
}

/// @nodoc
mixin _$WebSocketMessage {
  String get type => throw _privateConstructorUsedError;
  Map<String, dynamic> get data => throw _privateConstructorUsedError;
  String? get roomId => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this WebSocketMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WebSocketMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebSocketMessageCopyWith<WebSocketMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebSocketMessageCopyWith<$Res> {
  factory $WebSocketMessageCopyWith(
    WebSocketMessage value,
    $Res Function(WebSocketMessage) then,
  ) = _$WebSocketMessageCopyWithImpl<$Res, WebSocketMessage>;
  @useResult
  $Res call({
    String type,
    Map<String, dynamic> data,
    String? roomId,
    String? userId,
    DateTime timestamp,
  });
}

/// @nodoc
class _$WebSocketMessageCopyWithImpl<$Res, $Val extends WebSocketMessage>
    implements $WebSocketMessageCopyWith<$Res> {
  _$WebSocketMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebSocketMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? data = null,
    Object? roomId = freezed,
    Object? userId = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            data:
                null == data
                    ? _value.data
                    : data // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
            roomId:
                freezed == roomId
                    ? _value.roomId
                    : roomId // ignore: cast_nullable_to_non_nullable
                        as String?,
            userId:
                freezed == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String?,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WebSocketMessageImplCopyWith<$Res>
    implements $WebSocketMessageCopyWith<$Res> {
  factory _$$WebSocketMessageImplCopyWith(
    _$WebSocketMessageImpl value,
    $Res Function(_$WebSocketMessageImpl) then,
  ) = __$$WebSocketMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    Map<String, dynamic> data,
    String? roomId,
    String? userId,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$WebSocketMessageImplCopyWithImpl<$Res>
    extends _$WebSocketMessageCopyWithImpl<$Res, _$WebSocketMessageImpl>
    implements _$$WebSocketMessageImplCopyWith<$Res> {
  __$$WebSocketMessageImplCopyWithImpl(
    _$WebSocketMessageImpl _value,
    $Res Function(_$WebSocketMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WebSocketMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? data = null,
    Object? roomId = freezed,
    Object? userId = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _$WebSocketMessageImpl(
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        data:
            null == data
                ? _value._data
                : data // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
        roomId:
            freezed == roomId
                ? _value.roomId
                : roomId // ignore: cast_nullable_to_non_nullable
                    as String?,
        userId:
            freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String?,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WebSocketMessageImpl implements _WebSocketMessage {
  const _$WebSocketMessageImpl({
    required this.type,
    required final Map<String, dynamic> data,
    this.roomId,
    this.userId,
    required this.timestamp,
  }) : _data = data;

  factory _$WebSocketMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$WebSocketMessageImplFromJson(json);

  @override
  final String type;
  final Map<String, dynamic> _data;
  @override
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  final String? roomId;
  @override
  final String? userId;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'WebSocketMessage(type: $type, data: $data, roomId: $roomId, userId: $userId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebSocketMessageImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    const DeepCollectionEquality().hash(_data),
    roomId,
    userId,
    timestamp,
  );

  /// Create a copy of WebSocketMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebSocketMessageImplCopyWith<_$WebSocketMessageImpl> get copyWith =>
      __$$WebSocketMessageImplCopyWithImpl<_$WebSocketMessageImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WebSocketMessageImplToJson(this);
  }
}

abstract class _WebSocketMessage implements WebSocketMessage {
  const factory _WebSocketMessage({
    required final String type,
    required final Map<String, dynamic> data,
    final String? roomId,
    final String? userId,
    required final DateTime timestamp,
  }) = _$WebSocketMessageImpl;

  factory _WebSocketMessage.fromJson(Map<String, dynamic> json) =
      _$WebSocketMessageImpl.fromJson;

  @override
  String get type;
  @override
  Map<String, dynamic> get data;
  @override
  String? get roomId;
  @override
  String? get userId;
  @override
  DateTime get timestamp;

  /// Create a copy of WebSocketMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebSocketMessageImplCopyWith<_$WebSocketMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TypingIndicator _$TypingIndicatorFromJson(Map<String, dynamic> json) {
  return _TypingIndicator.fromJson(json);
}

/// @nodoc
mixin _$TypingIndicator {
  String get roomId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this TypingIndicator to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TypingIndicator
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TypingIndicatorCopyWith<TypingIndicator> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TypingIndicatorCopyWith<$Res> {
  factory $TypingIndicatorCopyWith(
    TypingIndicator value,
    $Res Function(TypingIndicator) then,
  ) = _$TypingIndicatorCopyWithImpl<$Res, TypingIndicator>;
  @useResult
  $Res call({
    String roomId,
    String userId,
    String username,
    String? displayName,
    DateTime startedAt,
    DateTime expiresAt,
  });
}

/// @nodoc
class _$TypingIndicatorCopyWithImpl<$Res, $Val extends TypingIndicator>
    implements $TypingIndicatorCopyWith<$Res> {
  _$TypingIndicatorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TypingIndicator
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? userId = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? startedAt = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _value.copyWith(
            roomId:
                null == roomId
                    ? _value.roomId
                    : roomId // ignore: cast_nullable_to_non_nullable
                        as String,
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            username:
                null == username
                    ? _value.username
                    : username // ignore: cast_nullable_to_non_nullable
                        as String,
            displayName:
                freezed == displayName
                    ? _value.displayName
                    : displayName // ignore: cast_nullable_to_non_nullable
                        as String?,
            startedAt:
                null == startedAt
                    ? _value.startedAt
                    : startedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            expiresAt:
                null == expiresAt
                    ? _value.expiresAt
                    : expiresAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TypingIndicatorImplCopyWith<$Res>
    implements $TypingIndicatorCopyWith<$Res> {
  factory _$$TypingIndicatorImplCopyWith(
    _$TypingIndicatorImpl value,
    $Res Function(_$TypingIndicatorImpl) then,
  ) = __$$TypingIndicatorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String roomId,
    String userId,
    String username,
    String? displayName,
    DateTime startedAt,
    DateTime expiresAt,
  });
}

/// @nodoc
class __$$TypingIndicatorImplCopyWithImpl<$Res>
    extends _$TypingIndicatorCopyWithImpl<$Res, _$TypingIndicatorImpl>
    implements _$$TypingIndicatorImplCopyWith<$Res> {
  __$$TypingIndicatorImplCopyWithImpl(
    _$TypingIndicatorImpl _value,
    $Res Function(_$TypingIndicatorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TypingIndicator
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? userId = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? startedAt = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _$TypingIndicatorImpl(
        roomId:
            null == roomId
                ? _value.roomId
                : roomId // ignore: cast_nullable_to_non_nullable
                    as String,
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        username:
            null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                    as String,
        displayName:
            freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                    as String?,
        startedAt:
            null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        expiresAt:
            null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TypingIndicatorImpl implements _TypingIndicator {
  const _$TypingIndicatorImpl({
    required this.roomId,
    required this.userId,
    required this.username,
    this.displayName,
    required this.startedAt,
    required this.expiresAt,
  });

  factory _$TypingIndicatorImpl.fromJson(Map<String, dynamic> json) =>
      _$$TypingIndicatorImplFromJson(json);

  @override
  final String roomId;
  @override
  final String userId;
  @override
  final String username;
  @override
  final String? displayName;
  @override
  final DateTime startedAt;
  @override
  final DateTime expiresAt;

  @override
  String toString() {
    return 'TypingIndicator(roomId: $roomId, userId: $userId, username: $username, displayName: $displayName, startedAt: $startedAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TypingIndicatorImpl &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    roomId,
    userId,
    username,
    displayName,
    startedAt,
    expiresAt,
  );

  /// Create a copy of TypingIndicator
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TypingIndicatorImplCopyWith<_$TypingIndicatorImpl> get copyWith =>
      __$$TypingIndicatorImplCopyWithImpl<_$TypingIndicatorImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TypingIndicatorImplToJson(this);
  }
}

abstract class _TypingIndicator implements TypingIndicator {
  const factory _TypingIndicator({
    required final String roomId,
    required final String userId,
    required final String username,
    final String? displayName,
    required final DateTime startedAt,
    required final DateTime expiresAt,
  }) = _$TypingIndicatorImpl;

  factory _TypingIndicator.fromJson(Map<String, dynamic> json) =
      _$TypingIndicatorImpl.fromJson;

  @override
  String get roomId;
  @override
  String get userId;
  @override
  String get username;
  @override
  String? get displayName;
  @override
  DateTime get startedAt;
  @override
  DateTime get expiresAt;

  /// Create a copy of TypingIndicator
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TypingIndicatorImplCopyWith<_$TypingIndicatorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserOnlineStatus _$UserOnlineStatusFromJson(Map<String, dynamic> json) {
  return _UserOnlineStatus.fromJson(json);
}

/// @nodoc
mixin _$UserOnlineStatus {
  String get userId => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;
  DateTime? get lastSeen => throw _privateConstructorUsedError;
  DateTime? get lastActivity => throw _privateConstructorUsedError;

  /// Serializes this UserOnlineStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserOnlineStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserOnlineStatusCopyWith<UserOnlineStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserOnlineStatusCopyWith<$Res> {
  factory $UserOnlineStatusCopyWith(
    UserOnlineStatus value,
    $Res Function(UserOnlineStatus) then,
  ) = _$UserOnlineStatusCopyWithImpl<$Res, UserOnlineStatus>;
  @useResult
  $Res call({
    String userId,
    bool isOnline,
    DateTime? lastSeen,
    DateTime? lastActivity,
  });
}

/// @nodoc
class _$UserOnlineStatusCopyWithImpl<$Res, $Val extends UserOnlineStatus>
    implements $UserOnlineStatusCopyWith<$Res> {
  _$UserOnlineStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserOnlineStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? isOnline = null,
    Object? lastSeen = freezed,
    Object? lastActivity = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            isOnline:
                null == isOnline
                    ? _value.isOnline
                    : isOnline // ignore: cast_nullable_to_non_nullable
                        as bool,
            lastSeen:
                freezed == lastSeen
                    ? _value.lastSeen
                    : lastSeen // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            lastActivity:
                freezed == lastActivity
                    ? _value.lastActivity
                    : lastActivity // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserOnlineStatusImplCopyWith<$Res>
    implements $UserOnlineStatusCopyWith<$Res> {
  factory _$$UserOnlineStatusImplCopyWith(
    _$UserOnlineStatusImpl value,
    $Res Function(_$UserOnlineStatusImpl) then,
  ) = __$$UserOnlineStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    bool isOnline,
    DateTime? lastSeen,
    DateTime? lastActivity,
  });
}

/// @nodoc
class __$$UserOnlineStatusImplCopyWithImpl<$Res>
    extends _$UserOnlineStatusCopyWithImpl<$Res, _$UserOnlineStatusImpl>
    implements _$$UserOnlineStatusImplCopyWith<$Res> {
  __$$UserOnlineStatusImplCopyWithImpl(
    _$UserOnlineStatusImpl _value,
    $Res Function(_$UserOnlineStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserOnlineStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? isOnline = null,
    Object? lastSeen = freezed,
    Object? lastActivity = freezed,
  }) {
    return _then(
      _$UserOnlineStatusImpl(
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        isOnline:
            null == isOnline
                ? _value.isOnline
                : isOnline // ignore: cast_nullable_to_non_nullable
                    as bool,
        lastSeen:
            freezed == lastSeen
                ? _value.lastSeen
                : lastSeen // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        lastActivity:
            freezed == lastActivity
                ? _value.lastActivity
                : lastActivity // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserOnlineStatusImpl implements _UserOnlineStatus {
  const _$UserOnlineStatusImpl({
    required this.userId,
    required this.isOnline,
    this.lastSeen,
    this.lastActivity,
  });

  factory _$UserOnlineStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserOnlineStatusImplFromJson(json);

  @override
  final String userId;
  @override
  final bool isOnline;
  @override
  final DateTime? lastSeen;
  @override
  final DateTime? lastActivity;

  @override
  String toString() {
    return 'UserOnlineStatus(userId: $userId, isOnline: $isOnline, lastSeen: $lastSeen, lastActivity: $lastActivity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserOnlineStatusImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.lastActivity, lastActivity) ||
                other.lastActivity == lastActivity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, isOnline, lastSeen, lastActivity);

  /// Create a copy of UserOnlineStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserOnlineStatusImplCopyWith<_$UserOnlineStatusImpl> get copyWith =>
      __$$UserOnlineStatusImplCopyWithImpl<_$UserOnlineStatusImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserOnlineStatusImplToJson(this);
  }
}

abstract class _UserOnlineStatus implements UserOnlineStatus {
  const factory _UserOnlineStatus({
    required final String userId,
    required final bool isOnline,
    final DateTime? lastSeen,
    final DateTime? lastActivity,
  }) = _$UserOnlineStatusImpl;

  factory _UserOnlineStatus.fromJson(Map<String, dynamic> json) =
      _$UserOnlineStatusImpl.fromJson;

  @override
  String get userId;
  @override
  bool get isOnline;
  @override
  DateTime? get lastSeen;
  @override
  DateTime? get lastActivity;

  /// Create a copy of UserOnlineStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserOnlineStatusImplCopyWith<_$UserOnlineStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatRoomListResponse _$ChatRoomListResponseFromJson(Map<String, dynamic> json) {
  return _ChatRoomListResponse.fromJson(json);
}

/// @nodoc
mixin _$ChatRoomListResponse {
  List<ChatRoom> get rooms => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get pages => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;
  bool get hasPrev => throw _privateConstructorUsedError;

  /// Serializes this ChatRoomListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatRoomListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatRoomListResponseCopyWith<ChatRoomListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRoomListResponseCopyWith<$Res> {
  factory $ChatRoomListResponseCopyWith(
    ChatRoomListResponse value,
    $Res Function(ChatRoomListResponse) then,
  ) = _$ChatRoomListResponseCopyWithImpl<$Res, ChatRoomListResponse>;
  @useResult
  $Res call({
    List<ChatRoom> rooms,
    int total,
    int page,
    int pages,
    bool hasNext,
    bool hasPrev,
  });
}

/// @nodoc
class _$ChatRoomListResponseCopyWithImpl<
  $Res,
  $Val extends ChatRoomListResponse
>
    implements $ChatRoomListResponseCopyWith<$Res> {
  _$ChatRoomListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatRoomListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rooms = null,
    Object? total = null,
    Object? page = null,
    Object? pages = null,
    Object? hasNext = null,
    Object? hasPrev = null,
  }) {
    return _then(
      _value.copyWith(
            rooms:
                null == rooms
                    ? _value.rooms
                    : rooms // ignore: cast_nullable_to_non_nullable
                        as List<ChatRoom>,
            total:
                null == total
                    ? _value.total
                    : total // ignore: cast_nullable_to_non_nullable
                        as int,
            page:
                null == page
                    ? _value.page
                    : page // ignore: cast_nullable_to_non_nullable
                        as int,
            pages:
                null == pages
                    ? _value.pages
                    : pages // ignore: cast_nullable_to_non_nullable
                        as int,
            hasNext:
                null == hasNext
                    ? _value.hasNext
                    : hasNext // ignore: cast_nullable_to_non_nullable
                        as bool,
            hasPrev:
                null == hasPrev
                    ? _value.hasPrev
                    : hasPrev // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatRoomListResponseImplCopyWith<$Res>
    implements $ChatRoomListResponseCopyWith<$Res> {
  factory _$$ChatRoomListResponseImplCopyWith(
    _$ChatRoomListResponseImpl value,
    $Res Function(_$ChatRoomListResponseImpl) then,
  ) = __$$ChatRoomListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ChatRoom> rooms,
    int total,
    int page,
    int pages,
    bool hasNext,
    bool hasPrev,
  });
}

/// @nodoc
class __$$ChatRoomListResponseImplCopyWithImpl<$Res>
    extends _$ChatRoomListResponseCopyWithImpl<$Res, _$ChatRoomListResponseImpl>
    implements _$$ChatRoomListResponseImplCopyWith<$Res> {
  __$$ChatRoomListResponseImplCopyWithImpl(
    _$ChatRoomListResponseImpl _value,
    $Res Function(_$ChatRoomListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatRoomListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rooms = null,
    Object? total = null,
    Object? page = null,
    Object? pages = null,
    Object? hasNext = null,
    Object? hasPrev = null,
  }) {
    return _then(
      _$ChatRoomListResponseImpl(
        rooms:
            null == rooms
                ? _value._rooms
                : rooms // ignore: cast_nullable_to_non_nullable
                    as List<ChatRoom>,
        total:
            null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                    as int,
        page:
            null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                    as int,
        pages:
            null == pages
                ? _value.pages
                : pages // ignore: cast_nullable_to_non_nullable
                    as int,
        hasNext:
            null == hasNext
                ? _value.hasNext
                : hasNext // ignore: cast_nullable_to_non_nullable
                    as bool,
        hasPrev:
            null == hasPrev
                ? _value.hasPrev
                : hasPrev // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRoomListResponseImpl implements _ChatRoomListResponse {
  const _$ChatRoomListResponseImpl({
    final List<ChatRoom> rooms = const [],
    this.total = 0,
    this.page = 1,
    this.pages = 0,
    this.hasNext = false,
    this.hasPrev = false,
  }) : _rooms = rooms;

  factory _$ChatRoomListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatRoomListResponseImplFromJson(json);

  final List<ChatRoom> _rooms;
  @override
  @JsonKey()
  List<ChatRoom> get rooms {
    if (_rooms is EqualUnmodifiableListView) return _rooms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rooms);
  }

  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int pages;
  @override
  @JsonKey()
  final bool hasNext;
  @override
  @JsonKey()
  final bool hasPrev;

  @override
  String toString() {
    return 'ChatRoomListResponse(rooms: $rooms, total: $total, page: $page, pages: $pages, hasNext: $hasNext, hasPrev: $hasPrev)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRoomListResponseImpl &&
            const DeepCollectionEquality().equals(other._rooms, _rooms) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pages, pages) || other.pages == pages) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext) &&
            (identical(other.hasPrev, hasPrev) || other.hasPrev == hasPrev));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_rooms),
    total,
    page,
    pages,
    hasNext,
    hasPrev,
  );

  /// Create a copy of ChatRoomListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRoomListResponseImplCopyWith<_$ChatRoomListResponseImpl>
  get copyWith =>
      __$$ChatRoomListResponseImplCopyWithImpl<_$ChatRoomListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatRoomListResponseImplToJson(this);
  }
}

abstract class _ChatRoomListResponse implements ChatRoomListResponse {
  const factory _ChatRoomListResponse({
    final List<ChatRoom> rooms,
    final int total,
    final int page,
    final int pages,
    final bool hasNext,
    final bool hasPrev,
  }) = _$ChatRoomListResponseImpl;

  factory _ChatRoomListResponse.fromJson(Map<String, dynamic> json) =
      _$ChatRoomListResponseImpl.fromJson;

  @override
  List<ChatRoom> get rooms;
  @override
  int get total;
  @override
  int get page;
  @override
  int get pages;
  @override
  bool get hasNext;
  @override
  bool get hasPrev;

  /// Create a copy of ChatRoomListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatRoomListResponseImplCopyWith<_$ChatRoomListResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MessageListResponse _$MessageListResponseFromJson(Map<String, dynamic> json) {
  return _MessageListResponse.fromJson(json);
}

/// @nodoc
mixin _$MessageListResponse {
  List<ChatMessage> get messages => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get pages => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;
  bool get hasPrev => throw _privateConstructorUsedError;

  /// Serializes this MessageListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageListResponseCopyWith<MessageListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageListResponseCopyWith<$Res> {
  factory $MessageListResponseCopyWith(
    MessageListResponse value,
    $Res Function(MessageListResponse) then,
  ) = _$MessageListResponseCopyWithImpl<$Res, MessageListResponse>;
  @useResult
  $Res call({
    List<ChatMessage> messages,
    int total,
    int page,
    int pages,
    bool hasNext,
    bool hasPrev,
  });
}

/// @nodoc
class _$MessageListResponseCopyWithImpl<$Res, $Val extends MessageListResponse>
    implements $MessageListResponseCopyWith<$Res> {
  _$MessageListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? total = null,
    Object? page = null,
    Object? pages = null,
    Object? hasNext = null,
    Object? hasPrev = null,
  }) {
    return _then(
      _value.copyWith(
            messages:
                null == messages
                    ? _value.messages
                    : messages // ignore: cast_nullable_to_non_nullable
                        as List<ChatMessage>,
            total:
                null == total
                    ? _value.total
                    : total // ignore: cast_nullable_to_non_nullable
                        as int,
            page:
                null == page
                    ? _value.page
                    : page // ignore: cast_nullable_to_non_nullable
                        as int,
            pages:
                null == pages
                    ? _value.pages
                    : pages // ignore: cast_nullable_to_non_nullable
                        as int,
            hasNext:
                null == hasNext
                    ? _value.hasNext
                    : hasNext // ignore: cast_nullable_to_non_nullable
                        as bool,
            hasPrev:
                null == hasPrev
                    ? _value.hasPrev
                    : hasPrev // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageListResponseImplCopyWith<$Res>
    implements $MessageListResponseCopyWith<$Res> {
  factory _$$MessageListResponseImplCopyWith(
    _$MessageListResponseImpl value,
    $Res Function(_$MessageListResponseImpl) then,
  ) = __$$MessageListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ChatMessage> messages,
    int total,
    int page,
    int pages,
    bool hasNext,
    bool hasPrev,
  });
}

/// @nodoc
class __$$MessageListResponseImplCopyWithImpl<$Res>
    extends _$MessageListResponseCopyWithImpl<$Res, _$MessageListResponseImpl>
    implements _$$MessageListResponseImplCopyWith<$Res> {
  __$$MessageListResponseImplCopyWithImpl(
    _$MessageListResponseImpl _value,
    $Res Function(_$MessageListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? total = null,
    Object? page = null,
    Object? pages = null,
    Object? hasNext = null,
    Object? hasPrev = null,
  }) {
    return _then(
      _$MessageListResponseImpl(
        messages:
            null == messages
                ? _value._messages
                : messages // ignore: cast_nullable_to_non_nullable
                    as List<ChatMessage>,
        total:
            null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                    as int,
        page:
            null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                    as int,
        pages:
            null == pages
                ? _value.pages
                : pages // ignore: cast_nullable_to_non_nullable
                    as int,
        hasNext:
            null == hasNext
                ? _value.hasNext
                : hasNext // ignore: cast_nullable_to_non_nullable
                    as bool,
        hasPrev:
            null == hasPrev
                ? _value.hasPrev
                : hasPrev // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageListResponseImpl implements _MessageListResponse {
  const _$MessageListResponseImpl({
    final List<ChatMessage> messages = const [],
    this.total = 0,
    this.page = 1,
    this.pages = 0,
    this.hasNext = false,
    this.hasPrev = false,
  }) : _messages = messages;

  factory _$MessageListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageListResponseImplFromJson(json);

  final List<ChatMessage> _messages;
  @override
  @JsonKey()
  List<ChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int pages;
  @override
  @JsonKey()
  final bool hasNext;
  @override
  @JsonKey()
  final bool hasPrev;

  @override
  String toString() {
    return 'MessageListResponse(messages: $messages, total: $total, page: $page, pages: $pages, hasNext: $hasNext, hasPrev: $hasPrev)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageListResponseImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pages, pages) || other.pages == pages) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext) &&
            (identical(other.hasPrev, hasPrev) || other.hasPrev == hasPrev));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_messages),
    total,
    page,
    pages,
    hasNext,
    hasPrev,
  );

  /// Create a copy of MessageListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageListResponseImplCopyWith<_$MessageListResponseImpl> get copyWith =>
      __$$MessageListResponseImplCopyWithImpl<_$MessageListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageListResponseImplToJson(this);
  }
}

abstract class _MessageListResponse implements MessageListResponse {
  const factory _MessageListResponse({
    final List<ChatMessage> messages,
    final int total,
    final int page,
    final int pages,
    final bool hasNext,
    final bool hasPrev,
  }) = _$MessageListResponseImpl;

  factory _MessageListResponse.fromJson(Map<String, dynamic> json) =
      _$MessageListResponseImpl.fromJson;

  @override
  List<ChatMessage> get messages;
  @override
  int get total;
  @override
  int get page;
  @override
  int get pages;
  @override
  bool get hasNext;
  @override
  bool get hasPrev;

  /// Create a copy of MessageListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageListResponseImplCopyWith<_$MessageListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserSearchResponse _$UserSearchResponseFromJson(Map<String, dynamic> json) {
  return _UserSearchResponse.fromJson(json);
}

/// @nodoc
mixin _$UserSearchResponse {
  List<UserSearchResult> get users => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get perPage => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;

  /// Serializes this UserSearchResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSearchResponseCopyWith<UserSearchResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSearchResponseCopyWith<$Res> {
  factory $UserSearchResponseCopyWith(
    UserSearchResponse value,
    $Res Function(UserSearchResponse) then,
  ) = _$UserSearchResponseCopyWithImpl<$Res, UserSearchResponse>;
  @useResult
  $Res call({
    List<UserSearchResult> users,
    int totalCount,
    int page,
    int perPage,
    bool hasNext,
  });
}

/// @nodoc
class _$UserSearchResponseCopyWithImpl<$Res, $Val extends UserSearchResponse>
    implements $UserSearchResponseCopyWith<$Res> {
  _$UserSearchResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? users = null,
    Object? totalCount = null,
    Object? page = null,
    Object? perPage = null,
    Object? hasNext = null,
  }) {
    return _then(
      _value.copyWith(
            users:
                null == users
                    ? _value.users
                    : users // ignore: cast_nullable_to_non_nullable
                        as List<UserSearchResult>,
            totalCount:
                null == totalCount
                    ? _value.totalCount
                    : totalCount // ignore: cast_nullable_to_non_nullable
                        as int,
            page:
                null == page
                    ? _value.page
                    : page // ignore: cast_nullable_to_non_nullable
                        as int,
            perPage:
                null == perPage
                    ? _value.perPage
                    : perPage // ignore: cast_nullable_to_non_nullable
                        as int,
            hasNext:
                null == hasNext
                    ? _value.hasNext
                    : hasNext // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserSearchResponseImplCopyWith<$Res>
    implements $UserSearchResponseCopyWith<$Res> {
  factory _$$UserSearchResponseImplCopyWith(
    _$UserSearchResponseImpl value,
    $Res Function(_$UserSearchResponseImpl) then,
  ) = __$$UserSearchResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<UserSearchResult> users,
    int totalCount,
    int page,
    int perPage,
    bool hasNext,
  });
}

/// @nodoc
class __$$UserSearchResponseImplCopyWithImpl<$Res>
    extends _$UserSearchResponseCopyWithImpl<$Res, _$UserSearchResponseImpl>
    implements _$$UserSearchResponseImplCopyWith<$Res> {
  __$$UserSearchResponseImplCopyWithImpl(
    _$UserSearchResponseImpl _value,
    $Res Function(_$UserSearchResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? users = null,
    Object? totalCount = null,
    Object? page = null,
    Object? perPage = null,
    Object? hasNext = null,
  }) {
    return _then(
      _$UserSearchResponseImpl(
        users:
            null == users
                ? _value._users
                : users // ignore: cast_nullable_to_non_nullable
                    as List<UserSearchResult>,
        totalCount:
            null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                    as int,
        page:
            null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                    as int,
        perPage:
            null == perPage
                ? _value.perPage
                : perPage // ignore: cast_nullable_to_non_nullable
                    as int,
        hasNext:
            null == hasNext
                ? _value.hasNext
                : hasNext // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSearchResponseImpl implements _UserSearchResponse {
  const _$UserSearchResponseImpl({
    final List<UserSearchResult> users = const [],
    this.totalCount = 0,
    this.page = 1,
    this.perPage = 20,
    this.hasNext = false,
  }) : _users = users;

  factory _$UserSearchResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSearchResponseImplFromJson(json);

  final List<UserSearchResult> _users;
  @override
  @JsonKey()
  List<UserSearchResult> get users {
    if (_users is EqualUnmodifiableListView) return _users;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_users);
  }

  @override
  @JsonKey()
  final int totalCount;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int perPage;
  @override
  @JsonKey()
  final bool hasNext;

  @override
  String toString() {
    return 'UserSearchResponse(users: $users, totalCount: $totalCount, page: $page, perPage: $perPage, hasNext: $hasNext)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSearchResponseImpl &&
            const DeepCollectionEquality().equals(other._users, _users) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.perPage, perPage) || other.perPage == perPage) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_users),
    totalCount,
    page,
    perPage,
    hasNext,
  );

  /// Create a copy of UserSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSearchResponseImplCopyWith<_$UserSearchResponseImpl> get copyWith =>
      __$$UserSearchResponseImplCopyWithImpl<_$UserSearchResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSearchResponseImplToJson(this);
  }
}

abstract class _UserSearchResponse implements UserSearchResponse {
  const factory _UserSearchResponse({
    final List<UserSearchResult> users,
    final int totalCount,
    final int page,
    final int perPage,
    final bool hasNext,
  }) = _$UserSearchResponseImpl;

  factory _UserSearchResponse.fromJson(Map<String, dynamic> json) =
      _$UserSearchResponseImpl.fromJson;

  @override
  List<UserSearchResult> get users;
  @override
  int get totalCount;
  @override
  int get page;
  @override
  int get perPage;
  @override
  bool get hasNext;

  /// Create a copy of UserSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSearchResponseImplCopyWith<_$UserSearchResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatError _$ChatErrorFromJson(Map<String, dynamic> json) {
  return _ChatError.fromJson(json);
}

/// @nodoc
mixin _$ChatError {
  String get errorCode => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  Map<String, dynamic>? get details => throw _privateConstructorUsedError;

  /// Serializes this ChatError to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatErrorCopyWith<ChatError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatErrorCopyWith<$Res> {
  factory $ChatErrorCopyWith(ChatError value, $Res Function(ChatError) then) =
      _$ChatErrorCopyWithImpl<$Res, ChatError>;
  @useResult
  $Res call({String errorCode, String message, Map<String, dynamic>? details});
}

/// @nodoc
class _$ChatErrorCopyWithImpl<$Res, $Val extends ChatError>
    implements $ChatErrorCopyWith<$Res> {
  _$ChatErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? errorCode = null,
    Object? message = null,
    Object? details = freezed,
  }) {
    return _then(
      _value.copyWith(
            errorCode:
                null == errorCode
                    ? _value.errorCode
                    : errorCode // ignore: cast_nullable_to_non_nullable
                        as String,
            message:
                null == message
                    ? _value.message
                    : message // ignore: cast_nullable_to_non_nullable
                        as String,
            details:
                freezed == details
                    ? _value.details
                    : details // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatErrorImplCopyWith<$Res>
    implements $ChatErrorCopyWith<$Res> {
  factory _$$ChatErrorImplCopyWith(
    _$ChatErrorImpl value,
    $Res Function(_$ChatErrorImpl) then,
  ) = __$$ChatErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String errorCode, String message, Map<String, dynamic>? details});
}

/// @nodoc
class __$$ChatErrorImplCopyWithImpl<$Res>
    extends _$ChatErrorCopyWithImpl<$Res, _$ChatErrorImpl>
    implements _$$ChatErrorImplCopyWith<$Res> {
  __$$ChatErrorImplCopyWithImpl(
    _$ChatErrorImpl _value,
    $Res Function(_$ChatErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? errorCode = null,
    Object? message = null,
    Object? details = freezed,
  }) {
    return _then(
      _$ChatErrorImpl(
        errorCode:
            null == errorCode
                ? _value.errorCode
                : errorCode // ignore: cast_nullable_to_non_nullable
                    as String,
        message:
            null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                    as String,
        details:
            freezed == details
                ? _value._details
                : details // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatErrorImpl implements _ChatError {
  const _$ChatErrorImpl({
    required this.errorCode,
    required this.message,
    final Map<String, dynamic>? details,
  }) : _details = details;

  factory _$ChatErrorImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatErrorImplFromJson(json);

  @override
  final String errorCode;
  @override
  final String message;
  final Map<String, dynamic>? _details;
  @override
  Map<String, dynamic>? get details {
    final value = _details;
    if (value == null) return null;
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ChatError(errorCode: $errorCode, message: $message, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatErrorImpl &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    errorCode,
    message,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of ChatError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatErrorImplCopyWith<_$ChatErrorImpl> get copyWith =>
      __$$ChatErrorImplCopyWithImpl<_$ChatErrorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatErrorImplToJson(this);
  }
}

abstract class _ChatError implements ChatError {
  const factory _ChatError({
    required final String errorCode,
    required final String message,
    final Map<String, dynamic>? details,
  }) = _$ChatErrorImpl;

  factory _ChatError.fromJson(Map<String, dynamic> json) =
      _$ChatErrorImpl.fromJson;

  @override
  String get errorCode;
  @override
  String get message;
  @override
  Map<String, dynamic>? get details;

  /// Create a copy of ChatError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatErrorImplCopyWith<_$ChatErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
