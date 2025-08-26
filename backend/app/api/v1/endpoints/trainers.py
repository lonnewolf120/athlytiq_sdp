from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from sqlalchemy.orm import Session
from uuid import UUID

from app.api.dependencies import get_db, get_current_user
from app.schemas.trainer import (
    TrainerProfileCreate,
    TrainerProfilePublic,
    TrainerAvailabilityCreate,
    TrainerAvailabilityPublic,
    TrainerSessionCreate,
    TrainerSessionPublic,
)
from app.crud import trainer_crud

router = APIRouter(prefix="/trainers", tags=["trainers"])


@router.post("/", response_model=TrainerProfilePublic)
def create_or_update_profile(
    profile_in: TrainerProfileCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    user = current_user
    if not user:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authenticated")
    profile = trainer_crud.create_or_update_trainer_profile(db=db, user_id=user.id, profile_in=profile_in)
    return profile


@router.get("/", response_model=List[TrainerProfilePublic])
def list_trainers(skip: int = 0, limit: int = 20, db: Session = Depends(get_db)):
    return trainer_crud.list_trainers(db=db, skip=skip, limit=limit)


@router.get("/{trainer_id}", response_model=TrainerProfilePublic)
def get_trainer(trainer_id: UUID, db: Session = Depends(get_db)):
    profile = trainer_crud.get_trainer_profile(db=db, trainer_id=trainer_id)
    if not profile:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trainer not found")
    return profile


@router.post("/{trainer_id}/availabilities", response_model=TrainerAvailabilityPublic)
def add_availability(trainer_id: UUID, avail_in: TrainerAvailabilityCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    # only allow trainer owner to add availabilities
    profile = trainer_crud.get_trainer_profile(db=db, trainer_id=trainer_id)
    if not profile:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trainer not found")
    if profile.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to modify this trainer")
    avail = trainer_crud.add_availability(db=db, trainer_id=trainer_id, avail_in=avail_in)
    return avail


@router.get("/{trainer_id}/availabilities", response_model=List[TrainerAvailabilityPublic])
def get_availabilities(trainer_id: UUID, db: Session = Depends(get_db)):
    return trainer_crud.get_availabilities(db=db, trainer_id=trainer_id)


@router.post("/{trainer_id}/sessions", response_model=TrainerSessionPublic, status_code=status.HTTP_201_CREATED)
def book_session(trainer_id: UUID, session_in: TrainerSessionCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    # create a booking for the current user
    if not current_user:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authenticated")
    trainer = trainer_crud.get_trainer_profile(db=db, trainer_id=trainer_id)
    if not trainer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trainer not found")
    sess = trainer_crud.create_trainer_session(db=db, trainer_id=trainer_id, user_id=current_user.id, session_in=session_in)
    return sess


@router.get("/sessions/me", response_model=List[TrainerSessionPublic])
def my_sessions(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    if not current_user:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authenticated")
    return trainer_crud.get_sessions_for_user(db=db, user_id=current_user.id)


@router.put("/sessions/{session_id}/status", response_model=TrainerSessionPublic)
def update_session_status(session_id: UUID, status: str, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    sess = trainer_crud.update_session_status(db=db, session_id=session_id, status=status)
    if not sess:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Session not found")
    return sess
