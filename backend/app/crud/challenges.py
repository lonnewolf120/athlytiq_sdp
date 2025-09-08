from typing import List, Optional
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import and_, or_, desc, asc, func
from datetime import datetime, timedelta
import uuid

from ..models_db import Challenge, ChallengeParticipant, User
from ..schemas.challenges import (
    ChallengeCreate, ChallengeUpdate, 
    ChallengeParticipantCreate, ChallengeParticipantUpdate,
    ActivityTypeEnum, ChallengeStatusEnum, ParticipantStatusEnum
)





def get_challenge(db: Session, challenge_id: str) -> Optional[Challenge]:
    """Get a single challenge by ID."""
    try:
        challenge_uuid = uuid.UUID(challenge_id)
    except ValueError:
        return None
        
    return db.query(Challenge).options(
        joinedload(Challenge.creator),
        joinedload(Challenge.participants).joinedload(ChallengeParticipant.participant)
    ).filter(Challenge.id == challenge_uuid).first()

def get_challenges(
    db: Session,
    skip: int = 0,
    limit: int = 20,
    activity_type: Optional[ActivityTypeEnum] = None,
    status: Optional[ChallengeStatusEnum] = None,
    is_public: Optional[bool] = None,
    search: Optional[str] = None,
    user_id: Optional[str] = None
) -> List[Challenge]:
    """Get challenges with filtering options."""
    query = db.query(Challenge).options(
        joinedload(Challenge.creator),
        joinedload(Challenge.participants).joinedload(ChallengeParticipant.participant)
    )
    
    
    if activity_type:
        query = query.filter(Challenge.activity_type == activity_type)
    
    if status:
        query = query.filter(Challenge.status == status)
    elif status is None:
        
        query = query.filter(Challenge.status.in_(['active', 'upcoming']))
    
    if is_public is not None:
        query = query.filter(Challenge.is_public == is_public)
    
    if search:
        search_pattern = f"%{search}%"
        query = query.filter(
            or_(
                Challenge.title.ilike(search_pattern),
                Challenge.description.ilike(search_pattern),
                Challenge.brand.ilike(search_pattern)
            )
        )
    
    
    query = query.order_by(asc(Challenge.start_date))
    
    return query.offset(skip).limit(limit).all()

def get_user_challenges(
    db: Session,
    user_id: str,
    skip: int = 0,
    limit: int = 20,
    participant_status: Optional[ParticipantStatusEnum] = None
) -> List[Challenge]:
    """Get challenges that a user has participated in."""
    try:
        user_uuid = uuid.UUID(user_id)
    except ValueError:
        return []
    
    query = db.query(Challenge).options(
        joinedload(Challenge.creator),
        joinedload(Challenge.participants).joinedload(ChallengeParticipant.participant)
    ).join(ChallengeParticipant).filter(ChallengeParticipant.user_id == user_uuid)
    
    if participant_status:
        query = query.filter(ChallengeParticipant.status == participant_status)
    
    return query.order_by(desc(ChallengeParticipant.joined_at)).offset(skip).limit(limit).all()

def get_created_challenges(
    db: Session,
    user_id: str,
    skip: int = 0,
    limit: int = 20
) -> List[Challenge]:
    """Get challenges created by a user."""
    try:
        user_uuid = uuid.UUID(user_id)
    except ValueError:
        return []
    
    return db.query(Challenge).options(
        joinedload(Challenge.creator),
        joinedload(Challenge.participants).joinedload(ChallengeParticipant.participant)
    ).filter(Challenge.created_by == user_uuid).order_by(desc(Challenge.created_at)).offset(skip).limit(limit).all()

