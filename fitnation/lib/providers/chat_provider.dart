import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_models.dart';
import '../services/websocket_service.dart';
import '../api/chat_api_service.dart';

class ChatProvider with ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  final ChatApiService _chatApiService = ChatApiService();

  // State
  bool _isConnected = false;
  bool _isLoading = false;
  String? _currentUserId;
  String? _currentRoomId;

  // Data
  List<ChatRoom> _rooms = [];
  List<ChatMessage> _messages = [];
  List<Friend> _friends = [];
  List<FriendRequest> _friendRequests = [];
  Map<String, List<TypingIndicator>> _typingIndicators = {};
  Map<String, bool> _userOnlineStatus = {};

  // Getters
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;
  String? get currentRoomId => _currentRoomId;
  List<ChatRoom> get rooms => _rooms;
  List<ChatMessage> get messages => _messages;
  List<Friend> get friends => _friends;
  List<FriendRequest> get friendRequests => _friendRequests;
  Map<String, List<TypingIndicator>> get typingIndicators => _typingIndicators;
  Map<String, bool> get userOnlineStatus => _userOnlineStatus;

  // Initialize the chat provider
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get user token and ID from storage
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      _currentUserId = userId;

      // Initialize WebSocket connection
      await _webSocketService.initialize(token, userId);

      // Set up WebSocket listeners
      _setupWebSocketListeners();

      // Load initial data
      await _loadInitialData();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error initializing chat provider: $e');
      }
      rethrow;
    }
  }

  // Set up WebSocket listeners
  void _setupWebSocketListeners() {
    // Connection status
    _webSocketService.connectionStream.listen((event) {
      _isConnected = event['type'] == 'connected';
      notifyListeners();
    });

    // Messages
    _webSocketService.messageStream.listen((event) {
      _handleWebSocketMessage(event);
    });

    // Typing indicators
    _webSocketService.typingStream.listen((event) {
      _handleTypingIndicator(event);
    });

    // User status changes
    _webSocketService.statusStream.listen((event) {
      _handleUserStatusChange(event);
    });

    // Errors
    _webSocketService.errorStream.listen((event) {
      if (kDebugMode) {
        print('WebSocket error: ${event['data']['message']}');
      }
    });
  }

  // Handle WebSocket messages
  void _handleWebSocketMessage(Map<String, dynamic> event) {
    final type = event['type'] as String;
    final data = event['data'] as Map<String, dynamic>;

    switch (type) {
      case 'new_message':
      case 'message_sent':
        final message = ChatMessage.fromJson(data);
        _addMessage(message);
        _updateRoomLastMessage(message);
        break;
      case 'message_read_receipt':
        _handleMessageReadReceipt(data);
        break;
    }
  }

  // Handle typing indicators
  void _handleTypingIndicator(Map<String, dynamic> event) {
    final data = event['data'] as Map<String, dynamic>;
    final roomId = data['room_id'] as String;
    final userId = data['user_id'] as String;
    final isTyping = data['is_typing'] as bool;

    if (!_typingIndicators.containsKey(roomId)) {
      _typingIndicators[roomId] = [];
    }

    if (isTyping) {
      // Add typing indicator
      final indicator = TypingIndicator(
        roomId: roomId,
        userId: userId,
        username: data['username'] ?? 'Unknown',
        displayName: data['display_name'],
        startedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(seconds: 3)),
      );

      _typingIndicators[roomId]!.removeWhere((i) => i.userId == userId);
      _typingIndicators[roomId]!.add(indicator);
    } else {
      // Remove typing indicator
      _typingIndicators[roomId]!.removeWhere((i) => i.userId == userId);
    }

    notifyListeners();
  }

  // Handle user status changes
  void _handleUserStatusChange(Map<String, dynamic> event) {
    final data = event['data'] as Map<String, dynamic>;
    final userId = data['user_id'] as String;
    final isOnline = data['is_online'] as bool;

    _userOnlineStatus[userId] = isOnline;
    notifyListeners();
  }

  // Handle message read receipts
  void _handleMessageReadReceipt(Map<String, dynamic> data) {
    final roomId = data['room_id'] as String;
    final userId = data['user_id'] as String;
    final messageIds = List<String>.from(data['message_ids'] ?? []);

    // Update read status for messages
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].roomId == roomId &&
          messageIds.contains(_messages[i].id)) {
        _messages[i] = _messages[i].copyWith(
          readReceipts: [
            ..._messages[i].readReceipts,
            MessageReadReceipt(
              userId: userId,
              username: data['username'] ?? 'Unknown',
              displayName: data['display_name'],
              readAt: DateTime.now(),
            ),
          ],
        );
      }
    }

    notifyListeners();
  }

  // Load initial data
  Future<void> _loadInitialData() async {
    try {
      // Load chat rooms
      await loadChatRooms();

      // Load friends
      await loadFriends();

      // Load friend requests
      await loadFriendRequests();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading initial data: $e');
      }
    }
  }

  // Load chat rooms
  Future<void> loadChatRooms() async {
    try {
      final response = await _chatApiService.getChatRooms();
      _rooms = response.rooms;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading chat rooms: $e');
      }
    }
  }

  // Load messages for a room
  Future<void> loadMessages(String roomId, {String? beforeMessageId}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _chatApiService.getMessages(
        roomId,
        beforeMessageId: beforeMessageId,
      );

      if (beforeMessageId == null) {
        _messages = response.messages;
      } else {
        _messages = [...response.messages, ..._messages];
      }

      _currentRoomId = roomId;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error loading messages: $e');
      }
      rethrow;
    }
  }

  // Send a message
  Future<void> sendMessage(
    String roomId,
    String content, {
    String? replyToId,
  }) async {
    try {
      // Create optimistic message
      final newMessage = ChatMessage(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        roomId: roomId,
        senderId: 'current_user',
        senderName: 'current_user',
        senderDisplayName: 'You',
        content: content,
        messageType: MessageType.text,
        createdAt: DateTime.now(),
      );

      // Add to state immediately for optimistic UI
      state = [...state, newMessage];
      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Add message to local list
  void _addMessage(ChatMessage message) {
    // Remove temporary message if it exists
    _messages.removeWhere(
      (m) => m.id == 'temp_${message.createdAt.millisecondsSinceEpoch}',
    );

    // Add new message
    _messages.add(message);

    // Sort messages by creation time
    _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    notifyListeners();
  }

  // Update room's last message
  void _updateRoomLastMessage(ChatMessage message) {
    final roomIndex = _rooms.indexWhere((r) => r.id == message.roomId);
    if (roomIndex != -1) {
      _rooms[roomIndex] = _rooms[roomIndex].copyWith(
        lastMessageAt: message.createdAt,
        lastMessageContent: message.content,
        lastMessageSenderId: message.senderId,
      );
      notifyListeners();
    }
  }

  // Join a chat room
  void joinRoom(String roomId) {
    _webSocketService.joinRoom(roomId);
    _currentRoomId = roomId;
    notifyListeners();
  }

  void refresh() {
    _loadMockMessages();
  }

  // Send typing indicator
  void sendTypingIndicator(String roomId, bool isTyping) {
    _webSocketService.sendTypingIndicator(roomId, isTyping);
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(
    String roomId,
    List<String> messageIds,
  ) async {
    try {
      _webSocketService.markMessagesAsRead(roomId, messageIds);

      // Update local read status
      for (int i = 0; i < _messages.length; i++) {
        if (_messages[i].roomId == roomId &&
            messageIds.contains(_messages[i].id)) {
          _messages[i] = _messages[i].copyWith(isReadByCurrentUser: true);
        }
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error marking messages as read: $e');
      }
    }
  }

  // Load friends
  Future<void> loadFriends() async {
    try {
      _friends = await _chatApiService.getFriends();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading friends: $e');
      }
    }
  }

  // Load friend requests
  Future<void> loadFriendRequests() async {
    try {
      _friendRequests = await _chatApiService.getFriendRequests();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading friend requests: $e');
      }
    }
  }

  // Send friend request
  Future<void> sendFriendRequest(String userId, {String? message}) async {
    try {
      await _chatApiService.sendFriendRequest(userId, message: message);
      await loadFriendRequests();
    } catch (e) {
      if (kDebugMode) {
        print('Error sending friend request: $e');
      }
      rethrow;
    }
  }

  // Respond to friend request
  Future<void> respondToFriendRequest(String requestId, bool accept) async {
    try {
      await _chatApiService.respondToFriendRequest(requestId, accept);
      await loadFriendRequests();
      if (accept) {
        await loadFriends();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error responding to friend request: $e');
      }
      rethrow;
    }
  }

  // Create direct chat room
  Future<ChatRoom> createDirectChatRoom(String userId) async {
    try {
      final room = await _chatApiService.createDirectChatRoom(userId);
      _rooms.add(room);
      notifyListeners();
      return room;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating direct chat room: $e');
      }
      rethrow;
    }
  }

  // Create group chat room
  Future<ChatRoom> createGroupChatRoom({
    required String name,
    required List<String> participantIds,
    String? description,
  }) async {
    try {
      final room = await _chatApiService.createGroupChatRoom(
        name: name,
        participantIds: participantIds,
        description: description,
      );
      _rooms.add(room);
      notifyListeners();
      return room;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating group chat room: $e');
      }
      rethrow;
    }
  }

  // Search users
  Future<List<UserSearchResult>> searchUsers(String query) async {
    try {
      final response = await _chatApiService.searchUsers(query);
      return response.users;
    } catch (e) {
      if (kDebugMode) {
        print('Error searching users: $e');
      }
      return [];
    }
  }

  // Get typing indicators for a room
  List<TypingIndicator> getTypingIndicatorsForRoom(String roomId) {
    return _typingIndicators[roomId] ?? [];
  }

  // Check if user is online
  bool isUserOnline(String userId) {
    return _userOnlineStatus[userId] ?? false;
  }

  // Get unread count for a room
  int getUnreadCountForRoom(String roomId) {
    final room = _rooms.firstWhere(
      (r) => r.id == roomId,
      orElse:
          () => ChatRoom(
            id: '',
            type: ChatRoomType.direct,
            createdAt: DateTime.now(),
          ),
    );
    return room.unreadCount;
  }

  // Clear messages for current room
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  // Dispose
  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }
}
