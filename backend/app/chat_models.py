# Additional models for chat and friends functionality
# These should be added to the main models_db.py file

from sqlalchemy import Column, String, Integer, Float, Double, Text, Boolean, DateTime, ForeignKey, Enum, UniqueConstraint, Index, JSON, TIMESTAMP
from sqlalchemy.dialects.postgresql import UUID, ENUM as PGEnum, JSONB, ARRAY
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from enum import Enum as PyEnum
import uuid
from datetime import datetime

Base = declarative_base()

# Enums for chat system
class ChatRoomType(PyEnum):
    direct = "direct"
    group = "group"

class MessageType(PyEnum):
    text = "text"
    image = "image"
    video = "video"
    audio = "audio"
    file = "file"
    system = "system"
    workout = "workout"
    challenge = "challenge"

class ParticipantRole(PyEnum):
    member = "member"
    admin = "admin"
    
class FriendRequestStatus(PyEnum):
    pending = "pending"
    accepted = "accepted"
    rejected = "rejected"
    blocked = "blocked"

# Create PostgreSQL ENUMs
chat_room_type_enum = PGEnum(
    'direct', 'group',
    name='chat_room_type',
    create_type=False
)

message_type_enum = PGEnum(
    'text', 'image', 'video', 'audio', 'file', 'system', 'workout', 'challenge',
    name='message_type',
    create_type=False
)

participant_role_enum = PGEnum(
    'member', 'admin',
    name='participant_role',
    create_type=False
)

friend_request_status_enum = PGEnum(
    'pending', 'accepted', 'rejected', 'blocked',
    name='friend_request_status',
    create_type=False
)

# Existing Buddies model (this should already exist in main models_db.py)
class Buddies(Base):
    __tablename__ = 'buddies'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    requester_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    requestee_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    status = Column(String(20), nullable=False, default='requested')  # requested | accepted | declined
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
    # Add unique constraint
    __table_args__ = (
        UniqueConstraint('requester_id', 'requestee_id', name='_requester_requestee_uc'),
        Index('idx_buddies_requester', 'requester_id'),
        Index('idx_buddies_requestee', 'requestee_id'),
    )
    
    # Relationships
    requester = relationship("User", foreign_keys=[requester_id])
    requestee = relationship("User", foreign_keys=[requestee_id])

# New Chat models
class ChatRoom(Base):
    __tablename__ = 'chat_rooms'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    type = Column(chat_room_type_enum, nullable=False)
    name = Column(String(255), nullable=True)  # Only for group chats
    description = Column(Text, nullable=True)
    image_url = Column(Text, nullable=True)
    created_by = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='SET NULL'), nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    last_message_at = Column(DateTime(timezone=True), nullable=True)
    last_message_content = Column(Text, nullable=True)
    last_message_sender_id = Column(UUID(as_uuid=True), nullable=True)
    is_archived = Column(Boolean, default=False)
    
    # Indexes
    __table_args__ = (
        Index('idx_chat_rooms_type', 'type'),
        Index('idx_chat_rooms_created_by', 'created_by'),
        Index('idx_chat_rooms_last_message_at', 'last_message_at'),
    )
    
    # Relationships
    creator = relationship("User", foreign_keys=[created_by])
    participants = relationship("ChatParticipant", back_populates="room", cascade="all, delete-orphan")
    messages = relationship("ChatMessage", back_populates="room", cascade="all, delete-orphan")

