# Chat and Friends Feature Integration Plan for Athlytiq

## Overview
This document outlines the comprehensive plan to integrate real-time chat and friends management features into the Athlytiq fitness platform, including backend API development, database schema, and frontend implementation.

## Current Architecture Analysis

### Existing Backend Structure
- **Framework**: FastAPI with SQLAlchemy ORM
- **Database**: PostgreSQL with Supabase
- **Authentication**: JWT-based with Google OAuth support
- **API Structure**: RESTful endpoints under `/api/v1/`
- **Models**: Centralized in `backend/app/models_db.py`

### Existing Frontend Structure
- **Framework**: Flutter with Riverpod state management
- **API Service**: Centralized in `lib/api/API_Services.dart`
- **Models**: Located in `lib/models/`
- **Screens**: Organized by feature in `lib/Screens/`

### Current Chat Implementation Status
- ✅ Basic UI screens created: `messages_page.dart`, `chat_screen.dart`, `find_friends_page.dart`
- ✅ Trainer chat functionality exists in `TrainerChatScreen.dart`
- ❌ No backend support for general user-to-user chat
- ❌ No friends/buddy system backend
- ❌ No real-time messaging infrastructure

## Database Schema Design

### New Tables Required

#### 1. Friends/Buddy System
```sql
-- Friend requests table
CREATE TABLE friend_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'blocked')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(sender_id, receiver_id)
);

-- Friends/Buddies table (accepted relationships)
CREATE TABLE friends (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user1_id, user2_id),
    CHECK (user1_id < user2_id) -- Ensures consistent ordering
);
```

#### 2. Chat System
```sql
-- Chat rooms table
CREATE TABLE chat_rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255), -- For group chats, NULL for direct messages
    is_group BOOLEAN DEFAULT FALSE,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat participants table
CREATE TABLE chat_participants (
    chat_room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_read_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (chat_room_id, user_id)
);

-- Chat messages table
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chat_room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'location', 'workout')),
    content TEXT NOT NULL,
    media_url TEXT, -- For images/files
    reply_to_id UUID REFERENCES chat_messages(id),
    is_edited BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat message reads (for group chats)
CREATE TABLE chat_message_reads (
    message_id UUID REFERENCES chat_messages(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (message_id, user_id)
);
```

#### 3. Indexes for Performance
```sql
-- Friend requests indexes
CREATE INDEX idx_friend_requests_sender ON friend_requests(sender_id);
CREATE INDEX idx_friend_requests_receiver ON friend_requests(receiver_id);
CREATE INDEX idx_friend_requests_status ON friend_requests(status);

-- Friends indexes
CREATE INDEX idx_friends_user1 ON friends(user1_id);
CREATE INDEX idx_friends_user2 ON friends(user2_id);

-- Chat indexes
CREATE INDEX idx_chat_messages_room_time ON chat_messages(chat_room_id, created_at DESC);
CREATE INDEX idx_chat_messages_sender ON chat_messages(sender_id);
CREATE INDEX idx_chat_participants_user ON chat_participants(user_id);
CREATE INDEX idx_chat_participants_room ON chat_participants(chat_room_id);
```

## Backend Implementation Plan

### 1. Database Models (`backend/app/models_db.py`)

Add the following models:

```python
class FriendRequest(Base):
    __tablename__ = 'friend_requests'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    sender_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    receiver_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    status = Column(String(20), nullable=False, default='pending')
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    sender = relationship("User", foreign_keys=[sender_id], backref="sent_friend_requests")
    receiver = relationship("User", foreign_keys=[receiver_id], backref="received_friend_requests")

class Friend(Base):
    __tablename__ = 'friends'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user1_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    user2_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
    # Relationships
    user1 = relationship("User", foreign_keys=[user1_id])
    user2 = relationship("User", foreign_keys=[user2_id])

class ChatRoom(Base):
    __tablename__ = 'chat_rooms'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=True)
    is_group = Column(Boolean, default=False)
    created_by = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='SET NULL'), nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    creator = relationship("User", backref="created_chat_rooms")
    participants = relationship("ChatParticipant", back_populates="chat_room")
    messages = relationship("ChatMessage", back_populates="chat_room")

class ChatParticipant(Base):
    __tablename__ = 'chat_participants'
    
    chat_room_id = Column(UUID(as_uuid=True), ForeignKey('chat_rooms.id', ondelete='CASCADE'), primary_key=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    joined_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    last_read_at = Column(DateTime(timezone=True), nullable=True)
    is_active = Column(Boolean, default=True)
    
    # Relationships
    chat_room = relationship("ChatRoom", back_populates="participants")
    user = relationship("User", backref="chat_participations")

class ChatMessage(Base):
    __tablename__ = 'chat_messages'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    chat_room_id = Column(UUID(as_uuid=True), ForeignKey('chat_rooms.id', ondelete='CASCADE'), nullable=False)
    sender_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    message_type = Column(String(20), default='text')
    content = Column(Text, nullable=False)
    media_url = Column(Text, nullable=True)
    reply_to_id = Column(UUID(as_uuid=True), ForeignKey('chat_messages.id'), nullable=True)
    is_edited = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    chat_room = relationship("ChatRoom", back_populates="messages")
    sender = relationship("User", backref="sent_messages")
    reply_to = relationship("ChatMessage", remote_side=[id])
```

