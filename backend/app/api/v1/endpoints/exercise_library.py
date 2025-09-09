from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func, or_, and_, text
from app.models_db import (
    ExerciseLibrary, ExerciseCategory, MuscleGroup, EquipmentType,
    ExerciseMuscleGroup, ExerciseEquipment, ExerciseVariation
)
from app.schemas.exercise_library import (
    ExerciseLibraryResponse, ExerciseLibraryCreate, ExerciseSearchParams,
    ExerciseSearchResponse, ExerciseCategoryResponse, MuscleGroupResponse,
    EquipmentTypeResponse, ExerciseQuickSelectResponse, ExerciseQuickSelect
)
from app.database.base import get_db
from typing import List, Optional
import uuid


router = APIRouter()


# --- Exercise Library Management ---

@router.get("/library", response_model=ExerciseSearchResponse)
def search_exercises(
    params: ExerciseSearchParams = Depends(),
    db: Session = Depends(get_db)
):
    """
    Advanced exercise search with filtering, pagination, and sorting.
    Supports full-text search, muscle group filtering, equipment filtering, etc.
    """
    
    # Base query with eager loading for relationships
    query = db.query(ExerciseLibrary).options(
        joinedload(ExerciseLibrary.category),
        joinedload(ExerciseLibrary.muscle_groups).joinedload(ExerciseMuscleGroup.muscle_group),
        joinedload(ExerciseLibrary.equipment).joinedload(ExerciseEquipment.equipment)
    ).filter(ExerciseLibrary.is_active == True)
    
    # Text search across name, description, and instructions
    if params.q:
        search_filter = or_(
            ExerciseLibrary.name.ilike(f"%{params.q}%"),
            ExerciseLibrary.description.ilike(f"%{params.q}%"),
            ExerciseLibrary.instructions.ilike(f"%{params.q}%")
        )
        query = query.filter(search_filter)
    
    # Category filtering
    if params.categories:
        category_ids = db.query(ExerciseCategory.id).filter(
            ExerciseCategory.name.in_(params.categories)
        ).subquery()
        query = query.filter(ExerciseLibrary.category_id.in_(category_ids))
    
    # Muscle group filtering
    if params.muscle_groups:
        muscle_group_ids = db.query(MuscleGroup.id).filter(
            MuscleGroup.name.in_(params.muscle_groups)
        ).subquery()
        exercise_ids_with_muscle_groups = db.query(ExerciseMuscleGroup.exercise_id).filter(
            ExerciseMuscleGroup.muscle_group_id.in_(muscle_group_ids)
        ).subquery()
        query = query.filter(ExerciseLibrary.id.in_(exercise_ids_with_muscle_groups))
    
    # Equipment filtering
    if params.equipment:
        equipment_ids = db.query(EquipmentType.id).filter(
            EquipmentType.name.in_(params.equipment)
        ).subquery()
        exercise_ids_with_equipment = db.query(ExerciseEquipment.exercise_id).filter(
            ExerciseEquipment.equipment_id.in_(equipment_ids)
        ).subquery()
        query = query.filter(ExerciseLibrary.id.in_(exercise_ids_with_equipment))
    
    # Difficulty filtering
    if params.difficulty:
        query = query.filter(ExerciseLibrary.difficulty_level.in_(params.difficulty))
    
    # Compound/unilateral filtering
    if params.compound is not None:
        query = query.filter(ExerciseLibrary.is_compound == params.compound)
    
    if params.unilateral is not None:
        query = query.filter(ExerciseLibrary.is_unilateral == params.unilateral)
    
    # Popularity filtering
    if params.min_popularity is not None:
        query = query.filter(ExerciseLibrary.popularity_score >= params.min_popularity)
    
    # Get total count before pagination
    total_count = query.count()
    
    # Sorting
    if params.sort_by == "name":
        order_column = ExerciseLibrary.name
    elif params.sort_by == "difficulty":
        order_column = ExerciseLibrary.difficulty_level
    elif params.sort_by == "popularity":
        order_column = ExerciseLibrary.popularity_score
    elif params.sort_by == "created_at":
        order_column = ExerciseLibrary.created_at
    else:
        order_column = ExerciseLibrary.popularity_score
    
    if params.sort_order == "asc":
        query = query.order_by(order_column.asc())
    else:
        query = query.order_by(order_column.desc())
    
    # Pagination
    offset = (params.page - 1) * params.page_size
    exercises = query.offset(offset).limit(params.page_size).all()
    
    total_pages = (total_count + params.page_size - 1) // params.page_size
    
    return ExerciseSearchResponse(
        exercises=exercises,
        total_count=total_count,
        page=params.page,
        page_size=params.page_size,
        total_pages=total_pages
    )


