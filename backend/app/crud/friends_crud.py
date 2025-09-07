from sqlalchemy.orm import Session
from sqlalchemy import or_, and_, func
from app.models_db import User, FriendRequest, Friend
from app.schemas.friends import FriendRequestCreate
from typing import List, Optional
from uuid import UUID
from datetime import datetime


def search_users(db: Session, query: str, current_user_id: UUID, limit: int = 20) -> List[User]:
    """Search for users by username or email, excluding current user"""
    return db.query(User).filter(
        or_(
            User.username.ilike(f"%{query}%"),
            User.email.ilike(f"%{query}%")
        ),
        User.id != current_user_id
    ).limit(limit).all()


def send_friend_request(db: Session, sender_id: UUID, receiver_id: UUID) -> FriendRequest:
    """Send a friend request"""
    if sender_id == receiver_id:
        raise ValueError("Cannot send friend request to yourself")
    
    # Check if request already exists (in either direction)
    existing = db.query(FriendRequest).filter(
        or_(
            and_(FriendRequest.sender_id == sender_id, FriendRequest.receiver_id == receiver_id),
            and_(FriendRequest.sender_id == receiver_id, FriendRequest.receiver_id == sender_id)
        )
    ).first()
    
    if existing:
        raise ValueError("Friend request already exists")
    
    # Check if already friends
    friendship = db.query(Friend).filter(
        or_(
            and_(Friend.user1_id == min(sender_id, receiver_id), Friend.user2_id == max(sender_id, receiver_id))
        )
    ).first()
    
    if friendship:
        raise ValueError("Already friends")
    
    # Create new friend request
    request = FriendRequest(sender_id=sender_id, receiver_id=receiver_id)
    db.add(request)
    db.commit()
    db.refresh(request)
    return request


def get_friend_requests(db: Session, user_id: UUID) -> List[FriendRequest]:
    """Get pending friend requests for a user"""
    return db.query(FriendRequest).filter(
        FriendRequest.receiver_id == user_id,
        FriendRequest.status == 'pending'
    ).all()


def get_sent_friend_requests(db: Session, user_id: UUID) -> List[FriendRequest]:
    """Get sent friend requests by a user"""
    return db.query(FriendRequest).filter(
        FriendRequest.sender_id == user_id,
        FriendRequest.status == 'pending'
    ).all()


def handle_friend_request(db: Session, request_id: UUID, action: str, user_id: UUID) -> FriendRequest:
    """Accept or reject a friend request"""
    request = db.query(FriendRequest).filter(
        FriendRequest.id == request_id,
        FriendRequest.receiver_id == user_id,
        FriendRequest.status == 'pending'
    ).first()
    
    if not request:
        raise ValueError("Friend request not found or already handled")
    
    request.status = action
    request.updated_at = datetime.utcnow()
    
    if action == 'accepted':
        # Create friendship with consistent ordering (smaller UUID first)
        user1_id = min(request.sender_id, request.receiver_id)
        user2_id = max(request.sender_id, request.receiver_id)
        
        friendship = Friend(user1_id=user1_id, user2_id=user2_id)
        db.add(friendship)
    
    db.commit()
    db.refresh(request)
    return request


def get_friends(db: Session, user_id: UUID) -> List[dict]:
    """Get all friends of a user with their details"""
    friends_query = db.query(Friend).filter(
        or_(Friend.user1_id == user_id, Friend.user2_id == user_id)
    ).all()
    
    friend_data = []
    for friendship in friends_query:
        friend_id = friendship.user2_id if friendship.user1_id == user_id else friendship.user1_id
        friend_user = db.query(User).filter(User.id == friend_id).first()
        
        if friend_user:
            friend_data.append({
                'id': friendship.id,
                'user_id': friend_user.id,
                'username': friend_user.username,
                'display_name': getattr(friend_user, 'display_name', None),
                'avatar_url': getattr(friend_user, 'avatar_url', None),
                'created_at': friendship.created_at
            })
    
    return friend_data


def check_friendship_status(db: Session, user1_id: UUID, user2_id: UUID) -> dict:
    """Check if two users are friends or have pending requests"""
    # Check friendship
    friendship = db.query(Friend).filter(
        or_(
            and_(Friend.user1_id == min(user1_id, user2_id), Friend.user2_id == max(user1_id, user2_id))
        )
    ).first()
    
    if friendship:
        return {'is_friend': True, 'has_pending_request': False}
    
    # Check pending requests
    pending_request = db.query(FriendRequest).filter(
        or_(
            and_(FriendRequest.sender_id == user1_id, FriendRequest.receiver_id == user2_id),
            and_(FriendRequest.sender_id == user2_id, FriendRequest.receiver_id == user1_id)
        ),
        FriendRequest.status == 'pending'
    ).first()
    
    return {
        'is_friend': False, 
        'has_pending_request': pending_request is not None
    }


def remove_friend(db: Session, user_id: UUID, friend_user_id: UUID) -> bool:
    """Remove a friend relationship"""
    friendship = db.query(Friend).filter(
        or_(
            and_(Friend.user1_id == min(user_id, friend_user_id), Friend.user2_id == max(user_id, friend_user_id))
        )
    ).first()
    
    if friendship:
        db.delete(friendship)
        db.commit()
        return True
    return False