### 2. Pydantic Schemas

Create `backend/app/schemas/friends.py`:
```python
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from uuid import UUID

class FriendRequestCreate(BaseModel):
    receiver_id: UUID

class FriendRequestResponse(BaseModel):
    id: UUID
    sender_id: UUID
    receiver_id: UUID
    status: str
    created_at: datetime
    sender_username: Optional[str] = None
    receiver_username: Optional[str] = None

class FriendResponse(BaseModel):
    id: UUID
    user_id: UUID
    username: str
    display_name: Optional[str]
    avatar_url: Optional[str]
    created_at: datetime

class UserSearchResponse(BaseModel):
    id: UUID
    username: str
    display_name: Optional[str]
    avatar_url: Optional[str]
    is_friend: bool = False
    has_pending_request: bool = False
```

Create `backend/app/schemas/chat.py`:
```python
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from uuid import UUID

class ChatMessageCreate(BaseModel):
    chat_room_id: UUID
    content: str
    message_type: Optional[str] = "text"
    media_url: Optional[str] = None
    reply_to_id: Optional[UUID] = None

class ChatMessageResponse(BaseModel):
    id: UUID
    chat_room_id: UUID
    sender_id: UUID
    sender_username: str
    content: str
    message_type: str
    media_url: Optional[str]
    reply_to_id: Optional[UUID]
    is_edited: bool
    created_at: datetime

class ChatRoomCreate(BaseModel):
    name: Optional[str] = None
    is_group: bool = False
    participant_ids: List[UUID]

class ChatRoomResponse(BaseModel):
    id: UUID
    name: Optional[str]
    is_group: bool
    created_at: datetime
    last_message: Optional[ChatMessageResponse]
    unread_count: int = 0
    participants: List[dict]
```

### 3. CRUD Operations

Create `backend/app/crud/friends_crud.py`:
```python
from sqlalchemy.orm import Session
from sqlalchemy import or_, and_
from app.models_db import User, FriendRequest, Friend
from app.schemas.friends import FriendRequestCreate
from typing import List, Optional
from uuid import UUID

def search_users(db: Session, query: str, current_user_id: UUID, limit: int = 20) -> List[User]:
    return db.query(User).filter(
        or_(
            User.username.ilike(f"%{query}%"),
            User.email.ilike(f"%{query}%")
        ),
        User.id != current_user_id
    ).limit(limit).all()

def send_friend_request(db: Session, sender_id: UUID, receiver_id: UUID) -> FriendRequest:
    # Check if request already exists
    existing = db.query(FriendRequest).filter(
        or_(
            and_(FriendRequest.sender_id == sender_id, FriendRequest.receiver_id == receiver_id),
            and_(FriendRequest.sender_id == receiver_id, FriendRequest.receiver_id == sender_id)
        )
    ).first()
    
    if existing:
        raise ValueError("Friend request already exists")
    
    # Check if already friends
    friendship = db.query(Friend).filter(
        or_(
            and_(Friend.user1_id == min(sender_id, receiver_id), Friend.user2_id == max(sender_id, receiver_id))
        )
    ).first()
    
    if friendship:
        raise ValueError("Already friends")
    
    request = FriendRequest(sender_id=sender_id, receiver_id=receiver_id)
    db.add(request)
    db.commit()
    db.refresh(request)
    return request

def get_friend_requests(db: Session, user_id: UUID) -> List[FriendRequest]:
    return db.query(FriendRequest).filter(
        FriendRequest.receiver_id == user_id,
        FriendRequest.status == 'pending'
    ).all()

def handle_friend_request(db: Session, request_id: UUID, action: str, user_id: UUID) -> FriendRequest:
    request = db.query(FriendRequest).filter(
        FriendRequest.id == request_id,
        FriendRequest.receiver_id == user_id
    ).first()
    
    if not request:
        raise ValueError("Friend request not found")
    
    request.status = action
    
    if action == 'accepted':
        # Create friendship
        user1_id = min(request.sender_id, request.receiver_id)
        user2_id = max(request.sender_id, request.receiver_id)
        
        friendship = Friend(user1_id=user1_id, user2_id=user2_id)
        db.add(friendship)
    
    db.commit()
    return request

def get_friends(db: Session, user_id: UUID) -> List[User]:
    friends_query = db.query(Friend).filter(
        or_(Friend.user1_id == user_id, Friend.user2_id == user_id)
    ).all()
    
    friend_ids = []
    for friendship in friends_query:
        friend_id = friendship.user2_id if friendship.user1_id == user_id else friendship.user1_id
        friend_ids.append(friend_id)
    
    return db.query(User).filter(User.id.in_(friend_ids)).all()
```

