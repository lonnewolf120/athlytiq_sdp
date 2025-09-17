import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_models.dart';

class ChatApiService {
  static const String _baseUrl = 'http://localhost:8000/api/v1';
  
  // Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get base URL from preferences or use default
  Future<String> _getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_base_url') ?? _baseUrl;
  }

  // Chat Rooms
  Future<ChatRoomListResponse> getChatRooms({
    int skip = 0,
    int limit = 20,
  }) async {
    final url = Uri.parse('${await _getBaseUrl()}/chat/rooms?skip=$skip&limit=$limit');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ChatRoomListResponse.fromJson(data);
    } else {
      throw Exception('Failed to load chat rooms: ${response.statusCode}');
    }
  }

  Future<ChatRoom> getChatRoom(String roomId) async {
    final url = Uri.parse('${await _getBaseUrl()}/chat/rooms/$roomId');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ChatRoom.fromJson(data);
    } else {
      throw Exception('Failed to load chat room: ${response.statusCode}');
    }
  }

  Future<ChatRoom> createDirectChatRoom(String otherUserId) async {
    final url = Uri.parse('${await _getBaseUrl()}/chat/rooms/direct?other_user_id=$otherUserId');
    final response = await http.post(url, headers: await _getHeaders());

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return ChatRoom.fromJson(data);
    } else {
      throw Exception('Failed to create direct chat room: ${response.statusCode}');
    }
  }

  Future<ChatRoom> createGroupChatRoom({
    required String name,
    required List<String> participantIds,
    String? description,
  }) async {
    final url = Uri.parse('${await _getBaseUrl()}/chat/rooms/group');
    final body = json.encode({
      'name': name,
      'description': description,
      'participant_ids': participantIds,
      'room_type': 'group',
    });

    final response = await http.post(url, headers: await _getHeaders(), body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return ChatRoom.fromJson(data);
    } else {
      throw Exception('Failed to create group chat room: ${response.statusCode}');
    }
  }

  Future<void> deleteChatRoom(String roomId) async {
    final url = Uri.parse('${await _getBaseUrl()}/chat/rooms/$roomId');
    final response = await http.delete(url, headers: await _getHeaders());

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete chat room: ${response.statusCode}');
    }
  }

  // Messages
  Future<MessageListResponse> getMessages(
    String roomId, {
    String? beforeMessageId,
    int limit = 50,
  }) async {
    final url = Uri.parse('${await _getBaseUrl()}/chat/rooms/$roomId/messages?limit=$limit${beforeMessageId != null ? '&before_message_id=$beforeMessageId' : ''}');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MessageListResponse.fromJson(data);
    } else {
      throw Exception('Failed to load messages: ${response.statusCode}');
    }
  }

  Future<ChatMessage> getMessage(String messageId) async {
    final url = Uri.parse('${await _getBaseUrl()}/chat/messages/$messageId');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ChatMessage.fromJson(data);
    } else {
      throw Exception('Failed to load message: ${response.statusCode}');
    }
  }

  Future<ChatMessage> sendMessage(String roomId, MessageCreate message) async {
    final url = Uri.parse('${await _getBaseUrl()}/chat/rooms/$roomId/messages');
    final body = json.encode(message.toJson());

    final response = await http.post(url, headers: await _getHeaders(), body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return ChatMessage.fromJson(data);
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }

  Future<ChatMessage> updateMessage(String messageId, Map<String, dynamic> updates) async {
    final url = Uri.parse('${await _getBaseUrl()}/chat/messages/$messageId');
    final body = json.encode(updates);

    final response = await http.put(url, headers: await _getHeaders(), body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ChatMessage.fromJson(data);
    } else {
      throw Exception('Failed to update message: ${response.statusCode}');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final url = Uri.parse('${await _getBaseUrl()}/chat/messages/$messageId');
    final response = await http.delete(url, headers: await _getHeaders());

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete message: ${response.statusCode}');
    }
  }

  Future<void> markMessagesAsRead(String roomId, {List<String>? messageIds}) async {
    final url = Uri.parse('${await _getBaseUrl()}/chat/rooms/$roomId/messages/read');
    final body = json.encode({
      if (messageIds != null) 'message_ids': messageIds,
    });

    final response = await http.put(url, headers: await _getHeaders(), body: body);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to mark messages as read: ${response.statusCode}');
    }
  }

  // Friends
  Future<List<Friend>> getFriends({
    String? search,
    bool? onlineOnly,
    int skip = 0,
    int limit = 50,
  }) async {
    final queryParams = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
    };
    
    if (search != null) queryParams['search'] = search;
    if (onlineOnly != null) queryParams['online_only'] = onlineOnly.toString();

    final url = Uri.parse('${await _getBaseUrl()}/friends/').replace(queryParameters: queryParams);
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Friend.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load friends: ${response.statusCode}');
    }
  }

  Future<List<FriendRequest>> getFriendRequests({
    String? requestType,
    String? statusFilter,
    int skip = 0,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
    };
    
    if (requestType != null) queryParams['request_type'] = requestType;
    if (statusFilter != null) queryParams['status_filter'] = statusFilter;

    final url = Uri.parse('${await _getBaseUrl()}/friends/requests').replace(queryParameters: queryParams);
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => FriendRequest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load friend requests: ${response.statusCode}');
    }
  }

  Future<void> sendFriendRequest(String userId, {String? message}) async {
    final url = Uri.parse('${await _getBaseUrl()}/friends/requests?receiver_id=$userId${message != null ? '&message=${Uri.encodeComponent(message)}' : ''}');
    final response = await http.post(url, headers: await _getHeaders());

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send friend request: ${response.statusCode}');
    }
  }

  Future<void> respondToFriendRequest(String requestId, bool accept) async {
    final url = Uri.parse('${await _getBaseUrl()}/friends/requests/$requestId');
    final body = json.encode({
      'status': accept ? 'accepted' : 'declined',
    });

    final response = await http.put(url, headers: await _getHeaders(), body: body);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to respond to friend request: ${response.statusCode}');
    }
  }

  Future<void> cancelFriendRequest(String requestId) async {
    final url = Uri.parse('${await _getBaseUrl()}/friends/requests/$requestId');
    final response = await http.delete(url, headers: await _getHeaders());

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to cancel friend request: ${response.statusCode}');
    }
  }

  Future<void> removeFriend(String friendId) async {
    final url = Uri.parse('${await _getBaseUrl()}/friends/$friendId');
    final response = await http.delete(url, headers: await _getHeaders());

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to remove friend: ${response.statusCode}');
    }
  }

  Future<UserSearchResponse> searchUsers(String query, {
    bool? excludeFriends,
    int limit = 50,
  }) async {
    final queryParams = <String, String>{
      'q': query,
      'limit': limit.toString(),
    };
    
    if (excludeFriends != null) queryParams['exclude_friends'] = excludeFriends.toString();

    final url = Uri.parse('${await _getBaseUrl()}/friends/search').replace(queryParameters: queryParams);
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserSearchResponse.fromJson(data);
    } else {
      throw Exception('Failed to search users: ${response.statusCode}');
    }
  }

  Future<void> blockUser(String userId) async {
    final url = Uri.parse('${await _getBaseUrl()}/friends/block/$userId');
    final response = await http.post(url, headers: await _getHeaders());

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to block user: ${response.statusCode}');
    }
  }

  Future<void> unblockUser(String userId) async {
    final url = Uri.parse('${await _getBaseUrl()}/friends/block/$userId');
    final response = await http.delete(url, headers: await _getHeaders());

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to unblock user: ${response.statusCode}');
    }
  }

  Future<List<UserSearchResult>> getBlockedUsers() async {
    final url = Uri.parse('${await _getBaseUrl()}/friends/blocked');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => UserSearchResult.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load blocked users: ${response.statusCode}');
    }
  }

  // Room Management
  Future<void> updateRoomParticipants(String roomId, String action, List<String> userIds) async {
    final url = Uri.parse('${await _getBaseUrl()}/chat/rooms/$roomId/participants?action=$action');
    final body = json.encode(userIds);

    final response = await http.put(url, headers: await _getHeaders(), body: body);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update room participants: ${response.statusCode}');
    }
  }

  Future<void> updateRoomSettings(String roomId, {bool? isMuted, bool? isPinned}) async {
    final queryParams = <String, String>{};
    if (isMuted != null) queryParams['is_muted'] = isMuted.toString();
    if (isPinned != null) queryParams['is_pinned'] = isPinned.toString();

    final url = Uri.parse('${await _getBaseUrl()}/chat/rooms/$roomId/settings').replace(queryParameters: queryParams);
    final response = await http.put(url, headers: await _getHeaders());

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update room settings: ${response.statusCode}');
    }
  }

  // Message Reactions
  Future<void> addMessageReaction(String messageId, ReactionType reactionType, String emoji) async {
    final url = Uri.parse('${await _getBaseUrl()}/chat/messages/$messageId/reactions');
    final body = json.encode({
      'reaction_type': reactionType.name,
      'emoji': emoji,
    });

    final response = await http.post(url, headers: await _getHeaders(), body: body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add message reaction: ${response.statusCode}');
    }
  }

  Future<void> removeMessageReaction(String messageId, ReactionType reactionType) async {
    final url = Uri.parse('${await _getBaseUrl()}/chat/messages/$messageId/reactions');
    final body = json.encode({
      'reaction_type': reactionType.name,
    });

    final response = await http.delete(url, headers: await _getHeaders(), body: body);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to remove message reaction: ${response.statusCode}');
    }
  }
}