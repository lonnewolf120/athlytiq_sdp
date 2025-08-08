from pydantic import BaseModel,UUID4,Field,EmailStr
from typing import Optional
from uuid import UUID
from datetime import datetime
from .profile import ProfilePublic # Import ProfilePublic

class UserBase(BaseModel):
    username:str = Field(...,min_length=3,max_length=50)
    email:EmailStr

# class UserCreate(UserBase):
#     password:str = Field(...,min_length=3,max_length=8)
#     role: Optional[str] = Field("user", min_length=3, max_length=20)

class UserCreate(UserBase):
    password_hash: Optional[str] = None
    role: Optional[str] = Field("user", min_length=3, max_length=20)

class UserUpdate(UserBase):
    username: Optional[str] = Field(None, min_length=3, max_length=50)
    email: Optional[EmailStr] = None
    password: Optional[str] = Field(None, min_length=3)
    role: Optional[str] = Field(None, min_length=3, max_length=20)


class UserInDB(UserBase):
    id: UUID
    role: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class UserPublic(UserBase):
    id: UUID
    role: str
    created_at: datetime
    profile: Optional[ProfilePublic] = None # Include ProfilePublic as a nested object
    
    class Config:
        from_attributes = True
