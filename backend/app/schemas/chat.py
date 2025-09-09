from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict, Any, Union
from uuid import UUID
from datetime import datetime
from enum import Enum

# Enums
class ChatRoomType(str, Enum):
    DIRECT = "direct"
    GROUP = "group"

class MessageType(str, Enum):
    TEXT = "text"
    IMAGE = "image"
    FILE = "file"
    LOCATION = "location"
    SYSTEM = "system"

class ParticipantRole(str, Enum):
    ADMIN = "admin"
    MEMBER = "member"

class FriendRequestStatus(str, Enum):
    PENDING = "pending"
    ACCEPTED = "accepted"
    DECLINED = "declined"
    BLOCKED = "blocked"

class ReactionType(str, Enum):
    LIKE = "like"
    LOVE = "love"
    LAUGH = "laugh"
    ANGRY = "angry"
    SAD = "sad"
    WOW = "wow"

# Base schemas
class TimestampMixin(BaseModel):
    created_at: datetime
    updated_at: Optional[datetime] = None

# Chat Room Schemas
class ChatRoomBase(BaseModel):
    type: ChatRoomType = ChatRoomType.DIRECT
    name: Optional[str] = None
    description: Optional[str] = None
    image_url: Optional[str] = None

class ChatRoomCreate(ChatRoomBase):
    participant_ids: List[UUID] = Field(..., min_items=1)
    
    @validator('name')
    def name_required_for_group(cls, v, values):
        if values.get('type') == ChatRoomType.GROUP and not v:
            raise ValueError('Group chats must have a name')
        return v

class ChatRoomUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    image_url: Optional[str] = None

class ChatParticipantResponse(BaseModel):
    user_id: UUID
    username: str
    display_name: Optional[str] = None
    avatar_url: Optional[str] = None
    role: ParticipantRole
    joined_at: datetime
    left_at: Optional[datetime] = None
    last_read_at: Optional[datetime] = None
    unread_count: int = 0
    is_muted: bool = False
    is_pinned: bool = False
    is_online: bool = False
    last_seen: Optional[datetime] = None

    class Config:
        from_attributes = True

class ChatRoomResponse(ChatRoomBase, TimestampMixin):
    id: UUID
    created_by: Optional[UUID] = None
    last_message_at: Optional[datetime] = None
    last_message_content: Optional[str] = None
    last_message_sender_id: Optional[UUID] = None
    participants: List[ChatParticipantResponse] = []
    unread_count: int = 0
    is_archived: bool = False
    total_messages: int = 0

    class Config:
        from_attributes = True

# Message Schemas
class MessageCreate(BaseModel):
    content: Optional[str] = None
    message_type: MessageType = MessageType.TEXT
    media_urls: Optional[List[str]] = None
    metadata: Optional[Dict[str, Any]] = None
    reply_to_id: Optional[UUID] = None
    forwarded_from_id: Optional[UUID] = None

    @validator('content')
    def content_required_for_text(cls, v, values):
        if values.get('message_type') == MessageType.TEXT and not v:
            raise ValueError('Text messages must have content')
        return v

    @validator('media_urls')
    def media_required_for_media_types(cls, v, values):
        media_types = [MessageType.IMAGE, MessageType.FILE]
        if values.get('message_type') in media_types and not v:
            raise ValueError(f'Media messages must have media_urls')
        return v

class MessageUpdate(BaseModel):
    content: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None

class MessageReactionResponse(BaseModel):
    id: UUID
    user_id: UUID
    username: str
    display_name: Optional[str] = None
    reaction_type: ReactionType
    emoji: str
    created_at: datetime

    class Config:
        from_attributes = True

class MessageReadReceiptResponse(BaseModel):
    user_id: UUID
    username: str
    display_name: Optional[str] = None
    read_at: datetime

    class Config:
        from_attributes = True

class MessageResponse(BaseModel):
    id: UUID
    room_id: UUID
    sender_id: UUID
    sender_name: str
    sender_display_name: Optional[str] = None
    sender_avatar: Optional[str] = None
    message_type: MessageType
    content: Optional[str] = None
    media_urls: Optional[List[str]] = None
    metadata: Optional[Dict[str, Any]] = None
    reply_to_id: Optional[UUID] = None
    reply_to_message: Optional['MessageResponse'] = None
    forwarded_from_id: Optional[UUID] = None
    reactions: List[MessageReactionResponse] = []
    read_receipts: List[MessageReadReceiptResponse] = []
    created_at: datetime
    edited_at: Optional[datetime] = None
    is_deleted: bool = False
    deleted_at: Optional[datetime] = None
    is_read_by_current_user: bool = False

    class Config:
        from_attributes = True

# Forward reference fix
MessageResponse.model_rebuild()

# Reaction Schemas
class MessageReactionCreate(BaseModel):
    reaction_type: ReactionType
    emoji: str

