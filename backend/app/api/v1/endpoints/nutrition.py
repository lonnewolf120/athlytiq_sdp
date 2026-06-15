from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from typing import Dict, List, Tuple
from datetime import datetime, timedelta
from collections import defaultdict
import httpx

from app.database.base import get_db
from app.models_db import User, FoodLog, HealthLog, DietRecommendation
from app.schemas.nutrition import (
    BarcodeLookupRequest, BarcodeLookupResponse,
    NutritionFavoriteResponse, NutritionSummaryResponse,
    FoodLogCreate, FoodLogResponse,
    HealthLogCreate, HealthLogResponse,
    DietRecommendationResponse
)
from app.api.deps import get_current_active_user # Assuming this is the correct path

router = APIRouter()

_BARCODE_CACHE: Dict[str, Tuple[datetime, BarcodeLookupResponse]] = {}
_BARCODE_CACHE_TTL = timedelta(hours=12)


def _safe_float(value):
    try:
        if value is None:
            return None
        return float(value)
    except (TypeError, ValueError):
        return None


def _macro_bucket():
    return {"calories": 0.0, "protein_g": 0.0, "carbs_g": 0.0, "fat_g": 0.0}


# --- Non-AI Food Database / Barcode / Summary Endpoints ---
@router.post("/barcode-lookup", response_model=BarcodeLookupResponse)
def barcode_lookup(
    payload: BarcodeLookupRequest,
    current_user: User = Depends(get_current_active_user),
):
    """
    Non-AI barcode lookup using Open Food Facts.

    This is the default nutrition lookup path and works without Gemini/LLM tokens.
    Results are normalized to Athlytiq's food log macro fields and cached in-process.
    """
    barcode = payload.barcode.strip()
    cached = _BARCODE_CACHE.get(barcode)
    now = datetime.utcnow()
    if cached and now - cached[0] < _BARCODE_CACHE_TTL:
        return cached[1]

    url = f"https://world.openfoodfacts.org/api/v0/product/{barcode}.json"
    try:
        response = httpx.get(url, timeout=8.0)
        response.raise_for_status()
    except httpx.HTTPError as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Food database lookup failed: {exc}",
        )

    data = response.json()
    if data.get("status") != 1 or not data.get("product"):
        result = BarcodeLookupResponse(barcode=barcode, found=False, raw_product_url=url)
        _BARCODE_CACHE[barcode] = (now, result)
        return result

    product = data["product"]
    nutriments = product.get("nutriments") or {}
    result = BarcodeLookupResponse(
        barcode=barcode,
        found=True,
        name=product.get("product_name") or product.get("generic_name") or "Unknown Product",
        brand=product.get("brands"),
        calories=_safe_float(nutriments.get("energy-kcal_100g")),
        protein_g=_safe_float(nutriments.get("proteins_100g")),
        carbs_g=_safe_float(nutriments.get("carbohydrates_100g")),
        fat_g=_safe_float(nutriments.get("fat_100g")),
        serving_size=product.get("serving_size") or "100g",
        raw_product_url=url,
    )
    _BARCODE_CACHE[barcode] = (now, result)
    return result


@router.get("/favorites", response_model=List[NutritionFavoriteResponse])
def read_nutrition_favorites(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
    limit: int = Query(20, ge=1, le=100),
):
    """
    Derived non-AI favorites from the user's most frequent food logs.

    No new table/migration required. This powers quick-add suggestions even when AI fails.
    """
    logs = (
        db.query(FoodLog)
        .filter(FoodLog.user_id == current_user.id)
        .order_by(FoodLog.log_date.desc())
        .limit(500)
        .all()
    )

    grouped: Dict[str, Dict] = {}
    for log in logs:
        key = (log.food_name or "").strip().lower()
        if not key:
            continue
        item = grouped.setdefault(
            key,
            {
                "food_name": log.food_name,
                "count": 0,
                "calories": 0.0,
                "protein_g": 0.0,
                "carbs_g": 0.0,
                "fat_g": 0.0,
                "most_recent_meal_type": log.meal_type,
                "most_recent_serving_size": log.serving_size,
            },
        )
        item["count"] += 1
        item["calories"] += float(log.calories or 0)
        item["protein_g"] += float(log.protein_g or 0)
        item["carbs_g"] += float(log.carbs_g or 0)
        item["fat_g"] += float(log.fat_g or 0)

    favorites = sorted(grouped.values(), key=lambda item: item["count"], reverse=True)[:limit]
    return [
        NutritionFavoriteResponse(
            food_name=item["food_name"],
            count=item["count"],
            avg_calories=round(item["calories"] / item["count"], 2),
            avg_protein_g=round(item["protein_g"] / item["count"], 2),
            avg_carbs_g=round(item["carbs_g"] / item["count"], 2),
            avg_fat_g=round(item["fat_g"] / item["count"], 2),
            most_recent_meal_type=item["most_recent_meal_type"],
            most_recent_serving_size=item["most_recent_serving_size"],
        )
        for item in favorites
    ]


