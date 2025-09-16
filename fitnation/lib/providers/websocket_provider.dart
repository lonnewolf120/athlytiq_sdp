import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum WebSocketStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  
  WebSocketStatus _status = WebSocketStatus.disconnected;
  String? _token;
  String? _currentRoomId;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const int _heartbeatInterval = 30; // seconds
  
  // Stream controllers for different types of updates
  final StreamController<Map<String, dynamic>> _roomUpdatesController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _messageUpdatesController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _friendUpdatesController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _typingUpdatesController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<WebSocketStatus> _statusController = 
      StreamController<WebSocketStatus>.broadcast();

  // Public streams
  Stream<Map<String, dynamic>> get roomUpdatesStream => _roomUpdatesController.stream;
  Stream<Map<String, dynamic>> get messageUpdatesStream => _messageUpdatesController.stream;
  Stream<Map<String, dynamic>> get friendUpdatesStream => _friendUpdatesController.stream;
  Stream<Map<String, dynamic>> get typingUpdatesStream => _typingUpdatesController.stream;
  Stream<WebSocketStatus> get statusStream => _statusController.stream;

  WebSocketStatus get status => _status;
  String? get currentRoomId => _currentRoomId;

  void _setStatus(WebSocketStatus status) {
    if (_status != status) {
      _status = status;
      _statusController.add(status);
    }
  }

  Future<void> connect(String token) async {
    if (_status == WebSocketStatus.connected || _status == WebSocketStatus.connecting) {
      return;
    }

    _token = token;
    _setStatus(WebSocketStatus.connecting);

    try {
      final baseUrl = dotenv.env['WS_BASE_URL'] ?? 'ws://10.103.135.254:8000';
      final wsUrl = '$baseUrl/api/v1/chat/ws?token=$token';
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      _setStatus(WebSocketStatus.connected);
      _reconnectAttempts = 0;
      _startHeartbeat();
      
    } catch (e) {
      _setStatus(WebSocketStatus.error);
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final Map<String, dynamic> message = json.decode(data.toString());
      final messageType = message['type'] as String?;

      switch (messageType) {
        case 'room_update':
        case 'room_created':
        case 'room_deleted':
          _roomUpdatesController.add(message);
          break;
          
        case 'new_message':
        case 'message_updated':
        case 'message_deleted':
          _messageUpdatesController.add(message);
          break;
          
        case 'friend_request_received':
        case 'friend_added':
        case 'friend_removed':
        case 'friend_online':
        case 'friend_offline':
          _friendUpdatesController.add(message);
          break;
          
        case 'user_typing':
        case 'user_stopped_typing':
          _typingUpdatesController.add(message);
          break;
          
        case 'pong':
          // Heartbeat response
          break;
          
        default:
          // Handle unknown message types
          break;
      }
    } catch (e) {
      // Invalid JSON or parsing error
    }
  }

  void _handleError(dynamic error) {
    _setStatus(WebSocketStatus.error);
    _scheduleReconnect();
  }

  void _handleDisconnection() {
    _setStatus(WebSocketStatus.disconnected);
    _stopHeartbeat();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _setStatus(WebSocketStatus.error);
      return;
    }

    _setStatus(WebSocketStatus.reconnecting);
    _reconnectAttempts++;
    
    final delay = Duration(seconds: _reconnectAttempts * 2); // Exponential backoff
    _reconnectTimer = Timer(delay, () {
      if (_token != null) {
        connect(_token!);
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(
      Duration(seconds: _heartbeatInterval),
      (_) => _sendHeartbeat(),
    );
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _sendHeartbeat() {
    if (_status == WebSocketStatus.connected) {
      _sendMessage({'type': 'ping'});
    }
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_status == WebSocketStatus.connected && _channel != null) {
      try {
        _channel!.sink.add(json.encode(message));
      } catch (e) {
        _handleError(e);
      }
    }
  }

  // Public methods for sending messages
  void joinRoom(String roomId) {
    _currentRoomId = roomId;
    _sendMessage({
      'type': 'join_room',
      'room_id': roomId,
    });
  }

  void leaveRoom(String roomId) {
    if (_currentRoomId == roomId) {
      _currentRoomId = null;
    }
    _sendMessage({
      'type': 'leave_room',
      'room_id': roomId,
    });
  }

  void sendTypingIndicator(String roomId, bool isTyping) {
    _sendMessage({
      'type': isTyping ? 'start_typing' : 'stop_typing',
      'room_id': roomId,
    });
  }

  void markMessageAsRead(String roomId, String messageId) {
    _sendMessage({
      'type': 'mark_read',
      'room_id': roomId,
      'message_id': messageId,
    });
  }

  void updateOnlineStatus(bool isOnline) {
    _sendMessage({
      'type': 'update_status',
      'is_online': isOnline,
    });
  }

  void disconnect() {
    _setStatus(WebSocketStatus.disconnected);
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    
    _reconnectAttempts = 0;
    _currentRoomId = null;
    _token = null;
  }

  void dispose() {
    disconnect();
    _roomUpdatesController.close();
    _messageUpdatesController.close();
    _friendUpdatesController.close();
    _typingUpdatesController.close();
    _statusController.close();
  }
}

// Provider for WebSocket service
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Provider to manage WebSocket connection based on auth state
final webSocketConnectionProvider = Provider<void>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  
  // This would be connected to your auth provider
  // For now, we'll assume the token is available from the API service
  // In a real app, you'd have an auth provider that provides the token
  
  ref.onDispose(() {
    webSocketService.disconnect();
  });
  
  return;
});

// Import your actual API service provider from your services
// This is just a placeholder
// You should replace this with: import '../services/your_api_service_provider.dart';
