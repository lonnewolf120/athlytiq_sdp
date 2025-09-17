import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/friend_models.dart';

class FriendsApiService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  FriendsApiService(this._dio, this._secureStorage) {
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
            debugPrint('FriendsApiService: Added Authorization header');
          } else {
            debugPrint('FriendsApiService: No token found');
          }
          debugPrint('FriendsApiService: Request to ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('FriendsApiService: Response [${response.statusCode}] ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('FriendsApiService: Error [${error.response?.statusCode}] ${error.requestOptions.uri}');
          debugPrint('FriendsApiService: Error message: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // Search users
  Future<List<UserSearchResult>> searchUsers({
    required String query,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/friends/search',
        queryParameters: {
          'query': query,
          'limit': limit,
        },
      );

      debugPrint('FriendsApiService: Search response: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = response.data['users'] as List<dynamic>;
        return usersJson
            .map((json) => UserSearchResult.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to search users: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('FriendsApiService: DioException in searchUsers: ${e.message}');
      debugPrint('FriendsApiService: Response data: ${e.response?.data}');
      throw Exception('Failed to search users: ${e.message}');
    } catch (e) {
      debugPrint('FriendsApiService: Exception in searchUsers: $e');
      throw Exception('Failed to search users: $e');
    }
  }

  // Send friend request
  Future<FriendRequest> sendFriendRequest(String receiverId) async {
    try {
      final response = await _dio.post(
        '/friends/request',
        data: FriendRequestCreate(receiverId: receiverId).toJson(),
      );

      debugPrint('FriendsApiService: Send request response: ${response.data}');

      if (response.statusCode == 201) {
        return FriendRequest.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to send friend request: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('FriendsApiService: DioException in sendFriendRequest: ${e.message}');
      debugPrint('FriendsApiService: Response data: ${e.response?.data}');
      throw Exception('Failed to send friend request: ${e.response?.data['detail'] ?? e.message}');
    } catch (e) {
      debugPrint('FriendsApiService: Exception in sendFriendRequest: $e');
      throw Exception('Failed to send friend request: $e');
    }
  }

  // Get received friend requests
  Future<List<FriendRequest>> getReceivedFriendRequests() async {
    try {
      final response = await _dio.get('/friends/requests/received');

      debugPrint('FriendsApiService: Get received requests response: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> requestsJson = response.data['requests'] as List<dynamic>;
        return requestsJson
            .map((json) => FriendRequest.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get friend requests: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('FriendsApiService: DioException in getReceivedFriendRequests: ${e.message}');
      throw Exception('Failed to get friend requests: ${e.message}');
    } catch (e) {
      debugPrint('FriendsApiService: Exception in getReceivedFriendRequests: $e');
      throw Exception('Failed to get friend requests: $e');
    }
  }

  // Get sent friend requests
  Future<List<FriendRequest>> getSentFriendRequests() async {
    try {
      final response = await _dio.get('/friends/requests/sent');

      debugPrint('FriendsApiService: Get sent requests response: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> requestsJson = response.data['requests'] as List<dynamic>;
        return requestsJson
            .map((json) => FriendRequest.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get sent requests: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('FriendsApiService: DioException in getSentFriendRequests: ${e.message}');
      throw Exception('Failed to get sent requests: ${e.message}');
    } catch (e) {
      debugPrint('FriendsApiService: Exception in getSentFriendRequests: $e');
      throw Exception('Failed to get sent requests: $e');
    }
  }

  // Handle friend request (accept/reject)
  Future<String> handleFriendRequest(String requestId, String action) async {
    try {
      final response = await _dio.put(
        '/friends/request/$requestId',
        data: FriendRequestAction(action: action).toJson(),
      );

      debugPrint('FriendsApiService: Handle request response: ${response.data}');

      if (response.statusCode == 200) {
        return response.data['message'] as String;
      } else {
        throw Exception('Failed to handle friend request: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('FriendsApiService: DioException in handleFriendRequest: ${e.message}');
      throw Exception('Failed to handle friend request: ${e.response?.data['detail'] ?? e.message}');
    } catch (e) {
      debugPrint('FriendsApiService: Exception in handleFriendRequest: $e');
      throw Exception('Failed to handle friend request: $e');
    }
  }

  // Get friends list
  Future<List<Friend>> getFriends() async {
    try {
      final response = await _dio.get('/friends');

      debugPrint('FriendsApiService: Get friends response: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> friendsJson = response.data['friends'] as List<dynamic>;
        return friendsJson
            .map((json) => Friend.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get friends: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('FriendsApiService: DioException in getFriends: ${e.message}');
      throw Exception('Failed to get friends: ${e.message}');
    } catch (e) {
      debugPrint('FriendsApiService: Exception in getFriends: $e');
      throw Exception('Failed to get friends: $e');
    }
  }
}
