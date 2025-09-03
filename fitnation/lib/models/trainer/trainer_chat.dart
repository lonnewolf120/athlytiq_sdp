import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_chat.freezed.dart';
part 'trainer_chat.g.dart';

@freezed
class TrainerChat with _$TrainerChat {
  const factory TrainerChat({
    required String id,
    required String senderId,
    required String receiverId,
    required String message,
    required DateTime createdAt,
    List<String>? attachmentUrls,
    DateTime? readAt,
  }) = _TrainerChat;

  factory TrainerChat.fromJson(Map<String, dynamic> json) =>
      _$TrainerChatFromJson(json);
}

@freezed
class TrainerChatRoom with _$TrainerChatRoom {
  const factory TrainerChatRoom({
    required String id,
    required String trainerId,
    required String userId,
    required DateTime lastMessageAt,
    required int unreadCount,
    String? lastMessage,
    required Map<String, dynamic> participants,
  }) = _TrainerChatRoom;

  factory TrainerChatRoom.fromJson(Map<String, dynamic> json) =>
      _$TrainerChatRoomFromJson(json);
}

@freezed
class PlanVerification with _$PlanVerification {
  const factory PlanVerification({
    required String id,
    required String planId,
    required String planType,
    required String trainerId,
    required String status,
    String? feedback,
    List<String>? suggestions,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _PlanVerification;

  factory PlanVerification.fromJson(Map<String, dynamic> json) =>
      _$PlanVerificationFromJson(json);
}
