from fastapi import APIRouter, Depends, HTTPException, Query # Added Query
from sqlalchemy.orm import Session
from app.api.dependencies import get_current_user, get_db # get_db from dependencies
from app.models_db import User, Workout # Import User and Workout from models_db
from typing import List
from uuid import UUID
import uuid

from app.schemas.workout import WorkoutFetch, WorkoutCreate, WorkoutPublic # Added WorkoutPublic
from app.crud import workout_plan_crud # Import the new CRUD file

router = APIRouter()

# This endpoint is for fetching all planned workouts for the current user
@router.get("/history", response_model=List[WorkoutPublic]) # Changed to WorkoutPublic
def get_user_workout_plans(
    *,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
):
    """
    Retrieve the current user's workout plans, paginated.
    """
    if not current_user:
        raise HTTPException(status_code=403, detail="Not authenticated")

    plans = workout_plan_crud.get_workout_plans_by_user(
        db=db, user_id=current_user.id, skip=skip, limit=limit
    )
    return plans

# This endpoint is for creating a new workout plan
@router.post("/", response_model=WorkoutPublic, status_code=201) # Changed to WorkoutPublic
def create_workout_plan( 
    *, # Use keyword-only arguments
    workout_in: WorkoutCreate, # Renamed parameter for clarity
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Create a new workout plan for the current user, including planned exercises.
    """
    if not current_user:
        raise HTTPException(status_code=403, detail="Not authenticated")

    db_workout = workout_plan_crud.create_workout_plan( # Use the new CRUD function
        db=db, user_id=current_user.id, workout_in=workout_in
    )
    
    return db_workout

# This endpoint is for fetching details of a specific workout plan
@router.get("/{workout_id}", response_model=WorkoutPublic) # Changed to WorkoutPublic
def get_workout_plan_details(
    *,
    db: Session = Depends(get_db),
    workout_id: UUID,
    current_user: User = Depends(get_current_user),
):
    """
    Retrieve details for a specific workout plan for the current user.
    """
    if not current_user:
        raise HTTPException(status_code=403, detail="Not authenticated")

    plan_details = workout_plan_crud.get_workout_plan_details(
        db=db, user_id=current_user.id, workout_id=workout_id
    )
    if not plan_details:
        raise HTTPException(status_code=404, detail="Workout plan not found or not authorized")
    return plan_details
