from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from sqlalchemy.orm import Session
from uuid import UUID

from app.api.dependencies import get_db, get_current_user
from app.schemas import social as social_schemas
from app.crud import social_crud
from app.schemas.post_schemas import PostResponse

router = APIRouter(prefix="/social", tags=["social"])

# Stories
@router.post('/stories', response_model=social_schemas.StoryPublic)
def create_story(story_in: social_schemas.StoryCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    if not current_user:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authenticated")
    res = social_crud.create_story(db=db, user_id=current_user.id, story_in=story_in)
    return res

@router.get('/stories/{user_id}', response_model=List[social_schemas.StoryPublic])
def get_user_stories(user_id: UUID, db: Session = Depends(get_db)):
    return social_crud.get_stories_for_user(db=db, user_id=user_id)

@router.get('/stories/feed', response_model=List[social_schemas.StoryPublic])
def get_stories_feed(db: Session = Depends(get_db), current_user=Depends(get_current_user), skip: int = 0, limit: int = 50):
    if not current_user:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authenticated")
    return social_crud.get_stories_feed(db=db, user_id=current_user.id, skip=skip, limit=limit)

# Buddies
@router.post('/users/{user_id}/add_buddy', response_model=social_schemas.BuddyRequestPublic)
def add_buddy(user_id: UUID, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    # user_id is the person to add
    if not current_user:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authenticated")
    res = social_crud.create_buddy_request(db=db, requester_id=current_user.id, requestee_id=user_id)
    return res

@router.post('/users/{user_id}/respond_buddy', response_model=social_schemas.BuddyRequestPublic)
def respond_buddy(user_id: UUID, resp: social_schemas.BuddyResponse, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    # user_id is the original requester
    if not current_user:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authenticated")
    res = social_crud.respond_buddy_request(db=db, requester_id=user_id, requestee_id=current_user.id, accept=resp.accept)
    if not res:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Buddy request not found")
    return res

@router.get('/users/{user_id}/buddies', response_model=List[dict])
def list_buddies(user_id: UUID, db: Session = Depends(get_db)):
    return social_crud.list_buddies(db=db, user_id=user_id)

# Communities
@router.post('/communities', response_model=social_schemas.CommunityPublic)
def create_community(community_in: social_schemas.CommunityCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    if not current_user:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authenticated")
    res = social_crud.create_community(db=db, creator_id=current_user.id, community_in=community_in)
    return res

@router.get('/communities/{community_id}', response_model=social_schemas.CommunityPublic)
def get_community(community_id: UUID, db: Session = Depends(get_db)):
    res = social_crud.get_community(db=db, community_id=community_id)
    if not res:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Community not found")
    return res

@router.get('/communities', response_model=List[social_schemas.CommunityListItem])
def list_communities(db: Session = Depends(get_db), current_user=Depends(get_current_user), skip: int = 0, limit: int = 50, my: bool = False):
    # If my=True, require auth and return only joined communities for current user
    if my:
        if not current_user:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authenticated")
        return social_crud.list_communities(db=db, user_id=current_user.id, joined_only=True, skip=skip, limit=limit)

    # When listing all, current_user may be None; joined flag will be False if not provided
    uid = current_user.id if current_user else None
    return social_crud.list_communities(db=db, user_id=uid, joined_only=False, skip=skip, limit=limit)

@router.post('/communities/{community_id}/messages', response_model=social_schemas.CommunityMessagePublic)
def post_community_message(community_id: UUID, message_in: social_schemas.CommunityMessageCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    if not current_user:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authenticated")
    res = social_crud.create_community_message(db=db, community_id=community_id, user_id=current_user.id, message_in=message_in)
    return res

@router.get('/communities/{community_id}/messages', response_model=List[social_schemas.CommunityMessagePublic])
def list_community_messages(community_id: UUID, db: Session = Depends(get_db), skip: int = 0, limit: int = 50):
    return social_crud.list_community_messages(db=db, community_id=community_id, skip=skip, limit=limit)

# Community posts
@router.get('/communities/{community_id}/posts', response_model=List[dict])
def list_posts_for_community(community_id: UUID, db: Session = Depends(get_db), skip: int = 0, limit: int = 20):
    return social_crud.list_community_posts(db=db, community_id=community_id, skip=skip, limit=limit)

@router.post('/communities/{community_id}/posts/{post_id}', response_model=dict)
def add_post_to_community(community_id: UUID, post_id: UUID, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    if not current_user:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authenticated")
    # Optional: verify current_user is author of post or a member of community
    return social_crud.add_post_to_community(db=db, community_id=community_id, post_id=post_id)

# Reports
@router.post('/reports', response_model=social_schemas.ReportPublic)
def create_report(report_in: social_schemas.ReportCreate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    if not current_user:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authenticated")
    res = social_crud.create_report(db=db, reporter_id=current_user.id, report_in=report_in)
    return res

# Community membership
@router.post('/communities/{community_id}/join', response_model=dict)
def join_community(community_id: UUID, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    if not current_user:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authenticated")
    return social_crud.join_community(db=db, community_id=community_id, user_id=current_user.id)

@router.delete('/communities/{community_id}/join', response_model=dict)
def leave_community(community_id: UUID, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    if not current_user:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authenticated")
    return social_crud.leave_community(db=db, community_id=community_id, user_id=current_user.id)
