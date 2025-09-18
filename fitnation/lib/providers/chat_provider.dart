import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/chat_models.dart';
import '../api/chat_service.dart';
import '../api/API_Services.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService;
  final FriendsService _friendsService;

  // State variables
  List<ChatRoom> _rooms = [];
  List<ChatMessage> _messages = [];
  List<Friend> _friends = [];
  List<FriendRequest> _friendRequests = [];
  Map<String, List<TypingIndicator>> _typingIndicators = {};
  bool _isLoading = false;
  String? _currentUserId = 'current_user'; // TODO: Get from auth service

  // Getters
  List<ChatRoom> get rooms => _rooms;
  List<ChatMessage> get messages => _messages;
  List<Friend> get friends => _friends;
  List<FriendRequest> get friendRequests => _friendRequests;
  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;

  ChatProvider()
    : _chatService = ChatService(
        ApiService(Dio(), const FlutterSecureStorage()),
      ),
      _friendsService = FriendsService(
        ApiService(Dio(), const FlutterSecureStorage()),
      ) {
    _loadMockData(); // Load mock data for now
  }

  // Initialize method
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load initial data
      await Future.wait([
        _loadChatRooms(),
        _loadFriends(),
        _loadFriendRequests(),
      ]);
    } catch (e) {
      print('Error initializing chat: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load mock data for demo purposes
  void _loadMockData() {
    _rooms = [
      ChatRoom(
        id: '1',
        type: ChatRoomType.direct,
        name: 'John Doe',
        lastMessageContent: 'Hey there! How\'s your workout going?',
        lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        participants: [
          ChatParticipant(
            userId: '1',
            username: 'john_doe',
            displayName: 'John Doe',
            role: ParticipantRole.member,
            joinedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      ChatRoom(
        id: '2',
        type: ChatRoomType.group,
        name: 'Fitness Group',
        description: 'Our workout group',
        lastMessageContent: 'Great workout today!',
        lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        participants: [
          ChatParticipant(
            userId: '2',
            username: 'jane_smith',
            displayName: 'Jane Smith',
            role: ParticipantRole.admin,
            joinedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
      ),
    ];

    _friends = [
      Friend(
        id: '1',
        username: 'john_doe',
        displayName: 'John Doe',
        avatarUrl: null,
        isOnline: true,
        friendsSince: DateTime.now().subtract(const Duration(days: 10)),
        canMessage: true,
      ),
      Friend(
        id: '2',
        username: 'jane_smith',
        displayName: 'Jane Smith',
        avatarUrl: null,
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        friendsSince: DateTime.now().subtract(const Duration(days: 5)),
        canMessage: true,
      ),
    ];

    _friendRequests = [
      FriendRequest(
        id: '1',
        requesterId: '3',
        requesterUsername: 'mike_wilson',
        requesterDisplayName: 'Mike Wilson',
        requesterAvatar: null,
        requesteeId: _currentUserId!,
        requesteeUsername: 'current_user',
        requesteeDisplayName: 'You',
        requesteeAvatar: null,
        status: FriendRequestStatus.pending,
        message: 'Hey! I saw your workout posts. Want to be friends?',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];

    notifyListeners();
  }

  // Chat Rooms
  Future<void> _loadChatRooms() async {
    try {
      _rooms = await _chatService.getUserChatRooms();
      notifyListeners();
    } catch (e) {
      print('Error loading chat rooms: $e');
      // Keep mock data if API fails
    }
  }

  Future<ChatRoom> createDirectChatRoom(String otherUserId) async {
    try {
      final room = await _chatService.createDirectChat(otherUserId);
      _rooms.add(room);
      notifyListeners();
      return room;
    } catch (e) {
      print('Error creating direct chat: $e');
      // Create mock room for demo
      final mockRoom = ChatRoom(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}',
        type: ChatRoomType.direct,
        name: 'New Direct Chat',
        createdAt: DateTime.now(),
        participants: [
          ChatParticipant(
            userId: otherUserId,
            username: 'user_$otherUserId',
            displayName: 'User $otherUserId',
            role: ParticipantRole.member,
            joinedAt: DateTime.now(),
          ),
        ],
      );
      _rooms.add(mockRoom);
      notifyListeners();
      return mockRoom;
    }
  }

  Future<ChatRoom> createGroupChatRoom({
    required String name,
    required List<String> participantIds,
    String? description,
  }) async {
    try {
      // For now, since the API method signature doesn't match, create a mock room
      // TODO: Fix ChatService.createGroupChat to accept ChatRoomCreate
      // final request = ChatRoomCreate(
      //   type: ChatRoomType.group,
      //   name: name,
      //   description: description,
      //   participantIds: participantIds,
      // );
      // final room = await _chatService.createGroupChat(request);

      final mockRoom = ChatRoom(
        id: 'group_${DateTime.now().millisecondsSinceEpoch}',
        type: ChatRoomType.group,
        name: name,
        description: description,
        createdAt: DateTime.now(),
        participants:
            participantIds
                .map(
                  (id) => ChatParticipant(
                    userId: id,
                    username: 'user_$id',
                    displayName: 'User $id',
                    role: ParticipantRole.member,
                    joinedAt: DateTime.now(),
                  ),
                )
                .toList(),
      );
      _rooms.add(mockRoom);
      notifyListeners();
      return mockRoom;
    } catch (e) {
      print('Error creating group chat: $e');
      // Create mock room for demo
      final mockRoom = ChatRoom(
        id: 'group_${DateTime.now().millisecondsSinceEpoch}',
        type: ChatRoomType.group,
        name: name,
        description: description,
        createdAt: DateTime.now(),
        participants:
            participantIds
                .map(
                  (id) => ChatParticipant(
                    userId: id,
                    username: 'user_$id',
                    displayName: 'User $id',
                    role: ParticipantRole.member,
                    joinedAt: DateTime.now(),
                  ),
                )
                .toList(),
      );
      _rooms.add(mockRoom);
      notifyListeners();
      return mockRoom;
    }
  }

  // Messages
  Future<void> loadMessages(String roomId) async {
    try {
      final roomMessages = await _chatService.getRoomMessages(roomId);
      _messages = roomMessages;
      notifyListeners();
    } catch (e) {
      print('Error loading messages: $e');
      // Load mock messages for demo
      _loadMockMessages(roomId);
    }
  }

  void _loadMockMessages(String roomId) {
    _messages = [
      ChatMessage(
        id: '1',
        roomId: roomId,
        senderId: '1',
        senderName: 'john_doe',
        senderDisplayName: 'John Doe',
        content: 'Hey there! How\'s your workout going?',
        messageType: MessageType.text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        isReadByCurrentUser: true,
      ),
      ChatMessage(
        id: '2',
        roomId: roomId,
        senderId: _currentUserId!,
        senderName: 'current_user',
        senderDisplayName: 'You',
        content: 'Going great! Just finished my cardio session.',
        messageType: MessageType.text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
        isReadByCurrentUser: true,
      ),
      ChatMessage(
        id: '3',
        roomId: roomId,
        senderId: '1',
        senderName: 'john_doe',
        senderDisplayName: 'John Doe',
        content: 'That\'s awesome! Keep it up! 💪',
        messageType: MessageType.text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isReadByCurrentUser: false,
      ),
    ];
    notifyListeners();
  }

  Future<void> sendMessage(String roomId, String content) async {
    try {
      // Create optimistic message
      final tempMessage = ChatMessage(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        roomId: roomId,
        senderId: _currentUserId!,
        senderName: 'current_user',
        senderDisplayName: 'You',
        content: content,
        messageType: MessageType.text,
        createdAt: DateTime.now(),
        isReadByCurrentUser: true,
      );

      // Add optimistically
      _messages.add(tempMessage);
      notifyListeners();

      // Send to server (API integration pending)
      // TODO: Fix ChatService.sendMessage to accept MessageCreate and implement API calls
      // final request = MessageCreate(content: content, messageType: MessageType.text);
      // final sentMessage = await _chatService.sendMessage(roomId, request);

      // For demo, just keep the optimistic message with a proper ID
      final realMessage = tempMessage.copyWith(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Replace temp message with real one
      final index = _messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        _messages[index] = realMessage;
        notifyListeners();
      } // Update room's last message
      final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
      if (roomIndex != -1) {
        _rooms[roomIndex] = _rooms[roomIndex].copyWith(
          lastMessageContent: content,
          lastMessageAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error sending message: $e');
      // Keep optimistic message for demo
    }
  }

  Future<void> markMessagesAsRead(
    String roomId,
    List<String> messageIds,
  ) async {
    try {
      await _chatService.markMessagesAsRead(roomId, messageIds: messageIds);

      // Update local state
      for (int i = 0; i < _messages.length; i++) {
        if (messageIds.contains(_messages[i].id)) {
          _messages[i] = _messages[i].copyWith(isReadByCurrentUser: true);
        }
      }

      // Update room unread count
      final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
      if (roomIndex != -1) {
        _rooms[roomIndex] = _rooms[roomIndex].copyWith(unreadCount: 0);
      }

      notifyListeners();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Room management
  Future<void> joinRoom(String roomId) async {
    // TODO: Implement WebSocket connection or room joining logic
    print('Joined room: $roomId');
  }

  Future<void> leaveRoom(String roomId) async {
    // TODO: Implement WebSocket disconnection or room leaving logic
    print('Left room: $roomId');
  }

  // Typing indicators
  void sendTypingIndicator(String roomId, bool isTyping) {
    if (isTyping) {
      final now = DateTime.now();
      final indicator = TypingIndicator(
        userId: _currentUserId!,
        username: 'current_user',
        displayName: 'You',
        roomId: roomId,
        startedAt: now,
        expiresAt: now.add(const Duration(seconds: 5)),
      );

      if (_typingIndicators[roomId] == null) {
        _typingIndicators[roomId] = [];
      }
      _typingIndicators[roomId]!.removeWhere((t) => t.userId == _currentUserId);
      _typingIndicators[roomId]!.add(indicator);
    } else {
      _typingIndicators[roomId]?.removeWhere((t) => t.userId == _currentUserId);
    }
    notifyListeners();
  }

  List<TypingIndicator> getTypingIndicatorsForRoom(String roomId) {
    final indicators = _typingIndicators[roomId] ?? [];
    // Filter out current user and old indicators
    final cutoff = DateTime.now().subtract(const Duration(seconds: 5));
    return indicators
        .where((t) => t.userId != _currentUserId && t.expiresAt.isAfter(cutoff))
        .toList();
  }

  // Friends
  Future<void> _loadFriends() async {
    try {
      _friends = await _friendsService.getFriendsList();
      notifyListeners();
    } catch (e) {
      print('Error loading friends: $e');
      // Keep mock data if API fails
    }
  }

  Future<void> _loadFriendRequests() async {
    try {
      _friendRequests = await _friendsService.getFriendRequests();
      notifyListeners();
    } catch (e) {
      print('Error loading friend requests: $e');
      // Keep mock data if API fails
    }
  }

  Future<void> respondToFriendRequest(String requestId, bool accept) async {
    try {
      await _friendsService.respondToFriendRequest(requestId, accept);

      // Update local state
      _friendRequests.removeWhere((r) => r.id == requestId);

      if (accept) {
        // Add to friends list if accepted
        final request = _friendRequests.firstWhere((r) => r.id == requestId);
        final newFriend = Friend(
          id: request.requesterId,
          username: request.requesterUsername,
          displayName: request.requesterDisplayName,
          avatarUrl: request.requesterAvatar,
          isOnline: false,
          friendsSince: DateTime.now(),
          canMessage: true,
        );
        _friends.add(newFriend);
      }

      notifyListeners();
    } catch (e) {
      print('Error responding to friend request: $e');
      // For demo, just remove the request
      _friendRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
    }
  }

  // User search
  Future<List<UserSearchResult>> searchUsers(String query) async {
    try {
      return await _friendsService.searchUsers(query);
    } catch (e) {
      print('Error searching users: $e');
      // Return mock results for demo
      return [
            UserSearchResult(
              id: 'search_1',
              username: 'alex_fitness',
              displayName: 'Alex Rodriguez',
              avatarUrl: null,
              isOnline: true,
              mutualFriendsCount: 2,
            ),
            UserSearchResult(
              id: 'search_2',
              username: 'sara_yoga',
              displayName: 'Sara Johnson',
              avatarUrl: null,
              isOnline: false,
              mutualFriendsCount: 0,
            ),
          ]
          .where(
            (user) =>
                user.username.toLowerCase().contains(query.toLowerCase()) ||
                (user.displayName?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }
  }
}
