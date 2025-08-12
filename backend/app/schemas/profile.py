from pydantic import BaseModel, Field
from typing import Optional
from uuid import UUID

class ProfilePublic(BaseModel):
    id: UUID
    user_id: UUID
    bio: Optional[str] = None
    profile_picture_url: Optional[str] = None
    fitness_goals: Optional[str] = None
    display_name: Optional[str] = None
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    activity_level: Optional[str] = None # New field for activity level

    class Config:
        from_attributes = True