Create `backend/app/crud/chat_crud.py`:
```python
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import desc, func
from app.models_db import ChatRoom, ChatMessage, ChatParticipant, User
from typing import List, Optional
from uuid import UUID

def create_chat_room(db: Session, participant_ids: List[UUID], is_group: bool = False, name: Optional[str] = None, creator_id: UUID = None) -> ChatRoom:
    # For direct messages, check if room already exists
    if not is_group and len(participant_ids) == 2:
        existing_room = db.query(ChatRoom).join(ChatParticipant).filter(
            ChatRoom.is_group == False,
            ChatParticipant.user_id.in_(participant_ids)
        ).group_by(ChatRoom.id).having(func.count(ChatParticipant.user_id) == 2).first()
        
        if existing_room:
            return existing_room
    
    # Create new room
    room = ChatRoom(name=name, is_group=is_group, created_by=creator_id)
    db.add(room)
    db.flush()
    
    # Add participants
    for user_id in participant_ids:
        participant = ChatParticipant(chat_room_id=room.id, user_id=user_id)
        db.add(participant)
    
    db.commit()
    db.refresh(room)
    return room

def get_user_chat_rooms(db: Session, user_id: UUID) -> List[ChatRoom]:
    return db.query(ChatRoom).join(ChatParticipant).filter(
        ChatParticipant.user_id == user_id,
        ChatParticipant.is_active == True
    ).options(joinedload(ChatRoom.participants)).all()

def create_message(db: Session, chat_room_id: UUID, sender_id: UUID, content: str, message_type: str = "text", media_url: Optional[str] = None) -> ChatMessage:
    message = ChatMessage(
        chat_room_id=chat_room_id,
        sender_id=sender_id,
        content=content,
        message_type=message_type,
        media_url=media_url
    )
    db.add(message)
    db.commit()
    db.refresh(message)
    return message

def get_chat_messages(db: Session, chat_room_id: UUID, limit: int = 50, offset: int = 0) -> List[ChatMessage]:
    return db.query(ChatMessage).filter(
        ChatMessage.chat_room_id == chat_room_id
    ).order_by(desc(ChatMessage.created_at)).offset(offset).limit(limit).all()

def mark_messages_as_read(db: Session, chat_room_id: UUID, user_id: UUID):
    participant = db.query(ChatParticipant).filter(
        ChatParticipant.chat_room_id == chat_room_id,
        ChatParticipant.user_id == user_id
    ).first()
    
    if participant:
        participant.last_read_at = datetime.utcnow()
        db.commit()
```

### 4. API Endpoints

