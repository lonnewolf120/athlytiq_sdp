from fastapi import HTTPException
from sqlalchemy.orm import Session
from uuid import UUID
from app.models_db import Profile

def update_profile_picture(db:Session,user_id:UUID,img_url:str):
    result = db.query(Profile).filter(Profile.user_id == user_id).first()
    if not result:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    result.profile_picture_url = img_url
    db.commit()
    db.refresh(result)
    return result