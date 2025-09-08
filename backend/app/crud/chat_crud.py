from sqlalchemy.orm import Session, joinedload
from sqlalchemy import desc, func, and_
from app.models_db import ChatRoom, ChatMessage, ChatParticipant, User
from typing import List, Optional, Dict
from uuid import UUID
from datetime import datetime


def create_chat_room(
    db: Session, 
    participant_ids: List[UUID], 
    is_group: bool = False, 
    name: Optional[str] = None, 
    creator_id: UUID = None
) -> ChatRoom:
    """Create a new chat room"""
    # For direct messages, check if room already exists
    if not is_group and len(participant_ids) == 2:
        existing_room = (
            db.query(ChatRoom)
            .join(ChatParticipant)
            .filter(
                ChatRoom.is_group == False,
                ChatParticipant.user_id.in_(participant_ids)
            )
            .group_by(ChatRoom.id)
            .having(func.count(ChatParticipant.user_id) == 2)
            .first()
        )
        
        if existing_room:
            return existing_room
    
    # Create new room
    room = ChatRoom(name=name, is_group=is_group, created_by=creator_id)
    db.add(room)
    db.flush()
    
    # Add participants
    for user_id in participant_ids:
        participant = ChatParticipant(chat_room_id=room.id, user_id=user_id)
        db.add(participant)
    
    db.commit()
    db.refresh(room)
    return room


def get_user_chat_rooms(db: Session, user_id: UUID) -> List[Dict]:
    """Get all chat rooms for a user with last message and unread count"""
    # Get rooms where user is a participant
    rooms_query = (
        db.query(ChatRoom)
        .join(ChatParticipant)
        .filter(
            ChatParticipant.user_id == user_id,
            ChatParticipant.is_active == True
        )
        .options(joinedload(ChatRoom.participants))
        .all()
    )
    
    result = []
    for room in rooms_query:
        # Get last message
        last_message = (
            db.query(ChatMessage)
            .filter(ChatMessage.chat_room_id == room.id)
            .order_by(desc(ChatMessage.created_at))
            .first()
        )
        
        # Get unread count
        participant = (
            db.query(ChatParticipant)
            .filter(
                ChatParticipant.chat_room_id == room.id,
                ChatParticipant.user_id == user_id
            )
            .first()
        )
        
        unread_count = 0
        if participant and participant.last_read_at:
            unread_count = (
                db.query(func.count(ChatMessage.id))
                .filter(
                    ChatMessage.chat_room_id == room.id,
                    ChatMessage.created_at > participant.last_read_at,
                    ChatMessage.sender_id != user_id
                )
                .scalar()
            )
        elif participant:
            # If never read, count all messages from others
            unread_count = (
                db.query(func.count(ChatMessage.id))
                .filter(
                    ChatMessage.chat_room_id == room.id,
                    ChatMessage.sender_id != user_id
                )
                .scalar()
            )
        
        # For direct messages, get the other participant's name
        other_participant_name = None
        other_participant_avatar = None
        if not room.is_group:
            other_participant = (
                db.query(User)
                .join(ChatParticipant)
                .filter(
                    ChatParticipant.chat_room_id == room.id,
                    ChatParticipant.user_id != user_id
                )
                .first()
            )
            if other_participant:
                other_participant_name = other_participant.username
                other_participant_avatar = getattr(other_participant, 'avatar_url', None)
        
        room_data = {
            'id': room.id,
            'name': room.name,
            'is_group': room.is_group,
            'created_at': room.created_at,
            'last_message_content': last_message.content if last_message else None,
            'last_message_time': last_message.created_at if last_message else None,
            'unread_count': unread_count or 0,
            'other_participant_name': other_participant_name,
            'other_participant_avatar': other_participant_avatar
        }
        result.append(room_data)
    
    return result


def create_message(
    db: Session,
    chat_room_id: UUID,
    sender_id: UUID,
    content: str,
    message_type: str = "text",
    media_url: Optional[str] = None,
    reply_to_id: Optional[UUID] = None
) -> ChatMessage:
    """Create a new chat message"""
    # Verify user is participant in the room
    participant = (
        db.query(ChatParticipant)
        .filter(
            ChatParticipant.chat_room_id == chat_room_id,
            ChatParticipant.user_id == sender_id,
            ChatParticipant.is_active == True
        )
        .first()
    )
    
    if not participant:
        raise ValueError("User is not a participant in this chat room")
    
    message = ChatMessage(
        chat_room_id=chat_room_id,
        sender_id=sender_id,
        content=content,
        message_type=message_type,
        media_url=media_url,
        reply_to_id=reply_to_id
    )
    
    db.add(message)
    db.commit()
    db.refresh(message)
    return message


