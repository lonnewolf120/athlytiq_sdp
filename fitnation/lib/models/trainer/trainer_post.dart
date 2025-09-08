import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_post.freezed.dart';
part 'trainer_post.g.dart';

@freezed
class TrainerPost with _$TrainerPost {
  const factory TrainerPost({
    required String id,
    required String trainerId,
    required String title,
    required String content,
    required String category,
    required List<String> tags,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<String> imageUrls,
    @Default(0) int likesCount,
    @Default(0) int commentsCount,
    @Default(false) bool isLiked,
  }) = _TrainerPost;

  factory TrainerPost.fromJson(Map<String, dynamic> json) =>
      _$TrainerPostFromJson(json);
}

@freezed
class TrainerComment with _$TrainerComment {
  const factory TrainerComment({
    required String id,
    required String postId,
    required String userId,
    required String content,
    required DateTime createdAt,
    String? userAvatar,
    String? userName,
  }) = _TrainerComment;

  factory TrainerComment.fromJson(Map<String, dynamic> json) =>
      _$TrainerCommentFromJson(json);
}
