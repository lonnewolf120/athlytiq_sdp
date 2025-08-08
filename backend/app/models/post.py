# from sqlalchemy import Column, Text, ForeignKey, DateTime, Enum
# from sqlalchemy.dialects.postgresql import UUID
# from datetime import datetime
# from app.database.base import Base
# import uuid
# from enum import Enum as PyEnum # Import Python's Enum

# class PrivacyType(PyEnum):
#     public = "public"
#     private = "private"
#     gymbuddies = "gymbuddies"
#     close = "close"

# class Post(Base):
#     __tablename__ = 'posts'
#     id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
#     user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
#     content = Column(Text)
#     media_url = Column(Text)
#     created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
#     updated_at = Column(DateTime(timezone=True), default=datetime.utcnow)
#     privacy = Column(Enum(PrivacyType, name="privacy_type_enum"), default=PrivacyType.public, nullable=False)
#     # community_id = Column(UUID(as_uuid=True), ForeignKey('communities.id', ondelete='SET NULL'), nullable=True)
