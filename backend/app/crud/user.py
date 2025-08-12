from sqlalchemy.orm import Session
from app.models_db import User, PasswordResetToken
from app.schemas.user import UserCreate,UserUpdate
from datetime import timedelta, datetime, timezone
from typing import Optional

def get_Users(db: Session,skip: int = 0,limit: int = 100):
    return db.query(User).offset(skip).limit(limit).all()

def get_User_by_username(db:Session,username:str):
    return db.query(User).filter(User.username == username).first()

def get_user_by_id(db: Session, user_id: str) -> Optional[User]: # Changed from any to str for UUID
    # If user_id is a UUID object, convert to str if your DB stores it as string, or query directly if UUID type
    # Assuming user_id is passed as a string representation of UUID from the token
    return db.query(User).filter(User.id == user_id).first()

def get_User_by_email(db:Session,email:str):
    return db.query(User).filter(User.email == email).first()


def create_user(db:Session,user:UserCreate, google_id: Optional[str] = None) -> User:
    db_user = User(
        username=user.username,
        email=user.email,
        password_hash=user.password_hash,
        role=user.role,
        google_id=google_id
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def create_password_reset_token(db: Session, user_id: str, token: str, expires_at: datetime):
    db_token = PasswordResetToken(user_id=user_id, token=token, expires_at=expires_at)
    db.add(db_token)
    db.commit()
    db.refresh(db_token)
    return db_token

def get_password_reset_token(db: Session, token: str):
    return db.query(PasswordResetToken).filter(PasswordResetToken.token == token).first()

def delete_password_reset_token(db: Session, token: str):
    db_token = get_password_reset_token(db, token)
    if db_token:
        db.delete(db_token)
        db.commit()

def update_user_password(db: Session, user: User, password_hash: str):
    user.password_hash = password_hash
    db.commit()
    db.refresh(user)
    return user

def get_user_by_google_id(db: Session, google_id: str):
    return db.query(User).filter(User.google_id == google_id).first()

def generate_unique_username(db: Session, base_username: str) -> str:
    username = base_username
    counter = 1
    while db.query(User).filter(User.username == username).first():
        username = f"{base_username}{counter}"
        counter += 1
    return username
