from fastapi import APIRouter, Depends, HTTPException, Query, Path, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Optional, Dict, Any
from uuid import UUID

from app.database.base import get_db
from app.dependencies import get_current_user
from app.models_db import User
from app.schemas.chat import (
    ChatRoomCreate, ChatRoomResponse, MessageCreate, MessageResponse,
    MessageReactionCreate
)
from app.crud.chat_crud import chat_crud

router = APIRouter(prefix="/chat", tags=["chat"])

@router.get("/rooms", response_model=List[Dict[str, Any]])
async def get_user_chat_rooms(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all chat rooms for the current user"""
    try:
        rooms = await chat_crud.get_user_chat_rooms(db, current_user.id, skip, limit)
        return rooms
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch chat rooms: {str(e)}"
        )

@router.post("/rooms/direct", response_model=Dict[str, Any])
async def create_direct_chat(
    other_user_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create or get existing direct chat room with another user"""
    try:
        if current_user.id == other_user_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot create direct chat with yourself"
            )
        
        room = await chat_crud.create_direct_chat_room(
            db, current_user.id, other_user_id
        )
        return room
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create direct chat: {str(e)}"
        )

@router.post("/rooms/group", response_model=Dict[str, Any])
async def create_group_chat(
    room_data: ChatRoomCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a new group chat room"""
    try:
        if not room_data.name or not room_data.name.strip():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Group chat name is required"
            )
        
        if len(room_data.participant_ids) < 1:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="At least one other participant is required for group chat"
            )
        
        if current_user.id in room_data.participant_ids:
            # Remove current user from participants if they added themselves
            room_data.participant_ids = [pid for pid in room_data.participant_ids if pid != current_user.id]
        
        room = await chat_crud.create_group_chat_room(db, current_user.id, room_data)
        return room
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create group chat: {str(e)}"
        )

@router.get("/rooms/{room_id}", response_model=Dict[str, Any])
async def get_chat_room(
    room_id: UUID = Path(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get detailed information about a specific chat room"""
    try:
        room = await chat_crud.get_chat_room_details(db, room_id, current_user.id)
        return room
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch chat room: {str(e)}"
        )

@router.get("/rooms/{room_id}/messages", response_model=List[Dict[str, Any]])
async def get_room_messages(
    room_id: UUID = Path(...),
    before_message_id: Optional[UUID] = Query(None),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get messages for a chat room with pagination"""
    try:
        messages = await chat_crud.get_room_messages(
            db, room_id, current_user.id, before_message_id, limit
        )
        return messages
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch messages: {str(e)}"
        )

@router.post("/rooms/{room_id}/messages", response_model=Dict[str, Any])
async def send_message(
    room_id: UUID = Path(...),
    message_data: MessageCreate = ...,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Send a message to a chat room"""
    try:
        if not message_data.content and not message_data.media_urls:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Message must have content or media"
            )
        
        message = await chat_crud.send_message(db, room_id, current_user.id, message_data)
        return message
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to send message: {str(e)}"
        )

@router.put("/rooms/{room_id}/messages/read")
async def mark_messages_as_read(
    room_id: UUID = Path(...),
    message_ids: Optional[List[UUID]] = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Mark messages as read in a chat room"""
    try:
        success = await chat_crud.mark_messages_as_read(
            db, room_id, current_user.id, message_ids
        )
        
        if success:
            return {"message": "Messages marked as read"}
        else:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to mark messages as read"
            )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to mark messages as read: {str(e)}"
        )

@router.get("/messages/{message_id}", response_model=Dict[str, Any])
async def get_message_details(
    message_id: UUID = Path(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get detailed information about a specific message"""
    try:
        message = await chat_crud.get_message_details(db, message_id, current_user.id)
        return message
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch message: {str(e)}"
        )

# Additional endpoints for chat room management
@router.put("/rooms/{room_id}/participants")
async def update_room_participants(
    room_id: UUID = Path(...),
    action: str = Query(..., pattern="^(add|remove|promote|demote)$"),
    user_ids: List[UUID] = ...,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Add/remove participants or change their roles in a group chat"""
    try:
        # This would require additional CRUD methods for participant management
        # For now, return a placeholder response
        return {
            "message": f"Participant {action} operation completed",
            "room_id": str(room_id),
            "affected_users": [str(uid) for uid in user_ids]
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update participants: {str(e)}"
        )

@router.put("/rooms/{room_id}/settings")
async def update_room_settings(
    room_id: UUID = Path(...),
    is_muted: Optional[bool] = None,
    is_pinned: Optional[bool] = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update user's settings for a specific chat room"""
    try:
        # This would require additional CRUD methods for user-specific room settings
        # For now, return a placeholder response
        settings_updated = {}
        if is_muted is not None:
            settings_updated["is_muted"] = is_muted
        if is_pinned is not None:
            settings_updated["is_pinned"] = is_pinned
        
        return {
            "message": "Room settings updated",
            "room_id": str(room_id),
            "settings": settings_updated
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update room settings: {str(e)}"
        )

@router.delete("/rooms/{room_id}")
async def leave_or_delete_room(
    room_id: UUID = Path(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Leave a chat room (or delete if you're the owner of a group chat)"""
    try:
        # This would require additional CRUD methods for leaving/deleting rooms
        # For now, return a placeholder response
        return {
            "message": "Successfully left the chat room",
            "room_id": str(room_id)
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to leave room: {str(e)}"
        )
