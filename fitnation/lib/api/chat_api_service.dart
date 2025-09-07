import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_models.dart';

class ChatApiService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ChatApiService(this._dio, this._secureStorage) {
    final String baseUrl = (dotenv.env['BASE_URL'] ?? 
        "http://127.0.0.1:8000/api/v1")
        .replaceAll(RegExp(r'/$'), '');
    _dio.options.baseUrl = baseUrl;
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint('ChatApiService: Added Authorization header');
          } else {
            debugPrint('ChatApiService: No token found');
          }
          debugPrint('ChatApiService: Request to ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('ChatApiService: Response [${response.statusCode}] ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('ChatApiService: Error [${error.response?.statusCode}] ${error.requestOptions.uri}');
          debugPrint('ChatApiService: Error message: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // Create chat room
  Future<ChatRoom> createChatRoom({
    required String name,
    required String type,
    String? description,
    required List<String> participantIds,
  }) async {
    try {
      final response = await _dio.post(
        '/chat/rooms',
        data: ChatRoomCreate(
          name: name,
          type: type,
          description: description,
          participantIds: participantIds,
        ).toJson(),
      );

      debugPrint('ChatApiService: Create room response: ${response.data}');

      if (response.statusCode == 201) {
        return ChatRoom.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create chat room: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('ChatApiService: DioException in createChatRoom: ${e.message}');
      debugPrint('ChatApiService: Response data: ${e.response?.data}');
      throw Exception('Failed to create chat room: ${e.response?.data['detail'] ?? e.message}');
    } catch (e) {
      debugPrint('ChatApiService: Exception in createChatRoom: $e');
      throw Exception('Failed to create chat room: $e');
    }
  }

  // Get user's chat rooms
  Future<List<ChatRoom>> getChatRooms() async {
    try {
      final response = await _dio.get('/chat/rooms');

      debugPrint('ChatApiService: Get rooms response: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> roomsJson = response.data['rooms'] as List<dynamic>;
        return roomsJson
            .map((json) => ChatRoom.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get chat rooms: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('ChatApiService: DioException in getChatRooms: ${e.message}');
      throw Exception('Failed to get chat rooms: ${e.message}');
    } catch (e) {
      debugPrint('ChatApiService: Exception in getChatRooms: $e');
      throw Exception('Failed to get chat rooms: $e');
    }
  }

  // Get messages for a chat room
  Future<List<ChatMessage>> getChatMessages(String roomId, {int limit = 50}) async {
    try {
      final response = await _dio.get(
        '/chat/rooms/$roomId/messages',
        queryParameters: {'limit': limit},
      );

      debugPrint('ChatApiService: Get messages response: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = response.data['messages'] as List<dynamic>;
        return messagesJson
            .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get messages: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('ChatApiService: DioException in getChatMessages: ${e.message}');
      throw Exception('Failed to get messages: ${e.message}');
    } catch (e) {
      debugPrint('ChatApiService: Exception in getChatMessages: $e');
      throw Exception('Failed to get messages: $e');
    }
  }

  // Send message
  Future<ChatMessage> sendMessage(String roomId, String content, {String messageType = 'text'}) async {
    try {
      final response = await _dio.post(
        '/chat/rooms/$roomId/messages',
        data: ChatMessageCreate(
          content: content,
          messageType: messageType,
        ).toJson(),
      );

      debugPrint('ChatApiService: Send message response: ${response.data}');

      if (response.statusCode == 201) {
        return ChatMessage.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to send message: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('ChatApiService: DioException in sendMessage: ${e.message}');
      debugPrint('ChatApiService: Response data: ${e.response?.data}');
      throw Exception('Failed to send message: ${e.response?.data['detail'] ?? e.message}');
    } catch (e) {
      debugPrint('ChatApiService: Exception in sendMessage: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String roomId) async {
    try {
      final response = await _dio.put('/chat/rooms/$roomId/read');

      debugPrint('ChatApiService: Mark as read response: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Failed to mark messages as read: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('ChatApiService: DioException in markMessagesAsRead: ${e.message}');
      throw Exception('Failed to mark messages as read: ${e.message}');
    } catch (e) {
      debugPrint('ChatApiService: Exception in markMessagesAsRead: $e');
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  // Create direct chat with a friend
  Future<ChatRoom> createDirectChat(String friendId, String friendUsername) async {
    return createChatRoom(
      name: friendUsername,
      type: 'direct',
      participantIds: [friendId],
    );
  }
}
