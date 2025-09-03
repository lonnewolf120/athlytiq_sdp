// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TrainerChat _$TrainerChatFromJson(Map<String, dynamic> json) {
  return _TrainerChat.fromJson(json);
}

/// @nodoc
mixin _$TrainerChat {
  String get id => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get receiverId => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<String>? get attachmentUrls => throw _privateConstructorUsedError;
  DateTime? get readAt => throw _privateConstructorUsedError;

  /// Serializes this TrainerChat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainerChat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerChatCopyWith<TrainerChat> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerChatCopyWith<$Res> {
  factory $TrainerChatCopyWith(
    TrainerChat value,
    $Res Function(TrainerChat) then,
  ) = _$TrainerChatCopyWithImpl<$Res, TrainerChat>;
  @useResult
  $Res call({
    String id,
    String senderId,
    String receiverId,
    String message,
    DateTime createdAt,
    List<String>? attachmentUrls,
    DateTime? readAt,
  });
}

/// @nodoc
class _$TrainerChatCopyWithImpl<$Res, $Val extends TrainerChat>
    implements $TrainerChatCopyWith<$Res> {
  _$TrainerChatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerChat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? message = null,
    Object? createdAt = null,
    Object? attachmentUrls = freezed,
    Object? readAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            senderId:
                null == senderId
                    ? _value.senderId
                    : senderId // ignore: cast_nullable_to_non_nullable
                        as String,
            receiverId:
                null == receiverId
                    ? _value.receiverId
                    : receiverId // ignore: cast_nullable_to_non_nullable
                        as String,
            message:
                null == message
                    ? _value.message
                    : message // ignore: cast_nullable_to_non_nullable
                        as String,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            attachmentUrls:
                freezed == attachmentUrls
                    ? _value.attachmentUrls
                    : attachmentUrls // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            readAt:
                freezed == readAt
                    ? _value.readAt
                    : readAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainerChatImplCopyWith<$Res>
    implements $TrainerChatCopyWith<$Res> {
  factory _$$TrainerChatImplCopyWith(
    _$TrainerChatImpl value,
    $Res Function(_$TrainerChatImpl) then,
  ) = __$$TrainerChatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String senderId,
    String receiverId,
    String message,
    DateTime createdAt,
    List<String>? attachmentUrls,
    DateTime? readAt,
  });
}

