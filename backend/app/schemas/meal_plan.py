from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
import uuid

# Meal Schemas
class MealBase(BaseModel):
    name: str
    ingredients: List[str]
    instructions: str
    calories: Optional[int] = None
    macronutrients: Optional[Dict[str, Any]] = None # e.g., {'protein': 30, 'carbs': 40, 'fat': 15}

class MealCreate(MealBase):
    pass

class MealPublic(MealBase):
    # No ID for individual meals, as they are part of the meal plan's JSONB
    pass

# MealPlan Schemas
class MealPlanBase(BaseModel):
    name: str
    description: Optional[str] = None
    user_goals: Optional[str] = None
    linked_workout_plan_id: Optional[uuid.UUID] = None
    meals: List[MealCreate] # Use MealCreate for nested meals

class MealPlanCreate(MealPlanBase):
    pass

class MealPlanInDBBase(MealPlanBase):
    id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class MealPlanPublic(MealPlanInDBBase):
    # This will be the response model for GET requests
    # The 'meals' field is already included from MealPlanBase
    pass

class MealPlanFetch(MealPlanInDBBase):
    # This might be used for internal fetching if different from public
    pass
