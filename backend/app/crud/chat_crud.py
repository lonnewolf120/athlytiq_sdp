from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete, and_, or_, func, text, case, exists
from sqlalchemy.orm import selectinload, joinedload
from typing import List, Optional, Dict, Any, Tuple
from uuid import UUID, uuid4
from datetime import datetime, timedelta
import json

from app.models_db import User
from app.schemas.chat import (
    ChatRoomCreate, ChatRoomResponse, MessageCreate, MessageResponse,
    FriendRequestCreate, FriendRequestResponse, UserSearchResult,
    ChatParticipantResponse, MessageReactionCreate, MessageReadReceiptCreate
)

# We'll need to add these models to models_db.py
# For now, using raw SQL queries to avoid modifying models_db.py immediately

class ChatCRUD:
    """CRUD operations for chat functionality"""
    
    async def create_direct_chat_room(
        self, 
        db: AsyncSession, 
        current_user_id: UUID, 
        other_user_id: UUID
    ) -> Dict[str, Any]:
        """Create or get existing direct chat room between two users"""
        
        # Use the database function we created
        query = text("""
            SELECT get_or_create_direct_chat(:user1_id, :user2_id) as room_id
        """)
        
        result = await db.execute(query, {
            'user1_id': str(current_user_id),
            'user2_id': str(other_user_id)
        })
        
        room_id = result.scalar()
        await db.commit()
        
        # Return the room details
        return await self.get_chat_room_details(db, UUID(room_id), current_user_id)
    
    async def create_group_chat_room(
        self,
        db: AsyncSession,
        current_user_id: UUID,
        room_data: ChatRoomCreate
    ) -> Dict[str, Any]:
        """Create a new group chat room"""
        
        room_id = uuid4()
        
        # Create the room
        insert_room = text("""
            INSERT INTO chat_rooms (id, type, name, description, image_url, created_by)
            VALUES (:id, 'group', :name, :description, :image_url, :created_by)
        """)
        
        await db.execute(insert_room, {
            'id': str(room_id),
            'name': room_data.name,
            'description': room_data.description,
            'image_url': room_data.image_url,
            'created_by': str(current_user_id)
        })
        
        # Add participants (including creator as admin)
        participants = [(current_user_id, 'admin')] + [(pid, 'member') for pid in room_data.participant_ids if pid != current_user_id]
        
        for user_id, role in participants:
            insert_participant = text("""
                INSERT INTO chat_participants (room_id, user_id, role)
                VALUES (:room_id, :user_id, :role)
            """)
            
            await db.execute(insert_participant, {
                'room_id': str(room_id),
                'user_id': str(user_id),
                'role': role
            })
        
        await db.commit()
        
        return await self.get_chat_room_details(db, room_id, current_user_id)
    
    async def get_user_chat_rooms(
        self,
        db: AsyncSession,
        user_id: UUID,
        skip: int = 0,
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get all chat rooms for a user"""
        
        query = text("""
            SELECT 
                cr.id,
                cr.type,
                cr.name,
                cr.description,
                cr.image_url,
                cr.created_by,
                cr.created_at,
                cr.updated_at,
                cr.last_message_at,
                cr.last_message_content,
                cr.last_message_sender_id,
                cr.is_archived,
                cp.unread_count,
                cp.is_muted,
                cp.is_pinned,
                cp.last_read_at,
                -- For direct chats, get the other user's info
                CASE 
                    WHEN cr.type = 'direct' THEN (
                        SELECT u.username FROM users u 
                        JOIN chat_participants cp2 ON cp2.user_id = u.id 
                        WHERE cp2.room_id = cr.id AND cp2.user_id != :user_id
                        LIMIT 1
                    )
                    ELSE cr.name 
                END as display_name,
                CASE 
                    WHEN cr.type = 'direct' THEN (
                        SELECT p.display_name FROM users u 
                        JOIN profiles p ON p.user_id = u.id
                        JOIN chat_participants cp2 ON cp2.user_id = u.id 
                        WHERE cp2.room_id = cr.id AND cp2.user_id != :user_id
                        LIMIT 1
                    )
                    ELSE NULL 
                END as other_user_display_name,
                CASE 
                    WHEN cr.type = 'direct' THEN (
                        SELECT p.profile_picture_url FROM users u 
                        JOIN profiles p ON p.user_id = u.id
                        JOIN chat_participants cp2 ON cp2.user_id = u.id 
                        WHERE cp2.room_id = cr.id AND cp2.user_id != :user_id
                        LIMIT 1
                    )
                    ELSE cr.image_url 
                END as display_image,
                (SELECT COUNT(*) FROM chat_participants cp3 WHERE cp3.room_id = cr.id AND cp3.left_at IS NULL) as participant_count
            FROM chat_rooms cr
            JOIN chat_participants cp ON cp.room_id = cr.id
            WHERE cp.user_id = :user_id 
            AND cp.left_at IS NULL
            AND cr.is_archived = FALSE
            ORDER BY 
                cp.is_pinned DESC,
                COALESCE(cr.last_message_at, cr.created_at) DESC
            LIMIT :limit OFFSET :skip
        """)
        
        result = await db.execute(query, {
            'user_id': str(user_id),
            'skip': skip,
            'limit': limit
        })
        
        rooms = []
        for row in result.fetchall():
            rooms.append({
                'id': row.id,
                'type': row.type,
                'name': row.display_name or row.other_user_display_name,
                'description': row.description,
                'image_url': row.display_image,
                'created_by': row.created_by,
                'created_at': row.created_at,
                'updated_at': row.updated_at,
                'last_message_at': row.last_message_at,
                'last_message_content': row.last_message_content,
                'last_message_sender_id': row.last_message_sender_id,
                'is_archived': row.is_archived,
                'unread_count': row.unread_count,
                'is_muted': row.is_muted,
                'is_pinned': row.is_pinned,
                'participant_count': row.participant_count
            })
        
        return rooms
    
    async def get_chat_room_details(
        self,
        db: AsyncSession,
        room_id: UUID,
        current_user_id: UUID
    ) -> Dict[str, Any]:
        """Get detailed information about a chat room"""
        
        # Check if user is participant
        check_participant = text("""
            SELECT 1 FROM chat_participants 
            WHERE room_id = :room_id AND user_id = :user_id AND left_at IS NULL
        """)
        
        result = await db.execute(check_participant, {
            'room_id': str(room_id),
            'user_id': str(current_user_id)
        })
        
        if not result.fetchone():
            raise ValueError("User is not a participant in this room")
        
        # Get room details
        room_query = text("""
            SELECT 
                cr.*,
                cp.unread_count,
                cp.is_muted,
                cp.is_pinned,
                cp.last_read_at
            FROM chat_rooms cr
            JOIN chat_participants cp ON cp.room_id = cr.id
            WHERE cr.id = :room_id AND cp.user_id = :user_id
        """)
        
        room_result = await db.execute(room_query, {
            'room_id': str(room_id),
            'user_id': str(current_user_id)
        })
        
        room_row = room_result.fetchone()
        if not room_row:
            raise ValueError("Room not found")
        
        # Get participants
        participants_query = text("""
            SELECT 
                cp.user_id,
                cp.role,
                cp.joined_at,
                cp.left_at,
                cp.last_read_at,
                cp.unread_count,
                cp.is_muted,
                cp.is_pinned,
                u.username,
                p.display_name,
                p.profile_picture_url,
                uos.is_online,
                uos.last_seen
            FROM chat_participants cp
            JOIN users u ON u.id = cp.user_id
            LEFT JOIN profiles p ON p.user_id = u.id
            LEFT JOIN user_online_status uos ON uos.user_id = u.id
            WHERE cp.room_id = :room_id AND cp.left_at IS NULL
            ORDER BY cp.role DESC, cp.joined_at ASC
        """)
        
        participants_result = await db.execute(participants_query, {
            'room_id': str(room_id)
        })
        
        participants = []
        for p in participants_result.fetchall():
            participants.append({
                'user_id': p.user_id,
                'username': p.username,
                'display_name': p.display_name,
                'avatar_url': p.profile_picture_url,
                'role': p.role,
                'joined_at': p.joined_at,
                'left_at': p.left_at,
                'last_read_at': p.last_read_at,
                'unread_count': p.unread_count if str(p.user_id) == str(current_user_id) else 0,
                'is_muted': p.is_muted,
                'is_pinned': p.is_pinned,
                'is_online': p.is_online or False,
                'last_seen': p.last_seen
            })
        
        return {
            'id': room_row.id,
            'type': room_row.type,
            'name': room_row.name,
            'description': room_row.description,
            'image_url': room_row.image_url,
            'created_by': room_row.created_by,
            'created_at': room_row.created_at,
            'updated_at': room_row.updated_at,
            'last_message_at': room_row.last_message_at,
            'last_message_content': room_row.last_message_content,
            'last_message_sender_id': room_row.last_message_sender_id,
            'is_archived': room_row.is_archived,
            'unread_count': room_row.unread_count,
            'is_muted': room_row.is_muted,
            'is_pinned': room_row.is_pinned,
            'participants': participants
        }
    
    async def send_message(
        self,
        db: AsyncSession,
        room_id: UUID,
        sender_id: UUID,
        message_data: MessageCreate
    ) -> Dict[str, Any]:
        """Send a message to a chat room"""
        
        # Verify user is participant
        check_participant = text("""
            SELECT 1 FROM chat_participants 
            WHERE room_id = :room_id AND user_id = :sender_id AND left_at IS NULL
        """)
        
        result = await db.execute(check_participant, {
            'room_id': str(room_id),
            'sender_id': str(sender_id)
        })
        
        if not result.fetchone():
            raise ValueError("User is not a participant in this room")
        
        message_id = uuid4()
        
        # Insert message
        insert_message = text("""
            INSERT INTO chat_messages 
            (id, room_id, sender_id, message_type, content, media_urls, metadata, reply_to_id, forwarded_from_id)
            VALUES (:id, :room_id, :sender_id, :message_type, :content, :media_urls, :metadata, :reply_to_id, :forwarded_from_id)
        """)
        
        await db.execute(insert_message, {
            'id': str(message_id),
            'room_id': str(room_id),
            'sender_id': str(sender_id),
            'message_type': message_data.message_type.value,
            'content': message_data.content,
            'media_urls': message_data.media_urls,
            'metadata': json.dumps(message_data.metadata) if message_data.metadata else None,
            'reply_to_id': str(message_data.reply_to_id) if message_data.reply_to_id else None,
            'forwarded_from_id': str(message_data.forwarded_from_id) if message_data.forwarded_from_id else None
        })
        
        await db.commit()
        
        # Return the created message
        return await self.get_message_details(db, message_id, sender_id)
    
    async def get_room_messages(
        self,
        db: AsyncSession,
        room_id: UUID,
        user_id: UUID,
        before_message_id: Optional[UUID] = None,
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get messages for a chat room with pagination"""
        
        # Verify user is participant
        check_participant = text("""
            SELECT 1 FROM chat_participants 
            WHERE room_id = :room_id AND user_id = :user_id AND left_at IS NULL
        """)
        
        result = await db.execute(check_participant, {
            'room_id': str(room_id),
            'user_id': str(user_id)
        })
        
        if not result.fetchone():
            raise ValueError("User is not a participant in this room")
        
        # Build query with optional pagination
        where_clause = "WHERE cm.room_id = :room_id AND cm.is_deleted = FALSE"
        params = {'room_id': str(room_id), 'user_id': str(user_id), 'limit': limit}
        
        if before_message_id:
            where_clause += " AND cm.created_at < (SELECT created_at FROM chat_messages WHERE id = :before_message_id)"
            params['before_message_id'] = str(before_message_id)
        
        messages_query = text(f"""
            SELECT 
                cm.id,
                cm.room_id,
                cm.sender_id,
                cm.message_type,
                cm.content,
                cm.media_urls,
                cm.metadata,
                cm.reply_to_id,
                cm.forwarded_from_id,
                cm.created_at,
                cm.edited_at,
                cm.is_deleted,
                cm.deleted_at,
                u.username as sender_username,
                p.display_name as sender_display_name,
                p.profile_picture_url as sender_avatar,
                EXISTS(
                    SELECT 1 FROM message_read_receipts mrr 
                    WHERE mrr.message_id = cm.id AND mrr.user_id = :user_id
                ) as is_read_by_current_user,
                -- Reply-to message info
                reply_cm.content as reply_to_content,
                reply_cm.sender_id as reply_to_sender_id,
                reply_u.username as reply_to_sender_username
            FROM chat_messages cm
            JOIN users u ON u.id = cm.sender_id
            LEFT JOIN profiles p ON p.user_id = u.id
            LEFT JOIN chat_messages reply_cm ON reply_cm.id = cm.reply_to_id
            LEFT JOIN users reply_u ON reply_u.id = reply_cm.sender_id
            {where_clause}
            ORDER BY cm.created_at DESC
            LIMIT :limit
        """)
        
        messages_result = await db.execute(messages_query, params)
        
        messages = []
        for row in messages_result.fetchall():
            message = {
                'id': row.id,
                'room_id': row.room_id,
                'sender_id': row.sender_id,
                'sender_name': row.sender_username,
                'sender_display_name': row.sender_display_name,
                'sender_avatar': row.sender_avatar,
                'message_type': row.message_type,
                'content': row.content,
                'media_urls': row.media_urls,
                'metadata': json.loads(row.metadata) if row.metadata else None,
                'reply_to_id': row.reply_to_id,
                'forwarded_from_id': row.forwarded_from_id,
                'created_at': row.created_at,
                'edited_at': row.edited_at,
                'is_deleted': row.is_deleted,
                'deleted_at': row.deleted_at,
                'is_read_by_current_user': row.is_read_by_current_user,
                'reactions': [],
                'read_receipts': []
            }
            
            # Add reply-to info if exists
            if row.reply_to_id:
                message['reply_to_message'] = {
                    'id': row.reply_to_id,
                    'content': row.reply_to_content,
                    'sender_id': row.reply_to_sender_id,
                    'sender_username': row.reply_to_sender_username
                }
            
            messages.append(message)
        
        # Reverse to get chronological order
        return list(reversed(messages))
    
    async def mark_messages_as_read(
        self,
        db: AsyncSession,
        room_id: UUID,
        user_id: UUID,
        message_ids: Optional[List[UUID]] = None
    ) -> bool:
        """Mark messages as read for a user"""
        
        if message_ids:
            # Mark specific messages as read
            for message_id in message_ids:
                insert_receipt = text("""
                    INSERT INTO message_read_receipts (message_id, user_id)
                    VALUES (:message_id, :user_id)
                    ON CONFLICT (message_id, user_id) DO NOTHING
                """)
                
                await db.execute(insert_receipt, {
                    'message_id': str(message_id),
                    'user_id': str(user_id)
                })
        else:
            # Mark all messages in room as read
            mark_all_read = text("""
                INSERT INTO message_read_receipts (message_id, user_id)
                SELECT cm.id, :user_id
                FROM chat_messages cm
                WHERE cm.room_id = :room_id 
                AND cm.sender_id != :user_id
                AND NOT EXISTS (
                    SELECT 1 FROM message_read_receipts mrr 
                    WHERE mrr.message_id = cm.id AND mrr.user_id = :user_id
                )
            """)
            
            await db.execute(mark_all_read, {
                'room_id': str(room_id),
                'user_id': str(user_id)
            })
        
        # Update participant's unread count and last read time
        update_participant = text("""
            UPDATE chat_participants 
            SET unread_count = 0, last_read_at = CURRENT_TIMESTAMP
            WHERE room_id = :room_id AND user_id = :user_id
        """)
        
        await db.execute(update_participant, {
            'room_id': str(room_id),
            'user_id': str(user_id)
        })
        
        await db.commit()
        return True
    
    async def get_message_details(
        self,
        db: AsyncSession,
        message_id: UUID,
        user_id: UUID
    ) -> Dict[str, Any]:
        """Get detailed information about a specific message"""
        
        message_query = text("""
            SELECT 
                cm.id,
                cm.room_id,
                cm.sender_id,
                cm.message_type,
                cm.content,
                cm.media_urls,
                cm.metadata,
                cm.reply_to_id,
                cm.forwarded_from_id,
                cm.created_at,
                cm.edited_at,
                cm.is_deleted,
                cm.deleted_at,
                u.username as sender_username,
                p.display_name as sender_display_name,
                p.profile_picture_url as sender_avatar,
                EXISTS(
                    SELECT 1 FROM message_read_receipts mrr 
                    WHERE mrr.message_id = cm.id AND mrr.user_id = :user_id
                ) as is_read_by_current_user
            FROM chat_messages cm
            JOIN users u ON u.id = cm.sender_id
            LEFT JOIN profiles p ON p.user_id = u.id
            WHERE cm.id = :message_id
        """)
        
        result = await db.execute(message_query, {
            'message_id': str(message_id),
            'user_id': str(user_id)
        })
        
        row = result.fetchone()
        if not row:
            raise ValueError("Message not found")
        
        return {
            'id': row.id,
            'room_id': row.room_id,
            'sender_id': row.sender_id,
            'sender_name': row.sender_username,
            'sender_display_name': row.sender_display_name,
            'sender_avatar': row.sender_avatar,
            'message_type': row.message_type,
            'content': row.content,
            'media_urls': row.media_urls,
            'metadata': json.loads(row.metadata) if row.metadata else None,
            'reply_to_id': row.reply_to_id,
            'forwarded_from_id': row.forwarded_from_id,
            'created_at': row.created_at,
            'edited_at': row.edited_at,
            'is_deleted': row.is_deleted,
            'deleted_at': row.deleted_at,
            'is_read_by_current_user': row.is_read_by_current_user
        }

# Create instance
chat_crud = ChatCRUD()
