from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session

from app.database.base import get_db
from app.api.dependencies import get_current_user
from app.crud import challenges as crud_challenges
from app.schemas.challenges import (
    Challenge, ChallengeCreate, ChallengeUpdate, ChallengeListResponse,
    ChallengeParticipant, ChallengeParticipantsResponse, ChallengeStatsResponse,
    JoinChallengeRequest, LeaveChallengeRequest, UpdateProgressRequest,
    ActivityTypeEnum, ChallengeStatusEnum, ParticipantStatusEnum
)

router = APIRouter()





@router.get("/challenges", response_model=ChallengeListResponse)
async def get_challenges(
    skip: int = Query(0, ge=0, description="Number of challenges to skip"),
    limit: int = Query(20, ge=1, le=100, description="Number of challenges to return"),
    activity_type: Optional[ActivityTypeEnum] = Query(None, description="Filter by activity type"),
    status: Optional[ChallengeStatusEnum] = Query(None, description="Filter by challenge status"),
    search: Optional[str] = Query(None, description="Search in title, description, or brand"),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get challenges with filtering options."""
    challenges = crud_challenges.get_challenges(
        db=db,
        skip=skip,
        limit=limit,
        activity_type=activity_type,
        status=status,
        is_public=True,
        search=search,
        user_id=str(current_user.id)
    )
    
    
    challenge_list = []
    for challenge in challenges:
        
        participation = crud_challenges.get_user_participation(
            db=db,
            challenge_id=str(challenge.id),
            user_id=str(current_user.id)
        )
        
        
        active_participants = len([p for p in challenge.participants if p.status in ['joined', 'completed']])
        
        challenge_dict = {
            "id": str(challenge.id),
            "title": challenge.title,
            "description": challenge.description,
            "brand": challenge.brand,
            "brand_logo": challenge.brand_logo,
            "background_image": challenge.background_image,
            "distance": challenge.distance,
            "duration": challenge.duration,
            "start_date": challenge.start_date,
            "end_date": challenge.end_date,
            "activity_type": challenge.activity_type,
            "status": challenge.status,
            "brand_color": challenge.brand_color,
            "max_participants": challenge.max_participants,
            "is_public": challenge.is_public,
            "created_by": str(challenge.created_by),
            "created_at": challenge.created_at,
            "updated_at": challenge.updated_at,
            "friends_joined": active_participants,
            "is_joined": participation is not None and participation.status in ['joined', 'completed'],
            "creator_username": challenge.creator.username if challenge.creator else None
        }
        challenge_list.append(Challenge(**challenge_dict))
    
    
    total = len(challenges)  
    has_next = len(challenges) == limit
    has_prev = skip > 0
    
    return ChallengeListResponse(
        challenges=challenge_list,
        total=total,
        page=skip // limit + 1,
        size=limit,
        has_next=has_next,
        has_prev=has_prev
    )

@router.get("/challenges/{challenge_id}", response_model=Challenge)
async def get_challenge(
    challenge_id: str,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get a specific challenge by ID."""
    challenge = crud_challenges.get_challenge(db=db, challenge_id=challenge_id)
    if not challenge:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Challenge not found"
        )
    
    
    participation = crud_challenges.get_user_participation(
        db=db,
        challenge_id=challenge_id,
        user_id=str(current_user.id)
    )
    
    
    active_participants = len([p for p in challenge.participants if p.status in ['joined', 'completed']])
    
    challenge_dict = {
        "id": str(challenge.id),
        "title": challenge.title,
        "description": challenge.description,
        "brand": challenge.brand,
        "brand_logo": challenge.brand_logo,
        "background_image": challenge.background_image,
        "distance": challenge.distance,
        "duration": challenge.duration,
        "start_date": challenge.start_date,
        "end_date": challenge.end_date,
        "activity_type": challenge.activity_type,
        "status": challenge.status,
        "brand_color": challenge.brand_color,
        "max_participants": challenge.max_participants,
        "is_public": challenge.is_public,
        "created_by": str(challenge.created_by),
        "created_at": challenge.created_at,
        "updated_at": challenge.updated_at,
        "friends_joined": active_participants,
        "is_joined": participation is not None and participation.status in ['joined', 'completed'],
        "creator_username": challenge.creator.username if challenge.creator else None,
        "participants": [
            {
                "id": str(p.id),
                "challenge_id": str(p.challenge_id),
                "user_id": str(p.user_id),
                "status": p.status,
                "progress": p.progress,
                "progress_percentage": p.progress_percentage,
                "completion_proof_url": p.completion_proof_url,
                "joined_at": p.joined_at,
                "completed_at": p.completed_at,
                "notes": p.notes,
                "username": p.participant.username if p.participant else None
            }
            for p in challenge.participants if p.status in ['joined', 'completed']
        ]
    }
    
    return Challenge(**challenge_dict)