def get_chat_messages(
    db: Session, 
    chat_room_id: UUID, 
    user_id: UUID,
    limit: int = 50, 
    offset: int = 0
) -> List[Dict]:
    """Get messages for a chat room"""
    # Verify user is participant in the room
    participant = (
        db.query(ChatParticipant)
        .filter(
            ChatParticipant.chat_room_id == chat_room_id,
            ChatParticipant.user_id == user_id,
            ChatParticipant.is_active == True
        )
        .first()
    )
    
    if not participant:
        raise ValueError("User is not a participant in this chat room")
    
    messages = (
        db.query(ChatMessage)
        .join(User, ChatMessage.sender_id == User.id)
        .filter(ChatMessage.chat_room_id == chat_room_id)
        .order_by(desc(ChatMessage.created_at))
        .offset(offset)
        .limit(limit)
        .all()
    )
    
    result = []
    for message in messages:
        sender = db.query(User).filter(User.id == message.sender_id).first()
        message_data = {
            'id': message.id,
            'chat_room_id': message.chat_room_id,
            'sender_id': message.sender_id,
            'sender_username': sender.username if sender else 'Unknown',
            'content': message.content,
            'message_type': message.message_type,
            'media_url': message.media_url,
            'reply_to_id': message.reply_to_id,
            'is_edited': message.is_edited,
            'created_at': message.created_at
        }
        result.append(message_data)
    
    return result


def mark_messages_as_read(db: Session, chat_room_id: UUID, user_id: UUID) -> bool:
    """Mark all messages in a chat room as read for a user"""
    participant = (
        db.query(ChatParticipant)
        .filter(
            ChatParticipant.chat_room_id == chat_room_id,
            ChatParticipant.user_id == user_id
        )
        .first()
    )
    
    if participant:
        participant.last_read_at = datetime.utcnow()
        db.commit()
        return True
    return False


def get_chat_room_participants(db: Session, chat_room_id: UUID) -> List[Dict]:
    """Get all participants in a chat room"""
    participants = (
        db.query(ChatParticipant)
        .join(User)
        .filter(ChatParticipant.chat_room_id == chat_room_id)
        .all()
    )
    
    result = []
    for participant in participants:
        user = db.query(User).filter(User.id == participant.user_id).first()
        if user:
            participant_data = {
                'user_id': user.id,
                'username': user.username,
                'display_name': getattr(user, 'display_name', None),
                'avatar_url': getattr(user, 'avatar_url', None),
                'joined_at': participant.joined_at,
                'last_read_at': participant.last_read_at,
                'is_active': participant.is_active
            }
            result.append(participant_data)
    
    return result


def add_participant_to_room(db: Session, chat_room_id: UUID, user_id: UUID) -> bool:
    """Add a participant to a chat room (for group chats)"""
    # Check if room exists and is a group chat
    room = db.query(ChatRoom).filter(ChatRoom.id == chat_room_id).first()
    if not room or not room.is_group:
        return False
    
    # Check if user is already a participant
    existing = (
        db.query(ChatParticipant)
        .filter(
            ChatParticipant.chat_room_id == chat_room_id,
            ChatParticipant.user_id == user_id
        )
        .first()
    )
    
    if existing:
        existing.is_active = True
        existing.joined_at = datetime.utcnow()
    else:
        participant = ChatParticipant(chat_room_id=chat_room_id, user_id=user_id)
        db.add(participant)
    
    db.commit()
    return True


def remove_participant_from_room(db: Session, chat_room_id: UUID, user_id: UUID) -> bool:
    """Remove a participant from a chat room"""
    participant = (
        db.query(ChatParticipant)
        .filter(
            ChatParticipant.chat_room_id == chat_room_id,
            ChatParticipant.user_id == user_id
        )
        .first()
    )
    
    if participant:
        participant.is_active = False
        db.commit()
        return True
    return False
