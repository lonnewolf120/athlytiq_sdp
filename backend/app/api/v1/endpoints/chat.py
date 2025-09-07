from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from app.database.base import get_db
from app.api.deps import get_current_user
from app.crud import chat_crud
from app.schemas.chat import (
    ChatMessageCreate,
    ChatMessageResponse,
    ChatRoomCreate,
    ChatRoomResponse,
    ChatRoomListResponse,
    ChatParticipantResponse
)
from app.models_db import User
from uuid import UUID

router = APIRouter()


@router.post("/rooms", response_model=ChatRoomResponse)
async def create_chat_room(
    room_data: ChatRoomCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a new chat room"""
    try:
        # Add current user to participants if not included
        if current_user.id not in room_data.participant_ids:
            room_data.participant_ids.append(current_user.id)
        
        room = chat_crud.create_chat_room(
            db, 
            room_data.participant_ids, 
            room_data.is_group, 
            room_data.name,
            current_user.id
        )
        
        # Get participants info
        participants = chat_crud.get_chat_room_participants(db, room.id)
        
        return ChatRoomResponse(
            id=room.id,
            name=room.name,
            is_group=room.is_group,
            created_at=room.created_at,
            participants=[ChatParticipantResponse(**p) for p in participants]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating chat room: {str(e)}")


@router.get("/rooms", response_model=List[ChatRoomListResponse])
async def get_chat_rooms(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all chat rooms for the current user"""
    try:
        rooms = chat_crud.get_user_chat_rooms(db, current_user.id)
        return [ChatRoomListResponse(**room) for room in rooms]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting chat rooms: {str(e)}")


@router.get("/rooms/{room_id}")
async def get_chat_room_details(
    room_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get detailed information about a chat room"""
    try:
        # Verify user is a participant
        participants = chat_crud.get_chat_room_participants(db, room_id)
        user_is_participant = any(p['user_id'] == current_user.id for p in participants)
        
        if not user_is_participant:
            raise HTTPException(status_code=403, detail="You are not a participant in this chat room")
        
        # Get room details (this would need to be implemented in chat_crud)
        return {"room_id": room_id, "participants": participants}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting chat room details: {str(e)}")


@router.post("/messages", response_model=ChatMessageResponse)
async def send_message(
    message_data: ChatMessageCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Send a message to a chat room"""
    try:
        message = chat_crud.create_message(
            db,
            message_data.chat_room_id,
            current_user.id,
            message_data.content,
            message_data.message_type or "text",
            message_data.media_url,
            message_data.reply_to_id
        )
        
        return ChatMessageResponse(
            id=message.id,
            chat_room_id=message.chat_room_id,
            sender_id=message.sender_id,
            sender_username=current_user.username,
            content=message.content,
            message_type=message.message_type,
            media_url=message.media_url,
            reply_to_id=message.reply_to_id,
            is_edited=message.is_edited,
            created_at=message.created_at
        )
    except ValueError as e:
        raise HTTPException(status_code=403, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error sending message: {str(e)}")


@router.get("/rooms/{room_id}/messages", response_model=List[ChatMessageResponse])
async def get_chat_messages(
    room_id: UUID,
    limit: int = Query(50, le=100, ge=1),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get messages from a chat room"""
    try:
        messages = chat_crud.get_chat_messages(db, room_id, current_user.id, limit, offset)
        return [ChatMessageResponse(**msg) for msg in messages]
    except ValueError as e:
        raise HTTPException(status_code=403, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting messages: {str(e)}")


@router.put("/rooms/{room_id}/read")
async def mark_messages_as_read(
    room_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Mark all messages in a chat room as read"""
    try:
        success = chat_crud.mark_messages_as_read(db, room_id, current_user.id)
        if success:
            return {"message": "Messages marked as read"}
        else:
            raise HTTPException(status_code=404, detail="Chat room not found or user not a participant")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error marking messages as read: {str(e)}")


@router.post("/rooms/{room_id}/participants/{user_id}")
async def add_participant(
    room_id: UUID,
    user_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Add a participant to a group chat"""
    try:
        success = chat_crud.add_participant_to_room(db, room_id, user_id)
        if success:
            return {"message": "Participant added successfully"}
        else:
            raise HTTPException(status_code=400, detail="Cannot add participant to this chat room")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error adding participant: {str(e)}")


@router.delete("/rooms/{room_id}/participants/{user_id}")
async def remove_participant(
    room_id: UUID,
    user_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Remove a participant from a chat room"""
    try:
        success = chat_crud.remove_participant_from_room(db, room_id, user_id)
        if success:
            return {"message": "Participant removed successfully"}
        else:
            raise HTTPException(status_code=404, detail="Participant not found in chat room")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error removing participant: {str(e)}")


@router.delete("/messages/{message_id}")
async def delete_message(
    message_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Delete a message (only by sender)"""
    try:
        # This would need to be implemented in chat_crud
        return {"message": "Message deletion not implemented yet"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting message: {str(e)}")