class ChatParticipant(Base):
    __tablename__ = 'chat_participants'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    room_id = Column(UUID(as_uuid=True), ForeignKey('chat_rooms.id', ondelete='CASCADE'), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    role = Column(participant_role_enum, nullable=False, default='member')
    joined_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    left_at = Column(DateTime(timezone=True), nullable=True)
    last_read_at = Column(DateTime(timezone=True), nullable=True)
    unread_count = Column(Integer, default=0)
    is_muted = Column(Boolean, default=False)
    is_pinned = Column(Boolean, default=False)
    
    # Indexes and constraints
    __table_args__ = (
        UniqueConstraint('room_id', 'user_id', name='_room_user_uc'),
        Index('idx_chat_participants_room_id', 'room_id'),
        Index('idx_chat_participants_user_id', 'user_id'),
    )
    
    # Relationships
    room = relationship("ChatRoom", back_populates="participants")
    user = relationship("User")

class ChatMessage(Base):
    __tablename__ = 'chat_messages'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    room_id = Column(UUID(as_uuid=True), ForeignKey('chat_rooms.id', ondelete='CASCADE'), nullable=False)
    sender_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    message_type = Column(message_type_enum, nullable=False, default='text')
    content = Column(Text, nullable=True)
    media_urls = Column(ARRAY(Text), nullable=True)
    metadata = Column(JSONB, nullable=True)
    reply_to_id = Column(UUID(as_uuid=True), ForeignKey('chat_messages.id', ondelete='SET NULL'), nullable=True)
    forwarded_from_id = Column(UUID(as_uuid=True), ForeignKey('chat_messages.id', ondelete='SET NULL'), nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    edited_at = Column(DateTime(timezone=True), nullable=True)
    is_deleted = Column(Boolean, default=False)
    deleted_at = Column(DateTime(timezone=True), nullable=True)
    
    # Indexes
    __table_args__ = (
        Index('idx_chat_messages_room_id', 'room_id'),
        Index('idx_chat_messages_sender_id', 'sender_id'),
        Index('idx_chat_messages_created_at', 'created_at'),
        Index('idx_chat_messages_reply_to_id', 'reply_to_id'),
    )
    
    # Relationships
    room = relationship("ChatRoom", back_populates="messages")
    sender = relationship("User", foreign_keys=[sender_id])
    reply_to = relationship("ChatMessage", foreign_keys=[reply_to_id], remote_side="ChatMessage.id")
    forwarded_from = relationship("ChatMessage", foreign_keys=[forwarded_from_id], remote_side="ChatMessage.id")
    reactions = relationship("MessageReaction", back_populates="message", cascade="all, delete-orphan")
    read_receipts = relationship("MessageReadReceipt", back_populates="message", cascade="all, delete-orphan")

class MessageReaction(Base):
    __tablename__ = 'message_reactions'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    message_id = Column(UUID(as_uuid=True), ForeignKey('chat_messages.id', ondelete='CASCADE'), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    emoji = Column(String(10), nullable=False)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
    # Constraints and indexes
    __table_args__ = (
        UniqueConstraint('message_id', 'user_id', 'emoji', name='_message_user_emoji_uc'),
        Index('idx_message_reactions_message_id', 'message_id'),
        Index('idx_message_reactions_user_id', 'user_id'),
    )
    
    # Relationships
    message = relationship("ChatMessage", back_populates="reactions")
    user = relationship("User")

class MessageReadReceipt(Base):
    __tablename__ = 'message_read_receipts'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    message_id = Column(UUID(as_uuid=True), ForeignKey('chat_messages.id', ondelete='CASCADE'), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    read_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
    # Constraints and indexes
    __table_args__ = (
        UniqueConstraint('message_id', 'user_id', name='_message_user_read_uc'),
        Index('idx_message_read_receipts_message_id', 'message_id'),
        Index('idx_message_read_receipts_user_id', 'user_id'),
    )
    
    # Relationships
    message = relationship("ChatMessage", back_populates="read_receipts")
    user = relationship("User")

class FriendRequest(Base):
    __tablename__ = 'friend_requests'
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    sender_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    receiver_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    message = Column(Text, nullable=True)
    status = Column(friend_request_status_enum, nullable=False, default='pending')
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    responded_at = Column(DateTime(timezone=True), nullable=True)
    
    # Constraints and indexes
    __table_args__ = (
        UniqueConstraint('sender_id', 'receiver_id', name='_sender_receiver_uc'),
        Index('idx_friend_requests_sender_id', 'sender_id'),
        Index('idx_friend_requests_receiver_id', 'receiver_id'),
        Index('idx_friend_requests_status', 'status'),
    )
    
    # Relationships
    sender = relationship("User", foreign_keys=[sender_id])
    receiver = relationship("User", foreign_keys=[receiver_id])

class UserOnlineStatus(Base):
    __tablename__ = 'user_online_status'
    
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    is_online = Column(Boolean, default=False)
    last_seen = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Indexes
    __table_args__ = (
        Index('idx_user_online_status_is_online', 'is_online'),
        Index('idx_user_online_status_last_seen', 'last_seen'),
    )
    
    # Relationships
    user = relationship("User")
