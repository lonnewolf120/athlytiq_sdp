from sqlalchemy import Column, String, Integer, Float, DateTime, ForeignKey, Boolean, ARRAY, Text, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import enum

from app.db.base_class import Base


class TrainerSpecialization(str, enum.Enum):
    WEIGHT_TRAINING = "weight_training"
    CARDIO = "cardio"
    YOGA = "yoga"
    PILATES = "pilates"
    CROSSFIT = "crossfit"
    MARTIAL_ARTS = "martial_arts"
    DANCE = "dance"
    SPORTS = "sports"
    REHABILITATION = "rehabilitation"
    NUTRITION = "nutrition"


class TrainerApplicationStatus(str, enum.Enum):
    PENDING = "pending"
    IN_REVIEW = "in_review"
    APPROVED = "approved"
    REJECTED = "rejected"
    ADDITIONAL_INFO_NEEDED = "additional_info_needed"


class TrainerApplication(Base):
    __tablename__ = "trainer_applications"

    id = Column(UUID(as_uuid=True), primary_key=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    full_name = Column(String, nullable=False)
    bio = Column(Text, nullable=False)
    years_of_experience = Column(Integer, nullable=False)
    specializations = Column(ARRAY(SQLEnum(TrainerSpecialization)), nullable=False)
    certification_details = Column(Text, nullable=False)
    id_document_url = Column(String, nullable=False)
    certification_document_urls = Column(ARRAY(String), nullable=False)
    profile_photo_url = Column(String, nullable=False)
    contact_email = Column(String, nullable=False)
    phone_number = Column(String, nullable=False)
    social_links = Column(Text)  # JSON string
    status = Column(SQLEnum(TrainerApplicationStatus), default=TrainerApplicationStatus.PENDING)
    feedback = Column(Text)
    reviewed_by = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    reviewed_at = Column(DateTime)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user = relationship("User", foreign_keys=[user_id])
    reviewer = relationship("User", foreign_keys=[reviewed_by])


class TrainerPost(Base):
    __tablename__ = "trainer_posts"

    id = Column(UUID(as_uuid=True), primary_key=True)
    trainer_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    title = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    category = Column(SQLEnum(TrainerSpecialization), nullable=False)
    tags = Column(ARRAY(String), default=[])
    image_urls = Column(ARRAY(String), default=[])
    likes_count = Column(Integer, default=0)
    comments_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    trainer = relationship("User")
    comments = relationship("TrainerPostComment", back_populates="post")
    likes = relationship("TrainerPostLike", back_populates="post")


class TrainerPostComment(Base):
    __tablename__ = "trainer_post_comments"

    id = Column(UUID(as_uuid=True), primary_key=True)
    post_id = Column(UUID(as_uuid=True), ForeignKey("trainer_posts.id"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    post = relationship("TrainerPost", back_populates="comments")
    user = relationship("User")


class TrainerPostLike(Base):
    __tablename__ = "trainer_post_likes"

    id = Column(UUID(as_uuid=True), primary_key=True)
    post_id = Column(UUID(as_uuid=True), ForeignKey("trainer_posts.id"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)

    post = relationship("TrainerPost", back_populates="likes")
    user = relationship("User")


class PlanVerification(Base):
    __tablename__ = "plan_verifications"

    id = Column(UUID(as_uuid=True), primary_key=True)
    plan_id = Column(UUID(as_uuid=True), nullable=False)
    plan_type = Column(String, nullable=False)  # 'workout' or 'meal'
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    trainer_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    status = Column(String, default="pending")
    feedback = Column(Text)
    is_approved = Column(Boolean)
    suggestions = Column(ARRAY(String))
    notes = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime)

    user = relationship("User", foreign_keys=[user_id])
    trainer = relationship("User", foreign_keys=[trainer_id])


class TrainerChatRoom(Base):
    __tablename__ = "trainer_chat_rooms"

    id = Column(UUID(as_uuid=True), primary_key=True)
    trainer_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)
    last_message = Column(Text)
    last_message_at = Column(DateTime)
    trainer_unread_count = Column(Integer, default=0)
    user_unread_count = Column(Integer, default=0)

    trainer = relationship("User", foreign_keys=[trainer_id])
    user = relationship("User", foreign_keys=[user_id])
    messages = relationship("TrainerChat", back_populates="room")


class TrainerChat(Base):
    __tablename__ = "trainer_chats"

    id = Column(UUID(as_uuid=True), primary_key=True)
    room_id = Column(UUID(as_uuid=True), ForeignKey("trainer_chat_rooms.id"))
    sender_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    message = Column(Text, nullable=False)
    attachment_urls = Column(ARRAY(String), default=[])
    created_at = Column(DateTime, default=datetime.utcnow)
    read_at = Column(DateTime)

    room = relationship("TrainerChatRoom", back_populates="messages")
    sender = relationship("User")