@router.get("/history-summary", response_model=NutritionSummaryResponse)
def read_nutrition_history_summary(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
    days: int = Query(7, ge=1, le=365),
):
    """Non-AI calorie/macro summaries from existing FoodLog rows."""
    since = datetime.utcnow() - timedelta(days=days)
    logs = (
        db.query(FoodLog)
        .filter(FoodLog.user_id == current_user.id, FoodLog.log_date >= since)
        .order_by(FoodLog.log_date.asc())
        .all()
    )

    totals = _macro_bucket()
    daily = defaultdict(_macro_bucket)
    by_meal_type = defaultdict(_macro_bucket)

    for log in logs:
        values = {
            "calories": float(log.calories or 0),
            "protein_g": float(log.protein_g or 0),
            "carbs_g": float(log.carbs_g or 0),
            "fat_g": float(log.fat_g or 0),
        }
        date_key = (log.log_date or log.created_at or datetime.utcnow()).date().isoformat()
        meal_key = (log.meal_type or "unspecified").lower()
        for key, value in values.items():
            totals[key] += value
            daily[date_key][key] += value
            by_meal_type[meal_key][key] += value

    return NutritionSummaryResponse(
        days=days,
        totals={key: round(value, 2) for key, value in totals.items()},
        daily=[{"date": date, **{k: round(v, 2) for k, v in values.items()}} for date, values in sorted(daily.items())],
        by_meal_type={meal: {k: round(v, 2) for k, v in values.items()} for meal, values in by_meal_type.items()},
    )

# --- FoodLog Endpoints ---
@router.post("/food_logs", response_model=FoodLogResponse, status_code=status.HTTP_201_CREATED)
def create_food_log(
    food_log: FoodLogCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_food_log = FoodLog(
        **food_log.dict(),
        user_id=current_user.id,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    db.add(db_food_log)
    db.commit()
    db.refresh(db_food_log)
    return db_food_log

@router.get("/food_logs", response_model=List[FoodLogResponse])
def read_food_logs(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
    skip: int = 0,
    limit: int = 100
):
    food_logs = db.query(FoodLog).filter(FoodLog.user_id == current_user.id).offset(skip).limit(limit).all()
    return food_logs

@router.get("/food_logs/{food_log_id}", response_model=FoodLogResponse)
def read_food_log(
    food_log_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_food_log = db.query(FoodLog).filter(
        FoodLog.id == food_log_id,
        FoodLog.user_id == current_user.id
    ).first()
    if db_food_log is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Food log not found")
    return db_food_log

@router.put("/food_logs/{food_log_id}", response_model=FoodLogResponse)
def update_food_log(
    food_log_id: str,
    food_log: FoodLogCreate, # Using Create schema for update for simplicity, could be a dedicated Update schema
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_food_log = db.query(FoodLog).filter(
        FoodLog.id == food_log_id,
        FoodLog.user_id == current_user.id
    ).first()
    if db_food_log is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Food log not found")

    for key, value in food_log.dict(exclude_unset=True).items():
        setattr(db_food_log, key, value)
    db_food_log.updated_at = datetime.utcnow() # Manually update timestamp
    db.add(db_food_log)
    db.commit()
    db.refresh(db_food_log)
    return db_food_log

@router.delete("/food_logs/{food_log_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_food_log(
    food_log_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_food_log = db.query(FoodLog).filter(
        FoodLog.id == food_log_id,
        FoodLog.user_id == current_user.id
    ).first()
    if db_food_log is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Food log not found")
    db.delete(db_food_log)
    db.commit()
    return {"message": "Food log deleted successfully"}

# --- HealthLog Endpoints ---
@router.post("/health_logs", response_model=HealthLogResponse, status_code=status.HTTP_201_CREATED)
def create_health_log(
    health_log: HealthLogCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_health_log = HealthLog(
        **health_log.dict(),
        user_id=current_user.id,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    db.add(db_health_log)
    db.commit()
    db.refresh(db_health_log)
    return db_health_log

@router.get("/health_logs", response_model=List[HealthLogResponse])
def read_health_logs(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
    skip: int = 0,
    limit: int = 100
):
    health_logs = db.query(HealthLog).filter(HealthLog.user_id == current_user.id).offset(skip).limit(limit).all()
    return health_logs

@router.get("/health_logs/{health_log_id}", response_model=HealthLogResponse)
def read_health_log(
    health_log_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_health_log = db.query(HealthLog).filter(
        HealthLog.id == health_log_id,
        HealthLog.user_id == current_user.id
    ).first()
    if db_health_log is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Health log not found")
    return db_health_log

@router.put("/health_logs/{health_log_id}", response_model=HealthLogResponse)
def update_health_log(
    health_log_id: str,
    health_log: HealthLogCreate, # Using Create schema for update for simplicity
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_health_log = db.query(HealthLog).filter(
        HealthLog.id == health_log_id,
        HealthLog.user_id == current_user.id
    ).first()
    if db_health_log is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Health log not found")

    for key, value in health_log.dict(exclude_unset=True).items():
        setattr(db_health_log, key, value)
    db_health_log.updated_at = datetime.utcnow() # Manually update timestamp
    db.add(db_health_log)
    db.commit()
    db.refresh(db_health_log)
    return db_health_log

@router.delete("/health_logs/{health_log_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_health_log(
    health_log_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_health_log = db.query(HealthLog).filter(
        HealthLog.id == health_log_id,
        HealthLog.user_id == current_user.id
    ).first()
    if db_health_log is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Health log not found")
    db.delete(db_health_log)
    db.commit()
    return {"message": "Health log deleted successfully"}

# --- DietRecommendation Endpoints (Read-only as they are AI-generated) ---
@router.get("/diet_recommendations", response_model=List[DietRecommendationResponse])
def read_diet_recommendations(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
    skip: int = 0,
    limit: int = 100
):
    diet_recommendations = db.query(DietRecommendation).filter(
        DietRecommendation.user_id == current_user.id
    ).offset(skip).limit(limit).all()
    return diet_recommendations

@router.get("/diet_recommendations/{recommendation_id}", response_model=DietRecommendationResponse)
def read_diet_recommendation(
    recommendation_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_recommendation = db.query(DietRecommendation).filter(
        DietRecommendation.id == recommendation_id,
        DietRecommendation.user_id == current_user.id
    ).first()
    if db_recommendation is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Diet recommendation not found")
    return db_recommendation
