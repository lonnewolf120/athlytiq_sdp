import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  String? _token;
  String? _userId;
  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _pingInterval = Duration(seconds: 30);

  // Stream controllers for different message types
  final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _connectionController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _errorController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _statusController = 
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters for streams
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get connectionStream => _connectionController.stream;
  Stream<Map<String, dynamic>> get errorStream => _errorController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;

  bool get isConnected => _isConnected;
  String? get userId => _userId;

  /// Initialize WebSocket connection with authentication token
  Future<void> initialize(String token, String userId) async {
    _token = token;
    _userId = userId;
    await connect();
  }

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnecting || _isConnected) return;
    
    _isConnecting = true;
    
    try {
      // Get base URL from shared preferences or use default
      final prefs = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('api_base_url') ?? 'ws://localhost:8000';
      
      // Replace http/https with ws/wss
      final wsUrl = baseUrl.replaceFirst(RegExp(r'^https?://'), 'ws://');
      final wsEndpoint = '$wsUrl/ws/chat?token=$_token';
      
      if (kDebugMode) {
        print('Connecting to WebSocket: $wsEndpoint');
      }

      _channel = WebSocketChannel.connect(Uri.parse(wsEndpoint));
      
      // Listen to incoming messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      
      // Start ping timer
      _startPingTimer();
      
      // Emit connection event
      _connectionController.add({
        'type': 'connected',
        'data': {'user_id': _userId}
      });

      if (kDebugMode) {
        print('WebSocket connected successfully');
      }
      
    } catch (e) {
      _isConnecting = false;
      _handleError(e);
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _stopPingTimer();
    _stopReconnectTimer();
    
    if (_channel != null) {
      await _channel!.sink.close(status.goingAway);
      _channel = null;
    }
    
    _isConnected = false;
    _isConnecting = false;
    
    _connectionController.add({
      'type': 'disconnected',
      'data': {'user_id': _userId}
    });

    if (kDebugMode) {
      print('WebSocket disconnected');
    }
  }

  /// Send a message through WebSocket
  void sendMessage(Map<String, dynamic> message) {
    if (!_isConnected || _channel == null) {
      _errorController.add({
        'type': 'error',
        'data': {'message': 'WebSocket not connected'}
      });
      return;
    }

    try {
      final jsonMessage = json.encode(message);
      _channel!.sink.add(jsonMessage);
      
      if (kDebugMode) {
        print('Sent WebSocket message: $jsonMessage');
      }
    } catch (e) {
      _errorController.add({
        'type': 'error',
        'data': {'message': 'Failed to send message: $e'}
      });
    }
  }

  /// Join a chat room
  void joinRoom(String roomId) {
    sendMessage({
      'type': 'join_room',
      'data': {'room_id': roomId}
    });
  }

  /// Leave a chat room
  void leaveRoom(String roomId) {
    sendMessage({
      'type': 'leave_room',
      'data': {'room_id': roomId}
    });
  }

  /// Send a text message
  void sendTextMessage(String roomId, String content, {String? replyToId}) {
    sendMessage({
      'type': 'send_message',
      'data': {
        'room_id': roomId,
        'content': content,
        'message_type': 'text',
        'reply_to_id': replyToId,
      }
    });
  }

  /// Send typing indicator
  void sendTypingIndicator(String roomId, bool isTyping) {
    sendMessage({
      'type': isTyping ? 'typing_start' : 'typing_stop',
      'data': {'room_id': roomId}
    });
  }

  /// Mark messages as read
  void markMessagesAsRead(String roomId, List<String> messageIds) {
    sendMessage({
      'type': 'message_read',
      'data': {
        'room_id': roomId,
        'message_ids': messageIds,
      }
    });
  }

  /// Send ping to keep connection alive
  void _sendPing() {
    if (_isConnected) {
      sendMessage({
        'type': 'ping',
        'data': {'timestamp': DateTime.now().millisecondsSinceEpoch}
      });
    }
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic data) {
    try {
      final message = json.decode(data);
      final type = message['type'] as String?;
      final messageData = message['data'] as Map<String, dynamic>?;

      if (kDebugMode) {
        print('Received WebSocket message: $message');
      }

      switch (type) {
        case 'connection_established':
          _connectionController.add(message);
          break;
        case 'new_message':
        case 'message_sent':
          _messageController.add(message);
          break;
        case 'typing_indicator':
          _typingController.add(message);
          break;
        case 'message_read_receipt':
          _messageController.add(message);
          break;
        case 'user_status_change':
          _statusController.add(message);
          break;
        case 'pong':
          // Handle pong response
          break;
        case 'error':
          _errorController.add(message);
          break;
        default:
          if (kDebugMode) {
            print('Unknown WebSocket message type: $type');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing WebSocket message: $e');
      }
      _errorController.add({
        'type': 'error',
        'data': {'message': 'Failed to parse message: $e'}
      });
    }
  }

  /// Handle WebSocket errors
  void _handleError(dynamic error) {
    if (kDebugMode) {
      print('WebSocket error: $error');
    }
    
    _isConnected = false;
    _isConnecting = false;
    
    _errorController.add({
      'type': 'error',
      'data': {'message': 'WebSocket error: $error'}
    });

    // Attempt to reconnect
    _attemptReconnect();
  }

  /// Handle WebSocket disconnection
  void _handleDisconnection() {
    if (kDebugMode) {
      print('WebSocket disconnected');
    }
    
    _isConnected = false;
    _isConnecting = false;
    _stopPingTimer();
    
    _connectionController.add({
      'type': 'disconnected',
      'data': {'user_id': _userId}
    });

    // Attempt to reconnect
    _attemptReconnect();
  }

  /// Attempt to reconnect to WebSocket
  void _attemptReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      if (kDebugMode) {
        print('Max reconnection attempts reached');
      }
      return;
    }

    _reconnectAttempts++;
    
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (kDebugMode) {
        print('Attempting to reconnect (attempt $_reconnectAttempts/$_maxReconnectAttempts)');
      }
      connect();
    });
  }

  /// Start ping timer to keep connection alive
  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(_pingInterval, (_) => _sendPing());
  }

  /// Stop ping timer
  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  /// Stop reconnect timer
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Dispose of all resources
  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
    _errorController.close();
    _typingController.close();
    _statusController.close();
  }
}