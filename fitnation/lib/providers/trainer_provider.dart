import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/models/trainer/trainer_application.dart';
import 'package:fitnation/models/trainer/trainer_post.dart';
import 'package:fitnation/models/trainer/trainer_chat.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TrainerNotifier extends StateNotifier<AsyncValue<void>> {
  final Dio _dio;
  final String _baseUrl;

  TrainerNotifier(this._dio, this._baseUrl) : super(const AsyncValue.data(null));

  // Application Status Management
  Future<void> submitTrainerApplication(TrainerApplication application) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.post(
        '$_baseUrl/trainers/apply',
        data: application.toJson(),
      );
      if (response.statusCode == 201) {
        state = const AsyncValue.data(null);
      } else {
        throw Exception('Failed to submit application');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<TrainerApplicationStatus> checkApplicationStatus(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/trainers/application-status/$userId');
      return TrainerApplicationStatus.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Post Management
  Future<List<TrainerPost>> getTrainerPosts({
    String? trainerId,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        if (trainerId != null) 'trainer_id': trainerId,
        if (category != null) 'category': category,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _dio.get(
        '$_baseUrl/trainers/posts',
        queryParameters: queryParams,
      );

      return (response.data['posts'] as List)
          .map((post) => TrainerPost.fromJson(post))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<TrainerPost> createPost(Map<String, dynamic> postData) async {
    try {
      final response = await _dio.post('$_baseUrl/trainers/posts', data: postData);
      return TrainerPost.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Chat System
  Future<List<TrainerChatRoom>> getChatRooms(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/trainers/chats/rooms/$userId');
      return (response.data['rooms'] as List)
          .map((room) => TrainerChatRoom.fromJson(room))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TrainerChat>> getChatMessages(String roomId, {int limit = 50}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/trainers/chats/messages/$roomId',
        queryParameters: {'limit': limit.toString()},
      );
      return (response.data['messages'] as List)
          .map((msg) => TrainerChat.fromJson(msg))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendMessage(TrainerChat message) async {
    try {
      await _dio.post(
        '$_baseUrl/trainers/chats/send',
        data: message.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Plan Verification
  Future<PlanVerification> requestPlanVerification(Map<String, dynamic> request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/trainers/verify-plan',
        data: request,
      );
      return PlanVerification.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PlanVerification>> getVerificationRequests({
    String? trainerId,
    String? status,
  }) async {
    try {
      final queryParams = {
        if (trainerId != null) 'trainer_id': trainerId,
        if (status != null) 'status': status,
      };

      final response = await _dio.get(
        '$_baseUrl/trainers/verification-requests',
        queryParameters: queryParams,
      );

      return (response.data['requests'] as List)
          .map((req) => PlanVerification.fromJson(req))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitVerificationFeedback(
    String requestId,
    Map<String, dynamic> feedback,
  ) async {
    try {
      await _dio.post(
        '$_baseUrl/trainers/verification-feedback/$requestId',
        data: feedback,
      );
    } catch (e) {
      rethrow;
    }
  }
}

final trainerProvider = StateNotifierProvider<TrainerNotifier, AsyncValue<void>>((ref) {
  final dio = Dio();
   final baseUrl = dotenv.env['BASE_URL'] ?? 'http://ap2.shalish.xyz';
  return TrainerNotifier(dio, baseUrl);
});
