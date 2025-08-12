from typing import List, Optional
from fastapi import Depends, HTTPException, status, Query
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from jose import JWTError, jwt
from pydantic import ValidationError

from app.database.base import get_db # Assuming get_db is here for session
from app.models_db import User # Your SQLAlchemy User model
from app.schemas.auth import TokenData # Your Pydantic model for token payload
from app.schemas.post_schemas import PostType # Import PostType enum
from app.core.config import settings # Access to SECRET_KEY, ALGORITHM
from app.crud import user as user_crud # Access to get_user_by_id or similar

oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{settings.API_V1_STR}/auth/login") # Adjust tokenUrl if needed

async def get_current_user(
    db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)
) -> User:
    print(f"[AUTH_DEBUG] get_current_user called. Raw token received: {token[:20]}...") # Log raw token (first 20 chars)
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        print(f"[AUTH_DEBUG] Attempting to decode token.")
        print(f"[AUTH_DEBUG] SECRET_KEY starts with: {settings.SECRET_KEY[:5] if settings.SECRET_KEY else 'NOT SET'}")
        print(f"[AUTH_DEBUG] ALGORITHM: {settings.ALGORITHM}")
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        print(f"[AUTH_DEBUG] Token decoded successfully. Payload: {payload}")
        user_id: str = payload.get("sub") # Assuming 'sub' contains the user_id (UUID as string)
        print(f"[AUTH_DEBUG] Extracted 'sub' from payload: {user_id}")
        if user_id is None:
            user_id = payload.get("user_id") # Fallback if 'user_id' is used directly
            print(f"[AUTH_DEBUG] 'sub' was None, extracted 'user_id' from payload: {user_id}")
        
        if user_id is None:
            print(f"[AUTH_DEBUG] user_id is None after checking 'sub' and 'user_id'. Raising credentials_exception.")
            raise credentials_exception
        
        # Ensure token_data can handle user_id being None temporarily if validation fails
        token_data_payload = {"user_id": user_id, "username": payload.get("username")}
        print(f"[AUTH_DEBUG] Creating TokenData with: {token_data_payload}")
        # token_data = TokenData(**token_data_payload) 
        # print(f"[AUTH_DEBUG] TokenData created: {token_data}")

    except JWTError as e:
        print(f"[AUTH_DEBUG] JWTError during token decoding: {e}")
        raise credentials_exception
    except ValidationError as e:
        print(f"[AUTH_DEBUG] ValidationError for TokenData: {e}")
        raise credentials_exception
    except Exception as e:
        print(f"[AUTH_DEBUG] Unexpected error during token processing: {e}")
        raise credentials_exception
    
    print(f"[AUTH_DEBUG] Attempting to fetch user from DB with user_id: {user_id} (type: {type(user_id)})")
    # Fetch user from DB
    # Assuming user_id in token_data.user_id is the actual UUID string.
    # Adjust user_crud.get_user_by_id if it expects a different ID format or method name.
    # For example, if user_crud.get_user_by_id expects an int, you'd need to adjust.
    # Based on your auth.py, user.id is a UUID. token_data.user_id is a string.
    user = user_crud.get_user_by_id(db, user_id=str(user_id)) # Use get_user_by_id
    print(f"[AUTH_DEBUG] User fetched from DB: {user.id if user else 'None'}")

    if user is None:
        print(f"[AUTH_DEBUG] User not found in DB for user_id: {user_id}. Raising credentials_exception.")
        raise credentials_exception
    
    print(f"[AUTH_DEBUG] User {user.id} authenticated successfully.")
    return user

async def get_current_active_user(
    current_user: User = Depends(get_current_user),
) -> User:
    # if not current_user.is_active: # Add is_active check if your User model has it
    #     raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

# If you need a superuser check:
# async def get_current_active_superuser(
#     current_user: User = Depends(get_current_user),
# ) -> User:
#     if not user_crud.is_superuser(current_user): # Assuming is_superuser check in user_crud
#         raise HTTPException(
#             status_code=403, detail="The user doesn't have enough privileges"
#         )
#     return current_user

async def list_post_types(
    post_types_str: Optional[str] = Query(
        None,
        alias="post_type",
        description="Comma-separated list of post types (e.g., 'workout,challenge')"
    )
) -> Optional[List[PostType]]:
    if post_types_str is None:
        return None
    
    types = [pt.strip() for pt in post_types_str.split(',') if pt.strip()]
    
    # Validate each type against the PostType enum
    valid_types = []
    for t in types:
        try:
            valid_types.append(PostType(t))
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid post type: {t}. Allowed types are: {', '.join([pt.value for pt in PostType])}"
            )
    return valid_types