@router.get("/library/{exercise_id}", response_model=ExerciseLibraryResponse)
def get_exercise_details(
    exercise_id: uuid.UUID,
    db: Session = Depends(get_db)
):
    """Get detailed information about a specific exercise including variations."""
    
    exercise = db.query(ExerciseLibrary).options(
        joinedload(ExerciseLibrary.category),
        joinedload(ExerciseLibrary.muscle_groups).joinedload(ExerciseMuscleGroup.muscle_group),
        joinedload(ExerciseLibrary.equipment).joinedload(ExerciseEquipment.equipment),
        joinedload(ExerciseLibrary.variations_as_base).joinedload(ExerciseVariation.variation_exercise)
    ).filter(
        ExerciseLibrary.id == exercise_id,
        ExerciseLibrary.is_active == True
    ).first()
    
    if not exercise:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Exercise not found"
        )
    
    return exercise


@router.get("/quick-select", response_model=ExerciseQuickSelectResponse)
def get_exercises_for_selection(
    search: Optional[str] = Query(None, description="Search term"),
    category: Optional[str] = Query(None, description="Filter by category"),
    muscle_group: Optional[str] = Query(None, description="Filter by muscle group"),
    equipment: Optional[str] = Query(None, description="Filter by equipment"),
    limit: int = Query(50, ge=1, le=100, description="Number of exercises to return"),
    db: Session = Depends(get_db)
):
    """
    Get exercises in a simplified format for workout creation UI.
    Optimized for mobile app exercise selection with minimal data transfer.
    """
    
    # Base query for exercises
    query = db.query(ExerciseLibrary).options(
        joinedload(ExerciseLibrary.category),
        joinedload(ExerciseLibrary.muscle_groups).joinedload(ExerciseMuscleGroup.muscle_group),
        joinedload(ExerciseLibrary.equipment).joinedload(ExerciseEquipment.equipment)
    ).filter(ExerciseLibrary.is_active == True)
    
    # Apply filters
    if search:
        query = query.filter(ExerciseLibrary.name.ilike(f"%{search}%"))
    
    if category:
        query = query.join(ExerciseCategory).filter(ExerciseCategory.name.ilike(f"%{category}%"))
    
    if muscle_group:
        query = query.join(ExerciseMuscleGroup).join(MuscleGroup).filter(
            MuscleGroup.name.ilike(f"%{muscle_group}%")
        )
    
    if equipment:
        query = query.join(ExerciseEquipment).join(EquipmentType).filter(
            EquipmentType.name.ilike(f"%{equipment}%")
        )
    
    # Order by popularity and limit
    exercises = query.order_by(ExerciseLibrary.popularity_score.desc()).limit(limit).all()
    
    # Transform to quick select format
    quick_exercises = []
    for exercise in exercises:
        # Get primary muscle groups
        primary_muscles = [
            emg.muscle_group.name for emg in exercise.muscle_groups 
            if emg.is_primary
        ]
        
        # Get required equipment
        required_equipment = [
            ee.equipment.name for ee in exercise.equipment 
            if ee.is_required
        ]
        
        quick_exercises.append(ExerciseQuickSelect(
            id=exercise.id,
            name=exercise.name,
            category=exercise.category.name if exercise.category else None,
            difficulty_level=exercise.difficulty_level,
            primary_muscle_groups=primary_muscles,
            equipment_required=required_equipment,
            is_compound=exercise.is_compound
        ))
    
    # Get reference data for filters
    categories = db.query(ExerciseCategory).order_by(ExerciseCategory.name).all()
    muscle_groups = db.query(MuscleGroup).filter(
        MuscleGroup.group_type == 'primary'
    ).order_by(MuscleGroup.name).all()
    equipment_types = db.query(EquipmentType).order_by(EquipmentType.name).all()
    
    return ExerciseQuickSelectResponse(
        exercises=quick_exercises,
        categories=categories,
        muscle_groups=muscle_groups,
        equipment_types=equipment_types
    )


# --- Reference Data Endpoints ---

@router.get("/categories", response_model=List[ExerciseCategoryResponse])
def get_exercise_categories(db: Session = Depends(get_db)):
    """Get all exercise categories for filtering UI."""
    return db.query(ExerciseCategory).order_by(ExerciseCategory.name).all()


@router.get("/muscle-groups", response_model=List[MuscleGroupResponse])
def get_muscle_groups(
    group_type: Optional[str] = Query(None, description="Filter by group type: primary, secondary, stabilizer"),
    db: Session = Depends(get_db)
):
    """Get muscle groups, optionally filtered by type."""
    query = db.query(MuscleGroup).options(joinedload(MuscleGroup.children))
    
    if group_type:
        query = query.filter(MuscleGroup.group_type == group_type)
    
    return query.order_by(MuscleGroup.name).all()


