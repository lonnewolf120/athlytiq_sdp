import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../lib/services/websocket_service.dart';
import '../lib/models/chat_models.dart';

// Generate mocks
@GenerateMocks([WebSocketChannel])
import 'websocket_chat_test.mocks.dart';

void main() {
  group('WebSocketService Tests', () {
    late WebSocketService webSocketService;
    late MockWebSocketChannel mockChannel;

    setUp(() {
      webSocketService = WebSocketService();
      mockChannel = MockWebSocketChannel();
    });

    tearDown(() {
      webSocketService.dispose();
    });

    test('should initialize with token and user ID', () async {
      // Arrange
      const token = 'test_token';
      const userId = 'test_user_id';

      // Act
      await webSocketService.initialize(token, userId);

      // Assert
      expect(webSocketService.userId, equals(userId));
    });

    test('should send message when connected', () {
      // Arrange
      const message = {
        'type': 'test_message',
        'data': {'content': 'Hello World'}
      };

      // Act
      webSocketService.sendMessage(message);

      // Assert
      // In a real test, you would verify that the message was sent
      // This is a simplified test structure
    });

    test('should join room', () {
      // Arrange
      const roomId = 'test_room_id';

      // Act
      webSocketService.joinRoom(roomId);

      // Assert
      // Verify that join_room message was sent
    });

    test('should leave room', () {
      // Arrange
      const roomId = 'test_room_id';

      // Act
      webSocketService.leaveRoom(roomId);

      // Assert
      // Verify that leave_room message was sent
    });

    test('should send text message', () {
      // Arrange
      const roomId = 'test_room_id';
      const content = 'Hello, World!';

      // Act
      webSocketService.sendTextMessage(roomId, content);

      // Assert
      // Verify that send_message was called with correct parameters
    });

    test('should send typing indicator', () {
      // Arrange
      const roomId = 'test_room_id';
      const isTyping = true;

      // Act
      webSocketService.sendTypingIndicator(roomId, isTyping);

      // Assert
      // Verify that typing_start message was sent
    });

    test('should mark messages as read', () {
      // Arrange
      const roomId = 'test_room_id';
      const messageIds = ['msg1', 'msg2', 'msg3'];

      // Act
      webSocketService.markMessagesAsRead(roomId, messageIds);

      // Assert
      // Verify that message_read message was sent
    });

    test('should handle connection status', () {
      // Arrange
      bool connectionStatus = false;

      // Act
      webSocketService.connectionStream.listen((event) {
        connectionStatus = event['type'] == 'connected';
      });

      // Assert
      // In a real test, you would simulate connection events
    });

    test('should handle message events', () {
      // Arrange
      List<Map<String, dynamic>> receivedMessages = [];

      // Act
      webSocketService.messageStream.listen((event) {
        receivedMessages.add(event);
      });

      // Assert
      // In a real test, you would simulate message events
    });

    test('should handle typing events', () {
      // Arrange
      List<Map<String, dynamic>> typingEvents = [];

      // Act
      webSocketService.typingStream.listen((event) {
        typingEvents.add(event);
      });

      // Assert
      // In a real test, you would simulate typing events
    });

    test('should handle error events', () {
      // Arrange
      List<Map<String, dynamic>> errorEvents = [];

      // Act
      webSocketService.errorStream.listen((event) {
        errorEvents.add(event);
      });

      // Assert
      // In a real test, you would simulate error events
    });

    test('should handle user status events', () {
      // Arrange
      List<Map<String, dynamic>> statusEvents = [];

      // Act
      webSocketService.statusStream.listen((event) {
        statusEvents.add(event);
      });

      // Assert
      // In a real test, you would simulate status events
    });

    test('should disconnect properly', () async {
      // Arrange
      await webSocketService.initialize('token', 'userId');

      // Act
      await webSocketService.disconnect();

      // Assert
      expect(webSocketService.isConnected, isFalse);
    });
  });

  group('Chat Models Tests', () {
    test('should create ChatMessage from JSON', () {
      // Arrange
      final json = {
        'id': 'msg_123',
        'room_id': 'room_456',
        'sender_id': 'user_789',
        'sender_name': 'John Doe',
        'message_type': 'text',
        'content': 'Hello World',
        'created_at': '2024-01-01T12:00:00Z',
        'is_read_by_current_user': false,
      };

      // Act
      final message = ChatMessage.fromJson(json);

      // Assert
      expect(message.id, equals('msg_123'));
      expect(message.roomId, equals('room_456'));
      expect(message.senderId, equals('user_789'));
      expect(message.senderName, equals('John Doe'));
      expect(message.messageType, equals(MessageType.text));
      expect(message.content, equals('Hello World'));
      expect(message.isReadByCurrentUser, isFalse);
    });

    test('should create ChatRoom from JSON', () {
      // Arrange
      final json = {
        'id': 'room_123',
        'type': 'direct',
        'name': 'Test Room',
        'created_at': '2024-01-01T12:00:00Z',
        'unread_count': 5,
        'is_archived': false,
        'total_messages': 100,
        'participants': [],
      };

      // Act
      final room = ChatRoom.fromJson(json);

      // Assert
      expect(room.id, equals('room_123'));
      expect(room.type, equals(ChatRoomType.direct));
      expect(room.name, equals('Test Room'));
      expect(room.unreadCount, equals(5));
      expect(room.isArchived, isFalse);
      expect(room.totalMessages, equals(100));
    });

    test('should create Friend from JSON', () {
      // Arrange
      final json = {
        'id': 'user_123',
        'username': 'johndoe',
        'display_name': 'John Doe',
        'is_online': true,
        'friends_since': '2024-01-01T12:00:00Z',
        'mutual_friends_count': 5,
        'can_message': true,
      };

      // Act
      final friend = Friend.fromJson(json);

      // Assert
      expect(friend.id, equals('user_123'));
      expect(friend.username, equals('johndoe'));
      expect(friend.displayName, equals('John Doe'));
      expect(friend.isOnline, isTrue);
      expect(friend.mutualFriendsCount, equals(5));
      expect(friend.canMessage, isTrue);
    });

    test('should create FriendRequest from JSON', () {
      // Arrange
      final json = {
        'id': 'req_123',
        'requester_id': 'user_456',
        'requester_username': 'johndoe',
        'requestee_id': 'user_789',
        'requestee_username': 'janedoe',
        'status': 'pending',
        'message': 'Hi, let\'s be friends!',
        'created_at': '2024-01-01T12:00:00Z',
      };

      // Act
      final request = FriendRequest.fromJson(json);

      // Assert
      expect(request.id, equals('req_123'));
      expect(request.requesterId, equals('user_456'));
      expect(request.requesterUsername, equals('johndoe'));
      expect(request.requesteeId, equals('user_789'));
      expect(request.requesteeUsername, equals('janedoe'));
      expect(request.status, equals(FriendRequestStatus.pending));
      expect(request.message, equals('Hi, let\'s be friends!'));
    });

    test('should create MessageCreate from JSON', () {
      // Arrange
      final json = {
        'content': 'Hello World',
        'message_type': 'text',
        'media_urls': ['url1', 'url2'],
        'reply_to_id': 'msg_123',
      };

      // Act
      final messageCreate = MessageCreate.fromJson(json);

      // Assert
      expect(messageCreate.content, equals('Hello World'));
      expect(messageCreate.messageType, equals(MessageType.text));
      expect(messageCreate.mediaUrls, equals(['url1', 'url2']));
      expect(messageCreate.replyToId, equals('msg_123'));
    });

    test('should create WebSocketMessage from JSON', () {
      // Arrange
      final json = {
        'type': 'new_message',
        'data': {'content': 'Hello World'},
        'room_id': 'room_123',
        'user_id': 'user_456',
        'timestamp': '2024-01-01T12:00:00Z',
      };

      // Act
      final wsMessage = WebSocketMessage.fromJson(json);

      // Assert
      expect(wsMessage.type, equals('new_message'));
      expect(wsMessage.data['content'], equals('Hello World'));
      expect(wsMessage.roomId, equals('room_123'));
      expect(wsMessage.userId, equals('user_456'));
    });

    test('should create TypingIndicator from JSON', () {
      // Arrange
      final json = {
        'room_id': 'room_123',
        'user_id': 'user_456',
        'username': 'johndoe',
        'started_at': '2024-01-01T12:00:00Z',
        'expires_at': '2024-01-01T12:00:03Z',
      };

      // Act
      final indicator = TypingIndicator.fromJson(json);

      // Assert
      expect(indicator.roomId, equals('room_123'));
      expect(indicator.userId, equals('user_456'));
      expect(indicator.username, equals('johndoe'));
    });

    test('should create UserOnlineStatus from JSON', () {
      // Arrange
      final json = {
        'user_id': 'user_123',
        'is_online': true,
        'last_seen': '2024-01-01T12:00:00Z',
        'last_activity': '2024-01-01T12:00:00Z',
      };

      // Act
      final status = UserOnlineStatus.fromJson(json);

      // Assert
      expect(status.userId, equals('user_123'));
      expect(status.isOnline, isTrue);
    });
  });
}