from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from app.database.base import get_db
from app.api.deps import get_current_user
from app.crud import friends_crud
from app.schemas.friends import (
    FriendRequestCreate, 
    FriendRequestResponse, 
    FriendResponse, 
    UserSearchResponse,
    FriendRequestAction
)
from app.models_db import User
from uuid import UUID

router = APIRouter()


@router.get("/search", response_model=List[UserSearchResponse])
async def search_users(
    query: str = Query(..., min_length=2),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Search for users by username or email"""
    try:
        users = friends_crud.search_users(db, query, current_user.id)
        
        # Check friendship status for each user
        result = []
        for user in users:
            status = friends_crud.check_friendship_status(db, current_user.id, user.id)
            user_data = UserSearchResponse(
                id=user.id,
                username=user.username,
                display_name=getattr(user, 'display_name', None),
                avatar_url=getattr(user, 'avatar_url', None),
                is_friend=status['is_friend'],
                has_pending_request=status['has_pending_request']
            )
            result.append(user_data)
        
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error searching users: {str(e)}")


@router.post("/requests", response_model=FriendRequestResponse)
async def send_friend_request(
    request_data: FriendRequestCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Send a friend request"""
    try:
        request = friends_crud.send_friend_request(db, current_user.id, request_data.receiver_id)
        
        # Get sender and receiver info
        sender = db.query(User).filter(User.id == current_user.id).first()
        receiver = db.query(User).filter(User.id == request_data.receiver_id).first()
        
        return FriendRequestResponse(
            id=request.id,
            sender_id=request.sender_id,
            receiver_id=request.receiver_id,
            status=request.status,
            created_at=request.created_at,
            sender_username=sender.username if sender else None,
            receiver_username=receiver.username if receiver else None
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error sending friend request: {str(e)}")


@router.get("/requests", response_model=List[FriendRequestResponse])
async def get_friend_requests(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get pending friend requests received by the current user"""
    try:
        requests = friends_crud.get_friend_requests(db, current_user.id)
        
        result = []
        for req in requests:
            sender = db.query(User).filter(User.id == req.sender_id).first()
            result.append(FriendRequestResponse(
                id=req.id,
                sender_id=req.sender_id,
                receiver_id=req.receiver_id,
                status=req.status,
                created_at=req.created_at,
                sender_username=sender.username if sender else None,
                receiver_username=current_user.username
            ))
        
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting friend requests: {str(e)}")


@router.get("/requests/sent", response_model=List[FriendRequestResponse])
async def get_sent_friend_requests(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get pending friend requests sent by the current user"""
    try:
        requests = friends_crud.get_sent_friend_requests(db, current_user.id)
        
        result = []
        for req in requests:
            receiver = db.query(User).filter(User.id == req.receiver_id).first()
            result.append(FriendRequestResponse(
                id=req.id,
                sender_id=req.sender_id,
                receiver_id=req.receiver_id,
                status=req.status,
                created_at=req.created_at,
                sender_username=current_user.username,
                receiver_username=receiver.username if receiver else None
            ))
        
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting sent friend requests: {str(e)}")


@router.put("/requests/{request_id}")
async def handle_friend_request(
    request_id: UUID,
    action: str = Query(..., regex="^(accepted|rejected)$"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Accept or reject a friend request"""
    try:
        request = friends_crud.handle_friend_request(db, request_id, action, current_user.id)
        return {"message": f"Friend request {action} successfully", "request_id": request_id}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error handling friend request: {str(e)}")


@router.get("/", response_model=List[FriendResponse])
async def get_friends(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all friends of the current user"""
    try:
        friends = friends_crud.get_friends(db, current_user.id)
        return [FriendResponse(**friend) for friend in friends]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting friends: {str(e)}")


@router.delete("/{friend_user_id}")
async def remove_friend(
    friend_user_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Remove a friend"""
    try:
        success = friends_crud.remove_friend(db, current_user.id, friend_user_id)
        if success:
            return {"message": "Friend removed successfully"}
        else:
            raise HTTPException(status_code=404, detail="Friendship not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error removing friend: {str(e)}")


@router.get("/status/{user_id}")
async def get_friendship_status(
    user_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Check friendship status with another user"""
    try:
        status = friends_crud.check_friendship_status(db, current_user.id, user_id)
        return status
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error checking friendship status: {str(e)}")
