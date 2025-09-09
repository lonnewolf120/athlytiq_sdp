# Chat and Friends Feature Implementation Plan for Athlytiq

## Overview
This document outlines the implementation plan for adding comprehensive chat and friends functionality to the Athlytiq fitness platform. The features will integrate with the existing social network foundation and expand the community experience.

## Current State Analysis

### ✅ Already Implemented
- **Backend Social Foundation**: 
  - Basic buddy system (`buddies` table, social CRUD operations)
  - Social endpoints (`/api/v1/social/*`)
  - Community messaging foundation
  - Trainer chat system (TrainerChat, TrainerChatRoom models)
  
- **Frontend Components**: 
  - Basic chat UI (`chat_screen.dart`, `messages_page.dart`, `find_friends_page.dart`)
  - Trainer chat implementation
  - User models and data providers

### 🚧 Partially Implemented
- **Database Schema**: Social tables exist but need extension
- **Flutter Models**: Trainer chat models exist, need general chat models
- **API Integration**: Basic endpoints exist, need enhancement

### ❌ Missing Components
- **Direct Messaging System**: Independent of trainer chat
- **Friends Management UI**: Complete friend request workflow
- **Real-time Chat**: WebSocket/Socket.io integration
- **Chat Features**: Media sharing, typing indicators, read receipts

## Architecture Overview

### Backend Stack
- **Database**: PostgreSQL with existing social tables
- **API**: FastAPI with existing social endpoints
- **Real-time**: WebSocket integration for live chat
- **Media**: Cloudinary for file/image sharing

### Frontend Stack
- **State Management**: Riverpod (consistent with existing app)
- **Real-time**: WebSocket integration
- **UI Framework**: Flutter with existing theme system
- **Chat UI**: Enhance existing chat components

## Database Schema Plan

### 1. Extend Existing Tables

```sql
-- Enhance buddies table (already exists but may need modifications)
ALTER TABLE buddies ADD COLUMN IF NOT EXISTS blocked_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE buddies ADD COLUMN IF NOT EXISTS blocked_by UUID REFERENCES users(id);

-- Create general chat rooms (separate from trainer chats)
CREATE TABLE IF NOT EXISTS chat_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(20) NOT NULL DEFAULT 'direct' CHECK (type IN ('direct', 'group')),
    name VARCHAR(255), -- For group chats
    description TEXT, -- For group chats
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_message_at TIMESTAMP WITH TIME ZONE,
    is_archived BOOLEAN DEFAULT FALSE
);

-- Create chat room participants (many-to-many)
CREATE TABLE IF NOT EXISTS chat_participants (
    room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('admin', 'member')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP WITH TIME ZONE,
    last_read_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    unread_count INTEGER DEFAULT 0,
    is_muted BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (room_id, user_id)
);

-- Create chat messages (separate from trainer chats)
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'location', 'system')),
    content TEXT, -- Text content or file description
    media_urls TEXT[], -- Array of media URLs
    reply_to_id UUID REFERENCES chat_messages(id) ON DELETE SET NULL,
    edited_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Create message read receipts
CREATE TABLE IF NOT EXISTS message_read_receipts (
    message_id UUID REFERENCES chat_messages(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    read_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (message_id, user_id)
);

-- Create friend requests (enhance existing buddy system)
CREATE TABLE IF NOT EXISTS friend_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    requestee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'blocked')),
    message TEXT, -- Optional message with friend request
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(requester_id, requestee_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_chat_rooms_last_message_at ON chat_rooms(last_message_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_participants_user_id ON chat_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_participants_room_id ON chat_participants(room_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_room_id_created_at ON chat_messages(room_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_id ON chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_requestee_id ON friend_requests(requestee_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_requester_id ON friend_requests(requester_id);
```

## Backend Implementation Plan

### 1. API Endpoints Structure

```
/api/v1/chat/
├── rooms/
│   ├── GET     /               # Get user's chat rooms
│   ├── POST    /               # Create new chat room
│   ├── GET     /{room_id}      # Get room details
│   ├── PUT     /{room_id}      # Update room (name, etc.)
│   ├── DELETE  /{room_id}      # Archive/leave room
│   └── POST    /{room_id}/join # Join room (for group chats)
├── messages/
│   ├── GET     /{room_id}      # Get messages for room (paginated)
│   ├── POST    /{room_id}      # Send message to room
│   ├── PUT     /{message_id}   # Edit message
│   ├── DELETE  /{message_id}   # Delete message
│   └── POST    /{message_id}/read # Mark message as read
├── friends/
│   ├── GET     /               # Get friends list
│   ├── GET     /requests       # Get friend requests (sent/received)
│   ├── POST    /requests       # Send friend request
│   ├── PUT     /requests/{id}  # Accept/decline friend request
│   ├── DELETE  /friends/{id}   # Remove friend
│   └── POST    /block/{user_id} # Block user

/api/v1/users/
├── GET /search                 # Search users for adding friends
└── GET /{user_id}/profile      # Get user profile (for friend suggestions)
```

