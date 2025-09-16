from fastapi import APIRouter, Depends, HTTPException, Query, Path, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Optional, Dict, Any
from uuid import UUID

from app.database.base import get_db
from app.dependencies import get_current_user
from app.models_db import User
from app.schemas.chat import (
    FriendRequestCreate, FriendRequestResponse, UserSearchResult
)
from app.crud.friends_crud import friends_crud

router = APIRouter(prefix="/friends", tags=["friends"])

@router.get("/", response_model=List[Dict[str, Any]])
async def get_friends_list(
    search: Optional[str] = Query(None),
    online_only: bool = Query(False),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get current user's friends list"""
    try:
        friends = await friends_crud.get_friends_list(
            db, current_user.id, search, online_only, skip, limit
        )
        return friends
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch friends list: {str(e)}"
        )

@router.get("/requests", response_model=List[Dict[str, Any]])
async def get_friend_requests(
    request_type: str = Query("received", pattern="^(received|sent|all)$"),
    status_filter: Optional[str] = Query(None, pattern="^(pending|accepted|rejected|blocked)$"),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get friend requests (received, sent, or all)"""
    try:
        requests = await friends_crud.get_friend_requests(
            db, current_user.id, request_type, status_filter, skip, limit
        )
        return requests
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch friend requests: {str(e)}"
        )

@router.post("/requests", response_model=Dict[str, Any])
async def send_friend_request(
    receiver_id: UUID,
    message: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Send a friend request to another user"""
    try:
        request = await friends_crud.send_friend_request(
            db, current_user.id, receiver_id, message
        )
        return request
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to send friend request: {str(e)}"
        )

@router.put("/requests/{request_id}")
async def respond_to_friend_request(
    request_id: UUID = Path(...),
    accept: bool = ...,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Accept or reject a friend request"""
    try:
        request = await friends_crud.respond_to_friend_request(
            db, request_id, current_user.id, accept
        )
        return {
            "message": f"Friend request {'accepted' if accept else 'rejected'}",
            "request": request
        }
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to respond to friend request: {str(e)}"
        )

@router.get("/requests/{request_id}", response_model=Dict[str, Any])
async def get_friend_request_details(
    request_id: UUID = Path(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get detailed information about a specific friend request"""
    try:
        request = await friends_crud.get_friend_request_details(
            db, request_id, current_user.id
        )
        return request
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch friend request: {str(e)}"
        )

@router.delete("/requests/{request_id}")
async def cancel_friend_request(
    request_id: UUID = Path(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Cancel a sent friend request"""
    try:
        # This would require additional CRUD method for canceling requests
        # For now, return a placeholder response
        return {
            "message": "Friend request cancelled",
            "request_id": str(request_id)
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to cancel friend request: {str(e)}"
        )

@router.delete("/{friend_id}")
async def remove_friend(
    friend_id: UUID = Path(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Remove a friend (unfriend)"""
    try:
        success = await friends_crud.remove_friend(db, current_user.id, friend_id)
        
        if success:
            return {"message": "Friend removed successfully"}
        else:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Friendship not found"
            )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to remove friend: {str(e)}"
        )

@router.get("/search", response_model=List[Dict[str, Any]])
async def search_users(
    q: str = Query(..., min_length=2),
    exclude_friends: bool = Query(False),
    limit: int = Query(20, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Search for users to add as friends"""
    try:
        users = await friends_crud.search_users(
            db, current_user.id, q, exclude_friends, limit
        )
        return users
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to search users: {str(e)}"
        )

@router.post("/block/{user_id}")
async def block_user(
    user_id: UUID = Path(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Block a user"""
    try:
        success = await friends_crud.block_user(db, current_user.id, user_id)
        
        if success:
            return {"message": "User blocked successfully"}
        else:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to block user"
            )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to block user: {str(e)}"
        )

@router.delete("/block/{user_id}")
async def unblock_user(
    user_id: UUID = Path(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Unblock a user"""
    try:
        success = await friends_crud.unblock_user(db, current_user.id, user_id)
        
        if success:
            return {"message": "User unblocked successfully"}
        else:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Block relationship not found"
            )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to unblock user: {str(e)}"
        )

@router.get("/blocked", response_model=List[Dict[str, Any]])
async def get_blocked_users(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get list of blocked users"""
    try:
        blocked_users = await friends_crud.get_blocked_users(
            db, current_user.id, skip, limit
        )
        return blocked_users
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch blocked users: {str(e)}"
        )

# Additional endpoints for friendship management
@router.get("/{friend_id}", response_model=Dict[str, Any])
async def get_friend_details(
    friend_id: UUID = Path(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get detailed information about a specific friend"""
    try:
        # This would require additional CRUD method for getting friend details
        # For now, return a placeholder response
        return {
            "user_id": str(friend_id),
            "username": "friend_username",
            "display_name": "Friend Display Name",
            "avatar_url": None,
            "is_online": False,
            "last_seen": None,
            "friendship_since": None,
            "mutual_friends_count": 0,
            "direct_chat_room_id": None
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch friend details: {str(e)}"
        )

@router.get("/{friend_id}/mutual")
async def get_mutual_friends(
    friend_id: UUID = Path(...),
    limit: int = Query(20, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get mutual friends with another user"""
    try:
        # This would require additional CRUD method for finding mutual friends
        # For now, return a placeholder response
        return {
            "mutual_friends": [],
            "total_count": 0
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch mutual friends: {str(e)}"
        )