def create_challenge(db: Session, challenge: ChallengeCreate, user_id: str) -> Challenge:
    """Create a new challenge."""
    try:
        user_uuid = uuid.UUID(user_id)
    except ValueError:
        raise ValueError("Invalid user ID format")
    
    db_challenge = Challenge(
        title=challenge.title,
        description=challenge.description,
        brand=challenge.brand,
        brand_logo=challenge.brand_logo,
        background_image=challenge.background_image,
        distance=challenge.distance,
        duration=challenge.duration,
        start_date=challenge.start_date,
        end_date=challenge.end_date,
        activity_type=challenge.activity_type,
        brand_color=challenge.brand_color,
        max_participants=challenge.max_participants,
        is_public=challenge.is_public,
        created_by=user_uuid,
        status=_determine_challenge_status(challenge.start_date, challenge.end_date)
    )
    
    db.add(db_challenge)
    db.commit()
    db.refresh(db_challenge)
    return db_challenge

def update_challenge(db: Session, challenge_id: str, challenge_update: ChallengeUpdate, user_id: str) -> Optional[Challenge]:
    """Update a challenge (only by creator)."""
    try:
        challenge_uuid = uuid.UUID(challenge_id)
        user_uuid = uuid.UUID(user_id)
    except ValueError:
        return None
    
    db_challenge = db.query(Challenge).filter(
        and_(Challenge.id == challenge_uuid, Challenge.created_by == user_uuid)
    ).first()
    
    if not db_challenge:
        return None
    
    
    update_data = challenge_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_challenge, field, value)
    
    
    if 'start_date' in update_data or 'end_date' in update_data:
        db_challenge.status = _determine_challenge_status(db_challenge.start_date, db_challenge.end_date)
    
    db.commit()
    db.refresh(db_challenge)
    return db_challenge

def delete_challenge(db: Session, challenge_id: str, user_id: str) -> bool:
    """Delete a challenge (only by creator)."""
    try:
        challenge_uuid = uuid.UUID(challenge_id)
        user_uuid = uuid.UUID(user_id)
    except ValueError:
        return False
    
    db_challenge = db.query(Challenge).filter(
        and_(Challenge.id == challenge_uuid, Challenge.created_by == user_uuid)
    ).first()
    
    if not db_challenge:
        return False
    
    db.delete(db_challenge)
    db.commit()
    return True





def get_challenge_participants(
    db: Session,
    challenge_id: str,
    skip: int = 0,
    limit: int = 50
) -> List[ChallengeParticipant]:
    """Get participants of a challenge."""
    try:
        challenge_uuid = uuid.UUID(challenge_id)
    except ValueError:
        return []
    
    return db.query(ChallengeParticipant).options(
        joinedload(ChallengeParticipant.participant)
    ).filter(ChallengeParticipant.challenge_id == challenge_uuid).filter(
        ChallengeParticipant.status.in_(['joined', 'completed'])
    ).order_by(desc(ChallengeParticipant.progress_percentage), asc(ChallengeParticipant.joined_at)).offset(skip).limit(limit).all()

def join_challenge(db: Session, challenge_id: str, user_id: str) -> Optional[ChallengeParticipant]:
    """Join a challenge."""
    try:
        challenge_uuid = uuid.UUID(challenge_id)
        user_uuid = uuid.UUID(user_id)
    except ValueError:
        return None
    
    
    challenge = db.query(Challenge).filter(Challenge.id == challenge_uuid).first()
    if not challenge or challenge.status not in ['active', 'upcoming']:
        return None
    
    
    existing = db.query(ChallengeParticipant).filter(
        and_(ChallengeParticipant.challenge_id == challenge_uuid, ChallengeParticipant.user_id == user_uuid)
    ).first()
    
    if existing:
        if existing.status == 'left':
            
            existing.status = ParticipantStatusEnum.joined
            existing.joined_at = datetime.utcnow()
            db.commit()
            db.refresh(existing)
            return existing
        else:
            
            return existing
    
    
    if challenge.max_participants:
        current_count = db.query(ChallengeParticipant).filter(
            and_(ChallengeParticipant.challenge_id == challenge_uuid, 
                 ChallengeParticipant.status.in_(['joined', 'completed']))
        ).count()
        
        if current_count >= challenge.max_participants:
            return None
    
    
    db_participant = ChallengeParticipant(
        challenge_id=challenge_uuid,
        user_id=user_uuid,
        status=ParticipantStatusEnum.joined,
        progress=0.0,
        progress_percentage=0.0
    )
    
    db.add(db_participant)
    db.commit()
    db.refresh(db_participant)
    return db_participant

