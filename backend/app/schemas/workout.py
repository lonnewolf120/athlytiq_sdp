from pydantic import BaseModel
from uuid import UUID
from datetime import datetime
from typing import List, Optional # Added for List and Optional

# PlannedExercise Schemas
class PlannedExerciseBase(BaseModel):
    exercise_id: str
    exercise_name: str
    exercise_equipments: Optional[List[str]] = None
    exercise_gif_url: Optional[str] = None
    type: Optional[str] = None
    planned_sets: int
    planned_reps: int
    planned_weight: Optional[str] = None

class PlannedExerciseCreate(PlannedExerciseBase):
    pass

class PlannedExerciseFetch(PlannedExerciseBase):
    id: UUID
    workout_id: UUID # Foreign key
    created_at: datetime

    class Config:
        from_attributes = True

class PlannedExercisePublic(PlannedExerciseFetch):
    pass # Can be same as fetch for now

# Workout Schemas
class WorkoutBase(BaseModel):
    name:str
    icon_url:Optional[str] = None # Made optional as per frontend model
    equipment_selected:Optional[str] = None # Made optional as per frontend model
    one_rm_goal:Optional[str] = None # Made optional as per frontend model
    type:Optional[str] = None # Made optional as per frontend model
    prompt: Optional[dict] = None # Changed prompt type to dict to match jsonb in Supabase
    description: Optional[str] = None # Added description field as per Supabase schema

class WorkoutCreate(WorkoutBase):
    # user_id will be set by the backend based on current_user
    exercises: List[PlannedExerciseCreate] # Now accepts nested planned exercises

class WorkoutFetch(WorkoutBase):
    id:UUID
    user_id:UUID # Added user_id for fetching
    created_at:datetime
    updated_at:datetime
    planned_exercises: List[PlannedExercisePublic] # Include planned exercises

    class Config:
        from_attributes=True

class WorkoutPublic(WorkoutFetch):
    pass # Can be same as fetch for now
