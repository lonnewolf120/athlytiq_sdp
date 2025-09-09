from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, desc
from typing import List, Optional
from datetime import datetime
from uuid import UUID

from app.models.trainer import (
    TrainerProfile,
    TrainerApplication,
    TrainerPost,
    PlanVerification,
    TrainerChat,
    TrainerChatRoom,
)
from app.schemas import trainer as schemas


) -> TrainerApplication:
    """Create a new trainer application"""
    db_application = TrainerApplication(
        user_id=user_id,
        status="pending",
        **application.dict(exclude_unset=True),
    )
    db.add(db_application)
    db.commit()
    db.refresh(db_application)
    return db_application


async def get_trainer_application_status(
    db: Session, user_id: UUID
) -> schemas.TrainerApplicationStatus:
    """Get the status of a trainer application"""
    application = (
        db.query(TrainerApplication)
        .filter(TrainerApplication.user_id == user_id)
        .order_by(desc(TrainerApplication.created_at))
        .first()
    )
    if not application:
        return None
    return application


async def is_trainer(db: Session, user_id: UUID) -> bool:
    """Check if a user is an approved trainer"""
    trainer = (
        db.query(TrainerProfile)
        .filter(
            and_(
                TrainerProfile.user_id == user_id,
                TrainerProfile.status == "approved",
            )
        )
        .first()
    )
    return bool(trainer)


async def create_trainer_post(
    db: Session, post: schemas.TrainerPostCreate, trainer_id: UUID
) -> TrainerPost:
    """Create a new trainer post"""
    db_post = TrainerPost(
        trainer_id=trainer_id,
        **post.dict(exclude_unset=True),
    )
    db.add(db_post)
    db.commit()
    db.refresh(db_post)
    return db_post


async def get_trainer_posts(
    db: Session,
    trainer_id: Optional[UUID] = None,
    category: Optional[str] = None,
    page: int = 1,
    limit: int = 20,
) -> List[TrainerPost]:
    """Get trainer posts with optional filtering"""
    query = db.query(TrainerPost)
    
    if trainer_id:
        query = query.filter(TrainerPost.trainer_id == trainer_id)
    if category:
        query = query.filter(TrainerPost.category == category)
    
    return query.offset((page - 1) * limit).limit(limit).all()


async def create_verification_request(
    db: Session,
    request: schemas.PlanVerificationRequest,
    user_id: UUID,
) -> PlanVerification:
    """Create a new plan verification request"""
    db_request = PlanVerification(
        user_id=user_id,
        status="pending",
        **request.dict(exclude_unset=True),
    )
    db.add(db_request)
    db.commit()
    db.refresh(db_request)
    return db_request


async def get_verification_requests(
    db: Session,
    trainer_id: Optional[UUID] = None,
    status: Optional[str] = None,
) -> List[PlanVerification]:
    """Get plan verification requests"""
    query = db.query(PlanVerification)
    
    if trainer_id:
        query = query.filter(PlanVerification.trainer_id == trainer_id)
    if status:
        query = query.filter(PlanVerification.status == status)
    
    return query.order_by(desc(PlanVerification.created_at)).all()


async def submit_verification_feedback(
    db: Session,
    request_id: UUID,
    feedback: schemas.PlanVerificationResponse,
    trainer_id: UUID,
) -> PlanVerification:
    """Submit feedback for a plan verification request"""
    request = (
        db.query(PlanVerification)
        .filter(PlanVerification.id == request_id)
        .first()
    )
    if not request:
        return None

    request.trainer_id = trainer_id
    request.feedback = feedback.feedback
    request.is_approved = feedback.is_approved
    request.suggestions = feedback.suggestions
    request.completed_at = datetime.utcnow()
    request.status = "completed"

    db.commit()
    db.refresh(request)
    return request


async def get_chat_rooms(db: Session, user_id: UUID) -> List[TrainerChatRoom]:
    """Get chat rooms for a user"""
    return (
        db.query(TrainerChatRoom)
        .filter(
            or_(
                TrainerChatRoom.trainer_id == user_id,
                TrainerChatRoom.user_id == user_id,
            )
        )
        .order_by(desc(TrainerChatRoom.last_message_at))
        .all()
    )


async def get_chat_messages(
    db: Session, room_id: UUID, limit: int = 50
) -> List[TrainerChat]:
    """Get messages from a chat room"""
    return (
        db.query(TrainerChat)
        .filter(TrainerChat.room_id == room_id)
        .order_by(desc(TrainerChat.created_at))
        .limit(limit)
        .all()
    )


async def send_chat_message(db: Session, message: schemas.TrainerChat) -> TrainerChat:
    """Send a message in a chat room"""
    db_message = TrainerChat(**message.dict(exclude_unset=True))
    db.add(db_message)

    # Update chat room's last message
    room = (
        db.query(TrainerChatRoom)
        .filter(TrainerChatRoom.id == message.room_id)
        .first()
    )
    room.last_message = message.message
    room.last_message_at = datetime.utcnow()

    db.commit()
    db.refresh(db_message)
    return db_message


async def can_access_chat_room(db: Session, room_id: UUID, user_id: UUID) -> bool:
    """Check if a user can access a chat room"""
    room = (
        db.query(TrainerChatRoom)
        .filter(
            and_(
                TrainerChatRoom.id == room_id,
                or_(
                    TrainerChatRoom.trainer_id == user_id,
                    TrainerChatRoom.user_id == user_id,
                ),
            )
        )
        .first()
    )
    return bool(room)
