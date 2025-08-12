import uuid
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.api import dependencies # Assuming this provides get_db
from app.models_db import User # Import User model for type hinting current_user
from app.crud import workout_crud
from app.schemas import workout_schemas
from app.api.dependencies import get_current_user # Import from new deps.py


router = APIRouter()

@router.post("/session", response_model=workout_schemas.CompletedWorkoutPublic, status_code=201)
def create_workout_session(
    *,
    db: Session = Depends(dependencies.get_db), # Assuming dependencies.get_db is correct
    workout_in: workout_schemas.CompletedWorkoutCreate,
    current_user: User = Depends(get_current_user), 
):
    """
    Create a new completed workout session for the current user.
    """
    if not current_user:
        raise HTTPException(status_code=403, detail="Not authenticated")
    print("calculating duration")
    # Basic validation for duration
    calculated_duration = (workout_in.end_time - workout_in.start_time).total_seconds()
    # print("calculating duration")
    print(calculated_duration)
    if abs(calculated_duration - workout_in.duration_seconds) <0: # Allow small discrepancy
         raise HTTPException(
            status_code=400,
            detail="Provided duration_seconds does not match start_time and end_time."
        )
    if workout_in.start_time >= workout_in.end_time:
        raise HTTPException(
            status_code=400,
            detail="Start time must be before end time."
        )
    print("trying to run crud")
    completed_workout = workout_crud.create_completed_workout(
        db=db, user_id=current_user.id, workout_in=workout_in
    )
    print(completed_workout)
    return completed_workout

# Real Workout history (connecting to backend)
@router.get("/history", response_model=List[workout_schemas.CompletedWorkoutPublic])
def get_user_workout_history(
    *,
    db: Session = Depends(dependencies.get_db), # Assuming dependencies.get_db is correct
    current_user: User = Depends(get_current_user), 
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
):
    """
    Retrieve the current user's completed workout history, paginated.
    """
    if not current_user:
        raise HTTPException(status_code=403, detail="Not authenticated")

    history = workout_crud.get_completed_workouts_by_user(
        db=db, user_id=current_user.id, skip=skip, limit=limit
    )
    print("User workout history:")
    # print(history)
    return history


@router.get("/session/{session_id}", response_model=workout_schemas.CompletedWorkoutPublic)
def get_workout_session_details(
    *,
    db: Session = Depends(dependencies.get_db), # Assuming dependencies.get_db is correct
    session_id: uuid.UUID,
    current_user: User = Depends(get_current_user), 
):
    """
    Retrieve details for a specific completed workout session for the current user.
    """
    if not current_user:
        raise HTTPException(status_code=403, detail="Not authenticated")

    session_details = workout_crud.get_completed_workout_details(
        db=db, user_id=current_user.id, session_id=session_id
    )
    if not session_details:
        raise HTTPException(status_code=404, detail="Workout session not found or not authorized")
    return session_details
