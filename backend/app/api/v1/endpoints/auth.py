from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import timedelta, datetime, timezone

from app.database.base import get_db
from app.models_db import User
from app.models_db import RefreshToken
from app.schemas.auth import Token, TokenData
from app.schemas.auth import Token, TokenData, PasswordResetRequest, PasswordReset, GoogleOAuthToken, LoginRequest
from app.schemas.user import UserCreate, UserPublic # Corrected import
from app.core.auth import (
    create_access_token,
    hash_token,
    verify_password,
    get_password_hash,
    token_expire_minutes,
)
from app.crud.user import get_User_by_username, create_user
import secrets
from app.crud.user import (
    get_User_by_email,
    create_user,
    create_password_reset_token,
    get_password_reset_token,
    delete_password_reset_token,
    update_user_password,
    get_user_by_google_id,
    generate_unique_username,
)
from app.core.email import send_email
from fastapi import BackgroundTasks
import uuid
from datetime import datetime, timedelta
from fastapi.encoders import jsonable_encoder
from app.core.config import settings
import firebase_admin
from firebase_admin import auth
from firebase_admin import credentials

# Initialize Firebase Admin SDK
import os

try:
    key_path = os.path.join(os.path.dirname(__file__), "serviceAccountKey.json")
    cred = credentials.Certificate(key_path)
    firebase_admin.initialize_app(cred)
except Exception as e:
    print(f"Error initializing Firebase Admin SDK: {e}")

router = APIRouter()


@router.post("/register", response_model=UserPublic) # Corrected response_model
async def register(user: UserCreate, db: Session = Depends(get_db)):
    if db.query(User).filter(User.username == user.username).first():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Username already taken"
        )
    if db.query(User).filter(User.email == user.email).first():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Email already taken"
        )

    hashed_pass = get_password_hash(user.password)
    db_user = User(
        username=user.username,
        email=user.email,
        password_hash=hashed_pass,
        role=user.role,
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


@router.post("/login", response_model=Token)
async def login_for_access_token(
    request: LoginRequest, db: Session = Depends(get_db)
):
    print(request)
    user = get_User_by_email(db, email=request.email) # Removed await
    if not user or not verify_password(request.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token_expires = timedelta(minutes=token_expire_minutes)
    access_token = create_access_token(
        data={"sub": str(user.id), "user_id": str(user.id), "username": user.username, "email": user.email}, expires_delta=access_token_expires
    )
    refresh_token_raw = secrets.token_urlsafe(64)
    refresh_token_hash = hash_token(refresh_token_raw)
    refresh_expires_at = datetime.now(timezone.utc) + timedelta(days=60)
    db_token = RefreshToken(
        user_id=user.id, token_hash=refresh_token_hash, expires_at=refresh_expires_at
    )
    db.add(db_token)
    db.commit()
    return {
        "access_token": access_token,
        "refresh_token": refresh_token_raw,
        "token_type": "bearer",
    }


@router.post("/refresh", response_model=Token)
async def refresh_access_token(refresh_token: str, db: Session = Depends(get_db)):
    token_hash = hash_token(refresh_token)
    db_token = (
        db.query(RefreshToken).filter(RefreshToken.token_hash == token_hash).first()
    )

    if not db_token or db_token.revoked_at is not None:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    if db_token.expires_at < datetime.now(timezone.utc):
        raise HTTPException(status_code=401, detail="Refresh token expired")

    user = db.query(User).filter(User.id == db_token.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    access_token = create_access_token(
        data={"sub": user.username, "user_id": str(user.id), "role": user.role},
        expires_delta=timedelta(minutes=token_expire_minutes),
    )

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
    }
@router.post("/logout")
async def logout(refresh_token:str,db:Session = Depends(get_db)):
    token_hash = hash_token(refresh_token)
    db_token = db.query(RefreshToken).filter(RefreshToken.token_hash == token_hash).first()

    if not db_token:
        raise HTTPException(status_code=404, detail="Token not found")
    db_token.revoked_at = datetime.utcnow()
    db.commit()

    return {"detail": "Logged out"}
           
    #         data={"sub": str(user.id)},
    #         expires_delta=access_token_expires
    #     )
    # return {"access_token": access_token, "token_type": "bearer"}


@router.post("/forgot-password")
async def forgot_password(
    request: PasswordResetRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )

    token = str(uuid.uuid4())
    expires_at = datetime.utcnow() + timedelta(hours=24)
    create_password_reset_token(db, str(user.id), token, expires_at)
    print(f"Password reset token created, token: {token} user_id: {str(user.id)}")

    reset_link = f"{settings.FRONTEND_URL}/reset-password?token={token}&user_id={str(user.id)}"
    email_sent = await send_email(user.email, "Password Reset Request", f"This is a system generated mail to change your password for your Pulse account.\nClick this link to reset your password: {reset_link}")
    if email_sent:
        return {"message": "Password reset email sent successfully."}
    else:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to send password reset email. Please try again later."
        )


@router.post("/reset-password")
async def reset_password(request: PasswordReset, db: Session = Depends(get_db)):
    token = get_password_reset_token(db, request.token)
    if not token:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid token"
        )
    if token.expires_at < datetime.utcnow():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Token expired"
        )

    user = db.query(User).filter(User.id == token.user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )

    hashed_password = get_password_hash(request.password)
    update_user_password(db, user, hashed_password)
    delete_password_reset_token(db, request.token)
    return {"message": "Password reset successfully"}


@router.post("/google-login", response_model=Token)
async def google_login(request: GoogleOAuthToken, db: Session = Depends(get_db)):
    try:
        decoded_token = auth.verify_id_token(request.token)
        uid = decoded_token["uid"]
        email = decoded_token["email"]
        name = decoded_token.get("name", email.split('@')[0]) # Use email prefix as name if not provided
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail=f"Invalid Google OAuth token: {e}"
        )

    user = get_user_by_google_id(db, uid)
    if not user:
        # Check if a user with this email already exists (e.g., they registered with email/password)
        user = get_User_by_email(db, email)
        if not user:
            # Generate a unique username
            unique_username = generate_unique_username(db, name)
            # Create a new user if no existing user with this Google ID or email
            user_create_schema = UserCreate(
                username=unique_username, # Use the unique username
                email=email,
                password_hash=None, # No password for Google-authenticated users
                role="user"
            )
            user = create_user(db, user_create_schema, google_id=uid)
        else:
            # Link Google ID to existing user
            user.google_id = uid
            db.commit()
            db.refresh(user)

    access_token_expires = timedelta(minutes=token_expire_minutes)
    access_token = create_access_token(
        data={"sub": str(user.id), "user_id": str(user.id), "username": user.username, "email": user.email},
        expires_delta=access_token_expires
    )
    refresh_token_raw = secrets.token_urlsafe(64)
    refresh_token_hash = hash_token(refresh_token_raw)
    refresh_expires_at = datetime.now(timezone.utc) + timedelta(days=60)
    db_token = RefreshToken(
        user_id=user.id, token_hash=refresh_token_hash, expires_at=refresh_expires_at
    )
    db.add(db_token)
    db.commit()

    return {
        "access_token": access_token,
        "refresh_token": refresh_token_raw,
        "token_type": "bearer",
    }
