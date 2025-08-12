from uuid import UUID
from typing import List, Optional
from datetime import datetime

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, insert, update, delete
from sqlalchemy.orm import selectinload

from app.models_db import Meal, FoodItem
from app.schemas.meal import MealCreate, MealInDB
from app.schemas.food_item import FoodItemCreate, FoodItemInDB

async def create_meal(db: AsyncSession, meal: MealCreate, user_id: UUID) -> MealInDB:
    """Creates a new meal entry and associated food items."""
    new_meal_data = meal.model_dump(exclude_unset=True, exclude={'food_items'})
    new_meal_data['user_id'] = user_id
    
    stmt = insert(Meal).values(**new_meal_data).returning(Meal)
    result = await db.execute(stmt)
    new_meal_db = result.scalar_one()

    food_items_in_db = []
    for food_item_create in meal.food_items:
        new_food_item_data = food_item_create.model_dump(exclude_unset=True)
        new_food_item_data['meal_id'] = new_meal_db.id
        food_item_stmt = insert(FoodItem).values(**new_food_item_data).returning(FoodItem)
        food_item_result = await db.execute(food_item_stmt)
        food_items_in_db.append(food_item_result.scalar_one())
    
    await db.commit()
    await db.refresh(new_meal_db, attribute_names=['food_items'])
    
    return MealInDB.model_validate(new_meal_db)

async def get_meal(db: AsyncSession, meal_id: UUID) -> Optional[MealInDB]:
    """Retrieves a single meal by its ID, including its food items."""
    result = await db.execute(
        select(Meal)
        .options(selectinload(Meal.food_items))
        .where(Meal.id == meal_id)
    )
    meal_db = result.scalar_one_or_none()
    if meal_db:
        return MealInDB.model_validate(meal_db)
    return None

async def get_meals_by_user(
    db: AsyncSession, user_id: UUID, skip: int = 0, limit: int = 100
) -> List[MealInDB]:
    """Retrieves a list of meals for a specific user, including their food items."""
    result = db.execute(
        select(Meal)
        .options(selectinload(Meal.food_items))
        .where(Meal.user_id == user_id)
        .offset(skip)
        .limit(limit)
        .order_by(Meal.logged_at.desc())
    )
    meals_db = result.scalars().all()
    print("Meals retrieved:", meals_db)
    return [MealInDB.model_validate(meal) for meal in meals_db]

async def update_meal(
    db: AsyncSession, meal_id: UUID, meal_update: MealCreate
) -> Optional[MealInDB]:
    """Updates an existing meal and its associated food items.
    This implementation deletes existing food items and recreates them.
    A more robust solution might involve diffing and updating.
    """
    # First, get the existing meal to ensure it exists
    existing_meal_result = await db.execute(
        select(Meal).where(Meal.id == meal_id)
    )
    existing_meal = existing_meal_result.scalar_one_or_none()

    if not existing_meal:
        return None

    # Update meal details
    update_data = meal_update.model_dump(exclude_unset=True, exclude={'food_items'})
    stmt = update(Meal).where(Meal.id == meal_id).values(**update_data).returning(Meal)
    result = await db.execute(stmt)
    updated_meal_db = result.scalar_one()

    # Delete existing food items for this meal
    await db.execute(delete(FoodItem).where(FoodItem.meal_id == meal_id))

    # Recreate food items
    food_items_in_db = []
    for food_item_create in meal_update.food_items:
        new_food_item_data = food_item_create.model_dump(exclude_unset=True)
        new_food_item_data['meal_id'] = updated_meal_db.id
        food_item_stmt = insert(FoodItem).values(**new_food_item_data).returning(FoodItem)
        food_item_result = await db.execute(food_item_stmt)
        food_items_in_db.append(food_item_result.scalar_one())

    await db.commit()
    await db.refresh(updated_meal_db, attribute_names=['food_items'])
    return MealInDB.model_validate(updated_meal_db)

async def delete_meal(db: AsyncSession, meal_id: UUID) -> bool:
    """Deletes a meal and its associated food items."""
    # Food items will be cascade deleted due to ON DELETE CASCADE
    stmt = delete(Meal).where(Meal.id == meal_id)
    result = await db.execute(stmt)
    await db.commit()
    return result.rowcount > 0
