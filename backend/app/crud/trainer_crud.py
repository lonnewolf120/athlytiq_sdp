from typing import List, Optional
import uuid
from sqlalchemy.orm import Session
from sqlalchemy import desc
from app.models.trainer_models import TrainerProfile, TrainerAvailability, TrainerSession


def create_or_update_trainer_profile(db: Session, *, user_id: uuid.UUID, profile_in) -> TrainerProfile:
    profile = db.query(TrainerProfile).filter(TrainerProfile.user_id == user_id).first()
    if not profile:
        profile = TrainerProfile(user_id=user_id)
        db.add(profile)
    # assign fields
    for attr in ('bio', 'certifications', 'specialties', 'hourly_rate'):
        if hasattr(profile_in, attr):
            setattr(profile, attr, getattr(profile_in, attr))
    db.commit()
    db.refresh(profile)
    return profile


def get_trainer_profile(db: Session, *, trainer_id: uuid.UUID) -> Optional[TrainerProfile]:
    return db.query(TrainerProfile).filter(TrainerProfile.id == trainer_id).first()


def list_trainers(db: Session, *, skip: int = 0, limit: int = 20) -> List[TrainerProfile]:
    return db.query(TrainerProfile).order_by(desc(TrainerProfile.created_at)).offset(skip).limit(limit).all()


def add_availability(db: Session, *, trainer_id: uuid.UUID, avail_in) -> TrainerAvailability:
    avail = TrainerAvailability(
        trainer_id=trainer_id,
        weekday=avail_in.weekday,
        start_time=avail_in.start_time,
        end_time=avail_in.end_time,
    )
    db.add(avail)
    db.commit()
    db.refresh(avail)
    return avail


def get_availabilities(db: Session, *, trainer_id: uuid.UUID) -> List[TrainerAvailability]:
    return db.query(TrainerAvailability).filter(TrainerAvailability.trainer_id == trainer_id).all()


def create_trainer_session(db: Session, *, trainer_id: uuid.UUID, user_id: uuid.UUID, session_in) -> TrainerSession:
    sess = TrainerSession(
        trainer_id=trainer_id,
        user_id=user_id,
        start_time=session_in.start_time,
        end_time=session_in.end_time,
        notes=session_in.notes,
        price=session_in.price,
    )
    db.add(sess)
    db.commit()
    db.refresh(sess)
    return sess


def get_sessions_for_trainer(db: Session, *, trainer_id: uuid.UUID) -> List[TrainerSession]:
    return db.query(TrainerSession).filter(TrainerSession.trainer_id == trainer_id).order_by(desc(TrainerSession.created_at)).all()


def get_sessions_for_user(db: Session, *, user_id: uuid.UUID) -> List[TrainerSession]:
    return db.query(TrainerSession).filter(TrainerSession.user_id == user_id).order_by(desc(TrainerSession.created_at)).all()


def update_session_status(db: Session, *, session_id: uuid.UUID, status: str):
    sess = db.query(TrainerSession).filter(TrainerSession.id == session_id).first()
    if not sess:
        return None
    sess.status = status
    db.commit()
    db.refresh(sess)
    return sess
