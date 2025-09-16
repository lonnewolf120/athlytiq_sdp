from fastapi import WebSocket, WebSocketDisconnect, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Dict, List, Set
import json
import logging
from uuid import UUID
import asyncio

from app.database.base import get_db
from app.dependencies import get_current_user_from_token
from app.crud.chat_crud import chat_crud
from app.schemas.chat import MessageType

logger = logging.getLogger(__name__)

class ConnectionManager:
    def __init__(self):
        # Store active connections by user_id
        self.active_connections: Dict[str, Set[WebSocket]] = {}
        # Store user_id by websocket for cleanup
        self.websocket_users: Dict[WebSocket, str] = {}
        # Store room subscriptions by user
        self.user_rooms: Dict[str, Set[str]] = {}

    async def connect(self, websocket: WebSocket, user_id: str):
        """Accept WebSocket connection and add user to active connections"""
        await websocket.accept()
        
        # Add to active connections
        if user_id not in self.active_connections:
            self.active_connections[user_id] = set()
        self.active_connections[user_id].add(websocket)
        
        # Track user for this websocket
        self.websocket_users[websocket] = user_id
        
        # Initialize room subscriptions
        if user_id not in self.user_rooms:
            self.user_rooms[user_id] = set()
        
        logger.info(f"User {user_id} connected via WebSocket")

    def disconnect(self, websocket: WebSocket):
        """Remove WebSocket connection and clean up user data"""
        if websocket in self.websocket_users:
            user_id = self.websocket_users[websocket]
            
            # Remove from active connections
            if user_id in self.active_connections:
                self.active_connections[user_id].discard(websocket)
                if not self.active_connections[user_id]:
                    del self.active_connections[user_id]
                    # Clean up room subscriptions if no active connections
                    if user_id in self.user_rooms:
                        del self.user_rooms[user_id]
            
            # Remove websocket tracking
            del self.websocket_users[websocket]
            
            logger.info(f"User {user_id} disconnected from WebSocket")

    async def join_room(self, user_id: str, room_id: str):
        """Subscribe user to a chat room for real-time updates"""
        if user_id in self.user_rooms:
            self.user_rooms[user_id].add(room_id)
            logger.info(f"User {user_id} joined room {room_id}")

    async def leave_room(self, user_id: str, room_id: str):
        """Unsubscribe user from a chat room"""
        if user_id in self.user_rooms:
            self.user_rooms[user_id].discard(room_id)
            logger.info(f"User {user_id} left room {room_id}")

    async def send_personal_message(self, message: dict, user_id: str):
        """Send a message to a specific user across all their connections"""
        if user_id in self.active_connections:
            disconnected = []
            for websocket in self.active_connections[user_id]:
                try:
                    await websocket.send_text(json.dumps(message))
                except Exception as e:
                    logger.error(f"Error sending message to user {user_id}: {e}")
                    disconnected.append(websocket)
            
            # Clean up disconnected websockets
            for ws in disconnected:
                self.disconnect(ws)

    async def broadcast_to_room(self, message: dict, room_id: str, exclude_user_id: str = None):
        """Broadcast a message to all users in a specific room"""
        for user_id, rooms in self.user_rooms.items():
            if room_id in rooms and user_id != exclude_user_id:
                await self.send_personal_message(message, user_id)

    async def update_user_online_status(self, user_id: str, is_online: bool, db: AsyncSession):
        """Update user's online status in database"""
        try:
            from sqlalchemy import text
            
            update_status = text("""
                INSERT INTO user_online_status (user_id, is_online, last_seen, updated_at)
                VALUES (:user_id, :is_online, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                ON CONFLICT (user_id) 
                DO UPDATE SET 
                    is_online = :is_online, 
                    last_seen = CASE WHEN :is_online = false THEN CURRENT_TIMESTAMP ELSE user_online_status.last_seen END,
                    updated_at = CURRENT_TIMESTAMP
            """)
            
            await db.execute(update_status, {
                'user_id': user_id,
                'is_online': is_online
            })
            await db.commit()
            
            # Notify friends about status change
            await self.broadcast_status_change(user_id, is_online)
            
        except Exception as e:
            logger.error(f"Error updating online status for user {user_id}: {e}")

    async def broadcast_status_change(self, user_id: str, is_online: bool):
        """Notify friends when a user's online status changes"""
        # This would require getting user's friends list and notifying them
        status_message = {
            "type": "user_status_change",
            "data": {
                "user_id": user_id,
                "is_online": is_online
            }
        }
        
        # For now, we'll broadcast to all active users
        # In production, you'd want to query friends and only notify them
        for active_user_id in self.active_connections.keys():
            if active_user_id != user_id:
                await self.send_personal_message(status_message, active_user_id)

# Global connection manager instance
manager = ConnectionManager()

async def websocket_endpoint(
    websocket: WebSocket,
    token: str,
    db: AsyncSession = Depends(get_db)
):
    """Main WebSocket endpoint for chat functionality"""
    user = None
    user_id = None
    
    try:
        # Authenticate user from token
        user = await get_current_user_from_token(token, db)
        if not user:
            await websocket.close(code=4001, reason="Authentication failed")
            return
        
        user_id = str(user.id)
        
        # Accept connection
        await manager.connect(websocket, user_id)
        
        # Update user online status
        await manager.update_user_online_status(user_id, True, db)
        
        # Send connection confirmation
        await websocket.send_text(json.dumps({
            "type": "connection_established",
            "data": {
                "user_id": user_id,
                "message": "Connected successfully"
            }
        }))
        
        # Message handling loop
        while True:
            try:
                data = await websocket.receive_text()
                message_data = json.loads(data)
                
                await handle_websocket_message(websocket, message_data, user_id, db)
                
            except WebSocketDisconnect:
                break
            except json.JSONDecodeError:
                await websocket.send_text(json.dumps({
                    "type": "error",
                    "data": {"message": "Invalid JSON format"}
                }))
            except Exception as e:
                logger.error(f"Error processing WebSocket message: {e}")
                await websocket.send_text(json.dumps({
                    "type": "error",
                    "data": {"message": "Internal server error"}
                }))
    
    except Exception as e:
        logger.error(f"WebSocket connection error: {e}")
    
    finally:
        # Clean up connection
        manager.disconnect(websocket)
        if user_id:
            # Update user offline status
            await manager.update_user_online_status(user_id, False, db)

