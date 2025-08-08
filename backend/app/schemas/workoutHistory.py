from pydantic import BaseModel
from typing import Optional
from uuid import UUID
from datetime import datetime


class CreateWorkoutHistory(BaseModel):
    user_id: UUID
    original_workout_id: Optional[UUID] = None
    workout_name: str
    workout_icon_url: Optional[str] = None
    start_time: datetime
    end_time: datetime
    duration_seconds: int
    intensity_score: float


class FetchWorkoutHistory(CreateWorkoutHistory):
    id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
