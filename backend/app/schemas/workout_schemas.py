from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import uuid

# Schemas for CompletedWorkoutSet
class CompletedWorkoutSetBase(BaseModel):
    weight: str
    reps: str

class CompletedWorkoutSetCreate(CompletedWorkoutSetBase):
    pass

class CompletedWorkoutSetInDB(CompletedWorkoutSetBase):
    id: uuid.UUID
    completed_workout_exercise_id: uuid.UUID # Foreign key
    created_at: datetime

    class Config:
        from_attributes = True

class CompletedWorkoutSetPublic(CompletedWorkoutSetBase):
    id: uuid.UUID
    created_at: datetime

    class Config:
        from_attributes = True


# Schemas for CompletedWorkoutExercise
class CompletedWorkoutExerciseBase(BaseModel):
    exercise_id: str # Reference to a global exercise DB or just a name
    exercise_name: str
    exercise_equipments: Optional[List[str]] = None
    exercise_gif_url: Optional[str] = None

class CompletedWorkoutExerciseCreate(CompletedWorkoutExerciseBase):
    sets: List[CompletedWorkoutSetCreate]

class CompletedWorkoutExerciseInDB(CompletedWorkoutExerciseBase):
    id: uuid.UUID
    completed_workout_id: uuid.UUID # Foreign key
    created_at: datetime
    # sets will be loaded via relationship

    class Config:
        from_attributes = True

class CompletedWorkoutExercisePublic(CompletedWorkoutExerciseBase):
    id: uuid.UUID
    sets: List[CompletedWorkoutSetPublic]
    created_at: datetime

    class Config:
        from_attributes = True


# Schemas for CompletedWorkout (Session)
class CompletedWorkoutBase(BaseModel):
    workout_name: str
    start_time: datetime
    end_time: datetime
    duration_seconds: int # Calculated: end_time - start_time
    intensity_score: float # User reported, e.g., RPE 1-10

class CompletedWorkoutCreate(CompletedWorkoutBase):
    exercises: List[CompletedWorkoutExerciseCreate]

class CompletedWorkoutInDBBase(CompletedWorkoutBase):
    id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime
    # exercises will be loaded via relationship

    class Config:
        from_attributes = True

# This is the main schema for returning a completed workout to the client
class CompletedWorkoutPublic(CompletedWorkoutInDBBase):
    exercises: List[CompletedWorkoutExercisePublic]

    class Config:
        from_attributes = True
