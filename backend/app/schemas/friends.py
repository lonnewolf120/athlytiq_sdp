from pydantic import BaseModel, Field
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

    class Config:
        from_attributes = True


class FriendResponse(BaseModel):
    id: UUID
    user_id: UUID
    username: str
    display_name: Optional[str] = None
    avatar_url: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class UserSearchResponse(BaseModel):
    id: UUID
    username: str
    display_name: Optional[str] = None
    avatar_url: Optional[str] = None
    is_friend: bool = False
    has_pending_request: bool = False

    class Config:
        from_attributes = True


class FriendRequestAction(BaseModel):
    action: str = Field(..., pattern="^(accepted|rejected)$")
