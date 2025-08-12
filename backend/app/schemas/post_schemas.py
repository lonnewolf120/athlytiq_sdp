from typing import List, Optional
from datetime import datetime
from enum import Enum
from uuid import UUID # Added import for UUID

from pydantic import BaseModel, Field
from app.schemas.user import UserPublic  # Assuming UserPublic schema exists

# Enums
class PostType(str, Enum):
    text = "text"
    workout = "workout"
    challenge = "challenge"

# Exercise Schema (for WorkoutPostData)
class ExerciseSchema(BaseModel):
    exerciseId: str = Field(..., alias="exercise_id")
    name: str
    gifUrl: str = Field(..., alias="gif_url")
    bodyParts: List[str] = Field(..., alias="body_parts")
    equipments: List[str]
    targetMuscles: List[str] = Field(..., alias="target_muscles")
    secondaryMuscles: List[str] = Field(..., alias="secondary_muscles")
    instructions: List[str]

    # Optional fields from Flutter model
    imageUrl: Optional[str] = Field(None, alias="image_url")
    exerciseType: Optional[str] = Field(None, alias="exercise_type")
    keywords: Optional[List[str]] = None
    overview: Optional[str] = None
    videoUrl: Optional[str] = Field(None, alias="video_url")
    exerciseTips: Optional[List[str]] = Field(None, alias="exercise_tips")
    variations: Optional[List[str]] = None
    relatedExerciseIds: Optional[List[str]] = Field(None, alias="related_exercise_ids")
    sets: Optional[str] = None
    reps: Optional[str] = None
    weight: Optional[str] = None

    class Config:
        populate_by_name = True
        use_enum_values = True

# Workout Post Data Schema
class WorkoutPostDataSchema(BaseModel):
    workoutType: str = Field(..., alias="workout_type")
    durationMinutes: int = Field(..., alias="duration_minutes")
    caloriesBurned: int = Field(..., alias="calories_burned")
    exercises: List[ExerciseSchema]
    notes: Optional[str] = None

    class Config:
        populate_by_name = True
        use_enum_values = True

# Challenge Post Data Schema
class ChallengePostDataSchema(BaseModel):
    title: str
    description: str
    startDate: datetime = Field(..., alias="start_date")
    durationDays: int = Field(..., alias="duration_days")
    coverImageUrl: Optional[str] = Field(None, alias="cover_image_url")
    participantCount: int = Field(0, alias="participant_count")

    class Config:
        populate_by_name = True
        use_enum_values = True

# Post Comment Schema
class PostCommentSchema(BaseModel):
    id: UUID # Changed from str to UUID
    postId: UUID = Field(..., alias="post_id") # Changed from str to UUID
    userId: UUID = Field(..., alias="user_id") # Changed from str to UUID
    content: str
    createdAt: datetime = Field(..., alias="created_at")
    updatedAt: datetime = Field(..., alias="updated_at")

    class Config:
        populate_by_name = True
        use_enum_values = True

# Post React Schema
class PostReactSchema(BaseModel):
    postId: UUID = Field(..., alias="post_id") # Changed from str to UUID
    userId: UUID = Field(..., alias="user_id") # Changed from str to UUID
    createdAt: datetime = Field(..., alias="created_at")
    reactType: str = Field(..., alias="react_type")
    emoji: Optional[str] = None

    class Config:
        populate_by_name = True
        use_enum_values = True

# Base Post Schema
class PostBase(BaseModel):
    content: Optional[str] = None
    mediaUrl: Optional[str] = Field(None, alias="media_url")
    postType: List[PostType] = Field(..., alias="post_type")
    
    # Nested data for specific post types
    workoutData: Optional[WorkoutPostDataSchema] = Field(None, alias="workout_data")
    challengeData: Optional[ChallengePostDataSchema] = Field(None, alias="challenge_data")

    class Config:
        populate_by_name = True
        use_enum_values = True

# Schema for creating a Post
class PostCreate(PostBase):
    # No ID, createdAt, updatedAt for creation
    pass

# Schema for updating a Post
class PostUpdate(PostBase):
    # All fields are optional for update
    content: Optional[str] = None
    mediaUrl: Optional[str] = Field(None, alias="media_url")
    postType: Optional[List[PostType]] = Field(None, alias="post_type")
    workoutData: Optional[WorkoutPostDataSchema] = Field(None, alias="workout_data")
    challengeData: Optional[ChallengePostDataSchema] = Field(None, alias="challenge_data")

# Schema for Post as stored in DB (includes DB-generated fields)
class PostInDB(PostBase):
    id: UUID # Changed from str to UUID
    userId: UUID = Field(..., alias="user_id") # Changed from str to UUID
    createdAt: datetime = Field(..., alias="created_at")
    updatedAt: datetime = Field(..., alias="updated_at")
    
    # Foreign key IDs for nested data
    workout_post_id: Optional[UUID] = None # Changed from str to UUID
    challenge_post_id: Optional[UUID] = None # Changed from str to UUID

    class Config:
        from_attributes = True  # Enable ORM mode for SQLAlchemy models
        populate_by_name = True
        use_enum_values = True

# Schema for Post response (includes author, comments, reacts)
class PostResponse(PostInDB):
    author: Optional[UserPublic] = None  # Assuming UserPublic is defined in app.schemas.user
    comments: Optional[List[PostCommentSchema]] = None
    reacts: Optional[List[PostReactSchema]] = None
    commentCount: Optional[int] = Field(None, alias="comment_count")
    reactCount: Optional[int] = Field(None, alias="react_count")

    class Config:
        from_attributes = True
        populate_by_name = True
        use_enum_values = True