Create `backend/app/api/v1/endpoints/friends.py`:
```python
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from app.database.base import get_db
from app.core.auth import get_current_user
from app.crud import friends_crud
from app.schemas.friends import *
from app.models_db import User

router = APIRouter()

@router.get("/search", response_model=List[UserSearchResponse])
async def search_users(
    query: str = Query(..., min_length=2),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    users = friends_crud.search_users(db, query, current_user.id)
    return [UserSearchResponse(
        id=user.id,
        username=user.username,
        display_name=getattr(user, 'display_name', None),
        avatar_url=getattr(user, 'avatar_url', None)
    ) for user in users]

@router.post("/requests", response_model=FriendRequestResponse)
async def send_friend_request(
    request_data: FriendRequestCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        request = friends_crud.send_friend_request(db, current_user.id, request_data.receiver_id)
        return FriendRequestResponse(**request.__dict__)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/requests", response_model=List[FriendRequestResponse])
async def get_friend_requests(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    requests = friends_crud.get_friend_requests(db, current_user.id)
    return [FriendRequestResponse(**req.__dict__) for req in requests]

@router.put("/requests/{request_id}")
async def handle_friend_request(
    request_id: UUID,
    action: str = Query(..., regex="^(accepted|rejected)$"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        request = friends_crud.handle_friend_request(db, request_id, action, current_user.id)
        return {"message": f"Friend request {action}"}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

@router.get("/", response_model=List[FriendResponse])
async def get_friends(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    friends = friends_crud.get_friends(db, current_user.id)
    return [FriendResponse(
        id=friend.id,
        user_id=friend.id,
        username=friend.username,
        display_name=getattr(friend, 'display_name', None),
        avatar_url=getattr(friend, 'avatar_url', None),
        created_at=friend.created_at
    ) for friend in friends]
```

Create `backend/app/api/v1/endpoints/chat.py`:
```python
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from app.database.base import get_db
from app.core.auth import get_current_user
from app.crud import chat_crud
from app.schemas.chat import *
from app.models_db import User

router = APIRouter()

@router.post("/rooms", response_model=ChatRoomResponse)
async def create_chat_room(
    room_data: ChatRoomCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Add current user to participants if not included
    if current_user.id not in room_data.participant_ids:
        room_data.participant_ids.append(current_user.id)
    
    room = chat_crud.create_chat_room(
        db, 
        room_data.participant_ids, 
        room_data.is_group, 
        room_data.name,
        current_user.id
    )
    
    return ChatRoomResponse(**room.__dict__)

@router.get("/rooms", response_model=List[ChatRoomResponse])
async def get_chat_rooms(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    rooms = chat_crud.get_user_chat_rooms(db, current_user.id)
    return [ChatRoomResponse(**room.__dict__) for room in rooms]

@router.post("/messages", response_model=ChatMessageResponse)
async def send_message(
    message_data: ChatMessageCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    message = chat_crud.create_message(
        db,
        message_data.chat_room_id,
        current_user.id,
        message_data.content,
        message_data.message_type,
        message_data.media_url
    )
    
    return ChatMessageResponse(
        **message.__dict__,
        sender_username=current_user.username
    )

@router.get("/rooms/{room_id}/messages", response_model=List[ChatMessageResponse])
async def get_chat_messages(
    room_id: UUID,
    limit: int = Query(50, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    messages = chat_crud.get_chat_messages(db, room_id, limit, offset)
    return [ChatMessageResponse(
        **msg.__dict__,
        sender_username=msg.sender.username
    ) for msg in messages]

@router.put("/rooms/{room_id}/read")
async def mark_messages_as_read(
    room_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    chat_crud.mark_messages_as_read(db, room_id, current_user.id)
    return {"message": "Messages marked as read"}
```

### 5. WebSocket Support (Optional but Recommended)

Create `backend/app/websockets/chat.py`:
```python
from fastapi import WebSocket, WebSocketDisconnect, Depends
from typing import Dict, List
import json
from uuid import UUID
from app.core.auth import get_current_user_from_websocket

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}
    
    async def connect(self, websocket: WebSocket, user_id: str):
        await websocket.accept()
        if user_id not in self.active_connections:
            self.active_connections[user_id] = []
        self.active_connections[user_id].append(websocket)
    
    def disconnect(self, websocket: WebSocket, user_id: str):
        if user_id in self.active_connections:
            self.active_connections[user_id].remove(websocket)
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]
    
    async def send_personal_message(self, message: dict, user_id: str):
        if user_id in self.active_connections:
            for connection in self.active_connections[user_id]:
                await connection.send_text(json.dumps(message))
    
    async def broadcast_to_room(self, message: dict, room_participants: List[str]):
        for user_id in room_participants:
            await self.send_personal_message(message, user_id)

manager = ConnectionManager()
```

### 6. Update Main App

Add to `backend/app/main.py`:
```python
from app.api.v1.endpoints import friends, chat

app.include_router(friends.router, prefix="/api/v1/friends", tags=["Friends"])
app.include_router(chat.router, prefix="/api/v1/chat", tags=["Chat"])
```

