# from fastapi import APIRouter,HTTPException,Depends
# from sqlalchemy.orm import Session
# from uuid import UUID
# from typing import List
# from app.database.base import get_db
# from app.models_db import WorkoutHistory
# from app.schemas.workoutHistory import FetchWorkoutHistory,CreateWorkoutHistory


# router = APIRouter()

# @router.get("/",response_model=List[FetchWorkoutHistory])
# def get_workout_history(user_id: UUID, db: Session = Depends(get_db)):
#     return db.query(WorkoutHistory).filter(WorkoutHistory.user_id==user_id)

# @router.post("/",response_model=FetchWorkoutHistory)
# def create_workout_history(data:CreateWorkoutHistory,db:Session = Depends(get_db)):
#     new_entry = WorkoutHistory(**data.dict())
#     db.add(new_entry)
#     db.commit()
#     db.refresh(new_entry)
#     return new_entry