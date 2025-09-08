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
    media_url: Optional[str] = None
    reply_to_id: Optional[UUID] = None
    is_edited: bool
    created_at: datetime

    class Config:
        from_attributes = True


class ChatParticipantResponse(BaseModel):
    user_id: UUID
    username: str
    display_name: Optional[str] = None
    avatar_url: Optional[str] = None
    joined_at: datetime
    last_read_at: Optional[datetime] = None
    is_active: bool

    class Config:
        from_attributes = True


class ChatRoomCreate(BaseModel):
    name: Optional[str] = None
    is_group: bool = False
    participant_ids: List[UUID]


class ChatRoomResponse(BaseModel):
    id: UUID
    name: Optional[str] = None
    is_group: bool
    created_at: datetime
    last_message: Optional[ChatMessageResponse] = None
    unread_count: int = 0
    participants: List[ChatParticipantResponse] = []

    class Config:
        from_attributes = True


class ChatRoomListResponse(BaseModel):
    id: UUID
    name: Optional[str] = None
    is_group: bool
    created_at: datetime
    last_message_content: Optional[str] = None
    last_message_time: Optional[datetime] = None
    unread_count: int = 0
    other_participant_name: Optional[str] = None
    other_participant_avatar: Optional[str] = None

    class Config:
        from_attributes = True