/// @nodoc
class __$$TrainerChatImplCopyWithImpl<$Res>
    extends _$TrainerChatCopyWithImpl<$Res, _$TrainerChatImpl>
    implements _$$TrainerChatImplCopyWith<$Res> {
  __$$TrainerChatImplCopyWithImpl(
    _$TrainerChatImpl _value,
    $Res Function(_$TrainerChatImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerChat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? message = null,
    Object? createdAt = null,
    Object? attachmentUrls = freezed,
    Object? readAt = freezed,
  }) {
    return _then(
      _$TrainerChatImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        senderId:
            null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                    as String,
        receiverId:
            null == receiverId
                ? _value.receiverId
                : receiverId // ignore: cast_nullable_to_non_nullable
                    as String,
        message:
            null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                    as String,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        attachmentUrls:
            freezed == attachmentUrls
                ? _value._attachmentUrls
                : attachmentUrls // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        readAt:
            freezed == readAt
                ? _value.readAt
                : readAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainerChatImpl implements _TrainerChat {
  const _$TrainerChatImpl({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
    final List<String>? attachmentUrls,
    this.readAt,
  }) : _attachmentUrls = attachmentUrls;

  factory _$TrainerChatImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainerChatImplFromJson(json);

  @override
  final String id;
  @override
  final String senderId;
  @override
  final String receiverId;
  @override
  final String message;
  @override
  final DateTime createdAt;
  final List<String>? _attachmentUrls;
  @override
  List<String>? get attachmentUrls {
    final value = _attachmentUrls;
    if (value == null) return null;
    if (_attachmentUrls is EqualUnmodifiableListView) return _attachmentUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? readAt;

  @override
  String toString() {
    return 'TrainerChat(id: $id, senderId: $senderId, receiverId: $receiverId, message: $message, createdAt: $createdAt, attachmentUrls: $attachmentUrls, readAt: $readAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerChatImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(
              other._attachmentUrls,
              _attachmentUrls,
            ) &&
            (identical(other.readAt, readAt) || other.readAt == readAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    senderId,
    receiverId,
    message,
    createdAt,
    const DeepCollectionEquality().hash(_attachmentUrls),
    readAt,
  );

  /// Create a copy of TrainerChat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerChatImplCopyWith<_$TrainerChatImpl> get copyWith =>
      __$$TrainerChatImplCopyWithImpl<_$TrainerChatImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainerChatImplToJson(this);
  }
}

abstract class _TrainerChat implements TrainerChat {
  const factory _TrainerChat({
    required final String id,
    required final String senderId,
    required final String receiverId,
    required final String message,
    required final DateTime createdAt,
    final List<String>? attachmentUrls,
    final DateTime? readAt,
  }) = _$TrainerChatImpl;

  factory _TrainerChat.fromJson(Map<String, dynamic> json) =
      _$TrainerChatImpl.fromJson;

  @override
  String get id;
  @override
  String get senderId;
  @override
  String get receiverId;
  @override
  String get message;
  @override
  DateTime get createdAt;
  @override
  List<String>? get attachmentUrls;
  @override
  DateTime? get readAt;

  /// Create a copy of TrainerChat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerChatImplCopyWith<_$TrainerChatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrainerChatRoom _$TrainerChatRoomFromJson(Map<String, dynamic> json) {
  return _TrainerChatRoom.fromJson(json);
}

/// @nodoc
mixin _$TrainerChatRoom {
  String get id => throw _privateConstructorUsedError;
  String get trainerId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get lastMessageAt => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  String? get lastMessage => throw _privateConstructorUsedError;
  Map<String, dynamic> get participants => throw _privateConstructorUsedError;

  /// Serializes this TrainerChatRoom to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainerChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerChatRoomCopyWith<TrainerChatRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerChatRoomCopyWith<$Res> {
  factory $TrainerChatRoomCopyWith(
    TrainerChatRoom value,
    $Res Function(TrainerChatRoom) then,
  ) = _$TrainerChatRoomCopyWithImpl<$Res, TrainerChatRoom>;
  @useResult
  $Res call({
    String id,
    String trainerId,
    String userId,
    DateTime lastMessageAt,
    int unreadCount,
    String? lastMessage,
    Map<String, dynamic> participants,
  });
}

/// @nodoc
class _$TrainerChatRoomCopyWithImpl<$Res, $Val extends TrainerChatRoom>
    implements $TrainerChatRoomCopyWith<$Res> {
  _$TrainerChatRoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trainerId = null,
    Object? userId = null,
    Object? lastMessageAt = null,
    Object? unreadCount = null,
    Object? lastMessage = freezed,
    Object? participants = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            trainerId:
                null == trainerId
                    ? _value.trainerId
                    : trainerId // ignore: cast_nullable_to_non_nullable
                        as String,
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            lastMessageAt:
                null == lastMessageAt
                    ? _value.lastMessageAt
                    : lastMessageAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            unreadCount:
                null == unreadCount
                    ? _value.unreadCount
                    : unreadCount // ignore: cast_nullable_to_non_nullable
                        as int,
            lastMessage:
                freezed == lastMessage
                    ? _value.lastMessage
                    : lastMessage // ignore: cast_nullable_to_non_nullable
                        as String?,
            participants:
                null == participants
                    ? _value.participants
                    : participants // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainerChatRoomImplCopyWith<$Res>
    implements $TrainerChatRoomCopyWith<$Res> {
  factory _$$TrainerChatRoomImplCopyWith(
    _$TrainerChatRoomImpl value,
    $Res Function(_$TrainerChatRoomImpl) then,
  ) = __$$TrainerChatRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String trainerId,
    String userId,
    DateTime lastMessageAt,
    int unreadCount,
    String? lastMessage,
    Map<String, dynamic> participants,
  });
}

/// @nodoc
class __$$TrainerChatRoomImplCopyWithImpl<$Res>
    extends _$TrainerChatRoomCopyWithImpl<$Res, _$TrainerChatRoomImpl>
    implements _$$TrainerChatRoomImplCopyWith<$Res> {
  __$$TrainerChatRoomImplCopyWithImpl(
    _$TrainerChatRoomImpl _value,
    $Res Function(_$TrainerChatRoomImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trainerId = null,
    Object? userId = null,
    Object? lastMessageAt = null,
    Object? unreadCount = null,
    Object? lastMessage = freezed,
    Object? participants = null,
  }) {
    return _then(
      _$TrainerChatRoomImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        trainerId:
            null == trainerId
                ? _value.trainerId
                : trainerId // ignore: cast_nullable_to_non_nullable
                    as String,
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        lastMessageAt:
            null == lastMessageAt
                ? _value.lastMessageAt
                : lastMessageAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        unreadCount:
            null == unreadCount
                ? _value.unreadCount
                : unreadCount // ignore: cast_nullable_to_non_nullable
                    as int,
        lastMessage:
            freezed == lastMessage
                ? _value.lastMessage
                : lastMessage // ignore: cast_nullable_to_non_nullable
                    as String?,
        participants:
            null == participants
                ? _value._participants
                : participants // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainerChatRoomImpl implements _TrainerChatRoom {
  const _$TrainerChatRoomImpl({
    required this.id,
    required this.trainerId,
    required this.userId,
    required this.lastMessageAt,
    required this.unreadCount,
    this.lastMessage,
    required final Map<String, dynamic> participants,
  }) : _participants = participants;

  factory _$TrainerChatRoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainerChatRoomImplFromJson(json);

  @override
  final String id;
  @override
  final String trainerId;
  @override
  final String userId;
  @override
  final DateTime lastMessageAt;
  @override
  final int unreadCount;
  @override
  final String? lastMessage;
  final Map<String, dynamic> _participants;
  @override
  Map<String, dynamic> get participants {
    if (_participants is EqualUnmodifiableMapView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_participants);
  }

  @override
  String toString() {
    return 'TrainerChatRoom(id: $id, trainerId: $trainerId, userId: $userId, lastMessageAt: $lastMessageAt, unreadCount: $unreadCount, lastMessage: $lastMessage, participants: $participants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerChatRoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.trainerId, trainerId) ||
                other.trainerId == trainerId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            const DeepCollectionEquality().equals(
              other._participants,
              _participants,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    trainerId,
    userId,
    lastMessageAt,
    unreadCount,
    lastMessage,
    const DeepCollectionEquality().hash(_participants),
  );

  /// Create a copy of TrainerChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerChatRoomImplCopyWith<_$TrainerChatRoomImpl> get copyWith =>
      __$$TrainerChatRoomImplCopyWithImpl<_$TrainerChatRoomImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainerChatRoomImplToJson(this);
  }
}

abstract class _TrainerChatRoom implements TrainerChatRoom {
  const factory _TrainerChatRoom({
    required final String id,
    required final String trainerId,
    required final String userId,
    required final DateTime lastMessageAt,
    required final int unreadCount,
    final String? lastMessage,
    required final Map<String, dynamic> participants,
  }) = _$TrainerChatRoomImpl;

  factory _TrainerChatRoom.fromJson(Map<String, dynamic> json) =
      _$TrainerChatRoomImpl.fromJson;

  @override
  String get id;
  @override
  String get trainerId;
  @override
  String get userId;
  @override
  DateTime get lastMessageAt;
  @override
  int get unreadCount;
  @override
  String? get lastMessage;
  @override
  Map<String, dynamic> get participants;

  /// Create a copy of TrainerChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerChatRoomImplCopyWith<_$TrainerChatRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlanVerification _$PlanVerificationFromJson(Map<String, dynamic> json) {
  return _PlanVerification.fromJson(json);
}

/// @nodoc
mixin _$PlanVerification {
  String get id => throw _privateConstructorUsedError;
  String get planId => throw _privateConstructorUsedError;
  String get planType => throw _privateConstructorUsedError;
  String get trainerId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get feedback => throw _privateConstructorUsedError;
  List<String>? get suggestions => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this PlanVerification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlanVerification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlanVerificationCopyWith<PlanVerification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlanVerificationCopyWith<$Res> {
  factory $PlanVerificationCopyWith(
    PlanVerification value,
    $Res Function(PlanVerification) then,
  ) = _$PlanVerificationCopyWithImpl<$Res, PlanVerification>;
  @useResult
  $Res call({
    String id,
    String planId,
    String planType,
    String trainerId,
    String status,
    String? feedback,
    List<String>? suggestions,
    DateTime createdAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class _$PlanVerificationCopyWithImpl<$Res, $Val extends PlanVerification>
    implements $PlanVerificationCopyWith<$Res> {
  _$PlanVerificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlanVerification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planId = null,
    Object? planType = null,
    Object? trainerId = null,
    Object? status = null,
    Object? feedback = freezed,
    Object? suggestions = freezed,
    Object? createdAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            planId:
                null == planId
                    ? _value.planId
                    : planId // ignore: cast_nullable_to_non_nullable
                        as String,
            planType:
                null == planType
                    ? _value.planType
                    : planType // ignore: cast_nullable_to_non_nullable
                        as String,
            trainerId:
                null == trainerId
                    ? _value.trainerId
                    : trainerId // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            feedback:
                freezed == feedback
                    ? _value.feedback
                    : feedback // ignore: cast_nullable_to_non_nullable
                        as String?,
            suggestions:
                freezed == suggestions
                    ? _value.suggestions
                    : suggestions // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            completedAt:
                freezed == completedAt
                    ? _value.completedAt
                    : completedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlanVerificationImplCopyWith<$Res>
    implements $PlanVerificationCopyWith<$Res> {
  factory _$$PlanVerificationImplCopyWith(
    _$PlanVerificationImpl value,
    $Res Function(_$PlanVerificationImpl) then,
  ) = __$$PlanVerificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String planId,
    String planType,
    String trainerId,
    String status,
    String? feedback,
    List<String>? suggestions,
    DateTime createdAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class __$$PlanVerificationImplCopyWithImpl<$Res>
    extends _$PlanVerificationCopyWithImpl<$Res, _$PlanVerificationImpl>
    implements _$$PlanVerificationImplCopyWith<$Res> {
  __$$PlanVerificationImplCopyWithImpl(
    _$PlanVerificationImpl _value,
    $Res Function(_$PlanVerificationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlanVerification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? planId = null,
    Object? planType = null,
    Object? trainerId = null,
    Object? status = null,
    Object? feedback = freezed,
    Object? suggestions = freezed,
    Object? createdAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$PlanVerificationImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        planId:
            null == planId
                ? _value.planId
                : planId // ignore: cast_nullable_to_non_nullable
                    as String,
        planType:
            null == planType
                ? _value.planType
                : planType // ignore: cast_nullable_to_non_nullable
                    as String,
        trainerId:
            null == trainerId
                ? _value.trainerId
                : trainerId // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        feedback:
            freezed == feedback
                ? _value.feedback
                : feedback // ignore: cast_nullable_to_non_nullable
                    as String?,
        suggestions:
            freezed == suggestions
                ? _value._suggestions
                : suggestions // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        completedAt:
            freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlanVerificationImpl implements _PlanVerification {
  const _$PlanVerificationImpl({
    required this.id,
    required this.planId,
    required this.planType,
    required this.trainerId,
    required this.status,
    this.feedback,
    final List<String>? suggestions,
    required this.createdAt,
    this.completedAt,
  }) : _suggestions = suggestions;

  factory _$PlanVerificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlanVerificationImplFromJson(json);

  @override
  final String id;
  @override
  final String planId;
  @override
  final String planType;
  @override
  final String trainerId;
  @override
  final String status;
  @override
  final String? feedback;
  final List<String>? _suggestions;
  @override
  List<String>? get suggestions {
    final value = _suggestions;
    if (value == null) return null;
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'PlanVerification(id: $id, planId: $planId, planType: $planType, trainerId: $trainerId, status: $status, feedback: $feedback, suggestions: $suggestions, createdAt: $createdAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlanVerificationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.planType, planType) ||
                other.planType == planType) &&
            (identical(other.trainerId, trainerId) ||
                other.trainerId == trainerId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback) &&
            const DeepCollectionEquality().equals(
              other._suggestions,
              _suggestions,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    planId,
    planType,
    trainerId,
    status,
    feedback,
    const DeepCollectionEquality().hash(_suggestions),
    createdAt,
    completedAt,
  );

  /// Create a copy of PlanVerification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlanVerificationImplCopyWith<_$PlanVerificationImpl> get copyWith =>
      __$$PlanVerificationImplCopyWithImpl<_$PlanVerificationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PlanVerificationImplToJson(this);
  }
}

abstract class _PlanVerification implements PlanVerification {
  const factory _PlanVerification({
    required final String id,
    required final String planId,
    required final String planType,
    required final String trainerId,
    required final String status,
    final String? feedback,
    final List<String>? suggestions,
    required final DateTime createdAt,
    final DateTime? completedAt,
  }) = _$PlanVerificationImpl;

  factory _PlanVerification.fromJson(Map<String, dynamic> json) =
      _$PlanVerificationImpl.fromJson;

  @override
  String get id;
  @override
  String get planId;
  @override
  String get planType;
  @override
  String get trainerId;
  @override
  String get status;
  @override
  String? get feedback;
  @override
  List<String>? get suggestions;
  @override
  DateTime get createdAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of PlanVerification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlanVerificationImplCopyWith<_$PlanVerificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