@router.post("/challenges", response_model=Challenge)
async def create_challenge(
    challenge: ChallengeCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Create a new challenge."""
    db_challenge = crud_challenges.create_challenge(
        db=db,
        challenge=challenge,
        user_id=str(current_user.id)
    )
    
    challenge_dict = {
        "id": str(db_challenge.id),
        "title": db_challenge.title,
        "description": db_challenge.description,
        "brand": db_challenge.brand,
        "brand_logo": db_challenge.brand_logo,
        "background_image": db_challenge.background_image,
        "distance": db_challenge.distance,
        "duration": db_challenge.duration,
        "start_date": db_challenge.start_date,
        "end_date": db_challenge.end_date,
        "activity_type": db_challenge.activity_type,
        "status": db_challenge.status,
        "brand_color": db_challenge.brand_color,
        "max_participants": db_challenge.max_participants,
        "is_public": db_challenge.is_public,
        "created_by": str(db_challenge.created_by),
        "created_at": db_challenge.created_at,
        "updated_at": db_challenge.updated_at,
        "friends_joined": 0,
        "is_joined": False,
        "creator_username": current_user.username
    }
    
    return Challenge(**challenge_dict)

@router.put("/challenges/{challenge_id}", response_model=Challenge)
async def update_challenge(
    challenge_id: str,
    challenge_update: ChallengeUpdate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Update a challenge (only by creator)."""
    db_challenge = crud_challenges.update_challenge(
        db=db,
        challenge_id=challenge_id,
        challenge_update=challenge_update,
        user_id=str(current_user.id)
    )
    
    if not db_challenge:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Challenge not found or you don't have permission to update it"
        )
    
    
    active_participants = len([p for p in db_challenge.participants if p.status in ['joined', 'completed']])
    
    challenge_dict = {
        "id": str(db_challenge.id),
        "title": db_challenge.title,
        "description": db_challenge.description,
        "brand": db_challenge.brand,
        "brand_logo": db_challenge.brand_logo,
        "background_image": db_challenge.background_image,
        "distance": db_challenge.distance,
        "duration": db_challenge.duration,
        "start_date": db_challenge.start_date,
        "end_date": db_challenge.end_date,
        "activity_type": db_challenge.activity_type,
        "status": db_challenge.status,
        "brand_color": db_challenge.brand_color,
        "max_participants": db_challenge.max_participants,
        "is_public": db_challenge.is_public,
        "created_by": str(db_challenge.created_by),
        "created_at": db_challenge.created_at,
        "updated_at": db_challenge.updated_at,
        "friends_joined": active_participants,
        "is_joined": False,
        "creator_username": current_user.username
    }
    
    return Challenge(**challenge_dict)

@router.delete("/challenges/{challenge_id}")
async def delete_challenge(
    challenge_id: str,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Delete a challenge (only by creator)."""
    success = crud_challenges.delete_challenge(
        db=db,
        challenge_id=challenge_id,
        user_id=str(current_user.id)
    )
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Challenge not found or you don't have permission to delete it"
        )
    
    return {"message": "Challenge deleted successfully"}





@router.post("/challenges/{challenge_id}/join", response_model=ChallengeParticipant)
async def join_challenge(
    challenge_id: str,
    request: JoinChallengeRequest,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Join a challenge."""
    participant = crud_challenges.join_challenge(
        db=db,
        challenge_id=challenge_id,
        user_id=str(current_user.id)
    )
    
    if not participant:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot join challenge. It may be full, inactive, or you're already participating."
        )
    
    participant_dict = {
        "id": str(participant.id),
        "challenge_id": str(participant.challenge_id),
        "user_id": str(participant.user_id),
        "status": participant.status,
        "progress": participant.progress,
        "progress_percentage": participant.progress_percentage,
        "completion_proof_url": participant.completion_proof_url,
        "joined_at": participant.joined_at,
        "completed_at": participant.completed_at,
        "notes": participant.notes,
        "username": current_user.username
    }
    
    return ChallengeParticipant(**participant_dict)

@router.post("/challenges/{challenge_id}/leave")
async def leave_challenge(
    challenge_id: str,
    request: LeaveChallengeRequest,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Leave a challenge."""
    success = crud_challenges.leave_challenge(
        db=db,
        challenge_id=challenge_id,
        user_id=str(current_user.id)
    )
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot leave challenge. You may not be participating or already left."
        )
    
    return {"message": "Left challenge successfully"}

@router.put("/challenges/{challenge_id}/progress", response_model=ChallengeParticipant)
async def update_progress(
    challenge_id: str,
    progress_update: UpdateProgressRequest,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Update your progress in a challenge."""
    from app.schemas.challenges import ChallengeParticipantUpdate
    
    participant_update = ChallengeParticipantUpdate(
        progress=progress_update.progress,
        progress_percentage=progress_update.progress_percentage,
        completion_proof_url=progress_update.completion_proof_url,
        notes=progress_update.notes
    )
    
    participant = crud_challenges.update_participant_progress(
        db=db,
        challenge_id=challenge_id,
        user_id=str(current_user.id),
        progress_update=participant_update
    )
    
    if not participant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Participation not found or you cannot update progress"
        )
    
    participant_dict = {
        "id": str(participant.id),
        "challenge_id": str(participant.challenge_id),
        "user_id": str(participant.user_id),
        "status": participant.status,
        "progress": participant.progress,
        "progress_percentage": participant.progress_percentage,
        "completion_proof_url": participant.completion_proof_url,
        "joined_at": participant.joined_at,
        "completed_at": participant.completed_at,
        "notes": participant.notes,
        "username": current_user.username
    }
    
    return ChallengeParticipant(**participant_dict)