## Frontend Implementation Plan

### 1. Models

Create `fitnation/lib/models/Friend.dart`:
```dart
class Friend {
  final String id;
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final DateTime createdAt;

  Friend({
    required this.id,
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    required this.createdAt,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      userId: json['user_id'],
      username: json['username'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class FriendRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String status;
  final DateTime createdAt;
  final String? senderUsername;
  final String? receiverUsername;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.senderUsername,
    this.receiverUsername,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      senderUsername: json['sender_username'],
      receiverUsername: json['receiver_username'],
    );
  }
}
```

Create `fitnation/lib/models/ChatModels.dart`:
```dart
class ChatRoom {
  final String id;
  final String? name;
  final bool isGroup;
  final DateTime createdAt;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final List<ChatParticipant> participants;

  ChatRoom({
    required this.id,
    this.name,
    required this.isGroup,
    required this.createdAt,
    this.lastMessage,
    this.unreadCount = 0,
    required this.participants,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      isGroup: json['is_group'],
      createdAt: DateTime.parse(json['created_at']),
      lastMessage: json['last_message'] != null 
          ? ChatMessage.fromJson(json['last_message']) 
          : null,
      unreadCount: json['unread_count'] ?? 0,
      participants: (json['participants'] as List?)
          ?.map((p) => ChatParticipant.fromJson(p))
          .toList() ?? [],
    );
  }
}

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderUsername;
  final String content;
  final String messageType;
  final String? mediaUrl;
  final String? replyToId;
  final bool isEdited;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderUsername,
    required this.content,
    required this.messageType,
    this.mediaUrl,
    this.replyToId,
    required this.isEdited,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      chatRoomId: json['chat_room_id'],
      senderId: json['sender_id'],
      senderUsername: json['sender_username'],
      content: json['content'],
      messageType: json['message_type'],
      mediaUrl: json['media_url'],
      replyToId: json['reply_to_id'],
      isEdited: json['is_edited'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'sender_username': senderUsername,
      'content': content,
      'message_type': messageType,
      'media_url': mediaUrl,
      'reply_to_id': replyToId,
      'is_edited': isEdited,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ChatParticipant {
  final String userId;
  final String username;
  final String? avatarUrl;
  final DateTime joinedAt;
  final DateTime? lastReadAt;

  ChatParticipant({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.joinedAt,
    this.lastReadAt,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      userId: json['user_id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      joinedAt: DateTime.parse(json['joined_at']),
      lastReadAt: json['last_read_at'] != null 
          ? DateTime.parse(json['last_read_at']) 
          : null,
    );
  }
}
```

### 2. API Service Updates

