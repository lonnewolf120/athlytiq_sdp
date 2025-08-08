from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.models_db import Exercise as ExerciseModel
from app.schemas.exercise import ExerciseResult
from app.database.base import get_db
from typing import List, Optional


router = APIRouter()


@router.get("/", response_model=List[ExerciseResult])
def get_exercises(
    db: Session = Depends(get_db),
    name: Optional[str] = Query(None, description="Search exercise by name"),
    body_part: Optional[str] = Query(None, description="Search exercise by body part"),
):
    query = db.query(ExerciseModel)
    
    if name:
         query = query.filter(ExerciseModel.name.ilike(f"%{name}%"))
    if body_part:
        query = query.filter(ExerciseModel.bodyParts.ilike(f"%{body_part}"))
    
    return query.all()