### 2. Pydantic Schemas

```python
# File: backend/app/schemas/chat.py

from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime

# Chat Room Schemas
class ChatRoomCreate(BaseModel):
    type: str = 'direct'  # 'direct' or 'group'
    name: Optional[str] = None
    description: Optional[str] = None
    participant_ids: List[UUID]

class ChatRoomResponse(BaseModel):
    id: UUID
    type: str
    name: Optional[str]
    description: Optional[str]
    created_by: Optional[UUID]
    created_at: datetime
    last_message_at: Optional[datetime]
    participants: List[Dict[str, Any]]
    unread_count: int = 0

# Message Schemas
class MessageCreate(BaseModel):
    content: Optional[str] = None
    message_type: str = 'text'
    media_urls: Optional[List[str]] = None
    reply_to_id: Optional[UUID] = None

class MessageResponse(BaseModel):
    id: UUID
    room_id: UUID
    sender_id: UUID
    sender_name: str
    sender_avatar: Optional[str]
    message_type: str
    content: Optional[str]
    media_urls: Optional[List[str]]
    reply_to_id: Optional[UUID]
    created_at: datetime
    edited_at: Optional[datetime]
    is_deleted: bool
    read_by: List[Dict[str, Any]] = []

# Friend Schemas
class FriendRequestCreate(BaseModel):
    requestee_id: UUID
    message: Optional[str] = None

class FriendRequestResponse(BaseModel):
    id: UUID
    requester_id: UUID
    requester_name: str
    requester_avatar: Optional[str]
    requestee_id: UUID
    requestee_name: str
    requestee_avatar: Optional[str]
    status: str
    message: Optional[str]
    created_at: datetime
    responded_at: Optional[datetime]

class FriendResponse(BaseModel):
    id: UUID
    username: str
    display_name: Optional[str]
    avatar_url: Optional[str]
    is_online: bool = False
    last_seen: Optional[datetime]
```

### 3. CRUD Operations

```python
# File: backend/app/crud/chat_crud.py

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete, and_, or_, func
from typing import List, Optional, Dict, Any
from uuid import UUID
import asyncio

from app.models_db import User
# We'll need to add these models to models_db.py

async def create_direct_chat_room(
    db: AsyncSession, 
    user1_id: UUID, 
    user2_id: UUID
) -> Dict[str, Any]:
    """Create or get existing direct chat room between two users"""
    # Implementation for creating direct chat rooms
    pass

async def get_user_chat_rooms(
    db: AsyncSession, 
    user_id: UUID, 
    skip: int = 0, 
    limit: int = 50
) -> List[Dict[str, Any]]:
    """Get all chat rooms for a user"""
    pass

async def send_message(
    db: AsyncSession,
    room_id: UUID,
    sender_id: UUID,
    message_data: Dict[str, Any]
) -> Dict[str, Any]:
    """Send a message to a chat room"""
    pass

async def get_room_messages(
    db: AsyncSession,
    room_id: UUID,
    user_id: UUID,  # For permission checking
    skip: int = 0,
    limit: int = 50
) -> List[Dict[str, Any]]:
    """Get messages for a chat room"""
    pass
```

## Frontend Implementation Plan

### 1. Flutter Models

