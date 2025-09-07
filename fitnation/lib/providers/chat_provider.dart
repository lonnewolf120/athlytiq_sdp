import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/chat_api_service.dart';
import '../models/chat_models.dart';
import 'friends_provider.dart';

// Chat API Service Provider
final chatApiServiceProvider = Provider<ChatApiService>((ref) {
  final dio = ref.watch(dioProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return ChatApiService(dio, secureStorage);
});

// Chat Rooms State
final chatRoomsProvider = StateNotifierProvider<ChatRoomsNotifier, AsyncValue<List<ChatRoom>>>((ref) {
  final apiService = ref.watch(chatApiServiceProvider);
  return ChatRoomsNotifier(apiService);
});

class ChatRoomsNotifier extends StateNotifier<AsyncValue<List<ChatRoom>>> {
  final ChatApiService _apiService;

  ChatRoomsNotifier(this._apiService) : super(const AsyncValue.loading());

  Future<void> loadChatRooms() async {
    state = const AsyncValue.loading();
    try {
      final rooms = await _apiService.getChatRooms();
      // Sort rooms by last message time
      rooms.sort((a, b) {
        final aTime = a.lastMessageAt ?? a.createdAt;
        final bTime = b.lastMessageAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      state = AsyncValue.data(rooms);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<ChatRoom?> createDirectChat(String friendId, String friendUsername) async {
    try {
      final room = await _apiService.createDirectChat(friendId, friendUsername);
      // Add the new room to the list
      state.whenData((rooms) {
        final updatedRooms = [room, ...rooms];
        state = AsyncValue.data(updatedRooms);
      });
      return room;
    } catch (e) {
      return null;
    }
  }

  Future<ChatRoom?> createGroupChat({
    required String name,
    String? description,
    required List<String> participantIds,
  }) async {
    try {
      final room = await _apiService.createChatRoom(
        name: name,
        type: 'group',
        description: description,
        participantIds: participantIds,
      );
      // Add the new room to the list
      state.whenData((rooms) {
        final updatedRooms = [room, ...rooms];
        state = AsyncValue.data(updatedRooms);
      });
      return room;
    } catch (e) {
      return null;
    }
  }

  void refresh() {
    loadChatRooms();
  }
}

// Chat Messages State for a specific room
final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, AsyncValue<List<ChatMessage>>, String>((ref, roomId) {
  final apiService = ref.watch(chatApiServiceProvider);
  return ChatMessagesNotifier(apiService, roomId);
});

class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final ChatApiService _apiService;
  final String roomId;

  ChatMessagesNotifier(this._apiService, this.roomId) : super(const AsyncValue.loading());

  Future<void> loadMessages() async {
    state = const AsyncValue.loading();
    try {
      final messages = await _apiService.getChatMessages(roomId);
      // Sort messages by creation time (newest first for display, but we'll reverse in UI)
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      state = AsyncValue.data(messages);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<bool> sendMessage(String content) async {
    try {
      final message = await _apiService.sendMessage(roomId, content);
      // Add the new message to the list
      state.whenData((messages) {
        final updatedMessages = [...messages, message];
        state = AsyncValue.data(updatedMessages);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> markAsRead() async {
    try {
      await _apiService.markMessagesAsRead(roomId);
    } catch (e) {
      // Silently fail for read receipts
    }
  }

  void refresh() {
    loadMessages();
  }

  // Add a message optimistically (before server confirmation)
  void addOptimisticMessage(String content, String senderId, String senderUsername) {
    state.whenData((messages) {
      final optimisticMessage = ChatMessage(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        chatRoomId: roomId,
        senderId: senderId,
        senderUsername: senderUsername,
        senderFirstName: null,
        senderLastName: null,
        senderProfileImageUrl: null,
        content: content,
        messageType: 'text',
        createdAt: DateTime.now(),
        editedAt: null,
        isRead: false,
      );
      final updatedMessages = [...messages, optimisticMessage];
      state = AsyncValue.data(updatedMessages);
    });
  }
}

// Current Chat Room State
final currentChatRoomProvider = StateProvider<ChatRoom?>((ref) => null);

// Message Input State
final messageInputProvider = StateProvider<String>((ref) => '');

// Sending Message State
final sendingMessageProvider = StateProvider<bool>((ref) => false);

// Unread Messages Count Provider
final unreadMessagesCountProvider = Provider<int>((ref) {
  final chatRoomsAsync = ref.watch(chatRoomsProvider);
  
  return chatRoomsAsync.when(
    data: (rooms) {
      // This is a simplified count - in a real app you'd track unread messages per room
      return rooms.where((room) => room.lastMessage != null).length;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});
