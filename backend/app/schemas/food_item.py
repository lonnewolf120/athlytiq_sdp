from pydantic import BaseModel, Field
from typing import Optional

class FoodItemBase(BaseModel):
    name: str
    calories: float
    protein: float
    carbs: float
    fat: float
    quantity: float = Field(default=1.0)
    unit: str = Field(default="item")

class FoodItemCreate(FoodItemBase):
    pass

class FoodItemInDB(FoodItemBase):
    id: str # UUID will be string in Pydantic
    meal_id: str # UUID will be string in Pydantic

    class Config:
        from_attributes = True
