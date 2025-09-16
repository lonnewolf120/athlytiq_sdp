from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID

from app.database.connection import get_db
from app.models_db import WorkoutTemplate, WorkoutTemplateExercise, User, Workout, PlannedExercise
from app.crud.auth import get_current_user
from app.schemas.workout_templates import (
    WorkoutTemplateResponse, 
    WorkoutTemplateListResponse, 
    WorkoutTemplateDetailResponse,
    TemplateFilters,
    ImportTemplateRequest,
    ImportTemplateResponse
)

router = APIRouter()


@router.get("/", response_model=WorkoutTemplateListResponse)
async def get_workout_templates(
    author: Optional[str] = Query(None, description="Filter by author (e.g., 'Ronnie Coleman')"),
    difficulty_level: Optional[str] = Query(None, description="Filter by difficulty level"),
    muscle_groups: Optional[str] = Query(None, description="Filter by muscle groups (comma-separated)"),
    tags: Optional[str] = Query(None, description="Filter by tags (comma-separated)"),
    search: Optional[str] = Query(None, description="Search in template names and descriptions"),
    skip: int = Query(0, ge=0, description="Number of templates to skip"),
    limit: int = Query(20, ge=1, le=100, description="Number of templates to return"),
    db: Session = Depends(get_db)
):
    """
    Get all workout templates with optional filters.
    
    - **author**: Filter by specific author
    - **difficulty_level**: Filter by difficulty (Beginner, Intermediate, Advanced)
    - **muscle_groups**: Filter by primary muscle groups (comma-separated)
    - **tags**: Filter by tags (comma-separated)
    - **search**: Search in template names and descriptions
    - **skip**: Pagination offset
    - **limit**: Number of results per page
    """
    
    query = db.query(WorkoutTemplate).filter(WorkoutTemplate.is_active == True)
    
    # Apply filters
    if author:
        query = query.filter(WorkoutTemplate.author.icontains(author))
    
    if difficulty_level:
        query = query.filter(WorkoutTemplate.difficulty_level == difficulty_level)
    
    if muscle_groups:
        muscle_group_list = [mg.strip() for mg in muscle_groups.split(',')]
        for mg in muscle_group_list:
            query = query.filter(WorkoutTemplate.primary_muscle_groups.contains([mg]))
    
    if tags:
        tag_list = [tag.strip() for tag in tags.split(',')]
        for tag in tag_list:
            query = query.filter(WorkoutTemplate.tags.contains([tag]))
    
    if search:
        query = query.filter(
            WorkoutTemplate.name.icontains(search) | 
            WorkoutTemplate.description.icontains(search)
        )
    
    # Get total count for pagination
    total_count = query.count()
    
    # Apply pagination and ordering
    templates = query.order_by(WorkoutTemplate.created_at.desc()).offset(skip).limit(limit).all()
    
    return WorkoutTemplateListResponse(
        templates=[WorkoutTemplateResponse.from_orm(template) for template in templates],
        total_count=total_count,
        page=skip // limit + 1,
        page_size=limit,
        total_pages=(total_count + limit - 1) // limit
    )


@router.get("/{template_id}", response_model=WorkoutTemplateDetailResponse)
async def get_workout_template(
    template_id: UUID,
    db: Session = Depends(get_db)
):
    """
    Get a specific workout template with all its exercises.
    
    - **template_id**: UUID of the workout template
    """
    
    template = db.query(WorkoutTemplate).filter(
        WorkoutTemplate.id == template_id,
        WorkoutTemplate.is_active == True
    ).first()
    
    if not template:
        raise HTTPException(status_code=404, detail="Workout template not found")
    
    return WorkoutTemplateDetailResponse.from_orm(template)


@router.post("/{template_id}/import", response_model=ImportTemplateResponse)
async def import_workout_template(
    template_id: UUID,
    import_request: ImportTemplateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Import a workout template to user's personal workout plans.
    
    - **template_id**: UUID of the template to import
    - **import_request**: Contains optional custom name for the imported workout
    """
    
    # Get the template with exercises
    template = db.query(WorkoutTemplate).filter(
        WorkoutTemplate.id == template_id,
        WorkoutTemplate.is_active == True
    ).first()
    
    if not template:
        raise HTTPException(status_code=404, detail="Workout template not found")
    
    # Create new personal workout from template
    workout_name = import_request.custom_name if import_request.custom_name else f"{template.name} (Imported)"
    
    new_workout = Workout(
        user_id=current_user.id,
        name=workout_name,
        icon_url=template.icon_url,
        description=f"Imported from {template.author}'s template: {template.name}",
        type=f"{template.difficulty_level} - {template.author}",
        equipment_selected=', '.join(template.equipment_required) if template.equipment_required else None
    )
    
    db.add(new_workout)
    db.flush()  # To get the new workout ID
    
    # Import exercises from template
    for template_exercise in template.exercises:
        planned_exercise = PlannedExercise(
            workout_id=new_workout.id,
            exercise_id=template_exercise.exercise_id,
            exercise_name=template_exercise.exercise_name,
            exercise_equipments=template_exercise.exercise_equipments,
            exercise_gif_url=template_exercise.exercise_gif_url,
            type="weight_reps",  # Default type
            planned_sets=template_exercise.default_sets,
            planned_reps=int(template_exercise.default_reps.split('-')[0]) if template_exercise.default_reps.replace('-', '').replace(' ', '').isdigit() else 10,  # Parse reps or default to 10
            planned_weight=template_exercise.default_weight
        )
        db.add(planned_exercise)
    
    db.commit()
    
    return ImportTemplateResponse(
        success=True,
        message=f"Successfully imported '{template.name}' by {template.author} to your workout plans",
        imported_workout_id=str(new_workout.id),
        imported_workout_name=workout_name
    )


@router.get("/authors/list")
async def get_template_authors(db: Session = Depends(get_db)):
    """
    Get list of all available authors with template counts.
    """
    
    authors = db.query(
        WorkoutTemplate.author,
        db.func.count(WorkoutTemplate.id).label('template_count')
    ).filter(
        WorkoutTemplate.is_active == True
    ).group_by(
        WorkoutTemplate.author
    ).order_by(
        WorkoutTemplate.author
    ).all()
    
    return {
        "authors": [
            {
                "name": author.author,
                "template_count": author.template_count
            }
            for author in authors
        ]
    }


@router.get("/tags/list")
async def get_template_tags(db: Session = Depends(get_db)):
    """
    Get list of all available tags.
    """
    
    # This is a simplified version - in a real implementation you'd want to
    # aggregate all unique tags from the JSONB arrays
    templates = db.query(WorkoutTemplate.tags).filter(WorkoutTemplate.is_active == True).all()
    
    all_tags = set()
    for template in templates:
        if template.tags:
            all_tags.update(template.tags)
    
    return {
        "tags": sorted(list(all_tags))
    }


@router.get("/muscle-groups/list")
async def get_template_muscle_groups(db: Session = Depends(get_db)):
    """
    Get list of all available muscle groups.
    """
    
    templates = db.query(WorkoutTemplate.primary_muscle_groups).filter(WorkoutTemplate.is_active == True).all()
    
    all_muscle_groups = set()
    for template in templates:
        if template.primary_muscle_groups:
            all_muscle_groups.update(template.primary_muscle_groups)
    
    return {
        "muscle_groups": sorted(list(all_muscle_groups))
    }