def leave_challenge(db: Session, challenge_id: str, user_id: str) -> bool:
    """Leave a challenge."""
    try:
        challenge_uuid = uuid.UUID(challenge_id)
        user_uuid = uuid.UUID(user_id)
    except ValueError:
        return False
    
    participant = db.query(ChallengeParticipant).filter(
        and_(ChallengeParticipant.challenge_id == challenge_uuid, ChallengeParticipant.user_id == user_uuid)
    ).first()
    
    if not participant or participant.status in ['left', 'completed']:
        return False
    
    participant.status = ParticipantStatusEnum.left
    db.commit()
    return True

def update_participant_progress(
    db: Session,
    challenge_id: str,
    user_id: str,
    progress_update: ChallengeParticipantUpdate
) -> Optional[ChallengeParticipant]:
    """Update participant progress."""
    try:
        challenge_uuid = uuid.UUID(challenge_id)
        user_uuid = uuid.UUID(user_id)
    except ValueError:
        return None
    
    participant = db.query(ChallengeParticipant).filter(
        and_(ChallengeParticipant.challenge_id == challenge_uuid, ChallengeParticipant.user_id == user_uuid)
    ).first()
    
    if not participant or participant.status not in ['joined', 'completed']:
        return None
    
    
    update_data = progress_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        if field == 'status' and value == ParticipantStatusEnum.completed:
            participant.completed_at = datetime.utcnow()
        setattr(participant, field, value)
    
    db.commit()
    db.refresh(participant)
    return participant

def get_user_participation(db: Session, challenge_id: str, user_id: str) -> Optional[ChallengeParticipant]:
    """Get user's participation in a specific challenge."""
    try:
        challenge_uuid = uuid.UUID(challenge_id)
        user_uuid = uuid.UUID(user_id)
    except ValueError:
        return None
    
    return db.query(ChallengeParticipant).filter(
        and_(ChallengeParticipant.challenge_id == challenge_uuid, ChallengeParticipant.user_id == user_uuid)
    ).first()

 



def _determine_challenge_status(start_date: datetime, end_date: datetime) -> ChallengeStatusEnum:
    """Determine challenge status based on dates."""
    now = datetime.utcnow()
    
    if now < start_date:
        return ChallengeStatusEnum.upcoming
    elif start_date <= now <= end_date:
        return ChallengeStatusEnum.active
    else:
        return ChallengeStatusEnum.completed

def get_challenge_stats(db: Session, user_id: Optional[str] = None) -> dict:
    """Get challenge statistics."""
    stats = {}
    
    
    stats['total_challenges'] = db.query(Challenge).filter(Challenge.is_public == True).count()
    stats['active_challenges'] = db.query(Challenge).filter(
        and_(Challenge.status == 'active', Challenge.is_public == True)
    ).count()
    
    
    activity_counts = db.query(
        Challenge.activity_type, func.count(Challenge.id).label('count')
    ).filter(Challenge.is_public == True).group_by(Challenge.activity_type).all()
    
    stats['popular_activity_types'] = [
        {'activity_type': activity_type, 'count': count} 
        for activity_type, count in activity_counts
    ]
    
    
    if user_id:
        try:
            user_uuid = uuid.UUID(user_id)
            stats['user_participations'] = db.query(ChallengeParticipant).filter(
                ChallengeParticipant.user_id == user_uuid
            ).count()
            stats['user_completed'] = db.query(ChallengeParticipant).filter(
                and_(ChallengeParticipant.user_id == user_uuid, ChallengeParticipant.status == 'completed')
            ).count()
        except ValueError:
            stats['user_participations'] = 0
            stats['user_completed'] = 0
    else:
        stats['user_participations'] = 0
        stats['user_completed'] = 0
    
    return stats
