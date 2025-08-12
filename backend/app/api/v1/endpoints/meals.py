from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from uuid import UUID

from app.schemas.meal import MealCreate, MealInDB
from app.crud import meal_crud
from app.api.dependencies import get_db, get_current_user
from app.models_db import User

router = APIRouter()

### ALL ROUTES HERE HAVE THE PREFIX: /api/v1/meals

@router.post("/", response_model=MealInDB, status_code=status.HTTP_201_CREATED)
async def create_meal_endpoint(
    meal: MealCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a new meal entry for the current user."""
    return await meal_crud.create_meal(db=db, meal=meal, user_id=current_user.id)

@router.get("/{meal_id}", response_model=MealInDB)
async def read_meal_endpoint(
    meal_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Retrieve a specific meal by its ID."""
    meal = await meal_crud.get_meal(db=db, meal_id=meal_id)
    if not meal:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Meal not found")
    if meal.user_id != str(current_user.id):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to view this meal")
    return meal

@router.get("/users/me/", response_model=List[MealInDB])
async def read_my_meals_endpoint(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Retrieve all meal entries for the current user."""
    meals = await meal_crud.get_meals_by_user(db=db, user_id=current_user.id, skip=skip, limit=limit)
    print("Meals retrieved", meals)
    return meals

@router.put("/{meal_id}", response_model=MealInDB)
async def update_meal_endpoint(
    meal_id: UUID,
    meal_update: MealCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update an existing meal entry."""
    existing_meal = await meal_crud.get_meal(db=db, meal_id=meal_id)
    if not existing_meal:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Meal not found")
    if existing_meal.user_id != str(current_user.id):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to update this meal")
    
    updated_meal = await meal_crud.update_meal(db=db, meal_id=meal_id, meal_update=meal_update)
    if not updated_meal:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to update meal")
    return updated_meal

@router.delete("/{meal_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_meal_endpoint(
    meal_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Delete a meal entry."""
    meal = await meal_crud.get_meal(db=db, meal_id=meal_id)
    if not meal:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Meal not found")
    if meal.user_id != str(current_user.id):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to delete this meal")
    
    success = await meal_crud.delete_meal(db=db, meal_id=meal_id)
    if not success:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to delete meal")
    return {"message": "Meal deleted successfully"}
