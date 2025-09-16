from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime
from typing import Optional, List


# --- Enhanced Exercise Library Schemas ---

class ExerciseCategoryBase(BaseModel):
    name: str = Field(..., max_length=100)
    description: Optional[str] = None
    color_code: Optional[str] = Field(None, pattern=r'^#[0-9A-Fa-f]{6}$')
    icon_name: Optional[str] = Field(None, max_length=50)


class ExerciseCategoryCreate(ExerciseCategoryBase):
    pass


class ExerciseCategoryResponse(ExerciseCategoryBase):
    id: UUID
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class MuscleGroupBase(BaseModel):
    name: str = Field(..., max_length=100)
    group_type: str = Field(..., pattern=r'^(primary|secondary|stabilizer)$')
    parent_id: Optional[UUID] = None
    description: Optional[str] = None


class MuscleGroupCreate(MuscleGroupBase):
    pass


class MuscleGroupResponse(MuscleGroupBase):
    id: UUID
    created_at: datetime
    updated_at: datetime
    children: List['MuscleGroupResponse'] = []
    
    class Config:
        from_attributes = True


class EquipmentTypeBase(BaseModel):
    name: str = Field(..., max_length=100)
    category: Optional[str] = Field(None, max_length=50)
    description: Optional[str] = None


class EquipmentTypeCreate(EquipmentTypeBase):
    pass


class EquipmentTypeResponse(EquipmentTypeBase):
    id: UUID
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class ExerciseLibraryBase(BaseModel):
    name: str = Field(..., max_length=200)
    description: Optional[str] = None
    instructions: Optional[str] = None
    form_tips: Optional[str] = None
    gif_url: Optional[str] = None
    video_url: Optional[str] = None
    category_id: Optional[UUID] = None
    difficulty_level: Optional[int] = Field(None, ge=1, le=5)
    popularity_score: Optional[float] = Field(0.0, ge=0.0, le=5.0)
    is_compound: bool = False
    is_unilateral: bool = False
    is_active: bool = True


class ExerciseLibraryCreate(ExerciseLibraryBase):
    muscle_group_ids: List[UUID] = []
    equipment_ids: List[UUID] = []


class ExerciseMuscleGroupResponse(BaseModel):
    id: UUID
    muscle_group_id: UUID
    is_primary: bool
    activation_level: Optional[int] = Field(None, ge=1, le=5)
    muscle_group: MuscleGroupResponse
    
    class Config:
        from_attributes = True


class ExerciseEquipmentResponse(BaseModel):
    id: UUID
    equipment_id: UUID
    is_required: bool
    is_alternative: bool
    equipment: EquipmentTypeResponse
    
    class Config:
        from_attributes = True


class ExerciseVariationResponse(BaseModel):
    id: UUID
    variation_exercise_id: UUID
    variation_type: Optional[str] = None
    notes: Optional[str] = None
    variation_exercise: 'ExerciseLibraryResponse'
    
    class Config:
        from_attributes = True


class ExerciseLibraryResponse(ExerciseLibraryBase):
    id: UUID
    created_at: datetime
    updated_at: datetime
    category: Optional[ExerciseCategoryResponse] = None
    muscle_groups: List[ExerciseMuscleGroupResponse] = []
    equipment: List[ExerciseEquipmentResponse] = []
    variations_as_base: List[ExerciseVariationResponse] = []
    
    class Config:
        from_attributes = True


# Exercise search and filter schemas
class ExerciseSearchFilters(BaseModel):
    search_query: Optional[str] = None
    category_ids: List[UUID] = []
    muscle_group_ids: List[UUID] = []
    equipment_ids: List[UUID] = []
    difficulty_levels: List[int] = Field([], validate_assignment=True)
    is_compound: Optional[bool] = None
    is_unilateral: Optional[bool] = None
    min_popularity: Optional[float] = Field(None, ge=0.0, le=5.0)
    equipment_required_only: bool = False  # If true, only show exercises with required equipment
    
    class Config:
        validate_assignment = True
        
    def __init__(self, **data):
        super().__init__(**data)
        # Validate difficulty levels
        if self.difficulty_levels:
            for level in self.difficulty_levels:
                if not (1 <= level <= 5):
                    raise ValueError("Difficulty levels must be between 1 and 5")


class ExerciseSearchResponse(BaseModel):
    exercises: List[ExerciseLibraryResponse]
    total_count: int
    page: int
    page_size: int
    total_pages: int
    
    class Config:
        from_attributes = True


# Enhanced search parameters
class ExerciseSearchParams(BaseModel):
    q: Optional[str] = Field(None, description="Search query for exercise name, description, or instructions")
    categories: List[str] = Field([], description="Exercise category names")
    muscle_groups: List[str] = Field([], description="Muscle group names")
    equipment: List[str] = Field([], description="Equipment type names")
    difficulty: List[int] = Field([], description="Difficulty levels (1-5)")
    compound: Optional[bool] = Field(None, description="Filter for compound exercises")
    unilateral: Optional[bool] = Field(None, description="Filter for unilateral exercises")
    min_popularity: Optional[float] = Field(None, ge=0.0, le=5.0, description="Minimum popularity score")
    page: int = Field(1, ge=1, description="Page number")
    page_size: int = Field(20, ge=1, le=100, description="Items per page")
    sort_by: str = Field("popularity", description="Sort field: name, difficulty, popularity, created_at")
    sort_order: str = Field("desc", pattern=r'^(asc|desc)$', description="Sort order")


# Quick exercise selection for workout creation
class ExerciseQuickSelect(BaseModel):
    id: UUID
    name: str
    category: Optional[str] = None
    difficulty_level: Optional[int] = None
    primary_muscle_groups: List[str] = []
    equipment_required: List[str] = []
    is_compound: bool = False
    
    class Config:
        from_attributes = True


class ExerciseQuickSelectResponse(BaseModel):
    exercises: List[ExerciseQuickSelect]
    categories: List[ExerciseCategoryResponse]
    muscle_groups: List[MuscleGroupResponse]
    equipment_types: List[EquipmentTypeResponse]
    
    class Config:
        from_attributes = True


# Update forward references
MuscleGroupResponse.model_rebuild()
ExerciseVariationResponse.model_rebuild()
ExerciseLibraryResponse.model_rebuild()
