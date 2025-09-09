// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainerChatImpl _$$TrainerChatImplFromJson(Map<String, dynamic> json) =>
    _$TrainerChatImpl(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      attachmentUrls:
          (json['attachmentUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      readAt:
          json['readAt'] == null
              ? null
              : DateTime.parse(json['readAt'] as String),
    );

Map<String, dynamic> _$$TrainerChatImplToJson(_$TrainerChatImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
      'attachmentUrls': instance.attachmentUrls,
      'readAt': instance.readAt?.toIso8601String(),
    };

_$TrainerChatRoomImpl _$$TrainerChatRoomImplFromJson(
  Map<String, dynamic> json,
) => _$TrainerChatRoomImpl(
  id: json['id'] as String,
  trainerId: json['trainerId'] as String,
  userId: json['userId'] as String,
  lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
  unreadCount: (json['unreadCount'] as num).toInt(),
  lastMessage: json['lastMessage'] as String?,
  participants: json['participants'] as Map<String, dynamic>,
);

Map<String, dynamic> _$$TrainerChatRoomImplToJson(
  _$TrainerChatRoomImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'trainerId': instance.trainerId,
  'userId': instance.userId,
  'lastMessageAt': instance.lastMessageAt.toIso8601String(),
  'unreadCount': instance.unreadCount,
  'lastMessage': instance.lastMessage,
  'participants': instance.participants,
};

_$PlanVerificationImpl _$$PlanVerificationImplFromJson(
  Map<String, dynamic> json,
) => _$PlanVerificationImpl(
  id: json['id'] as String,
  planId: json['planId'] as String,
  planType: json['planType'] as String,
  trainerId: json['trainerId'] as String,
  status: json['status'] as String,
  feedback: json['feedback'] as String?,
  suggestions:
      (json['suggestions'] as List<dynamic>?)?.map((e) => e as String).toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedAt:
      json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$$PlanVerificationImplToJson(
  _$PlanVerificationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'planId': instance.planId,
  'planType': instance.planType,
  'trainerId': instance.trainerId,
  'status': instance.status,
  'feedback': instance.feedback,
  'suggestions': instance.suggestions,
  'createdAt': instance.createdAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
};
