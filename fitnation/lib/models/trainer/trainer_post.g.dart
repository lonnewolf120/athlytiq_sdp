// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainerPostImpl _$$TrainerPostImplFromJson(Map<String, dynamic> json) =>
    _$TrainerPostImpl(
      id: json['id'] as String,
      trainerId: json['trainerId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );

Map<String, dynamic> _$$TrainerPostImplToJson(_$TrainerPostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trainerId': instance.trainerId,
      'title': instance.title,
      'content': instance.content,
      'category': instance.category,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'imageUrls': instance.imageUrls,
      'likesCount': instance.likesCount,
      'commentsCount': instance.commentsCount,
      'isLiked': instance.isLiked,
    };

_$TrainerCommentImpl _$$TrainerCommentImplFromJson(Map<String, dynamic> json) =>
    _$TrainerCommentImpl(
      id: json['id'] as String,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userAvatar: json['userAvatar'] as String?,
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$$TrainerCommentImplToJson(
  _$TrainerCommentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'postId': instance.postId,
  'userId': instance.userId,
  'content': instance.content,
  'createdAt': instance.createdAt.toIso8601String(),
  'userAvatar': instance.userAvatar,
  'userName': instance.userName,
};
