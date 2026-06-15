"""
Deterministic Workout Engine API Endpoint

Replaces Gemini-based workout generation with a rule-based engine
that queries the real exercise library database.
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.api import dependencies
from app.models_db import User
from app.schemas.workout_engine import WorkoutEngineRequest, WorkoutEngineResponse
from app.crud.workout_engine import WorkoutEngine
from app.api.dependencies import get_current_user


router = APIRouter()


@router.post(
    "/generate-engine",
    response_model=WorkoutEngineResponse,
    summary="Generate a workout plan using the deterministic engine (no AI)",
    description="""
    Generates a workout plan using ONLY the real exercise library database.
    
    - NO AI/Gemini involved — pure rule-based logic
    - Every exercise_id returned is a REAL UUID from the database
    - Supports: push/pull/legs, upper/lower, full body, balanced splits
    - Progressive overload from user workout history
    - Equipment filtering
    
    If user_id is provided, the engine will check the user's recent workout
    history and apply progressive overload suggestions.
    """,
)
def generate_workout_engine(
    *,
    db: Session = Depends(dependencies.get_db),
    request: WorkoutEngineRequest,
    current_user: User = Depends(get_current_user),
):
    """
    Generate a deterministic workout plan from the real exercise catalog.
    
    This is the replacement for the broken Gemini workout generation.
    Every exercise comes from the database with real exercise_ids.
    """
    if not current_user:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authenticated"
        )

    # Attach user_id for progressive overload
    if request.user_id is None:
        request.user_id = current_user.id

    engine = WorkoutEngine(db)
    result = engine.generate(request)

    return result


@router.get(
    "/split-types",
    summary="Get available workout split types",
)
def get_split_types():
    """Get the list of supported workout split types."""
    from app.schemas.workout_engine import SPLIT_CONFIGS
    
    return {
        "split_types": list(SPLIT_CONFIGS.keys()),
        "descriptions": {
            "balanced": "A balanced full-body workout targeting all major muscle groups",
            "push_pull_legs": "Push (chest/shoulders/triceps), Pull (back/biceps), Legs split",
            "upper_lower": "Upper body one day, lower body the next",
            "full_body": "Full body workout every session",
        }
    }


@router.get(
    "/goal-configs",
    summary="Get available workout goals with their sets/reps configs",
)
def get_goal_configs():
    """Get the list of supported workout goals and their training parameters."""
    from app.schemas.workout_engine import GOAL_CONFIGS
    
    return {
        "goals": list(GOAL_CONFIGS.keys()),
        "configs": GOAL_CONFIGS,
    }