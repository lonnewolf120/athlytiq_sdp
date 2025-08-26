from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from jose import JWTError, jwt
from pydantic import ValidationError
from typing import Optional

from app.database.base import get_db # Assuming get_db is here for session
import app.models_db # Import the entire module to ensure all models are loaded
from app.schemas.auth import TokenData # Your Pydantic model for token payload
from app.core.config import settings # Access to SECRET_KEY, ALGORITHM
from app.crud import user as user_crud # Access to get_user_by_id or similar

oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{settings.API_V1_STR}/auth/login") # Adjust tokenUrl if needed
oauth2_scheme_optional = OAuth2PasswordBearer(tokenUrl=f"{settings.API_V1_STR}/auth/login", auto_error=False)

async def get_current_user(
    db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)
) -> app.models_db.User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        user_id: str = payload.get("sub") # Assuming 'sub' contains the user_id (UUID as string)
        print(payload)
        if user_id is None:
            user_id = payload.get("user_id") # Fallback if 'user_id' is used directly
        
        # if user_id is None:
        #     raise credentials_exception
        token_data = TokenData(user_id=user_id, username=payload.get("username"), email =payload.get("email")) # username might be optional here
    except (JWTError, ValidationError) as e:
        print(f"Token decode/validation error: {e}")
        raise credentials_exception
    
    # Fetch user from DB
    # Assuming user_id in token_data.user_id is the actual UUID string.
    # Adjust user_crud.get_user_by_id if it expects a different ID format or method name.
    # For example, if user_crud.get_user_by_id expects an int, you'd need to adjust.
    # Based on your auth.py, user.id is a UUID. token_data.user_id is a string.
    user = user_crud.get_user_by_id(db, user_id=str(token_data.user_id)) # Use get_user_by_id

    if user is None:
        raise credentials_exception
    return user

async def get_current_active_user(
    current_user: app.models_db.User = Depends(get_current_user),
) -> app.models_db.User:
    # if not current_user.is_active: # Add is_active check if your User model has it
    #     raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

async def get_current_user_optional(
    db: Session = Depends(get_db), 
    token: Optional[str] = Depends(oauth2_scheme_optional)
) -> Optional[app.models_db.User]:
    """
    Optional authentication - returns User if valid token provided, None otherwise.
    Does not raise exceptions for missing or invalid tokens.
    """
    if not token:
        return None
    
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            return None
        token_data = TokenData(
            user_id=user_id, 
            username=payload.get("username"), 
            email=payload.get("email")
        )
    except (JWTError, ValidationError):
        return None
    
    user = user_crud.get_user_by_id(db, user_id=token_data.user_id)
    if user is None:
        return None
    return user

# If you need a superuser check:
# async def get_current_active_superuser(
#     current_user: app.models_db.User = Depends(get_current_user),
# ) -> app.models_db.User:
#     if not user_crud.is_superuser(current_user): # Assuming is_superuser check in user_crud
#         raise HTTPException(
#             status_code=403, detail="The user doesn't have enough privileges"
#         )
#     return current_user