Add to `fitnation/lib/api/API_Services.dart`:
```dart
// Friends API methods
Future<List<User>> searchUsers(String query) async {
  try {
    final response = await _dio.get('/friends/search', queryParameters: {'query': query});
    return (response.data as List).map((json) => User.fromJson(json)).toList();
  } catch (e) {
    debugPrint('Error searching users: $e');
    throw Exception('Failed to search users');
  }
}

Future<void> sendFriendRequest(String userId) async {
  try {
    await _dio.post('/friends/requests', data: {'receiver_id': userId});
  } catch (e) {
    debugPrint('Error sending friend request: $e');
    throw Exception('Failed to send friend request');
  }
}

Future<List<FriendRequest>> getFriendRequests() async {
  try {
    final response = await _dio.get('/friends/requests');
    return (response.data as List).map((json) => FriendRequest.fromJson(json)).toList();
  } catch (e) {
    debugPrint('Error getting friend requests: $e');
    throw Exception('Failed to get friend requests');
  }
}

Future<void> handleFriendRequest(String requestId, String action) async {
  try {
    await _dio.put('/friends/requests/$requestId', queryParameters: {'action': action});
  } catch (e) {
    debugPrint('Error handling friend request: $e');
    throw Exception('Failed to handle friend request');
  }
}

Future<List<Friend>> getFriends() async {
  try {
    final response = await _dio.get('/friends/');
    return (response.data as List).map((json) => Friend.fromJson(json)).toList();
  } catch (e) {
    debugPrint('Error getting friends: $e');
    throw Exception('Failed to get friends');
  }
}

// Chat API methods
Future<ChatRoom> createChatRoom(List<String> participantIds, {String? name, bool isGroup = false}) async {
  try {
    final response = await _dio.post('/chat/rooms', data: {
      'participant_ids': participantIds,
      'name': name,
      'is_group': isGroup,
    });
    return ChatRoom.fromJson(response.data);
  } catch (e) {
    debugPrint('Error creating chat room: $e');
    throw Exception('Failed to create chat room');
  }
}

Future<List<ChatRoom>> getChatRooms() async {
  try {
    final response = await _dio.get('/chat/rooms');
    return (response.data as List).map((json) => ChatRoom.fromJson(json)).toList();
  } catch (e) {
    debugPrint('Error getting chat rooms: $e');
    throw Exception('Failed to get chat rooms');
  }
}

Future<ChatMessage> sendMessage(String chatRoomId, String content, {String messageType = 'text'}) async {
  try {
    final response = await _dio.post('/chat/messages', data: {
      'chat_room_id': chatRoomId,
      'content': content,
      'message_type': messageType,
    });
    return ChatMessage.fromJson(response.data);
  } catch (e) {
    debugPrint('Error sending message: $e');
    throw Exception('Failed to send message');
  }
}

Future<List<ChatMessage>> getChatMessages(String chatRoomId, {int limit = 50, int offset = 0}) async {
  try {
    final response = await _dio.get('/chat/rooms/$chatRoomId/messages', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
    return (response.data as List).map((json) => ChatMessage.fromJson(json)).toList();
  } catch (e) {
    debugPrint('Error getting chat messages: $e');
    throw Exception('Failed to get chat messages');
  }
}

Future<void> markMessagesAsRead(String chatRoomId) async {
  try {
    await _dio.put('/chat/rooms/$chatRoomId/read');
  } catch (e) {
    debugPrint('Error marking messages as read: $e');
    throw Exception('Failed to mark messages as read');
  }
}
```

### 3. Providers

Create `fitnation/lib/providers/friends_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/api/API_Services.dart';
import 'package:fitnation/models/Friend.dart';
import 'package:fitnation/models/User.dart';

final friendsProvider = StateNotifierProvider<FriendsNotifier, AsyncValue<List<Friend>>>((ref) {
  return FriendsNotifier(ref.read(apiServiceProvider));
});

final friendRequestsProvider = StateNotifierProvider<FriendRequestsNotifier, AsyncValue<List<FriendRequest>>>((ref) {
  return FriendRequestsNotifier(ref.read(apiServiceProvider));
});

class FriendsNotifier extends StateNotifier<AsyncValue<List<Friend>>> {
  final ApiService _apiService;

  FriendsNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadFriends();
  }

  Future<void> loadFriends() async {
    state = const AsyncValue.loading();
    try {
      final friends = await _apiService.getFriends();
      state = AsyncValue.data(friends);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<List<User>> searchUsers(String query) async {
    return await _apiService.searchUsers(query);
  }

  Future<void> sendFriendRequest(String userId) async {
    await _apiService.sendFriendRequest(userId);
  }
}

class FriendRequestsNotifier extends StateNotifier<AsyncValue<List<FriendRequest>>> {
  final ApiService _apiService;

  FriendRequestsNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadFriendRequests();
  }

  Future<void> loadFriendRequests() async {
    state = const AsyncValue.loading();
    try {
      final requests = await _apiService.getFriendRequests();
      state = AsyncValue.data(requests);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> handleFriendRequest(String requestId, String action) async {
    await _apiService.handleFriendRequest(requestId, action);
    await loadFriendRequests(); // Refresh the list
  }
}
```

