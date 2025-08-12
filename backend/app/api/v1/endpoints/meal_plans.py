import uuid
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.api import dependencies
from app.models_db import User # Import User model for type hinting current_user
from app.crud import meal_crud
from app.schemas import meal_plan as meal_plan_schemas
from app.api.dependencies import get_current_user # Import from new deps.py


router = APIRouter()

@router.post("/", response_model=meal_plan_schemas.MealPlanPublic, status_code=201)
def create_meal_plan(
    *,
    db: Session = Depends(dependencies.get_db),
    meal_plan_in: meal_plan_schemas.MealPlanCreate,
    current_user: User = Depends(get_current_user),
):
    """
    Create a new meal plan for the current user.
    """
    if not current_user:
        raise HTTPException(status_code=403, detail="Not authenticated")

    db_meal_plan = meal_crud.create_meal_plan(
        db=db, user_id=current_user.id, meal_plan_in=meal_plan_in
    )
    return db_meal_plan

@router.get("/history", response_model=List[meal_plan_schemas.MealPlanPublic])
def get_user_meal_plan_history(
    *,
    db: Session = Depends(dependencies.get_db),
    current_user: User = Depends(get_current_user),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
):
    """
    Retrieve the current user's meal plan history, paginated.
    """
    if not current_user:
        raise HTTPException(status_code=403, detail="Not authenticated")

    history = meal_crud.get_meal_plans_by_user(
        db=db, user_id=current_user.id, skip=skip, limit=limit
    )
    return history

@router.get("/{meal_plan_id}", response_model=meal_plan_schemas.MealPlanPublic)
def get_meal_plan_details(
    *,
    db: Session = Depends(dependencies.get_db),
    meal_plan_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
):
    """
    Retrieve details for a specific meal plan for the current user.
    """
    if not current_user:
        raise HTTPException(status_code=403, detail="Not authenticated")

    meal_plan_details = meal_crud.get_meal_plan_details(
        db=db, user_id=current_user.id, meal_plan_id=meal_plan_id
    )
    if not meal_plan_details:
        raise HTTPException(status_code=404, detail="Meal plan not found or not authorized")
    return meal_plan_details
