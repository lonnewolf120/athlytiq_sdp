// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TrainerPost _$TrainerPostFromJson(Map<String, dynamic> json) {
  return _TrainerPost.fromJson(json);
}

/// @nodoc
mixin _$TrainerPost {
  String get id => throw _privateConstructorUsedError;
  String get trainerId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  List<String> get imageUrls => throw _privateConstructorUsedError;
  int get likesCount => throw _privateConstructorUsedError;
  int get commentsCount => throw _privateConstructorUsedError;
  bool get isLiked => throw _privateConstructorUsedError;

  /// Serializes this TrainerPost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainerPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerPostCopyWith<TrainerPost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerPostCopyWith<$Res> {
  factory $TrainerPostCopyWith(
    TrainerPost value,
    $Res Function(TrainerPost) then,
  ) = _$TrainerPostCopyWithImpl<$Res, TrainerPost>;
  @useResult
  $Res call({
    String id,
    String trainerId,
    String title,
    String content,
    String category,
    List<String> tags,
    DateTime createdAt,
    DateTime updatedAt,
    List<String> imageUrls,
    int likesCount,
    int commentsCount,
    bool isLiked,
  });
}

/// @nodoc
class _$TrainerPostCopyWithImpl<$Res, $Val extends TrainerPost>
    implements $TrainerPostCopyWith<$Res> {
  _$TrainerPostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trainerId = null,
    Object? title = null,
    Object? content = null,
    Object? category = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? imageUrls = null,
    Object? likesCount = null,
    Object? commentsCount = null,
    Object? isLiked = null,
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
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
            category:
                null == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as String,
            tags:
                null == tags
                    ? _value.tags
                    : tags // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            imageUrls:
                null == imageUrls
                    ? _value.imageUrls
                    : imageUrls // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            likesCount:
                null == likesCount
                    ? _value.likesCount
                    : likesCount // ignore: cast_nullable_to_non_nullable
                        as int,
            commentsCount:
                null == commentsCount
                    ? _value.commentsCount
                    : commentsCount // ignore: cast_nullable_to_non_nullable
                        as int,
            isLiked:
                null == isLiked
                    ? _value.isLiked
                    : isLiked // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainerPostImplCopyWith<$Res>
    implements $TrainerPostCopyWith<$Res> {
  factory _$$TrainerPostImplCopyWith(
    _$TrainerPostImpl value,
    $Res Function(_$TrainerPostImpl) then,
  ) = __$$TrainerPostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String trainerId,
    String title,
    String content,
    String category,
    List<String> tags,
    DateTime createdAt,
    DateTime updatedAt,
    List<String> imageUrls,
    int likesCount,
    int commentsCount,
    bool isLiked,
  });
}

