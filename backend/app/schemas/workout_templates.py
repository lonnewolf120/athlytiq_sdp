from pydantic import BaseModel, Field
from typing import List, Optional
from uuid import UUID
from datetime import datetime


class WorkoutTemplateExerciseBase(BaseModel):
    exercise_id: str = Field(..., description="Reference to exercise library")
    exercise_name: str = Field(..., description="Name of the exercise")
    exercise_equipments: Optional[List[str]] = Field(default=[], description="Equipment required for exercise")
    exercise_gif_url: Optional[str] = Field(None, description="URL to exercise demonstration GIF")
    exercise_order: int = Field(..., ge=1, description="Order of exercise in the workout")
    default_sets: int = Field(..., ge=1, description="Default number of sets")
    default_reps: str = Field(..., description="Default reps (e.g., '8-10', '12-15', 'AMRAP')")
    default_weight: Optional[str] = Field(None, description="Default weight (e.g., 'bodyweight', '60-70% 1RM')")
    rest_time_seconds: Optional[int] = Field(60, ge=0, description="Rest time between sets in seconds")
    notes: Optional[str] = Field(None, description="Special instructions or form cues")


class WorkoutTemplateExerciseResponse(WorkoutTemplateExerciseBase):
    id: UUID
    template_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True


class WorkoutTemplateBase(BaseModel):
    name: str = Field(..., description="Name of the workout template")
    description: Optional[str] = Field(None, description="Detailed description of the workout")
    author: str = Field(..., description="Author of the workout (e.g., 'Ronnie Coleman')")
    difficulty_level: str = Field(..., description="Difficulty level: Beginner, Intermediate, or Advanced")
    primary_muscle_groups: Optional[List[str]] = Field(default=[], description="Primary muscle groups targeted")
    estimated_duration_minutes: Optional[int] = Field(None, ge=1, description="Estimated workout duration in minutes")
    equipment_required: Optional[List[str]] = Field(default=[], description="Equipment required for the workout")
    tags: Optional[List[str]] = Field(default=[], description="Tags for categorization and filtering")
    icon_url: Optional[str] = Field(None, description="URL to workout icon/image")


class WorkoutTemplateResponse(WorkoutTemplateBase):
    id: UUID
    is_active: bool
    created_at: datetime
    updated_at: datetime
    exercise_count: Optional[int] = Field(None, description="Number of exercises in this template")

    class Config:
        from_attributes = True
    
    @classmethod
    def from_orm(cls, obj):
        # Calculate exercise count if exercises are loaded
        exercise_count = len(obj.exercises) if hasattr(obj, 'exercises') and obj.exercises else None
        
        return cls(
            id=obj.id,
            name=obj.name,
            description=obj.description,
            author=obj.author,
            difficulty_level=obj.difficulty_level,
            primary_muscle_groups=obj.primary_muscle_groups or [],
            estimated_duration_minutes=obj.estimated_duration_minutes,
            equipment_required=obj.equipment_required or [],
            tags=obj.tags or [],
            icon_url=obj.icon_url,
            is_active=obj.is_active,
            created_at=obj.created_at,
            updated_at=obj.updated_at,
            exercise_count=exercise_count
        )


class WorkoutTemplateDetailResponse(WorkoutTemplateBase):
    id: UUID
    is_active: bool
    created_at: datetime
    updated_at: datetime
    exercises: List[WorkoutTemplateExerciseResponse] = Field(default=[], description="List of exercises in this template")

    class Config:
        from_attributes = True
    
    @classmethod
    def from_orm(cls, obj):
        return cls(
            id=obj.id,
            name=obj.name,
            description=obj.description,
            author=obj.author,
            difficulty_level=obj.difficulty_level,
            primary_muscle_groups=obj.primary_muscle_groups or [],
            estimated_duration_minutes=obj.estimated_duration_minutes,
            equipment_required=obj.equipment_required or [],
            tags=obj.tags or [],
            icon_url=obj.icon_url,
            is_active=obj.is_active,
            created_at=obj.created_at,
            updated_at=obj.updated_at,
            exercises=[WorkoutTemplateExerciseResponse.from_orm(ex) for ex in (obj.exercises or [])]
        )


class WorkoutTemplateListResponse(BaseModel):
    templates: List[WorkoutTemplateResponse]
    total_count: int = Field(..., description="Total number of templates matching the filter")
    page: int = Field(..., ge=1, description="Current page number")
    page_size: int = Field(..., ge=1, description="Number of items per page")
    total_pages: int = Field(..., ge=1, description="Total number of pages")


class TemplateFilters(BaseModel):
    author: Optional[str] = None
    difficulty_level: Optional[str] = None
    muscle_groups: Optional[List[str]] = None
    tags: Optional[List[str]] = None
    search: Optional[str] = None


class ImportTemplateRequest(BaseModel):
    custom_name: Optional[str] = Field(None, description="Custom name for the imported workout (optional)")


class ImportTemplateResponse(BaseModel):
    success: bool
    message: str
    imported_workout_id: str
    imported_workout_name: str


# Create Template (Admin only)
class WorkoutTemplateCreate(WorkoutTemplateBase):
    exercises: List[WorkoutTemplateExerciseBase] = Field(..., description="List of exercises for this template")


class WorkoutTemplateExerciseCreate(WorkoutTemplateExerciseBase):
    pass


# Update Template (Admin only)
class WorkoutTemplateUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    author: Optional[str] = None
    difficulty_level: Optional[str] = None
    primary_muscle_groups: Optional[List[str]] = None
    estimated_duration_minutes: Optional[int] = None
    equipment_required: Optional[List[str]] = None
    tags: Optional[List[str]] = None
    icon_url: Optional[str] = None
    is_active: Optional[bool] = None