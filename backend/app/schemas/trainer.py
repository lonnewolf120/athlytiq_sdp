from pydantic import BaseModel, Field
from typing import List, Optional
from uuid import UUID
from datetime import datetime, time


class TrainerAvailabilityCreate(BaseModel):
    weekday: int = Field(..., ge=0, le=6)
    start_time: time
    end_time: time


class TrainerAvailabilityPublic(TrainerAvailabilityCreate):
    id: UUID
    created_at: datetime

    class Config:
        from_attributes = True


class TrainerProfileCreate(BaseModel):
    bio: Optional[str] = None
    certifications: Optional[str] = None
    specialties: Optional[str] = None
    hourly_rate: Optional[float] = None


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
