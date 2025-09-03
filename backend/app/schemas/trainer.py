from pydantic import BaseModel, Field, EmailStr, HttpUrl
from typing import List, Optional, Dict
from uuid import UUID
from datetime import datetime, time
from enum import Enum


class TrainerSpecialization(str, Enum):
    WEIGHT_TRAINING = "weight_training"
    CARDIO = "cardio"
    YOGA = "yoga"
    PILATES = "pilates"
    CROSSFIT = "crossfit"
    MARTIAL_ARTS = "martial_arts"
    DANCE = "dance"
    SPORTS = "sports"
    REHABILITATION = "rehabilitation"
    NUTRITION = "nutrition"


class TrainerApplicationStatus(str, Enum):
    PENDING = "pending"
    IN_REVIEW = "in_review"
    APPROVED = "approved"
    REJECTED = "rejected"
    ADDITIONAL_INFO_NEEDED = "additional_info_needed"


class TrainerAvailabilityCreate(BaseModel):
    weekday: int = Field(..., ge=0, le=6)
    start_time: time
    end_time: time


class TrainerAvailabilityPublic(TrainerAvailabilityCreate):
    id: UUID
    created_at: datetime

    class Config:
        from_attributes = True


class SocialLinks(BaseModel):
    facebook: Optional[HttpUrl] = None
    instagram: Optional[HttpUrl] = None
    whatsapp: Optional[str] = None
    email: Optional[EmailStr] = None


class TrainerApplicationCreate(BaseModel):
    full_name: str
    bio: str = Field(..., min_length=100, max_length=1000)
    years_of_experience: int = Field(..., ge=0)
    specializations: List[TrainerSpecialization]
    certification_details: str
    id_document_url: str
    certification_document_urls: List[str]
    profile_photo_url: str
    contact_email: EmailStr
    phone_number: str
    social_links: Optional[SocialLinks] = None


class TrainerApplicationUpdate(BaseModel):
    status: TrainerApplicationStatus
    feedback: Optional[str] = None
    reviewed_by: UUID
    reviewed_at: datetime


class TrainerProfileCreate(BaseModel):
    bio: str = Field(..., min_length=100, max_length=1000)
    certifications: List[str]
    specializations: List[TrainerSpecialization]
    hourly_rate: float = Field(..., ge=0)
    years_of_experience: int = Field(..., ge=0)
    profile_photo_url: str
    social_links: Optional[SocialLinks] = None
    education: Optional[List[str]] = None
    achievements: Optional[List[str]] = None
    available_for_consultation: bool = True


class TrainerProfilePublic(TrainerProfileCreate):
    id: UUID
    user_id: UUID
    rating: Optional[float] = None
    created_at: datetime
    updated_at: datetime
    availabilities: Optional[List[TrainerAvailabilityPublic]] = []

    class Config:
        from_attributes = True


class TrainerSessionCreate(BaseModel):
    start_time: datetime
    end_time: datetime
    notes: Optional[str] = None
    price: Optional[float] = None


class TrainerSessionPublic(TrainerSessionCreate):
    id: UUID
    trainer_id: UUID
    user_id: UUID
    status: str
    created_at: datetime

    class Config:
        from_attributes = True


class TrainerPostCreate(BaseModel):
    title: str = Field(..., min_length=5, max_length=200)
    content: str = Field(..., min_length=50)
    category: TrainerSpecialization
    tags: List[str] = Field(default_factory=list)
    image_urls: Optional[List[str]] = None


class TrainerPostPublic(TrainerPostCreate):
    id: UUID
    trainer_id: UUID
    likes_count: int = 0
    comments_count: int = 0
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class PlanVerificationRequest(BaseModel):
    plan_id: UUID
    plan_type: str = Field(..., regex='^(workout|meal)$')
    notes: Optional[str] = None


class PlanVerificationResponse(BaseModel):
    id: UUID
    trainer_id: UUID
    request_id: UUID
    feedback: str
    is_approved: bool
    suggestions: Optional[List[str]] = None
    created_at: datetime

    class Config:
        from_attributes = True


class TrainerChat(BaseModel):
    sender_id: UUID
    receiver_id: UUID
    message: str = Field(..., min_length=1)
    attachment_urls: Optional[List[str]] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    read_at: Optional[datetime] = None

    class Config:
        from_attributes = True
