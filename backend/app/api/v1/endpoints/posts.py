from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.schemas.post_schemas import PostCreate, PostResponse, PostUpdate, PostType
from app.crud import post_crud
from app.api import deps
from app.models_db import User

router = APIRouter()

@router.post("/", response_model=PostResponse, status_code=status.HTTP_201_CREATED)
def create_new_post(
    post_in: PostCreate,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """
    Create a new post.
    """
    if not post_in.content and not post_in.mediaUrl and not post_in.workoutData and not post_in.challengeData:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Post must have content, media, workout data, or challenge data."
        )
    
    # Ensure only one type of nested data is provided
    if sum([bool(post_in.workoutData), bool(post_in.challengeData)]) > 1:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A post can only contain one type of structured data (workout or challenge)."
        )

    # Validate post_type matches provided data
    if PostType.workout in post_in.postType and not post_in.workoutData:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Post type 'workout' requires workout_data."
        )
    if PostType.challenge in post_in.postType and not post_in.challengeData:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Post type 'challenge' requires challenge_data."
        )
    if (PostType.text in post_in.postType or not post_in.postType) and (post_in.workoutData or post_in.challengeData):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Post type 'text' cannot have workout_data or challenge_data."
        )
    
    # If no specific post type is provided, default to text
    if not post_in.postType:
        post_in.postType = [PostType.text]


    db_post = post_crud.create_post(db=db, post_data=post_in, user_id=str(current_user.id))
    return db_post

@router.get("/{post_id}", response_model=PostResponse)
def read_post_by_id(
    post_id: str,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user) # Authentication required to view any post
):
    """
    Retrieve a single post by its ID.
    """
    post = post_crud.get_post(db, post_id=post_id)
    if not post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")
    return post

@router.get("/", response_model=List[PostResponse])
def read_posts(
    skip: int = 0,
    limit: int = 100,
    user_id: Optional[str] = None,
    post_types: Optional[List[PostType]] = Depends(deps.list_post_types), # Custom dependency to parse list of enums
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user) # Authentication required to view feed
):
    """
    Retrieve multiple posts. Can filter by user_id and post_types.
    """
    posts = post_crud.get_posts(db, user_id=user_id, post_types=post_types, skip=skip, limit=limit)
    return posts

@router.put("/{post_id}", response_model=PostResponse)
def update_existing_post(
    post_id: str,
    post_update: PostUpdate,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """
    Update an existing post. Only the author can update their post.
    """
    db_post = post_crud.get_post(db, post_id=post_id)
    if not db_post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")
    if str(db_post.user_id) != str(current_user.id):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to update this post")

    # Ensure only one type of nested data is provided if updating
    if post_update.workoutData and post_update.challengeData:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A post can only contain one type of structured data (workout or challenge)."
        )
    
    # Validate post_type matches provided data if post_type is being updated
    if post_update.postType:
        if PostType.workout in post_update.postType and not post_update.workoutData and not db_post.workout_data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Post type 'workout' requires workout_data."
            )
        if PostType.challenge in post_update.postType and not post_update.challengeData and not db_post.challenge_data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Post type 'challenge' requires challenge_data."
            )
        if (PostType.text in post_update.postType or not post_update.postType) and (post_update.workoutData or post_update.challengeData):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Post type 'text' cannot have workout_data or challenge_data."
            )

    updated_post = post_crud.update_post(db=db, post_id=post_id, post_update=post_update)
    return updated_post

@router.delete("/{post_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_existing_post(
    post_id: str,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_user)
):
    """
    Delete a post. Only the author can delete their post.
    """
    db_post = post_crud.get_post(db, post_id=post_id)
    if not db_post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")
    if str(db_post.user_id) != str(current_user.id):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to delete this post")
    
    post_crud.delete_post(db, post_id=post_id)
    return {"message": "Post deleted successfully"}

@router.get("/feed/public", response_model=List[PostResponse])
def read_public_feed(
    skip: int = 0,
    limit: int = 20, # Default limit to 20 posts per page
    db: Session = Depends(deps.get_db)
):
    """
    Retrieve public posts for the main feed. No authentication required.
    """
    posts = post_crud.get_public_feed(db, skip=skip, limit=limit)
    return posts