```dart
// File: lib/models/chat/chat_models.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_models.freezed.dart';
part 'chat_models.g.dart';

@freezed
class ChatRoom with _$ChatRoom {
  const factory ChatRoom({
    required String id,
    required String type, // 'direct' or 'group'
    String? name,
    String? description,
    String? createdBy,
    required DateTime createdAt,
    DateTime? lastMessageAt,
    required List<ChatParticipant> participants,
    @Default(0) int unreadCount,
    ChatMessage? lastMessage,
  }) = _ChatRoom;

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);
}

@freezed
class ChatParticipant with _$ChatParticipant {
  const factory ChatParticipant({
    required String userId,
    required String username,
    String? displayName,
    String? avatarUrl,
    required String role,
    required DateTime joinedAt,
    DateTime? leftAt,
    DateTime? lastReadAt,
    @Default(0) int unreadCount,
    @Default(false) bool isMuted,
    @Default(false) bool isOnline,
  }) = _ChatParticipant;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantFromJson(json);
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String roomId,
    required String senderId,
    required String senderName,
    String? senderAvatar,
    @Default('text') String messageType,
    String? content,
    List<String>? mediaUrls,
    String? replyToId,
    required DateTime createdAt,
    DateTime? editedAt,
    @Default(false) bool isDeleted,
    @Default([]) List<MessageReadReceipt> readBy,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
class MessageReadReceipt with _$MessageReadReceipt {
  const factory MessageReadReceipt({
    required String userId,
    required String username,
    required DateTime readAt,
  }) = _MessageReadReceipt;

  factory MessageReadReceipt.fromJson(Map<String, dynamic> json) =>
      _$MessageReadReceiptFromJson(json);
}

@freezed
class FriendRequest with _$FriendRequest {
  const factory FriendRequest({
    required String id,
    required String requesterId,
    required String requesterName,
    String? requesterAvatar,
    required String requesteeId,
    required String requesteeName,
    String? requesteeAvatar,
    required String status, // 'pending', 'accepted', 'declined', 'blocked'
    String? message,
    required DateTime createdAt,
    DateTime? respondedAt,
  }) = _FriendRequest;

  factory FriendRequest.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestFromJson(json);
}

@freezed
class Friend with _$Friend {
  const factory Friend({
    required String id,
    required String username,
    String? displayName,
    String? avatarUrl,
    @Default(false) bool isOnline,
    DateTime? lastSeen,
    DateTime? friendsSince,
  }) = _Friend;

  factory Friend.fromJson(Map<String, dynamic> json) =>
      _$FriendFromJson(json);
}
```

### 2. Providers and State Management

```dart
// File: lib/providers/chat_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/services/api_service.dart';
import 'package:fitnation/models/chat/chat_models.dart';

class ChatRoomsNotifier extends AsyncNotifier<List<ChatRoom>> {
  @override
  Future<List<ChatRoom>> build() async {
    return await ref.read(apiServiceProvider).getChatRooms();
  }

  Future<ChatRoom> createDirectChat(String userId) async {
    final room = await ref.read(apiServiceProvider).createDirectChat(userId);
    ref.invalidateSelf();
    return room;
  }

  Future<void> archiveRoom(String roomId) async {
    await ref.read(apiServiceProvider).archiveRoom(roomId);
    ref.invalidateSelf();
  }
}

class ChatMessagesNotifier extends FamilyAsyncNotifier<List<ChatMessage>, String> {
  @override
  Future<List<ChatMessage>> build(String roomId) async {
    return await ref.read(apiServiceProvider).getRoomMessages(roomId);
  }

  Future<void> sendMessage(String content, {String? replyToId}) async {
    await ref.read(apiServiceProvider).sendMessage(arg, content, replyToId: replyToId);
    ref.invalidateSelf();
  }

  Future<void> markAsRead(String messageId) async {
    await ref.read(apiServiceProvider).markMessageAsRead(messageId);
    ref.invalidateSelf();
  }
}

final chatRoomsProvider = AsyncNotifierProvider<ChatRoomsNotifier, List<ChatRoom>>(
  () => ChatRoomsNotifier(),
);

final chatMessagesProvider = AsyncNotifierProvider.family<ChatMessagesNotifier, List<ChatMessage>, String>(
  () => ChatMessagesNotifier(),
);
```

### 3. Enhanced UI Components

```dart
// File: lib/screens/Community/enhanced_messages_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/chat_provider.dart';
import 'package:fitnation/widgets/chat/chat_room_tile.dart';
import 'enhanced_chat_screen.dart';

class EnhancedMessagesPage extends ConsumerWidget {
  const EnhancedMessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsAsync = ref.watch(chatRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showNewChatDialog(context, ref),
          ),
        ],
      ),
      body: chatRoomsAsync.when(
        data: (rooms) => ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return ChatRoomTile(
              room: room,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EnhancedChatScreen(room: room),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  void _showNewChatDialog(BuildContext context, WidgetRef ref) {
    // Show dialog to select friend and start chat
  }
}
```

## Real-time Integration Plan

### 1. WebSocket Setup (Backend)

```python
# File: backend/app/api/v1/endpoints/websocket.py

from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends
from typing import Dict, Set
import json
import asyncio

router = APIRouter()

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, Set[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, user_id: str):
        await websocket.accept()
        if user_id not in self.active_connections:
            self.active_connections[user_id] = set()
        self.active_connections[user_id].add(websocket)

    def disconnect(self, websocket: WebSocket, user_id: str):
        if user_id in self.active_connections:
            self.active_connections[user_id].discard(websocket)
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]

    async def send_to_user(self, user_id: str, message: dict):
        if user_id in self.active_connections:
            for connection in self.active_connections[user_id].copy():
                try:
                    await connection.send_text(json.dumps(message))
                except:
                    self.active_connections[user_id].discard(connection)

    async def broadcast_to_room(self, room_participants: List[str], message: dict):
        for user_id in room_participants:
            await self.send_to_user(user_id, message)

manager = ConnectionManager()

@router.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: str):
    await manager.connect(websocket, user_id)
    try:
        while True:
            data = await websocket.receive_text()
            # Handle real-time events (typing indicators, etc.)
    except WebSocketDisconnect:
        manager.disconnect(websocket, user_id)
```

