from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete, and_, or_, func, text, case
from typing import List, Optional, Dict, Any, Tuple
from uuid import UUID, uuid4
from datetime import datetime, timedelta

from app.schemas.chat import (
    FriendRequestCreate, FriendRequestResponse, UserSearchResult,
    FriendRequestStatus
)

class FriendsCRUD:
    """CRUD operations for friends functionality"""
    
    async def send_friend_request(
        self,
        db: AsyncSession,
        sender_id: UUID,
        receiver_id: UUID,
        message: Optional[str] = None
    ) -> Dict[str, Any]:
        """Send a friend request"""
        
        if sender_id == receiver_id:
            raise ValueError("Cannot send friend request to yourself")
        
        # Check if request already exists
        existing_request = text("""
            SELECT id, status FROM friend_requests 
            WHERE (sender_id = :sender_id AND receiver_id = :receiver_id)
            OR (sender_id = :receiver_id AND receiver_id = :sender_id)
            ORDER BY created_at DESC
            LIMIT 1
        """)
        
        result = await db.execute(existing_request, {
            'sender_id': str(sender_id),
            'receiver_id': str(receiver_id)
        })
        
        existing = result.fetchone()
        if existing:
            if existing.status == 'pending':
                raise ValueError("Friend request already pending")
            elif existing.status == 'accepted':
                raise ValueError("Users are already friends")
            elif existing.status == 'blocked':
                raise ValueError("Cannot send friend request - blocked")
        
        # Create new friend request
        request_id = uuid4()
        
        insert_request = text("""
            INSERT INTO friend_requests (id, sender_id, receiver_id, message, status)
            VALUES (:id, :sender_id, :receiver_id, :message, 'pending')
        """)
        
        await db.execute(insert_request, {
            'id': str(request_id),
            'sender_id': str(sender_id),
            'receiver_id': str(receiver_id),
            'message': message
        })
        
        await db.commit()
        
        return await self.get_friend_request_details(db, request_id, sender_id)
    
    async def respond_to_friend_request(
        self,
        db: AsyncSession,
        request_id: UUID,
        user_id: UUID,
        accept: bool
    ) -> Dict[str, Any]:
        """Accept or reject a friend request"""
        
        # Verify the request exists and user is the receiver
        verify_request = text("""
            SELECT sender_id, receiver_id, status FROM friend_requests 
            WHERE id = :request_id AND receiver_id = :user_id
        """)
        
        result = await db.execute(verify_request, {
            'request_id': str(request_id),
            'user_id': str(user_id)
        })
        
        request_data = result.fetchone()
        if not request_data:
            raise ValueError("Friend request not found or you're not authorized to respond")
        
        if request_data.status != 'pending':
            raise ValueError(f"Cannot respond to {request_data.status} request")
        
        new_status = 'accepted' if accept else 'rejected'
        
        # Update request status
        update_request = text("""
            UPDATE friend_requests 
            SET status = :status, responded_at = CURRENT_TIMESTAMP
            WHERE id = :request_id
        """)
        
        await db.execute(update_request, {
            'status': new_status,
            'request_id': str(request_id)
        })
        
        # If accepted, add to buddies table for mutual friendship
        if accept:
            # Add friendship both ways
            insert_friendship1 = text("""
                INSERT INTO buddies (user_id, buddy_user_id, status, created_at)
                VALUES (:user1, :user2, 'accepted', CURRENT_TIMESTAMP)
                ON CONFLICT (user_id, buddy_user_id) DO UPDATE SET status = 'accepted'
            """)
            
            insert_friendship2 = text("""
                INSERT INTO buddies (user_id, buddy_user_id, status, created_at)
                VALUES (:user2, :user1, 'accepted', CURRENT_TIMESTAMP)
                ON CONFLICT (user_id, buddy_user_id) DO UPDATE SET status = 'accepted'
            """)
            
            await db.execute(insert_friendship1, {
                'user1': str(user_id),
                'user2': str(request_data.sender_id)
            })
            
            await db.execute(insert_friendship2, {
                'user1': str(request_data.sender_id),
                'user2': str(user_id)
            })
        
        await db.commit()
        
        return await self.get_friend_request_details(db, request_id, user_id)
    
    async def get_friend_requests(
        self,
        db: AsyncSession,
        user_id: UUID,
        request_type: str = "received",  # "received", "sent", "all"
        status: Optional[str] = None,
        skip: int = 0,
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get friend requests for a user"""
        
        where_conditions = []
        params = {'user_id': str(user_id), 'skip': skip, 'limit': limit}
        
        if request_type == "received":
            where_conditions.append("fr.receiver_id = :user_id")
        elif request_type == "sent":
            where_conditions.append("fr.sender_id = :user_id")
        else:  # all
            where_conditions.append("(fr.sender_id = :user_id OR fr.receiver_id = :user_id)")
        
        if status:
            where_conditions.append("fr.status = :status")
            params['status'] = status
        
        where_clause = " AND ".join(where_conditions)
        
        requests_query = text(f"""
            SELECT 
                fr.id,
                fr.sender_id,
                fr.receiver_id,
                fr.message,
                fr.status,
                fr.created_at,
                fr.responded_at,
                sender_u.username as sender_username,
                sender_p.display_name as sender_display_name,
                sender_p.profile_picture_url as sender_avatar,
                receiver_u.username as receiver_username,
                receiver_p.display_name as receiver_display_name,
                receiver_p.profile_picture_url as receiver_avatar,
                sender_uos.is_online as sender_is_online,
                sender_uos.last_seen as sender_last_seen,
                receiver_uos.is_online as receiver_is_online,
                receiver_uos.last_seen as receiver_last_seen
            FROM friend_requests fr
            JOIN users sender_u ON sender_u.id = fr.sender_id
            JOIN users receiver_u ON receiver_u.id = fr.receiver_id
            LEFT JOIN profiles sender_p ON sender_p.user_id = fr.sender_id
            LEFT JOIN profiles receiver_p ON receiver_p.user_id = fr.receiver_id
            LEFT JOIN user_online_status sender_uos ON sender_uos.user_id = fr.sender_id
            LEFT JOIN user_online_status receiver_uos ON receiver_uos.user_id = fr.receiver_id
            WHERE {where_clause}
            ORDER BY fr.created_at DESC
            LIMIT :limit OFFSET :skip
        """)
        
        result = await db.execute(requests_query, params)
        
        requests = []
        for row in result.fetchall():
            # Determine which user is the "other" user relative to the current user
            if str(row.sender_id) == str(user_id):
                other_user = {
                    'user_id': row.receiver_id,
                    'username': row.receiver_username,
                    'display_name': row.receiver_display_name,
                    'avatar_url': row.receiver_avatar,
                    'is_online': row.receiver_is_online or False,
                    'last_seen': row.receiver_last_seen
                }
            else:
                other_user = {
                    'user_id': row.sender_id,
                    'username': row.sender_username,
                    'display_name': row.sender_display_name,
                    'avatar_url': row.sender_avatar,
                    'is_online': row.sender_is_online or False,
                    'last_seen': row.sender_last_seen
                }
            
            requests.append({
                'id': row.id,
                'sender_id': row.sender_id,
                'receiver_id': row.receiver_id,
                'message': row.message,
                'status': row.status,
                'created_at': row.created_at,
                'responded_at': row.responded_at,
                'other_user': other_user,
                'is_sent_by_current_user': str(row.sender_id) == str(user_id)
            })
        
        return requests
    
    async def get_friends_list(
        self,
        db: AsyncSession,
        user_id: UUID,
        search_query: Optional[str] = None,
        online_only: bool = False,
        skip: int = 0,
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get user's friends list"""
        
        where_conditions = ["b.user_id = :user_id", "b.status = 'accepted'"]
        params = {'user_id': str(user_id), 'skip': skip, 'limit': limit}
        
        if search_query:
            where_conditions.append("""
                (u.username ILIKE :search_query OR p.display_name ILIKE :search_query)
            """)
            params['search_query'] = f"%{search_query}%"
        
        if online_only:
            where_conditions.append("uos.is_online = true")
        
        where_clause = " AND ".join(where_conditions)
        
        friends_query = text(f"""
            SELECT 
                u.id as user_id,
                u.username,
                u.email,
                p.display_name,
                p.profile_picture_url,
                p.bio,
                uos.is_online,
                uos.last_seen,
                b.created_at as friendship_since,
                -- Check if there's an existing direct chat
                (
                    SELECT cr.id FROM chat_rooms cr
                    JOIN chat_participants cp1 ON cp1.room_id = cr.id AND cp1.user_id = :user_id
                    JOIN chat_participants cp2 ON cp2.room_id = cr.id AND cp2.user_id = u.id
                    WHERE cr.type = 'direct'
                    LIMIT 1
                ) as direct_chat_room_id
            FROM buddies b
            JOIN users u ON u.id = b.buddy_user_id
            LEFT JOIN profiles p ON p.user_id = u.id
            LEFT JOIN user_online_status uos ON uos.user_id = u.id
            WHERE {where_clause}
            ORDER BY 
                uos.is_online DESC,
                p.display_name ASC,
                u.username ASC
            LIMIT :limit OFFSET :skip
        """)
        
        result = await db.execute(friends_query, params)
        
        friends = []
        for row in result.fetchall():
            friends.append({
                'user_id': row.user_id,
                'username': row.username,
                'display_name': row.display_name,
                'avatar_url': row.profile_picture_url,
                'bio': row.bio,
                'is_online': row.is_online or False,
                'last_seen': row.last_seen,
                'friendship_since': row.friendship_since,
                'direct_chat_room_id': row.direct_chat_room_id
            })
        
        return friends
    
    async def remove_friend(
        self,
        db: AsyncSession,
        user_id: UUID,
        friend_id: UUID
    ) -> bool:
        """Remove a friend (unfriend)"""
        
        # Remove both friendship connections
        remove_friendship = text("""
            DELETE FROM buddies 
            WHERE (user_id = :user_id AND buddy_user_id = :friend_id)
            OR (user_id = :friend_id AND buddy_user_id = :user_id)
        """)
        
        result = await db.execute(remove_friendship, {
            'user_id': str(user_id),
            'friend_id': str(friend_id)
        })
        
        await db.commit()
        
        return result.rowcount > 0
    
    async def block_user(
        self,
        db: AsyncSession,
        user_id: UUID,
        blocked_user_id: UUID
    ) -> bool:
        """Block a user"""
        
        if user_id == blocked_user_id:
            raise ValueError("Cannot block yourself")
        
        # First, remove any existing friendship
        await self.remove_friend(db, user_id, blocked_user_id)
        
        # Create or update friend request with blocked status
        block_request = text("""
            INSERT INTO friend_requests (id, sender_id, receiver_id, status)
            VALUES (:id, :user_id, :blocked_user_id, 'blocked')
            ON CONFLICT (sender_id, receiver_id) 
            DO UPDATE SET status = 'blocked', responded_at = CURRENT_TIMESTAMP
        """)
        
        await db.execute(block_request, {
            'id': str(uuid4()),
            'user_id': str(user_id),
            'blocked_user_id': str(blocked_user_id)
        })
        
        await db.commit()
        return True
    
    async def unblock_user(
        self,
        db: AsyncSession,
        user_id: UUID,
        blocked_user_id: UUID
    ) -> bool:
        """Unblock a user"""
        
        # Remove block request
        unblock_request = text("""
            DELETE FROM friend_requests 
            WHERE sender_id = :user_id AND receiver_id = :blocked_user_id AND status = 'blocked'
        """)
        
        result = await db.execute(unblock_request, {
            'user_id': str(user_id),
            'blocked_user_id': str(blocked_user_id)
        })
        
        await db.commit()
        
        return result.rowcount > 0
    
    async def get_blocked_users(
        self,
        db: AsyncSession,
        user_id: UUID,
        skip: int = 0,
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get list of blocked users"""
        
        blocked_query = text("""
            SELECT 
                u.id as user_id,
                u.username,
                p.display_name,
                p.profile_picture_url,
                fr.created_at as blocked_at
            FROM friend_requests fr
            JOIN users u ON u.id = fr.receiver_id
            LEFT JOIN profiles p ON p.user_id = u.id
            WHERE fr.sender_id = :user_id AND fr.status = 'blocked'
            ORDER BY fr.created_at DESC
            LIMIT :limit OFFSET :skip
        """)
        
        result = await db.execute(blocked_query, {
            'user_id': str(user_id),
            'skip': skip,
            'limit': limit
        })
        
        blocked_users = []
        for row in result.fetchall():
            blocked_users.append({
                'user_id': row.user_id,
                'username': row.username,
                'display_name': row.display_name,
                'avatar_url': row.profile_picture_url,
                'blocked_at': row.blocked_at
            })
        
        return blocked_users
    
    async def search_users(
        self,
        db: AsyncSession,
        current_user_id: UUID,
        search_query: str,
        exclude_friends: bool = False,
        limit: int = 20
    ) -> List[Dict[str, Any]]:
        """Search for users to add as friends"""
        
        where_conditions = ["u.id != :current_user_id"]
        params = {
            'current_user_id': str(current_user_id),
            'search_query': f"%{search_query}%",
            'limit': limit
        }
        
        # Search by username or display name
        where_conditions.append("""
            (u.username ILIKE :search_query OR p.display_name ILIKE :search_query)
        """)
        
        if exclude_friends:
            where_conditions.append("""
                NOT EXISTS (
                    SELECT 1 FROM buddies b 
                    WHERE b.user_id = :current_user_id 
                    AND b.buddy_user_id = u.id 
                    AND b.status = 'accepted'
                )
            """)
        
        where_clause = " AND ".join(where_conditions)
        
        search_query_sql = text(f"""
            SELECT 
                u.id as user_id,
                u.username,
                p.display_name,
                p.profile_picture_url,
                p.bio,
                uos.is_online,
                uos.last_seen,
                -- Check friendship status
                CASE 
                    WHEN EXISTS (
                        SELECT 1 FROM buddies b 
                        WHERE b.user_id = :current_user_id 
                        AND b.buddy_user_id = u.id 
                        AND b.status = 'accepted'
                    ) THEN 'friends'
                    WHEN EXISTS (
                        SELECT 1 FROM friend_requests fr 
                        WHERE fr.sender_id = :current_user_id 
                        AND fr.receiver_id = u.id 
                        AND fr.status = 'pending'
                    ) THEN 'request_sent'
                    WHEN EXISTS (
                        SELECT 1 FROM friend_requests fr 
                        WHERE fr.sender_id = u.id 
                        AND fr.receiver_id = :current_user_id 
                        AND fr.status = 'pending'
                    ) THEN 'request_received'
                    WHEN EXISTS (
                        SELECT 1 FROM friend_requests fr 
                        WHERE fr.sender_id = :current_user_id 
                        AND fr.receiver_id = u.id 
                        AND fr.status = 'blocked'
                    ) THEN 'blocked'
                    ELSE 'none'
                END as relationship_status
            FROM users u
            LEFT JOIN profiles p ON p.user_id = u.id
            LEFT JOIN user_online_status uos ON uos.user_id = u.id
            WHERE {where_clause}
            ORDER BY 
                CASE 
                    WHEN u.username ILIKE :search_query THEN 1
                    WHEN p.display_name ILIKE :search_query THEN 2
                    ELSE 3
                END,
                uos.is_online DESC,
                p.display_name ASC,
                u.username ASC
            LIMIT :limit
        """)
        
        result = await db.execute(search_query_sql, params)
        
        users = []
        for row in result.fetchall():
            users.append({
                'user_id': row.user_id,
                'username': row.username,
                'display_name': row.display_name,
                'avatar_url': row.profile_picture_url,
                'bio': row.bio,
                'is_online': row.is_online or False,
                'last_seen': row.last_seen,
                'relationship_status': row.relationship_status
            })
        
        return users
    
    async def get_friend_request_details(
        self,
        db: AsyncSession,
        request_id: UUID,
        user_id: UUID
    ) -> Dict[str, Any]:
        """Get detailed information about a friend request"""
        
        request_query = text("""
            SELECT 
                fr.id,
                fr.sender_id,
                fr.receiver_id,
                fr.message,
                fr.status,
                fr.created_at,
                fr.responded_at,
                sender_u.username as sender_username,
                sender_p.display_name as sender_display_name,
                sender_p.profile_picture_url as sender_avatar,
                receiver_u.username as receiver_username,
                receiver_p.display_name as receiver_display_name,
                receiver_p.profile_picture_url as receiver_avatar
            FROM friend_requests fr
            JOIN users sender_u ON sender_u.id = fr.sender_id
            JOIN users receiver_u ON receiver_u.id = fr.receiver_id
            LEFT JOIN profiles sender_p ON sender_p.user_id = fr.sender_id
            LEFT JOIN profiles receiver_p ON receiver_p.user_id = fr.receiver_id
            WHERE fr.id = :request_id 
            AND (fr.sender_id = :user_id OR fr.receiver_id = :user_id)
        """)
        
        result = await db.execute(request_query, {
            'request_id': str(request_id),
            'user_id': str(user_id)
        })
        
        row = result.fetchone()
        if not row:
            raise ValueError("Friend request not found")
        
        return {
            'id': row.id,
            'sender_id': row.sender_id,
            'receiver_id': row.receiver_id,
            'message': row.message,
            'status': row.status,
            'created_at': row.created_at,
            'responded_at': row.responded_at,
            'sender': {
                'user_id': row.sender_id,
                'username': row.sender_username,
                'display_name': row.sender_display_name,
                'avatar_url': row.sender_avatar
            },
            'receiver': {
                'user_id': row.receiver_id,
                'username': row.receiver_username,
                'display_name': row.receiver_display_name,
                'avatar_url': row.receiver_avatar
            }
        }

# Create instance
friends_crud = FriendsCRUD()
