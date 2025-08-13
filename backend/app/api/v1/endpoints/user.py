from fastapi import APIRouter, Depends, HTTPException, status,UploadFile,File
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from typing import List
from jose import JWTError, jwt
from sqlalchemy.orm import joinedload

from app.database.base import get_db
from app.models_db import User
from app.schemas.user import UserInDB, UserPublic
from app.core.auth import secret_key, algo
from app.crud.user import get_Users, get_User_by_email, get_User_by_username
from app.crud.crud_profile import update_profile_picture
import cloudinary.uploader

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/v1/auth/login")

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, secret_key, algorithms=[algo])
        user_id: str = payload.get("user_id")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = db.query(User).options(joinedload(User.profile)).filter(User.id == user_id).first()
    # print(user.profile)
    if user is None:
        raise credentials_exception
    return user

router = APIRouter()

# Security issue: sWe can't get all users from user endpoint!
# @router.get("/",response_model=List[UserInDB])
# def read_user(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
#     response  = get_Users(db,skip = skip,limit = limit)
#     print(f"The Data type from Response is = {type(response)} and data is {response}")
#     return response

@router.get("/me", response_model=UserPublic)
async def read_users_me(current_user: User = Depends(get_current_user)):
    print(f"Current User: {current_user}")
    return current_user

@router.post("/upload-pfp",summary="Upload a profile picture")
async def upload_profile_picture(
    file:UploadFile=File(...),
    db:Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Invalid file type. Must be an image.")
    
    try:
        upload_result = cloudinary.uploader.upload(
            file.file,
            folder="profile_picture",
            use_filename=True,
            unique_filename=False
        )
        img_url = upload_result.get("secure_url")
        if not img_url:
            raise HTTPException(status_code=500, detail="Failed to upload image")
        
        update_profile = update_profile_picture(db=db,user_id=current_user.id,img_url=img_url)
        
        return{
            "message":"Profile Picture Uploaded Successfully",
            "medial_url":update_profile.profile_picture_url
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))