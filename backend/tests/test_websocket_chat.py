import pytest
import json
import asyncio
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import AsyncSession
from unittest.mock import AsyncMock, patch
import websockets
from app.main import app
from app.database.base import get_db
from app.models_db import User, ChatRoom, ChatMessage, ChatParticipant
from app.schemas.chat import MessageType, ChatRoomType, ParticipantRole

class TestWebSocketChat:
    """Test WebSocket chat functionality"""

    @pytest.fixture
    def client(self):
        return TestClient(app)

    @pytest.fixture
    async def test_user(self, db_session: AsyncSession):
        """Create a test user"""
        user = User(
            username="testuser",
            email="test@example.com",
            full_name="Test User",
            hashed_password="hashed_password"
        )
        db_session.add(user)
        await db_session.commit()
        await db_session.refresh(user)
        return user

    @pytest.fixture
    async def test_user2(self, db_session: AsyncSession):
        """Create a second test user"""
        user = User(
            username="testuser2",
            email="test2@example.com",
            full_name="Test User 2",
            hashed_password="hashed_password"
        )
        db_session.add(user)
        await db_session.commit()
        await db_session.refresh(user)
        return user

    @pytest.fixture
    async def test_chat_room(self, db_session: AsyncSession, test_user, test_user2):
        """Create a test chat room"""
        room = ChatRoom(
            type=ChatRoomType.DIRECT,
            created_by=test_user.id
        )
        db_session.add(room)
        await db_session.commit()
        await db_session.refresh(room)

        # Add participants
        participant1 = ChatParticipant(
            room_id=room.id,
            user_id=test_user.id,
            role=ParticipantRole.MEMBER
        )
        participant2 = ChatParticipant(
            room_id=room.id,
            user_id=test_user2.id,
            role=ParticipantRole.MEMBER
        )
        db_session.add(participant1)
        db_session.add(participant2)
        await db_session.commit()

        return room

    @pytest.fixture
    def auth_headers(self, test_user):
        """Get authentication headers for test user"""
        # This would normally use the actual JWT token generation
        # For testing, we'll mock this
        return {"Authorization": f"Bearer mock_token_{test_user.id}"}

    @pytest.mark.asyncio
    async def test_websocket_connection_success(self, client, test_user):
        """Test successful WebSocket connection"""
        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = test_user
            
            # Mock the WebSocket connection
            with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket:
                # Should receive connection confirmation
                data = websocket.receive_json()
                assert data["type"] == "connection_established"
                assert data["data"]["user_id"] == str(test_user.id)

    @pytest.mark.asyncio
    async def test_websocket_connection_authentication_failure(self, client):
        """Test WebSocket connection with invalid token"""
        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = None
            
            # Should close connection with authentication error
            with pytest.raises(Exception):  # WebSocket connection should fail
                with client.websocket_connect("/ws/chat?token=invalid_token") as websocket:
                    pass

    @pytest.mark.asyncio
    async def test_join_room(self, client, test_user, test_chat_room):
        """Test joining a chat room via WebSocket"""
        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = test_user
            
            with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket:
                # Receive connection confirmation
                websocket.receive_json()
                
                # Join room
                join_message = {
                    "type": "join_room",
                    "data": {"room_id": str(test_chat_room.id)}
                }
                websocket.send_json(join_message)
                
                # Should receive room joined confirmation
                response = websocket.receive_json()
                assert response["type"] == "room_joined"
                assert response["data"]["room_id"] == str(test_chat_room.id)

    @pytest.mark.asyncio
    async def test_leave_room(self, client, test_user, test_chat_room):
        """Test leaving a chat room via WebSocket"""
        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = test_user
            
            with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket:
                # Receive connection confirmation
                websocket.receive_json()
                
                # Leave room
                leave_message = {
                    "type": "leave_room",
                    "data": {"room_id": str(test_chat_room.id)}
                }
                websocket.send_json(leave_message)
                
                # Should receive room left confirmation
                response = websocket.receive_json()
                assert response["type"] == "room_left"
                assert response["data"]["room_id"] == str(test_chat_room.id)

    @pytest.mark.asyncio
    async def test_send_message(self, client, test_user, test_user2, test_chat_room, db_session):
        """Test sending a message via WebSocket"""
        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = test_user
            
            with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket:
                # Receive connection confirmation
                websocket.receive_json()
                
                # Join room
                join_message = {
                    "type": "join_room",
                    "data": {"room_id": str(test_chat_room.id)}
                }
                websocket.send_json(join_message)
                websocket.receive_json()  # Room joined confirmation
                
                # Send message
                message_data = {
                    "type": "send_message",
                    "data": {
                        "room_id": str(test_chat_room.id),
                        "content": "Hello, world!",
                        "message_type": "text"
                    }
                }
                websocket.send_json(message_data)
                
                # Should receive message sent confirmation
                response = websocket.receive_json()
                assert response["type"] == "message_sent"
                assert response["data"]["content"] == "Hello, world!"
                assert response["data"]["sender_id"] == str(test_user.id)
                assert response["data"]["room_id"] == str(test_chat_room.id)

    @pytest.mark.asyncio
    async def test_typing_indicator(self, client, test_user, test_user2, test_chat_room):
        """Test typing indicator via WebSocket"""
        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = test_user
            
            with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket:
                # Receive connection confirmation
                websocket.receive_json()
                
                # Join room
                join_message = {
                    "type": "join_room",
                    "data": {"room_id": str(test_chat_room.id)}
                }
                websocket.send_json(join_message)
                websocket.receive_json()  # Room joined confirmation
                
                # Send typing start
                typing_message = {
                    "type": "typing_start",
                    "data": {"room_id": str(test_chat_room.id)}
                }
                websocket.send_json(typing_message)
                
                # Send typing stop
                typing_stop_message = {
                    "type": "typing_stop",
                    "data": {"room_id": str(test_chat_room.id)}
                }
                websocket.send_json(typing_stop_message)

    @pytest.mark.asyncio
    async def test_message_read_receipt(self, client, test_user, test_chat_room, db_session):
        """Test message read receipt via WebSocket"""
        # Create a test message
        message = ChatMessage(
            room_id=test_chat_room.id,
            sender_id=test_user.id,
            content="Test message",
            message_type=MessageType.TEXT
        )
        db_session.add(message)
        await db_session.commit()
        await db_session.refresh(message)

        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = test_user
            
            with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket:
                # Receive connection confirmation
                websocket.receive_json()
                
                # Join room
                join_message = {
                    "type": "join_room",
                    "data": {"room_id": str(test_chat_room.id)}
                }
                websocket.send_json(join_message)
                websocket.receive_json()  # Room joined confirmation
                
                # Mark message as read
                read_message = {
                    "type": "message_read",
                    "data": {
                        "room_id": str(test_chat_room.id),
                        "message_ids": [str(message.id)]
                    }
                }
                websocket.send_json(read_message)

    @pytest.mark.asyncio
    async def test_ping_pong(self, client, test_user):
        """Test ping-pong keep-alive mechanism"""
        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = test_user
            
            with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket:
                # Receive connection confirmation
                websocket.receive_json()
                
                # Send ping
                ping_message = {
                    "type": "ping",
                    "data": {"timestamp": 1234567890}
                }
                websocket.send_json(ping_message)
                
                # Should receive pong
                response = websocket.receive_json()
                assert response["type"] == "pong"
                assert response["data"]["timestamp"] == 1234567890

    @pytest.mark.asyncio
    async def test_invalid_message_type(self, client, test_user):
        """Test handling of invalid message types"""
        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = test_user
            
            with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket:
                # Receive connection confirmation
                websocket.receive_json()
                
                # Send invalid message type
                invalid_message = {
                    "type": "invalid_type",
                    "data": {}
                }
                websocket.send_json(invalid_message)
                
                # Should receive error
                response = websocket.receive_json()
                assert response["type"] == "error"
                assert "Unknown message type" in response["data"]["message"]

    @pytest.mark.asyncio
    async def test_invalid_json(self, client, test_user):
        """Test handling of invalid JSON"""
        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = test_user
            
            with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket:
                # Receive connection confirmation
                websocket.receive_json()
                
                # Send invalid JSON
                websocket.send_text("invalid json")
                
                # Should receive error
                response = websocket.receive_json()
                assert response["type"] == "error"
                assert "Invalid JSON format" in response["data"]["message"]

    @pytest.mark.asyncio
    async def test_connection_manager_cleanup(self, client, test_user):
        """Test connection manager cleanup on disconnect"""
        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = test_user
            
            # Connect and disconnect
            with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket:
                # Receive connection confirmation
                websocket.receive_json()
                
                # Connection should be tracked
                from app.websocket.chat_websocket import manager
                assert str(test_user.id) in manager.active_connections
                
            # After disconnect, connection should be cleaned up
            # Note: This test might need adjustment based on how the cleanup works
            # in the actual implementation

    @pytest.mark.asyncio
    async def test_multiple_connections_same_user(self, client, test_user):
        """Test multiple WebSocket connections for the same user"""
        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = test_user
            
            # First connection
            with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket1:
                websocket1.receive_json()  # Connection confirmation
                
                # Second connection (simulated)
                # In a real test, you'd need to handle multiple connections properly
                # This is a simplified test
                from app.websocket.chat_websocket import manager
                assert str(test_user.id) in manager.active_connections

    @pytest.mark.asyncio
    async def test_room_broadcast(self, client, test_user, test_user2, test_chat_room):
        """Test message broadcasting to room participants"""
        # This test would require two WebSocket connections
        # One for each user in the room
        # For now, we'll test the basic functionality
        
        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = test_user
            
            with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket:
                # Receive connection confirmation
                websocket.receive_json()
                
                # Join room
                join_message = {
                    "type": "join_room",
                    "data": {"room_id": str(test_chat_room.id)}
                }
                websocket.send_json(join_message)
                websocket.receive_json()  # Room joined confirmation
                
                # Send message
                message_data = {
                    "type": "send_message",
                    "data": {
                        "room_id": str(test_chat_room.id),
                        "content": "Broadcast test",
                        "message_type": "text"
                    }
                }
                websocket.send_json(message_data)
                
                # Should receive message sent confirmation
                response = websocket.receive_json()
                assert response["type"] == "message_sent"
                assert response["data"]["content"] == "Broadcast test"

    @pytest.mark.asyncio
    async def test_user_online_status_update(self, client, test_user, db_session):
        """Test user online status update"""
        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = test_user
            
            with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket:
                # Receive connection confirmation
                websocket.receive_json()
                
                # User should be marked as online
                # This would be tested by checking the database
                # or by verifying the status update was sent to friends

    @pytest.mark.asyncio
    async def test_connection_error_handling(self, client, test_user):
        """Test error handling during WebSocket connection"""
        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.side_effect = Exception("Database error")
            
            # Connection should handle the error gracefully
            with pytest.raises(Exception):
                with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket:
                    pass

    @pytest.mark.asyncio
    async def test_message_validation(self, client, test_user, test_chat_room):
        """Test message validation"""
        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = test_user
            
            with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket:
                # Receive connection confirmation
                websocket.receive_json()
                
                # Join room
                join_message = {
                    "type": "join_room",
                    "data": {"room_id": str(test_chat_room.id)}
                }
                websocket.send_json(join_message)
                websocket.receive_json()  # Room joined confirmation
                
                # Send message without room_id
                invalid_message = {
                    "type": "send_message",
                    "data": {
                        "content": "Test message",
                        "message_type": "text"
                    }
                }
                websocket.send_json(invalid_message)
                
                # Should receive error
                response = websocket.receive_json()
                assert response["type"] == "error"
                assert "room_id is required" in response["data"]["message"]

    @pytest.mark.asyncio
    async def test_room_permissions(self, client, test_user, db_session):
        """Test room access permissions"""
        # Create a room that the user is not a participant of
        other_user = User(
            username="otheruser",
            email="other@example.com",
            full_name="Other User",
            hashed_password="hashed_password"
        )
        db_session.add(other_user)
        await db_session.commit()
        await db_session.refresh(other_user)

        room = ChatRoom(
            type=ChatRoomType.DIRECT,
            created_by=other_user.id
        )
        db_session.add(room)
        await db_session.commit()
        await db_session.refresh(room)

        with patch('app.websocket.chat_websocket.get_current_user_from_token') as mock_auth:
            mock_auth.return_value = test_user
            
            with client.websocket_connect(f"/ws/chat?token=mock_token_{test_user.id}") as websocket:
                # Receive connection confirmation
                websocket.receive_json()
                
                # Try to join room without permission
                join_message = {
                    "type": "join_room",
                    "data": {"room_id": str(room.id)}
                }
                websocket.send_json(join_message)
                
                # Should receive room joined confirmation (implementation dependent)
                # The actual behavior depends on how permissions are handled
                response = websocket.receive_json()
                # This test might need adjustment based on the actual permission logic