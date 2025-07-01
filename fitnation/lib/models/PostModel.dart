import 'package:fitnation/models/User.dart';
import 'package:fitnation/models/PostComment.dart'; // if you embed comments
import 'package:fitnation/models/PostReact.dart'; // if you embed reacts
import 'package:fitnation/models/WorkoutPostModel.dart';
import 'package:fitnation/models/ChallengePostModel.dart';

enum PostType {
  text, // Standard text/image post
  workout,
  challenge,
  // Add other types like achievement, etc. if needed
}


class Post {
  final String id;
  final String userId;
  final User? author; // Optional: Embed the author User object
  final String? content;
  final String? mediaUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PostComment>? comments; // Optional: Embed comments
  final List<PostReact>? reacts; // Optional: Embed reacts
  final int? commentCount;  
  // Specific data based on postType
  final WorkoutPostData? workoutData;
  final ChallengePostData? challengeData;
  
  final int? reactCount;
  final List<PostType> postType;
  // final String? communityId; // If posts can belong to a community

  Post({
    required this.id,
    required this.userId,
    this.author,
    this.content,
    this.mediaUrl,
    required this.createdAt,
    required this.updatedAt,
    this.workoutData,
    this.challengeData,
    this.comments,
    this.reacts,
    this.commentCount,
    this.reactCount,
    required this.postType,
    // this.communityId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    String? createdAtString = json['created_at'] as String?;
    String? updatedAtString = json['updated_at'] as String?;

    return Post(
      id: json['id'] as String? ?? 'default_id',
      userId: json['user_id'] as String? ?? 'default_user_id',
      postType: (json['post_type'] as List<dynamic>?)
                  ?.map((typeStr) {
                    if (typeStr is String && typeStr.isNotEmpty) {
                      try {
                        return PostType.values.byName(typeStr);
                      } catch (e) {
                        // Optional: handle or log if typeStr is not a valid enum name
                        print('Invalid PostType string: $typeStr, error: $e');
                        return null; 
                      }
                    }
                    return null; 
                  })
                  .where((item) => item != null) 
                  .cast<PostType>() 
                  .toList() ?? const [PostType.text],
      author:
          json['author'] != null
              ? User.fromJson(json['author'] as Map<String, dynamic>)
              : null,
      content: json['content'] as String? ?? '',
      mediaUrl: json['media_url'] as String? ?? '',
      workoutData:
          json['workout_data'] != null
              ? WorkoutPostData.fromJson(
                json['workout_data'] as Map<String, dynamic>,
              )
              : null,
      challengeData:
          json['challenge_data'] != null
              ? ChallengePostData.fromJson(
                json['challenge_data'] as Map<String, dynamic>,
              )
              : null,
      createdAt: (createdAtString != null && createdAtString.isNotEmpty)
          ? DateTime.parse(createdAtString)
          : DateTime.now(),
      updatedAt: (updatedAtString != null && updatedAtString.isNotEmpty)
          ? DateTime.parse(updatedAtString)
          : DateTime.now(),
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((c) => PostComment.fromJson(c as Map<String, dynamic>))
              .toList() ?? const [],
      reacts:
          (json['reacts'] as List<dynamic>?)
              ?.map((r) => PostReact.fromJson(r as Map<String, dynamic>))
              .toList() ?? const [],
      commentCount: json['comment_count'] as int? ?? 0,
      reactCount: json['react_count'] as int? ?? 0,
      // communityId: json['community_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'author': author?.toJson(),
      'content': content,
      'media_url': mediaUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'post_type': postType.map((pt) => pt.name).toList(), // Correctly serialize PostType list
      'workout_data': workoutData?.toJson(), // Call toJson on nested object
      'challenge_data': challengeData?.toJson(), // Call toJson on nested object
      'comments': comments?.map((c) => c.toJson()).toList(),
      'reacts': reacts?.map((r) => r.toJson()).toList(),
      'comment_count': commentCount,
      'react_count': reactCount,
      // 'community_id': communityId,
    };
  }
}