### 2. Flutter WebSocket Integration

```dart
// File: lib/services/websocket_service.dart

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

class WebSocketService extends Notifier<WebSocketChannel?> {
  WebSocketChannel? _channel;

  @override
  WebSocketChannel? build() => null;

  Future<void> connect(String userId) async {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8000/api/v1/chat/ws/$userId'),
      );
      state = _channel;
      
      _channel!.stream.listen(
        (message) => _handleMessage(jsonDecode(message)),
        onError: (error) => _handleError(error),
        onDone: () => _handleDisconnect(),
      );
    } catch (e) {
      print('WebSocket connection error: $e');
    }
  }

  void _handleMessage(Map<String, dynamic> message) {
    // Handle different message types
    switch (message['type']) {
      case 'new_message':
        _handleNewMessage(message['data']);
        break;
      case 'typing_indicator':
        _handleTypingIndicator(message['data']);
        break;
      case 'user_online':
        _handleUserOnline(message['data']);
        break;
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    // Invalidate relevant providers to refresh UI
    ref.invalidate(chatMessagesProvider(data['room_id']));
    ref.invalidate(chatRoomsProvider);
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    state = null;
  }
}

final webSocketServiceProvider = NotifierProvider<WebSocketService, WebSocketChannel?>(
  () => WebSocketService(),
);
```

## Feature Implementation Phases

### Phase 1: Core Chat Functionality (Week 1-2)
- **Backend**:
  - Implement basic chat API endpoints
  - Create database tables and migrations
  - Basic CRUD operations for rooms and messages
- **Frontend**:
  - Create enhanced chat models
  - Implement basic chat providers
  - Update existing UI components

### Phase 2: Friends System (Week 3-4)
- **Backend**:
  - Implement friends API endpoints
  - Friend request system
  - User search functionality
- **Frontend**:
  - Enhanced find friends page
  - Friend request management
  - Friends list with online status

### Phase 3: Real-time Features (Week 5-6)
- **Backend**:
  - WebSocket implementation
  - Typing indicators
  - Online status tracking
- **Frontend**:
  - WebSocket integration
  - Real-time message updates
  - Typing indicators and online status

### Phase 4: Advanced Features (Week 7-8)
- **Backend**:
  - Media sharing with Cloudinary
  - Message reactions and replies
  - Push notifications
- **Frontend**:
  - Media picker and sharing
  - Rich message UI (reactions, replies)
  - Notification handling

## Integration Points

### 1. Existing Community Features
- Link chat functionality with community groups
- Allow creating group chats from communities
- Integrate with existing post and story features

### 2. Profile Integration
- Show chat history in user profiles
- Friend suggestions based on mutual connections
- Activity status integration

### 3. Trainer System
- Extend existing trainer chat to use new infrastructure
- Allow trainers to create group chats with clients
- Training session coordination through chat

## Security Considerations

### 1. Privacy Controls
- Block/unblock users
- Message encryption (future enhancement)
- Privacy settings for friend requests

### 2. Content Moderation
- Report inappropriate messages
- Automated content filtering
- Admin moderation tools

### 3. Rate Limiting
- Prevent message spam
- Limit friend requests per user
- File upload limits

## Testing Strategy

### 1. Unit Tests
- Test all CRUD operations
- Test WebSocket message handling
- Test friend request workflows

### 2. Integration Tests
- Test API endpoints
- Test real-time message delivery
- Test media upload functionality

### 3. UI Tests
- Test chat interface interactions
- Test friend management flows
- Test notification handling

## Deployment Considerations

### 1. Database Migration
- Create migration scripts for new tables
- Ensure backward compatibility
- Plan rollback strategy

### 2. WebSocket Infrastructure
- Configure load balancing for WebSockets
- Set up monitoring for connection health
- Plan scaling strategy

### 3. Media Storage
- Cloudinary configuration for chat media
- File size and type restrictions
- Cleanup policies for old media

This implementation plan provides a comprehensive roadmap for adding robust chat and friends functionality to the Athlytiq platform while maintaining consistency with the existing architecture and user experience.