@router.get("/equipment", response_model=List[EquipmentTypeResponse])
def get_equipment_types(
    category: Optional[str] = Query(None, description="Filter by equipment category"),
    db: Session = Depends(get_db)
):
    """Get equipment types, optionally filtered by category."""
    query = db.query(EquipmentType)
    
    if category:
        query = query.filter(EquipmentType.category == category)
    
    return query.order_by(EquipmentType.name).all()


# --- Exercise Analytics ---

@router.get("/popular", response_model=List[ExerciseLibraryResponse])
def get_popular_exercises(
    limit: int = Query(10, ge=1, le=50, description="Number of exercises to return"),
    category: Optional[str] = Query(None, description="Filter by category"),
    db: Session = Depends(get_db)
):
    """Get most popular exercises, optionally filtered by category."""
    
    query = db.query(ExerciseLibrary).options(
        joinedload(ExerciseLibrary.category),
        joinedload(ExerciseLibrary.muscle_groups).joinedload(ExerciseMuscleGroup.muscle_group),
        joinedload(ExerciseLibrary.equipment).joinedload(ExerciseEquipment.equipment)
    ).filter(ExerciseLibrary.is_active == True)
    
    if category:
        query = query.join(ExerciseCategory).filter(ExerciseCategory.name == category)
    
    return query.order_by(ExerciseLibrary.popularity_score.desc()).limit(limit).all()


@router.get("/similar/{exercise_id}", response_model=List[ExerciseLibraryResponse])
def get_similar_exercises(
    exercise_id: uuid.UUID,
    limit: int = Query(5, ge=1, le=20, description="Number of similar exercises to return"),
    db: Session = Depends(get_db)
):
    """Get exercises similar to the specified exercise based on muscle groups and equipment."""
    
    # Get the base exercise
    base_exercise = db.query(ExerciseLibrary).filter(
        ExerciseLibrary.id == exercise_id,
        ExerciseLibrary.is_active == True
    ).first()
    
    if not base_exercise:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Exercise not found"
        )
    
    # Get muscle groups and equipment for the base exercise
    base_muscle_groups = db.query(ExerciseMuscleGroup.muscle_group_id).filter(
        ExerciseMuscleGroup.exercise_id == exercise_id
    ).subquery()
    
    base_equipment = db.query(ExerciseEquipment.equipment_id).filter(
        ExerciseEquipment.exercise_id == exercise_id
    ).subquery()
    
    # Find similar exercises based on shared muscle groups or equipment
    similar_query = db.query(ExerciseLibrary).options(
        joinedload(ExerciseLibrary.category),
        joinedload(ExerciseLibrary.muscle_groups).joinedload(ExerciseMuscleGroup.muscle_group),
        joinedload(ExerciseLibrary.equipment).joinedload(ExerciseEquipment.equipment)
    ).filter(
        ExerciseLibrary.id != exercise_id,
        ExerciseLibrary.is_active == True,
        or_(
            ExerciseLibrary.id.in_(
                db.query(ExerciseMuscleGroup.exercise_id).filter(
                    ExerciseMuscleGroup.muscle_group_id.in_(base_muscle_groups)
                )
            ),
            ExerciseLibrary.id.in_(
                db.query(ExerciseEquipment.exercise_id).filter(
                    ExerciseEquipment.equipment_id.in_(base_equipment)
                )
            )
        )
    ).order_by(ExerciseLibrary.popularity_score.desc()).limit(limit)
    
    return similar_query.all()


# --- Exercise Variations ---

@router.get("/variations/{exercise_id}", response_model=List[ExerciseLibraryResponse])
def get_exercise_variations(
    exercise_id: uuid.UUID,
    variation_type: Optional[str] = Query(None, description="Filter by variation type: easier, harder, alternative, progression"),
    db: Session = Depends(get_db)
):
    """Get exercise variations for a specific exercise."""
    
    query = db.query(ExerciseLibrary).join(
        ExerciseVariation, ExerciseLibrary.id == ExerciseVariation.variation_exercise_id
    ).options(
        joinedload(ExerciseLibrary.category),
        joinedload(ExerciseLibrary.muscle_groups).joinedload(ExerciseMuscleGroup.muscle_group),
        joinedload(ExerciseLibrary.equipment).joinedload(ExerciseEquipment.equipment)
    ).filter(
        ExerciseVariation.base_exercise_id == exercise_id,
        ExerciseLibrary.is_active == True
    )
    
    if variation_type:
        query = query.filter(ExerciseVariation.variation_type == variation_type)
    
    return query.all()