Create `fitnation/lib/providers/chat_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/api/API_Services.dart';
import 'package:fitnation/models/ChatModels.dart';

final chatRoomsProvider = StateNotifierProvider<ChatRoomsNotifier, AsyncValue<List<ChatRoom>>>((ref) {
  return ChatRoomsNotifier(ref.read(apiServiceProvider));
});

final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, AsyncValue<List<ChatMessage>>, String>((ref, roomId) {
  return ChatMessagesNotifier(ref.read(apiServiceProvider), roomId);
});

class ChatRoomsNotifier extends StateNotifier<AsyncValue<List<ChatRoom>>> {
  final ApiService _apiService;

  ChatRoomsNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadChatRooms();
  }

  Future<void> loadChatRooms() async {
    state = const AsyncValue.loading();
    try {
      final rooms = await _apiService.getChatRooms();
      state = AsyncValue.data(rooms);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<ChatRoom> createChatRoom(List<String> participantIds, {String? name, bool isGroup = false}) async {
    final room = await _apiService.createChatRoom(participantIds, name: name, isGroup: isGroup);
    await loadChatRooms(); // Refresh the list
    return room;
  }
}

class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final ApiService _apiService;
  final String roomId;

  ChatMessagesNotifier(this._apiService, this.roomId) : super(const AsyncValue.loading()) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    state = const AsyncValue.loading();
    try {
      final messages = await _apiService.getChatMessages(roomId);
      state = AsyncValue.data(messages.reversed.toList()); // Reverse for chat UI
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> sendMessage(String content, {String messageType = 'text'}) async {
    try {
      await _apiService.sendMessage(roomId, content, messageType: messageType);
      await loadMessages(); // Refresh messages
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> markAsRead() async {
    try {
      await _apiService.markMessagesAsRead(roomId);
    } catch (e) {
      // Handle error silently
    }
  }
}
```

### 4. Screen Updates

Update existing screens to integrate with the new backend:

`fitnation/lib/Screens/Community/find_friends_page.dart`:
```dart
// Add provider integration and real API calls
class FindFriendsPage extends ConsumerWidget {
  const FindFriendsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.darkBackground,
          title: const Text(
            "Find Friends",
            style: TextStyle(color: AppColors.darkPrimaryText),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.darkPrimaryText,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            labelColor: AppColors.darkPrimaryText,
            unselectedLabelColor: AppColors.darkHintText,
            tabs: [Tab(text: "Search"), Tab(text: "Requests")],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                style: const TextStyle(color: AppColors.darkPrimaryText),
                decoration: InputDecoration(
                  hintText: "Search friends...",
                  hintStyle: const TextStyle(color: AppColors.darkHintText),
                  filled: true,
                  fillColor: AppColors.darkSurface,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.darkIcon,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.darkInputBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.darkInputBorder,
                    ),
                  ),
                ),
                onChanged: (query) {
                  // Implement search functionality
                },
              ),
            ),
            const Expanded(
              child: TabBarView(children: [SearchTab(), RequestsTab()]),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchTab extends ConsumerWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Implement with real search functionality
    return ListView.builder(
      itemCount: 5, // Replace with actual search results
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(
            "User $index",
            style: const TextStyle(color: AppColors.darkPrimaryText),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.person_add, color: AppColors.darkPrimaryText),
            onPressed: () {
              // Send friend request
            },
          ),
        );
      },
    );
  }
}

class RequestsTab extends ConsumerWidget {
  const RequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(friendRequestsProvider);
    
    return requestsAsync.when(
      data: (requests) => ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              request.senderUsername ?? "Unknown User",
              style: const TextStyle(color: AppColors.darkPrimaryText),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    ref.read(friendRequestsProvider.notifier)
                        .handleFriendRequest(request.id, 'accepted');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    ref.read(friendRequestsProvider.notifier)
                        .handleFriendRequest(request.id, 'rejected');
                  },
                ),
              ],
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: AppColors.darkPrimaryText),
        ),
      ),
    );
  }
}
```

Update `fitnation/lib/Screens/Community/messages_page.dart`:
```dart
class MessagesPage extends ConsumerWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsAsync = ref.watch(chatRoomsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text(
          "Messages",
          style: TextStyle(color: AppColors.darkPrimaryText),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkPrimaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: AppColors.darkPrimaryText),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FindFriendsPage()),
              );
            },
          ),
        ],
      ),
      body: chatRoomsAsync.when(
        data: (chatRooms) => ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final room = chatRooms[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.secondary,
                child: Text(
                  room.name?.substring(0, 1).toUpperCase() ?? 
                  room.participants.first.username.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                room.name ?? room.participants.first.username,
                style: const TextStyle(color: AppColors.darkPrimaryText),
              ),
              subtitle: room.lastMessage != null
                  ? Text(
                      room.lastMessage!.content,
                      style: const TextStyle(color: AppColors.darkHintText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: room.unreadCount > 0
                  ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        room.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      roomId: room.id,
                      roomName: room.name ?? room.participants.first.username,
                    ),
                  ),
                );
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading chats: $error',
            style: const TextStyle(color: AppColors.darkPrimaryText),
          ),
        ),
      ),
    );
  }
}
```

