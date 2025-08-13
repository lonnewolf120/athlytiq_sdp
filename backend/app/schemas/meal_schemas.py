from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import uuid

class MealBase(BaseModel):
    name: str
    ingredients: List[str]
    instructions: str
    calories: Optional[int] = None
    macronutrients: Optional[dict] = None # e.g., {'protein': 30, 'carbs': 40, 'fat': 15}

class MealCreate(MealBase):
    pass

class MealPublic(MealBase):
    pass # No additional fields for now, as it's nested within MealPlan

class MealPlanBase(BaseModel):
    name: str
    description: Optional[str] = None
    user_goals: Optional[str] = None
    linked_workout_plan_id: Optional[uuid.UUID] = None
    meals: List[MealCreate] # Use MealCreate for input

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
    meals: List[MealPublic] # Use MealPublic for output
