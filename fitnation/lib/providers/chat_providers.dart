import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/chat_service.dart';
import '../models/chat_models.dart';
import 'data_providers.dart'; // Import existing data providers with apiServiceProvider
import 'websocket_provider.dart';

// Service providers
final chatServiceProvider = Provider<ChatService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ChatService(apiService);
});

final friendsServiceProvider = Provider<FriendsService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FriendsService(apiService);
});

// Chat Rooms State
class ChatRoomsState {
  final List<ChatRoom> rooms;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  const ChatRoomsState({
    this.rooms = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  ChatRoomsState copyWith({
    List<ChatRoom>? rooms,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) {
    return ChatRoomsState(
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Chat Rooms Provider
class ChatRoomsNotifier extends StateNotifier<ChatRoomsState> {
  final ChatService _chatService;
  final WebSocketService _webSocketService;
  static const int _pageSize = 20;

  ChatRoomsNotifier(this._chatService, this._webSocketService) 
      : super(const ChatRoomsState()) {
    // Listen to WebSocket room updates
    _webSocketService.roomUpdatesStream.listen((update) {
      _handleRoomUpdate(update);
    });
  }

  Future<void> loadRooms({bool refresh = false}) async {
    if (state.isLoading) return;
    
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final skip = refresh ? 0 : state.rooms.length;
      final newRooms = await _chatService.getUserChatRooms(
        skip: skip,
        limit: _pageSize,
      );

      if (refresh) {
        state = state.copyWith(
          rooms: newRooms,
          isLoading: false,
          hasMore: newRooms.length >= _pageSize,
        );
      } else {
        state = state.copyWith(
          rooms: [...state.rooms, ...newRooms],
          isLoading: false,
          hasMore: newRooms.length >= _pageSize,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createDirectChat(String userId) async {
    try {
      final room = await _chatService.createDirectChat(userId);
      
      // Add to the beginning of the list
      state = state.copyWith(
        rooms: [room, ...state.rooms],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> createGroupChat(CreateChatRoomRequest request) async {
    try {
      final room = await _chatService.createGroupChat(request);
      
      // Add to the beginning of the list
      state = state.copyWith(
        rooms: [room, ...state.rooms],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void _handleRoomUpdate(Map<String, dynamic> update) {
    final roomId = update['room_id'] as String?;
    if (roomId == null) return;

    final roomIndex = state.rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex == -1) return;

    final existingRoom = state.rooms[roomIndex];
    ChatRoom updatedRoom;

    switch (update['type']) {
      case 'new_message':
        final messageData = update['message'] as Map<String, dynamic>?;
        if (messageData != null) {
          final message = ChatMessage.fromJson(messageData);
          updatedRoom = existingRoom.copyWith(
            lastMessageAt: DateTime.now(),
            lastMessageContent: message.content,
            lastMessageSenderId: message.senderId,
            updatedAt: DateTime.now(),
            unreadCount: existingRoom.unreadCount + 1,
          );
        } else {
          return;
        }
        break;
      
      case 'messages_read':
        updatedRoom = existingRoom.copyWith(unreadCount: 0);
        break;
        
      default:
        return;
    }

    // Move updated room to the top and update
    final updatedRooms = [...state.rooms];
    updatedRooms.removeAt(roomIndex);
    updatedRooms.insert(0, updatedRoom);

    state = state.copyWith(rooms: updatedRooms);
  }

  void updateRoomSettings(String roomId, {bool? isMuted, bool? isPinned}) {
    final roomIndex = state.rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex == -1) return;

    final updatedRoom = state.rooms[roomIndex].copyWith(
      isMuted: isMuted,
      isPinned: isPinned,
    );

    final updatedRooms = [...state.rooms];
    updatedRooms[roomIndex] = updatedRoom;

    state = state.copyWith(rooms: updatedRooms);

    // Call API
    _chatService.updateRoomSettings(roomId, isMuted: isMuted, isPinned: isPinned);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final chatRoomsProvider = StateNotifierProvider<ChatRoomsNotifier, ChatRoomsState>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return ChatRoomsNotifier(chatService, webSocketService);
});

// Individual Chat Room Messages State
class ChatMessagesState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;

  const ChatMessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
  });

  ChatMessagesState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
  }) {
    return ChatMessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Chat Messages Provider (per room)
class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final ChatService _chatService;
  final WebSocketService _webSocketService;
  final String roomId;
  static const int _pageSize = 50;

  ChatMessagesNotifier(this._chatService, this._webSocketService, this.roomId) 
      : super(const ChatMessagesState()) {
    // Listen to WebSocket message updates for this room
    _webSocketService.messageUpdatesStream.listen((update) {
      if (update['room_id'] == roomId) {
        _handleMessageUpdate(update);
      }
    });
  }

  Future<void> loadMessages({bool refresh = false}) async {
    if (state.isLoading || state.isLoadingMore) return;

    if (refresh) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      String? beforeMessageId;
      if (!refresh && state.messages.isNotEmpty) {
        beforeMessageId = state.messages.last.id;
      }

      final newMessages = await _chatService.getRoomMessages(
        roomId,
        beforeMessageId: beforeMessageId,
        limit: _pageSize,
      );

      if (refresh) {
        state = state.copyWith(
          messages: newMessages,
          isLoading: false,
          isLoadingMore: false,
          hasMore: newMessages.length >= _pageSize,
        );
      } else {
        state = state.copyWith(
          messages: [...state.messages, ...newMessages],
          isLoading: false,
          isLoadingMore: false,
          hasMore: newMessages.length >= _pageSize,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendMessage(String content, {MessageType type = MessageType.text, List<String>? mediaUrls}) async {
    try {
      final request = CreateMessageRequest(
        roomId: roomId, // Added the required roomId parameter
        content: content,
        messageType: type,
        mediaUrls: mediaUrls,
      );

      final message = await _chatService.sendMessage(roomId, request);
      
      // Add to the beginning (newest messages first)
      state = state.copyWith(
        messages: [message, ...state.messages],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markMessagesAsRead({List<String>? messageIds}) async {
    try {
      await _chatService.markMessagesAsRead(roomId, messageIds: messageIds);
    } catch (e) {
      // Silently fail - this is not critical
    }
  }

  void _handleMessageUpdate(Map<String, dynamic> update) {
    switch (update['type']) {
      case 'new_message':
        final messageData = update['message'] as Map<String, dynamic>?;
        if (messageData != null) {
          final message = ChatMessage.fromJson(messageData);
          state = state.copyWith(
            messages: [message, ...state.messages],
          );
        }
        break;
        
      case 'message_updated':
        final messageData = update['message'] as Map<String, dynamic>?;
        if (messageData != null) {
          final updatedMessage = ChatMessage.fromJson(messageData);
          final messageIndex = state.messages.indexWhere((m) => m.id == updatedMessage.id);
          
          if (messageIndex != -1) {
            final updatedMessages = [...state.messages];
            updatedMessages[messageIndex] = updatedMessage;
            state = state.copyWith(messages: updatedMessages);
          }
        }
        break;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider factory for chat messages per room
final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, ChatMessagesState, String>((ref, roomId) {
  final chatService = ref.watch(chatServiceProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return ChatMessagesNotifier(chatService, webSocketService, roomId);
});

// Friends State
class FriendsState {
  final List<Friend> friends;
  final List<FriendRequest> receivedRequests;
  final List<FriendRequest> sentRequests;
  final bool isLoading;
  final String? error;

  const FriendsState({
    this.friends = const [],
    this.receivedRequests = const [],
    this.sentRequests = const [],
    this.isLoading = false,
    this.error,
  });

  FriendsState copyWith({
    List<Friend>? friends,
    List<FriendRequest>? receivedRequests,
    List<FriendRequest>? sentRequests,
    bool? isLoading,
    String? error,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Friends Provider
class FriendsNotifier extends StateNotifier<FriendsState> {
  final FriendsService _friendsService;
  final WebSocketService _webSocketService;

  FriendsNotifier(this._friendsService, this._webSocketService) 
      : super(const FriendsState()) {
    // Listen to WebSocket friend updates
    _webSocketService.friendUpdatesStream.listen((update) {
      _handleFriendUpdate(update);
    });
  }

  Future<void> loadFriends({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final futures = await Future.wait([
        _friendsService.getFriendsList(),
        _friendsService.getFriendRequests(requestType: 'received'),
        _friendsService.getFriendRequests(requestType: 'sent'),
      ]);

      state = state.copyWith(
        friends: futures[0] as List<Friend>,
        receivedRequests: futures[1] as List<FriendRequest>,
        sentRequests: futures[2] as List<FriendRequest>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendFriendRequest(String userId, {String? message}) async {
    try {
      final request = await _friendsService.sendFriendRequest(userId, message: message);
      
      state = state.copyWith(
        sentRequests: [request, ...state.sentRequests],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> respondToFriendRequest(String requestId, bool accept) async {
    try {
      await _friendsService.respondToFriendRequest(requestId, accept);
      
      // Remove from received requests
      final updatedReceived = state.receivedRequests.where((r) => r.id != requestId).toList();
      
      // If accepted, the backend should send a friend update via WebSocket
      state = state.copyWith(
        receivedRequests: updatedReceived,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeFriend(String friendId) async {
    try {
      await _friendsService.removeFriend(friendId);
      
      final updatedFriends = state.friends.where((f) => f.userId != friendId).toList();
      state = state.copyWith(friends: updatedFriends);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<List<UserSearchResult>> searchUsers(String query, {bool excludeFriends = true}) async {
    try {
      return await _friendsService.searchUsers(query, excludeFriends: excludeFriends);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  void _handleFriendUpdate(Map<String, dynamic> update) {
    switch (update['type']) {
      case 'friend_request_received':
        final requestData = update['request'] as Map<String, dynamic>?;
        if (requestData != null) {
          final request = FriendRequest.fromJson(requestData);
          state = state.copyWith(
            receivedRequests: [request, ...state.receivedRequests],
          );
        }
        break;
        
      case 'friend_added':
        final friendData = update['friend'] as Map<String, dynamic>?;
        if (friendData != null) {
          final friend = Friend.fromJson(friendData);
          state = state.copyWith(
            friends: [friend, ...state.friends],
          );
        }
        break;
        
      case 'friend_removed':
        final friendId = update['friend_id'] as String?;
        if (friendId != null) {
          final updatedFriends = state.friends.where((f) => f.userId != friendId).toList();
          state = state.copyWith(friends: updatedFriends);
        }
        break;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final friendsProvider = StateNotifierProvider<FriendsNotifier, FriendsState>((ref) {
  final friendsService = ref.watch(friendsServiceProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return FriendsNotifier(friendsService, webSocketService);
});

// User Search Provider
final userSearchProvider = FutureProvider.family<List<UserSearchResult>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  
  final friendsService = ref.watch(friendsServiceProvider);
  return await friendsService.searchUsers(query.trim());
});