/// @nodoc
class __$$TrainerPostImplCopyWithImpl<$Res>
    extends _$TrainerPostCopyWithImpl<$Res, _$TrainerPostImpl>
    implements _$$TrainerPostImplCopyWith<$Res> {
  __$$TrainerPostImplCopyWithImpl(
    _$TrainerPostImpl _value,
    $Res Function(_$TrainerPostImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trainerId = null,
    Object? title = null,
    Object? content = null,
    Object? category = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? imageUrls = null,
    Object? likesCount = null,
    Object? commentsCount = null,
    Object? isLiked = null,
  }) {
    return _then(
      _$TrainerPostImpl(
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
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        category:
            null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as String,
        tags:
            null == tags
                ? _value._tags
                : tags // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        imageUrls:
            null == imageUrls
                ? _value._imageUrls
                : imageUrls // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        likesCount:
            null == likesCount
                ? _value.likesCount
                : likesCount // ignore: cast_nullable_to_non_nullable
                    as int,
        commentsCount:
            null == commentsCount
                ? _value.commentsCount
                : commentsCount // ignore: cast_nullable_to_non_nullable
                    as int,
        isLiked:
            null == isLiked
                ? _value.isLiked
                : isLiked // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainerPostImpl implements _TrainerPost {
  const _$TrainerPostImpl({
    required this.id,
    required this.trainerId,
    required this.title,
    required this.content,
    required this.category,
    required final List<String> tags,
    required this.createdAt,
    required this.updatedAt,
    final List<String> imageUrls = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  }) : _tags = tags,
       _imageUrls = imageUrls;

  factory _$TrainerPostImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainerPostImplFromJson(json);

  @override
  final String id;
  @override
  final String trainerId;
  @override
  final String title;
  @override
  final String content;
  @override
  final String category;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  final List<String> _imageUrls;
  @override
  @JsonKey()
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  @override
  @JsonKey()
  final int likesCount;
  @override
  @JsonKey()
  final int commentsCount;
  @override
  @JsonKey()
  final bool isLiked;

  @override
  String toString() {
    return 'TrainerPost(id: $id, trainerId: $trainerId, title: $title, content: $content, category: $category, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt, imageUrls: $imageUrls, likesCount: $likesCount, commentsCount: $commentsCount, isLiked: $isLiked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerPostImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.trainerId, trainerId) ||
                other.trainerId == trainerId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(
              other._imageUrls,
              _imageUrls,
            ) &&
            (identical(other.likesCount, likesCount) ||
                other.likesCount == likesCount) &&
            (identical(other.commentsCount, commentsCount) ||
                other.commentsCount == commentsCount) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    trainerId,
    title,
    content,
    category,
    const DeepCollectionEquality().hash(_tags),
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_imageUrls),
    likesCount,
    commentsCount,
    isLiked,
  );

  /// Create a copy of TrainerPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerPostImplCopyWith<_$TrainerPostImpl> get copyWith =>
      __$$TrainerPostImplCopyWithImpl<_$TrainerPostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainerPostImplToJson(this);
  }
}

abstract class _TrainerPost implements TrainerPost {
  const factory _TrainerPost({
    required final String id,
    required final String trainerId,
    required final String title,
    required final String content,
    required final String category,
    required final List<String> tags,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final List<String> imageUrls,
    final int likesCount,
    final int commentsCount,
    final bool isLiked,
  }) = _$TrainerPostImpl;

  factory _TrainerPost.fromJson(Map<String, dynamic> json) =
      _$TrainerPostImpl.fromJson;

  @override
  String get id;
  @override
  String get trainerId;
  @override
  String get title;
  @override
  String get content;
  @override
  String get category;
  @override
  List<String> get tags;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  List<String> get imageUrls;
  @override
  int get likesCount;
  @override
  int get commentsCount;
  @override
  bool get isLiked;

  /// Create a copy of TrainerPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerPostImplCopyWith<_$TrainerPostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrainerComment _$TrainerCommentFromJson(Map<String, dynamic> json) {
  return _TrainerComment.fromJson(json);
}

/// @nodoc
mixin _$TrainerComment {
  String get id => throw _privateConstructorUsedError;
  String get postId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get userAvatar => throw _privateConstructorUsedError;
  String? get userName => throw _privateConstructorUsedError;

  /// Serializes this TrainerComment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainerComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainerCommentCopyWith<TrainerComment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerCommentCopyWith<$Res> {
  factory $TrainerCommentCopyWith(
    TrainerComment value,
    $Res Function(TrainerComment) then,
  ) = _$TrainerCommentCopyWithImpl<$Res, TrainerComment>;
  @useResult
  $Res call({
    String id,
    String postId,
    String userId,
    String content,
    DateTime createdAt,
    String? userAvatar,
    String? userName,
  });
}

/// @nodoc
class _$TrainerCommentCopyWithImpl<$Res, $Val extends TrainerComment>
    implements $TrainerCommentCopyWith<$Res> {
  _$TrainerCommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainerComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? postId = null,
    Object? userId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? userAvatar = freezed,
    Object? userName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            postId:
                null == postId
                    ? _value.postId
                    : postId // ignore: cast_nullable_to_non_nullable
                        as String,
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            userAvatar:
                freezed == userAvatar
                    ? _value.userAvatar
                    : userAvatar // ignore: cast_nullable_to_non_nullable
                        as String?,
            userName:
                freezed == userName
                    ? _value.userName
                    : userName // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainerCommentImplCopyWith<$Res>
    implements $TrainerCommentCopyWith<$Res> {
  factory _$$TrainerCommentImplCopyWith(
    _$TrainerCommentImpl value,
    $Res Function(_$TrainerCommentImpl) then,
  ) = __$$TrainerCommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String postId,
    String userId,
    String content,
    DateTime createdAt,
    String? userAvatar,
    String? userName,
  });
}

/// @nodoc
class __$$TrainerCommentImplCopyWithImpl<$Res>
    extends _$TrainerCommentCopyWithImpl<$Res, _$TrainerCommentImpl>
    implements _$$TrainerCommentImplCopyWith<$Res> {
  __$$TrainerCommentImplCopyWithImpl(
    _$TrainerCommentImpl _value,
    $Res Function(_$TrainerCommentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainerComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? postId = null,
    Object? userId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? userAvatar = freezed,
    Object? userName = freezed,
  }) {
    return _then(
      _$TrainerCommentImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        postId:
            null == postId
                ? _value.postId
                : postId // ignore: cast_nullable_to_non_nullable
                    as String,
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        userAvatar:
            freezed == userAvatar
                ? _value.userAvatar
                : userAvatar // ignore: cast_nullable_to_non_nullable
                    as String?,
        userName:
            freezed == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainerCommentImpl implements _TrainerComment {
  const _$TrainerCommentImpl({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.userAvatar,
    this.userName,
  });

  factory _$TrainerCommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainerCommentImplFromJson(json);

  @override
  final String id;
  @override
  final String postId;
  @override
  final String userId;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  final String? userAvatar;
  @override
  final String? userName;

  @override
  String toString() {
    return 'TrainerComment(id: $id, postId: $postId, userId: $userId, content: $content, createdAt: $createdAt, userAvatar: $userAvatar, userName: $userName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerCommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.userAvatar, userAvatar) ||
                other.userAvatar == userAvatar) &&
            (identical(other.userName, userName) ||
                other.userName == userName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    postId,
    userId,
    content,
    createdAt,
    userAvatar,
    userName,
  );

  /// Create a copy of TrainerComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerCommentImplCopyWith<_$TrainerCommentImpl> get copyWith =>
      __$$TrainerCommentImplCopyWithImpl<_$TrainerCommentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainerCommentImplToJson(this);
  }
}

abstract class _TrainerComment implements TrainerComment {
  const factory _TrainerComment({
    required final String id,
    required final String postId,
    required final String userId,
    required final String content,
    required final DateTime createdAt,
    final String? userAvatar,
    final String? userName,
  }) = _$TrainerCommentImpl;

  factory _TrainerComment.fromJson(Map<String, dynamic> json) =
      _$TrainerCommentImpl.fromJson;

  @override
  String get id;
  @override
  String get postId;
  @override
  String get userId;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  String? get userAvatar;
  @override
  String? get userName;

  /// Create a copy of TrainerComment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainerCommentImplCopyWith<_$TrainerCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
