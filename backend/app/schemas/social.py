from pydantic import BaseModel, Field
from typing import Optional, List, Any
from uuid import UUID
from datetime import datetime, time

# Stories
class StoryCreate(BaseModel):
    media_url: str
    caption: Optional[str] = None
    privacy: Optional[str] = 'public'  # public | buddies | private
    expires_at: datetime

class StoryPublic(StoryCreate):
    id: UUID
    user_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True

# Buddies
class BuddyRequestCreate(BaseModel):
    requestee_id: UUID

class BuddyRequestPublic(BaseModel):
    id: UUID
    requester_id: UUID
    requestee_id: UUID
    status: str
    created_at: datetime

    class Config:
        from_attributes = True

class BuddyResponse(BaseModel):
    accept: bool

# Communities
class CommunityCreate(BaseModel):
    name: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    is_private: Optional[bool] = False

class CommunityPublic(CommunityCreate):
    id: UUID
    creator_user_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class CommunityListItem(BaseModel):
    id: UUID
    name: str
    description: Optional[str] = None
    creator_user_id: UUID
    created_at: datetime
    updated_at: datetime
    member_count: int = 0
    joined: bool = False

# Community Messages
class CommunityMessageCreate(BaseModel):
    content: str
    attachments: Optional[Any] = None

class CommunityMessagePublic(CommunityMessageCreate):
    id: UUID
    community_id: UUID
    user_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True

# Reports
class ReportCreate(BaseModel):
    target_type: str
    target_id: UUID
    reason: Optional[str] = None

class ReportPublic(ReportCreate):
    id: UUID
    reporter_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
