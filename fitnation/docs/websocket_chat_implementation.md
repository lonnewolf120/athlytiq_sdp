# WebSocket Chat Implementation

This document describes the WebSocket-based real-time chat implementation for the Fitnation Flutter app.

## Overview

The chat system provides real-time messaging capabilities using WebSocket connections. It includes:

- Real-time text messaging
- Typing indicators
- Message read receipts
- User online status
- Friend management
- Chat room management (direct and group chats)

## Architecture

### Backend Components

1. **WebSocket Endpoint** (`/ws/chat`)
   - Handles WebSocket connections
   - Manages user authentication
   - Processes real-time messages

2. **Connection Manager**
   - Tracks active connections
   - Manages room subscriptions
   - Handles message broadcasting

3. **Message Handlers**
   - Send messages
   - Typing indicators
   - Read receipts
   - Room management

### Frontend Components

1. **WebSocketService** (`lib/services/websocket_service.dart`)
   - Manages WebSocket connection
   - Handles message sending/receiving
   - Provides streams for different event types

2. **ChatProvider** (`lib/providers/chat_provider.dart`)
   - State management for chat functionality
   - Integrates with WebSocket service
   - Manages local data

3. **Chat Models** (`lib/models/chat_models.dart`)
   - Data models for chat entities
   - JSON serialization/deserialization

4. **UI Components**
   - Chat screens and widgets
   - Message bubbles
   - Input widgets
   - Typing indicators

## WebSocket Protocol

### Connection

```javascript
// Connect to WebSocket
ws://localhost:8000/ws/chat?token=<jwt_token>
```

### Message Format

All messages follow this structure:

```json
{
  "type": "message_type",
  "data": {
    // Message-specific data
  }
}
```

### Message Types

#### Client to Server

1. **join_room**
   ```json
   {
     "type": "join_room",
     "data": {
       "room_id": "uuid"
     }
   }
   ```

2. **leave_room**
   ```json
   {
     "type": "leave_room",
     "data": {
       "room_id": "uuid"
     }
   }
   ```

3. **send_message**
   ```json
   {
     "type": "send_message",
     "data": {
       "room_id": "uuid",
       "content": "Hello World",
       "message_type": "text",
       "reply_to_id": "uuid" // optional
     }
   }
   ```

4. **typing_start/typing_stop**
   ```json
   {
     "type": "typing_start",
     "data": {
       "room_id": "uuid"
     }
   }
   ```

5. **message_read**
   ```json
   {
     "type": "message_read",
     "data": {
       "room_id": "uuid",
       "message_ids": ["uuid1", "uuid2"]
     }
   }
   ```

6. **ping**
   ```json
   {
     "type": "ping",
     "data": {
       "timestamp": 1234567890
     }
   }
   ```

#### Server to Client

1. **connection_established**
   ```json
   {
     "type": "connection_established",
     "data": {
       "user_id": "uuid",
       "message": "Connected successfully"
     }
   }
   ```

2. **new_message**
   ```json
   {
     "type": "new_message",
     "data": {
       "id": "uuid",
       "room_id": "uuid",
       "sender_id": "uuid",
       "content": "Hello World",
       "created_at": "2024-01-01T12:00:00Z"
     }
   }
   ```

3. **message_sent**
   ```json
   {
     "type": "message_sent",
     "data": {
       // Same as new_message
     }
   }
   ```

4. **typing_indicator**
   ```json
   {
     "type": "typing_indicator",
     "data": {
       "room_id": "uuid",
       "user_id": "uuid",
       "username": "johndoe",
       "is_typing": true
     }
   }
   ```

5. **message_read_receipt**
   ```json
   {
     "type": "message_read_receipt",
     "data": {
       "room_id": "uuid",
       "user_id": "uuid",
       "message_ids": ["uuid1", "uuid2"]
     }
   }
   ```

6. **user_status_change**
   ```json
   {
     "type": "user_status_change",
     "data": {
       "user_id": "uuid",
       "is_online": true
     }
   }
   ```

7. **pong**
   ```json
   {
     "type": "pong",
     "data": {
       "timestamp": 1234567890
     }
   }
   ```

8. **error**
   ```json
   {
     "type": "error",
     "data": {
       "message": "Error description"
     }
   }
   ```

## Usage

### Initialize Chat Provider

```dart
// In your main app or screen
final chatProvider = context.read<ChatProvider>();
await chatProvider.initialize();
```

### Send a Message

```dart
await chatProvider.sendMessage(roomId, "Hello World!");
```

### Join a Room

```dart
chatProvider.joinRoom(roomId);
```

### Listen to Messages

```dart
chatProvider.messageStream.listen((message) {
  // Handle new message
  print('New message: ${message['data']['content']}');
});
```

### Listen to Typing Indicators

```dart
chatProvider.typingStream.listen((event) {
  // Handle typing indicator
  final data = event['data'];
  if (data['is_typing']) {
    print('${data['username']} is typing...');
  }
});
```

## Features

### Real-time Messaging
- Instant message delivery
- Message history
- Message status (sent, delivered, read)

### Typing Indicators
- Shows when users are typing
- Auto-expires after 3 seconds
- Multiple users support

### Read Receipts
- Track message read status
- Bulk read marking
- Real-time updates

### User Status
- Online/offline status
- Last seen timestamps
- Status change notifications

### Room Management
- Direct messages
- Group chats
- Room creation/deletion
- Participant management

### Friend System
- Friend requests
- Friend list
- User search
- Blocking functionality

## Error Handling

The WebSocket service includes comprehensive error handling:

- Connection failures
- Authentication errors
- Message validation errors
- Network timeouts
- Automatic reconnection

## Testing

### Backend Tests

Run WebSocket tests:

```bash
cd backend
python tests/run_websocket_tests.py
```

### Frontend Tests

Run Flutter tests:

```bash
cd fitnation
flutter test test/websocket_chat_test.dart
```

## Security

- JWT token authentication
- Message validation
- Rate limiting
- Input sanitization
- CORS configuration

## Performance

- Connection pooling
- Message batching
- Efficient broadcasting
- Memory management
- Automatic cleanup

## Dependencies

### Backend
- FastAPI
- WebSockets
- SQLAlchemy
- Pydantic
- JWT

### Frontend
- web_socket_channel
- provider
- freezed
- json_annotation
- shared_preferences

## Configuration

### Backend Configuration

Set environment variables:

```bash
DATABASE_URL=postgresql://user:pass@localhost/db
JWT_SECRET_KEY=your_secret_key
CORS_ORIGINS=http://localhost:3000
```

### Frontend Configuration

Update API base URL in SharedPreferences:

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('api_base_url', 'http://your-backend-url');
```

## Troubleshooting

### Common Issues

1. **Connection Failed**
   - Check network connectivity
   - Verify backend is running
   - Check authentication token

2. **Messages Not Received**
   - Ensure room is joined
   - Check WebSocket connection status
   - Verify message format

3. **Typing Indicators Not Working**
   - Check typing timer implementation
   - Verify room subscription
   - Check message broadcasting

### Debug Mode

Enable debug logging:

```dart
// In WebSocketService
if (kDebugMode) {
  print('WebSocket message: $message');
}
```

## Future Enhancements

- File sharing
- Voice messages
- Video calls
- Message reactions
- Message editing
- Message deletion
- Push notifications
- Message encryption
- Message search
- Message archiving