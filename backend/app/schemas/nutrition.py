from pydantic import BaseModel, Field
from typing import Optional, List, Dict
from datetime import datetime
from uuid import UUID


# --- Non-AI food database / barcode schemas ---
class BarcodeLookupRequest(BaseModel):
    barcode: str = Field(..., min_length=3, max_length=64)


class BarcodeLookupResponse(BaseModel):
    barcode: str
    found: bool
    source: str = "open_food_facts"
    name: Optional[str] = None
    brand: Optional[str] = None
    calories: Optional[float] = None
    protein_g: Optional[float] = None
    carbs_g: Optional[float] = None
    fat_g: Optional[float] = None
    serving_size: Optional[str] = None
    unit: str = "100g"
    raw_product_url: Optional[str] = None


class NutritionFavoriteResponse(BaseModel):
    food_name: str
    count: int
    avg_calories: Optional[float] = None
    avg_protein_g: Optional[float] = None
    avg_carbs_g: Optional[float] = None
    avg_fat_g: Optional[float] = None
    most_recent_meal_type: Optional[str] = None
    most_recent_serving_size: Optional[str] = None


class NutritionSummaryResponse(BaseModel):
    days: int
    totals: Dict[str, float]
    daily: List[Dict[str, float | str]]
    by_meal_type: Dict[str, Dict[str, float]]

# --- FoodLog Schemas ---
class FoodLogBase(BaseModel):
    food_name: str
    external_food_id: Optional[str] = None
    calories: Optional[float] = None
    protein_g: Optional[float] = None
    carbs_g: Optional[float] = None
    fat_g: Optional[float] = None
    serving_size: Optional[str] = None
    meal_type: Optional[str] = None # e.g., 'breakfast', 'lunch', 'dinner', 'snack'
    log_date: datetime # Date the log pertains to
    notes: Optional[str] = None
    

class FoodLogCreate(FoodLogBase):
    # user_id will be derived from authenticated user
    pass

class FoodLogResponse(FoodLogBase):
    id: UUID
    user_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# --- HealthLog Schemas ---
class HealthLogBase(BaseModel):
    log_type: str # e.g., 'weight', 'sleep_hours', 'water_intake_ml'
    value: float
    log_date: datetime # Date the log pertains to

class HealthLogCreate(HealthLogBase):
    # user_id will be derived from authenticated user
    pass

class HealthLogResponse(HealthLogBase):
    id: UUID
    user_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# --- DietRecommendation Schemas ---
class DietRecommendationBase(BaseModel):
    recommendation: str
    generated_at: datetime # When the AI generated this

class DietRecommendationCreate(DietRecommendationBase):
    # user_id will be derived from authenticated user
    pass

class DietRecommendationResponse(DietRecommendationBase):
    id: UUID
    user_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
