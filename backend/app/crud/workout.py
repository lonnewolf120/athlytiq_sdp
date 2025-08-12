from sqlalchemy.orm import Session
from app.models_db import Workout

def get_workouts(db: Session,skip: int = 0,limit: int = 100):
    return db.query(Workout).offset(skip).limit(limit).all()
