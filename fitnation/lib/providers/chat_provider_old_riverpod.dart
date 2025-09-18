import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_models.dart';

// Simple Chat Providers that actually work

// Current chat room provider
final currentChatRoomProvider = StateProvider<ChatRoom?>((ref) => null);

// Chat rooms provider with basic state management
final chatRoomsProvider = FutureProvider<List<ChatRoom>>((ref) async {
  // For now, return mock data until backend is ready
  return [
    ChatRoom(
      id: '1',
      type: ChatRoomType.direct,
      name: 'John Doe',
      lastMessageContent: 'Hey there!',
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
});

// Chat messages provider for a specific room
final chatMessagesProvider = StateNotifierProvider.family<
  ChatMessagesNotifier,
  List<ChatMessage>,
  String
>((ref, roomId) {
  return ChatMessagesNotifier(roomId);
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final String roomId;

  ChatMessagesNotifier(this.roomId) : super([]) {
    _loadMockMessages();
  }

  void _loadMockMessages() {
    // Load mock messages
    state = [
      ChatMessage(
        id: '1',
        roomId: roomId,
        senderId: '1',
        senderName: 'john_doe',
        senderDisplayName: 'John Doe',
        content: 'Hey there! How\'s your workout going?',
        messageType: MessageType.text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      ChatMessage(
        id: '2',
        roomId: roomId,
        senderId: 'current_user',
        senderName: 'current_user',
        senderDisplayName: 'You',
        content: 'Going great! Just finished my cardio session.',
        messageType: MessageType.text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
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
      ),
    ];
  }

  Future<bool> sendMessage(String content) async {
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

  void addOptimisticMessage(
    String content,
    String senderId,
    String senderName,
  ) {
    final message = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: senderId,
      senderName: senderName,
      senderDisplayName: senderName,
      content: content,
      messageType: MessageType.text,
      createdAt: DateTime.now(),
    );
    state = [...state, message];
  }

  void refresh() {
    _loadMockMessages();
  }

  void markAsRead() {
    // Mark messages as read - for now just print
    print('Messages marked as read for room $roomId');
  }
}

// Friends provider
final friendsProvider = FutureProvider<List<Friend>>((ref) async {
  // Mock friends data
  return [
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
});

// Sending message state
final sendingMessageProvider = StateProvider<bool>((ref) => false);

// Create direct chat function
final createDirectChatProvider = Provider((ref) {
  return (String friendId, String friendUsername) async {
    // Create mock chat room
    final chatRoom = ChatRoom(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      type: ChatRoomType.direct,
      name: friendUsername,
      createdAt: DateTime.now(),
      participants: [
        ChatParticipant(
          userId: friendId,
          username: friendUsername,
          displayName: friendUsername,
          role: ParticipantRole.member,
          joinedAt: DateTime.now(),
        ),
      ],
    );

    return chatRoom;
  };
});