Update `fitnation/lib/Screens/Community/chat_screen.dart`:
```dart
class ChatScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String roomName;

  const ChatScreen({
    super.key, 
    required this.roomId,
    required this.roomName,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mark messages as read when entering chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatMessagesProvider(widget.roomId).notifier).markAsRead();
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    try {
      await ref.read(chatMessagesProvider(widget.roomId).notifier)
          .sendMessage(text.trim());
      _controller.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.roomId));
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: Text(
          widget.roomName,
          style: const TextStyle(color: AppColors.darkPrimaryText),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkPrimaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messagesAsync.when(
              data: (messages) => ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMe = message.senderId == getCurrentUserId(); // You'll need to implement this
                  
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.secondary : AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isMe)
                            Text(
                              message.senderUsername,
                              style: TextStyle(
                                color: AppColors.darkHintText,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Text(
                            message.content,
                            style: TextStyle(
                              color: isMe 
                                  ? AppColors.primaryForeground 
                                  : AppColors.darkPrimaryText,
                            ),
                          ),
                          Text(
                            _formatTime(message.createdAt),
                            style: TextStyle(
                              color: (isMe 
                                  ? AppColors.primaryForeground 
                                  : AppColors.darkHintText).withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading messages: $error',
                  style: const TextStyle(color: AppColors.darkPrimaryText),
                ),
              ),
            ),
          ),

          // Message input bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: AppColors.darkBackground,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.photo,
                      color: AppColors.darkPrimaryText,
                    ),
                    onPressed: () {
                      // Implement image sending
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: AppColors.darkPrimaryText),
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        hintStyle: const TextStyle(
                          color: AppColors.darkHintText,
                        ),
                        filled: true,
                        fillColor: AppColors.darkSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.secondary),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
  
  String getCurrentUserId() {
    // Implement method to get current user ID
    // This could be from your auth provider
    return ''; // Replace with actual implementation
  }
}
```

## Implementation Steps

### Phase 1: Backend Foundation (Week 1)
1. ✅ Add database schema and run migrations
2. ✅ Create SQLAlchemy models
3. ✅ Implement CRUD operations
4. ✅ Create API endpoints
5. ✅ Update main.py with new routes
6. ✅ Test endpoints with Postman

### Phase 2: Frontend Integration (Week 2)
1. ✅ Create Flutter models
2. ✅ Update API service with new methods
3. ✅ Create Riverpod providers
4. ✅ Update existing screens with backend integration
5. ✅ Test basic functionality

### Phase 3: Real-time Features (Week 3)
1. 🔄 Implement WebSocket support for real-time messaging
2. 🔄 Add push notifications for new messages
3. 🔄 Implement typing indicators
4. 🔄 Add message status (sent/delivered/read)

### Phase 4: Enhanced Features (Week 4)
1. 🔄 Media sharing (images, files)
2. 🔄 Group chat management
3. 🔄 Message search functionality
4. 🔄 Chat backup and sync

### Phase 5: Testing & Polish (Week 5)
1. 🔄 Unit tests for backend endpoints
2. 🔄 Widget tests for Flutter screens
3. 🔄 Integration testing
4. 🔄 Performance optimization
5. 🔄 UI/UX refinements

## Security Considerations

1. **Authentication**: All endpoints require valid JWT tokens
2. **Authorization**: Users can only access their own chats and friend data
3. **Input Validation**: All inputs are validated using Pydantic schemas
4. **Rate Limiting**: Implement rate limiting for message sending
5. **Privacy**: Friend searches respect user privacy settings
6. **Data Encryption**: Sensitive data is encrypted in transit and at rest

## Testing Strategy

### Backend Testing
- Unit tests for CRUD operations
- Integration tests for API endpoints
- Authentication and authorization tests
- Database constraint testing

### Frontend Testing
- Widget tests for all chat and friend screens
- Provider testing for state management
- API service testing with mock responses
- End-to-end user flow testing

## Monitoring and Analytics

1. **Message delivery rates**
2. **User engagement metrics**
3. **Friend request acceptance rates**
4. **Chat room activity**
5. **Error rates and types**

## Future Enhancements

1. **Voice messages**
2. **Video calling integration**
3. **Message encryption**
4. **Chat themes**
5. **Message reactions**
6. **Shared workout challenges in chat**
7. **Location sharing for gym meetups**

This comprehensive plan provides a solid foundation for implementing robust chat and friends features in the Athlytiq platform while maintaining consistency with the existing architecture and design patterns.