async def handle_websocket_message(
    websocket: WebSocket, 
    message_data: dict, 
    user_id: str, 
    db: AsyncSession
):
    """Handle incoming WebSocket messages"""
    
    message_type = message_data.get("type")
    data = message_data.get("data", {})
    
    try:
        if message_type == "join_room":
            room_id = data.get("room_id")
            if room_id:
                await manager.join_room(user_id, room_id)
                await websocket.send_text(json.dumps({
                    "type": "room_joined",
                    "data": {"room_id": room_id}
                }))
        
        elif message_type == "leave_room":
            room_id = data.get("room_id")
            if room_id:
                await manager.leave_room(user_id, room_id)
                await websocket.send_text(json.dumps({
                    "type": "room_left",
                    "data": {"room_id": room_id}
                }))
        
        elif message_type == "send_message":
            await handle_send_message(websocket, data, user_id, db)
        
        elif message_type == "typing_start":
            await handle_typing_indicator(data, user_id, True)
        
        elif message_type == "typing_stop":
            await handle_typing_indicator(data, user_id, False)
        
        elif message_type == "message_read":
            await handle_message_read(data, user_id, db)
        
        elif message_type == "ping":
            # Keep-alive ping
            await websocket.send_text(json.dumps({
                "type": "pong",
                "data": {"timestamp": data.get("timestamp")}
            }))
        
        else:
            await websocket.send_text(json.dumps({
                "type": "error",
                "data": {"message": f"Unknown message type: {message_type}"}
            }))
    
    except Exception as e:
        logger.error(f"Error handling WebSocket message {message_type}: {e}")
        await websocket.send_text(json.dumps({
            "type": "error",
            "data": {"message": f"Failed to process {message_type}"}
        }))

async def handle_send_message(websocket: WebSocket, data: dict, user_id: str, db: AsyncSession):
    """Handle sending a new message"""
    try:
        from app.schemas.chat import MessageCreate, MessageType
        
        room_id = data.get("room_id")
        content = data.get("content")
        message_type = data.get("message_type", "text")
        media_urls = data.get("media_urls", [])
        reply_to_id = data.get("reply_to_id")
        
        if not room_id:
            raise ValueError("room_id is required")
        
        # Create message using CRUD
        message_data = MessageCreate(
            content=content,
            message_type=MessageType(message_type),
            media_urls=media_urls,
            reply_to_id=UUID(reply_to_id) if reply_to_id else None,
            metadata=data.get("metadata")
        )
        
        message = await chat_crud.send_message(
            db, UUID(room_id), UUID(user_id), message_data
        )
        
        # Broadcast message to room participants
        broadcast_message = {
            "type": "new_message",
            "data": message
        }
        
        await manager.broadcast_to_room(broadcast_message, room_id, exclude_user_id=user_id)
        
        # Confirm message sent to sender
        await websocket.send_text(json.dumps({
            "type": "message_sent",
            "data": message
        }))
        
    except Exception as e:
        logger.error(f"Error sending message: {e}")
        await websocket.send_text(json.dumps({
            "type": "error",
            "data": {"message": f"Failed to send message: {str(e)}"}
        }))

async def handle_typing_indicator(data: dict, user_id: str, is_typing: bool):
    """Handle typing indicators"""
    room_id = data.get("room_id")
    if room_id:
        typing_message = {
            "type": "typing_indicator",
            "data": {
                "room_id": room_id,
                "user_id": user_id,
                "is_typing": is_typing
            }
        }
        
        await manager.broadcast_to_room(typing_message, room_id, exclude_user_id=user_id)

async def handle_message_read(data: dict, user_id: str, db: AsyncSession):
    """Handle message read receipts"""
    try:
        room_id = data.get("room_id")
        message_ids = data.get("message_ids", [])
        
        if room_id:
            # Mark messages as read
            await chat_crud.mark_messages_as_read(
                db, UUID(room_id), UUID(user_id), 
                [UUID(mid) for mid in message_ids] if message_ids else None
            )
            
            # Broadcast read receipt to room participants
            read_receipt_message = {
                "type": "message_read_receipt",
                "data": {
                    "room_id": room_id,
                    "user_id": user_id,
                    "message_ids": message_ids
                }
            }
            
            await manager.broadcast_to_room(read_receipt_message, room_id, exclude_user_id=user_id)
    
    except Exception as e:
        logger.error(f"Error handling message read: {e}")

# Helper function to send real-time notifications
async def send_friend_request_notification(sender_id: str, receiver_id: str, request_data: dict):
    """Send real-time notification for new friend request"""
    notification = {
        "type": "friend_request_received",
        "data": request_data
    }
    
    await manager.send_personal_message(notification, receiver_id)

async def send_friend_request_response_notification(sender_id: str, receiver_id: str, response_data: dict):
    """Send real-time notification for friend request response"""
    notification = {
        "type": "friend_request_responded",
        "data": response_data
    }
    
    await manager.send_personal_message(notification, sender_id)