class MessageReactionRemove(BaseModel):
    reaction_type: ReactionType

# Read Receipt Schemas
class MessageReadReceiptCreate(BaseModel):
    message_ids: List[UUID] = Field(..., min_items=1)

# Friend Request Schemas
class FriendRequestCreate(BaseModel):
    requestee_id: UUID
    message: Optional[str] = Field(None, max_length=500)

class FriendRequestUpdate(BaseModel):
    status: FriendRequestStatus
    
    @validator('status')
    def valid_response_status(cls, v):
        if v not in [FriendRequestStatus.ACCEPTED, FriendRequestStatus.DECLINED]:
            raise ValueError('Can only accept or decline friend requests')
        return v

class FriendRequestResponse(BaseModel):
    id: UUID
    requester_id: UUID
    requester_username: str
    requester_display_name: Optional[str] = None
    requester_avatar: Optional[str] = None
    requestee_id: UUID
    requestee_username: str
    requestee_display_name: Optional[str] = None
    requestee_avatar: Optional[str] = None
    status: FriendRequestStatus
    message: Optional[str] = None
    created_at: datetime
    responded_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# Friend Schemas
class FriendResponse(BaseModel):
    id: UUID
    username: str
    display_name: Optional[str] = None
    avatar_url: Optional[str] = None
    is_online: bool = False
    last_seen: Optional[datetime] = None
    friends_since: datetime
    mutual_friends_count: int = 0
    can_message: bool = True

    class Config:
        from_attributes = True

# User Search Schemas
class UserSearchResult(BaseModel):
    id: UUID
    username: str
    display_name: Optional[str] = None
    avatar_url: Optional[str] = None
    is_online: bool = False
    mutual_friends_count: int = 0
    friendship_status: Optional[str] = None  # 'friends', 'pending_sent', 'pending_received', 'blocked', None
    can_send_request: bool = True

    class Config:
        from_attributes = True

class UserSearchResponse(BaseModel):
    users: List[UserSearchResult]
    total_count: int
    page: int
    per_page: int
    has_next: bool

# Online Status Schemas
class UserOnlineStatusUpdate(BaseModel):
    is_online: bool

class UserOnlineStatusResponse(BaseModel):
    user_id: UUID
    is_online: bool
    last_seen: Optional[datetime] = None
    last_activity: Optional[datetime] = None

    class Config:
        from_attributes = True

# Typing Indicator Schemas
class TypingIndicatorCreate(BaseModel):
    room_id: UUID
    is_typing: bool

class TypingIndicatorResponse(BaseModel):
    room_id: UUID
    user_id: UUID
    username: str
    display_name: Optional[str] = None
    started_at: datetime
    expires_at: datetime

    class Config:
        from_attributes = True

# Bulk Operations Schemas
class BulkMessageRead(BaseModel):
    room_id: UUID
    message_ids: Optional[List[UUID]] = None  # If None, mark all as read

class BulkRoomUpdate(BaseModel):
    room_ids: List[UUID]
    action: str  # 'archive', 'unarchive', 'mute', 'unmute', 'pin', 'unpin'

# WebSocket Schemas
class WebSocketMessage(BaseModel):
    type: str
    data: Dict[str, Any]
    room_id: Optional[UUID] = None
    user_id: Optional[UUID] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)

class WebSocketEventType(str, Enum):
    NEW_MESSAGE = "new_message"
    MESSAGE_UPDATED = "message_updated"
    MESSAGE_DELETED = "message_deleted"
    MESSAGE_REACTION = "message_reaction"
    MESSAGE_READ = "message_read"
    TYPING_START = "typing_start"
    TYPING_STOP = "typing_stop"
    USER_ONLINE = "user_online"
    USER_OFFLINE = "user_offline"
    ROOM_CREATED = "room_created"
    ROOM_UPDATED = "room_updated"
    PARTICIPANT_JOINED = "participant_joined"
    PARTICIPANT_LEFT = "participant_left"
    FRIEND_REQUEST = "friend_request"
    FRIEND_ACCEPTED = "friend_accepted"

# Error Schemas
class ChatError(BaseModel):
    error_code: str
    message: str
    details: Optional[Dict[str, Any]] = None

# Pagination Schemas
class PaginationParams(BaseModel):
    page: int = Field(1, ge=1)
    per_page: int = Field(20, ge=1, le=100)
    
class MessagePaginationParams(PaginationParams):
    before_message_id: Optional[UUID] = None
    after_message_id: Optional[UUID] = None

# Statistics Schemas
class ChatRoomStats(BaseModel):
    total_messages: int
    total_participants: int
    active_participants: int  # Not left
    messages_today: int
    last_active: Optional[datetime] = None

class UserChatStats(BaseModel):
    total_rooms: int
    total_messages_sent: int
    total_messages_received: int
    unread_messages_count: int
    active_rooms_count: int  # Rooms with recent activity
