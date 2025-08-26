from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field, validator
from enum import Enum

class ActivityTypeEnum(str, Enum):
    run = "run"
    ride = "ride"
    swim = "swim"
    walk = "walk"
    hike = "hike"
    workout = "workout"

class ChallengeStatusEnum(str, Enum):
    upcoming = "upcoming"
    active = "active"
    completed = "completed"
    cancelled = "cancelled"

class ParticipantStatusEnum(str, Enum):
    joined = "joined"
    left = "left"
    completed = "completed"
    failed = "failed"


class ChallengeParticipantBase(BaseModel):
    progress: float = Field(default=0.0, ge=0.0)
    progress_percentage: float = Field(default=0.0, ge=0.0, le=100.0)
    completion_proof_url: Optional[str] = None
    notes: Optional[str] = None

class ChallengeParticipantCreate(ChallengeParticipantBase):
    challenge_id: str
    
class ChallengeParticipantUpdate(BaseModel):
    status: Optional[ParticipantStatusEnum] = None
    progress: Optional[float] = Field(None, ge=0.0)
    progress_percentage: Optional[float] = Field(None, ge=0.0, le=100.0)
    completion_proof_url: Optional[str] = None
    notes: Optional[str] = None

class ChallengeParticipant(ChallengeParticipantBase):
    id: str
    challenge_id: str
    user_id: str
    status: ParticipantStatusEnum
    joined_at: datetime
    completed_at: Optional[datetime] = None
    
    username: Optional[str] = None
    
    class Config:
        from_attributes = True



class ChallengeBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    brand: str = Field(..., min_length=1, max_length=100)
    brand_logo: Optional[str] = Field(None, max_length=10)
    background_image: Optional[str] = None
    distance: str = Field(..., min_length=1, max_length=100)
    duration: str = Field(..., min_length=1, max_length=200)
    activity_type: ActivityTypeEnum = ActivityTypeEnum.run
    brand_color: str = Field(default="#FF6B35", pattern=r'^#[0-9A-Fa-f]{6}$')
    max_participants: Optional[int] = Field(None, gt=0)
    is_public: bool = True

class ChallengeCreate(ChallengeBase):
    start_date: datetime
    end_date: datetime
    
    @validator('end_date')
    def end_date_must_be_after_start_date(cls, v, values):
        if 'start_date' in values and v <= values['start_date']:
            raise ValueError('End date must be after start date')
        return v

class ChallengeUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    brand: Optional[str] = Field(None, min_length=1, max_length=100)
    brand_logo: Optional[str] = Field(None, max_length=10)
    background_image: Optional[str] = None
    distance: Optional[str] = Field(None, min_length=1, max_length=100)
    duration: Optional[str] = Field(None, min_length=1, max_length=200)
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    activity_type: Optional[ActivityTypeEnum] = None
    status: Optional[ChallengeStatusEnum] = None
    brand_color: Optional[str] = Field(None, pattern=r'^#[0-9A-Fa-f]{6}$')
    max_participants: Optional[int] = Field(None, gt=0)
    is_public: Optional[bool] = None

class Challenge(ChallengeBase):
    id: str
    start_date: datetime
    end_date: datetime
    status: ChallengeStatusEnum
    created_by: str
    created_at: datetime
    updated_at: datetime
    
    friends_joined: int = 0  
    is_joined: bool = False 
    
    participants: Optional[List[ChallengeParticipant]] = None
    creator_username: Optional[str] = None
    
    class Config:
        from_attributes = True


class ChallengeListResponse(BaseModel):
    challenges: List[Challenge]
    total: int
    page: int
    size: int
    has_next: bool
    has_prev: bool

class ChallengeParticipantsResponse(BaseModel):
    participants: List[ChallengeParticipant]
    total: int
    
class ChallengeStatsResponse(BaseModel):
    total_challenges: int
    active_challenges: int
    user_participations: int
    user_completed: int
    popular_activity_types: List[dict]  # [{"activity_type": "run", "count": 5}, ...]


class JoinChallengeRequest(BaseModel):
    pass  

class LeaveChallengeRequest(BaseModel):
    pass  

class UpdateProgressRequest(BaseModel):
    progress: Optional[str] = None
    progress_percentage: Optional[float] = Field(None, ge=0.0, le=100.0)
    completion_proof_url: Optional[str] = None
    notes: Optional[str] = None
