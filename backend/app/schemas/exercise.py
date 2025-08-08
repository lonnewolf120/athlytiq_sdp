from pydantic import BaseModel
from uuid import UUID
from datetime import datetime
from typing import Optional

class ExerciseBase(BaseModel):
    name: str
    gifUrl: str
    bodyParts: Optional[str]
    equipments: Optional[str]
    sets: Optional[int]
    reps: Optional[int]
    weight: Optional[float]
    duration_seconds: Optional[int]
    notes: Optional[str]
    order_in_workout: Optional[int]
    created_at: Optional[datetime]
    updated_at: Optional[datetime]

class ExerciseResult(ExerciseBase):
    id:UUID
    
    class Config:
        from_attributes=True