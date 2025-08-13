from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from app.schemas.food_item import FoodItemInDB, FoodItemCreate

class MealBase(BaseModel):
    meal_type: str = Field(..., description="e.g., 'Breakfast', 'Lunch', 'Dinner', 'Snack'")
    logged_at: datetime = Field(default_factory=datetime.now)
    total_calories: float
    total_protein: float
    total_carbs: float
    total_fat: float
    image_url: Optional[str] = None

class MealCreate(MealBase):
    food_items: List[FoodItemCreate] = Field(default_factory=list)

class MealInDB(MealBase):
    id: str # UUID will be string in Pydantic
    user_id: str # UUID will be string in Pydantic
    food_items: List[FoodItemInDB] = Field(default_factory=list)

    class Config:
        from_attributes = True
