from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime

from app.database.base import get_db
from app.models_db import User, FoodLog, HealthLog, DietRecommendation
from app.schemas.nutrition import (
    FoodLogCreate, FoodLogResponse,
    HealthLogCreate, HealthLogResponse,
    DietRecommendationResponse
)
from app.api.deps import get_current_active_user # Assuming this is the correct path

router = APIRouter()

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