@router.get("/challenges/{challenge_id}/participants", response_model=ChallengeParticipantsResponse)
async def get_challenge_participants(
    challenge_id: str,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get participants of a challenge."""
    participants = crud_challenges.get_challenge_participants(
        db=db,
        challenge_id=challenge_id,
        skip=skip,
        limit=limit
    )
    
    participant_list = []
    for p in participants:
        participant_dict = {
            "id": str(p.id),
            "challenge_id": str(p.challenge_id),
            "user_id": str(p.user_id),
            "status": p.status,
            "progress": p.progress,
            "progress_percentage": p.progress_percentage,
            "completion_proof_url": p.completion_proof_url,
            "joined_at": p.joined_at,
            "completed_at": p.completed_at,
            "notes": p.notes,
            "username": p.participant.username if p.participant else None
        }
        participant_list.append(ChallengeParticipant(**participant_dict))
    
    return ChallengeParticipantsResponse(
        participants=participant_list,
        total=len(participants)
    )





@router.get("/my-challenges", response_model=ChallengeListResponse)
async def get_my_challenges(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    participant_status: Optional[ParticipantStatusEnum] = Query(None),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get challenges that the current user has participated in."""
    challenges = crud_challenges.get_user_challenges(
        db=db,
        user_id=str(current_user.id),
        skip=skip,
        limit=limit,
        participant_status=participant_status
    )
    
    challenge_list = []
    for challenge in challenges:
        
        participation = crud_challenges.get_user_participation(
            db=db,
            challenge_id=str(challenge.id),
            user_id=str(current_user.id)
        )
        
        
        active_participants = len([p for p in challenge.participants if p.status in ['joined', 'completed']])
        
        challenge_dict = {
            "id": str(challenge.id),
            "title": challenge.title,
            "description": challenge.description,
            "brand": challenge.brand,
            "brand_logo": challenge.brand_logo,
            "background_image": challenge.background_image,
            "distance": challenge.distance,
            "duration": challenge.duration,
            "start_date": challenge.start_date,
            "end_date": challenge.end_date,
            "activity_type": challenge.activity_type,
            "status": challenge.status,
            "brand_color": challenge.brand_color,
            "max_participants": challenge.max_participants,
            "is_public": challenge.is_public,
            "created_by": str(challenge.created_by),
            "created_at": challenge.created_at,
            "updated_at": challenge.updated_at,
            "friends_joined": active_participants,
            "is_joined": participation is not None and participation.status in ['joined', 'completed'],
            "creator_username": challenge.creator.username if challenge.creator else None
        }
        challenge_list.append(Challenge(**challenge_dict))
    
    return ChallengeListResponse(
        challenges=challenge_list,
        total=len(challenges),
        page=skip // limit + 1,
        size=limit,
        has_next=len(challenges) == limit,
        has_prev=skip > 0
    )

@router.get("/my-created-challenges", response_model=ChallengeListResponse)
async def get_my_created_challenges(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get challenges created by the current user."""
    challenges = crud_challenges.get_created_challenges(
        db=db,
        user_id=str(current_user.id),
        skip=skip,
        limit=limit
    )
    
    challenge_list = []
    for challenge in challenges:
        
        active_participants = len([p for p in challenge.participants if p.status in ['joined', 'completed']])
        
        challenge_dict = {
            "id": str(challenge.id),
            "title": challenge.title,
            "description": challenge.description,
            "brand": challenge.brand,
            "brand_logo": challenge.brand_logo,
            "background_image": challenge.background_image,
            "distance": challenge.distance,
            "duration": challenge.duration,
            "start_date": challenge.start_date,
            "end_date": challenge.end_date,
            "activity_type": challenge.activity_type,
            "status": challenge.status,
            "brand_color": challenge.brand_color,
            "max_participants": challenge.max_participants,
            "is_public": challenge.is_public,
            "created_by": str(challenge.created_by),
            "created_at": challenge.created_at,
            "updated_at": challenge.updated_at,
            "friends_joined": active_participants,
            "is_joined": False,  
            "creator_username": current_user.username
        }
        challenge_list.append(Challenge(**challenge_dict))
    
    return ChallengeListResponse(
        challenges=challenge_list,
        total=len(challenges),
        page=skip // limit + 1,
        size=limit,
        has_next=len(challenges) == limit,
        has_prev=skip > 0
    )





@router.get("/challenge-stats", response_model=ChallengeStatsResponse)
async def get_challenge_stats(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get challenge statistics."""
    stats = crud_challenges.get_challenge_stats(
        db=db,
        user_id=str(current_user.id)
    )
    
    return ChallengeStatsResponse(**stats)
