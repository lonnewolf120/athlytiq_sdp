# Chat and Friends Feature Implementation TODO

## Phase 1: Core Chat Functionality (Week 1-2)

### Backend Tasks

#### Database Setup
- [ ] **Create database migration script**
  - [ ] Add `chat_rooms` table
  - [ ] Add `chat_participants` table  
  - [ ] Add `chat_messages` table
  - [ ] Add `message_read_receipts` table
  - [ ] Add `friend_requests` table (enhance existing buddy system)
  - [ ] Create necessary indexes for performance
  - [ ] Test migration on development database

#### API Implementation
- [ ] **Create chat schemas** (`backend/app/schemas/chat.py`)
  - [ ] `ChatRoomCreate`, `ChatRoomResponse`
  - [ ] `MessageCreate`, `MessageResponse`
  - [ ] `FriendRequestCreate`, `FriendRequestResponse`
  - [ ] `FriendResponse`

- [ ] **Implement CRUD operations** (`backend/app/crud/chat_crud.py`)
  - [ ] `create_direct_chat_room()`
  - [ ] `get_user_chat_rooms()`
  - [ ] `send_message()`
  - [ ] `get_room_messages()`
  - [ ] `mark_message_as_read()`

- [ ] **Create API endpoints** (`backend/app/api/v1/endpoints/chat.py`)
  - [ ] `GET /api/v1/chat/rooms/` - Get user's chat rooms
  - [ ] `POST /api/v1/chat/rooms/` - Create new chat room
  - [ ] `GET /api/v1/chat/rooms/{room_id}` - Get room details
  - [ ] `GET /api/v1/chat/messages/{room_id}` - Get messages (paginated)
  - [ ] `POST /api/v1/chat/messages/{room_id}` - Send message
  - [ ] `POST /api/v1/chat/messages/{message_id}/read` - Mark as read

- [ ] **Update main.py** to include chat router
- [ ] **Update models_db.py** to include new chat models
- [ ] **Write unit tests** for all CRUD operations

### Frontend Tasks

#### Models and Data Layer
- [ ] **Create chat models** (`lib/models/chat/chat_models.dart`)
  - [ ] `ChatRoom` model with Freezed
  - [ ] `ChatMessage` model with Freezed
  - [ ] `ChatParticipant` model with Freezed
  - [ ] `MessageReadReceipt` model with Freezed
  - [ ] Generate .freezed.dart and .g.dart files

- [ ] **Create chat providers** (`lib/providers/chat_provider.dart`)
  - [ ] `ChatRoomsNotifier` for managing chat rooms list
  - [ ] `ChatMessagesNotifier` for managing messages per room
  - [ ] Riverpod providers setup

- [ ] **Update API service** (`lib/services/api_service.dart`)
  - [ ] Add chat-related API methods
  - [ ] Handle authentication headers
  - [ ] Error handling for chat operations

#### UI Components
- [ ] **Create enhanced chat room tile** (`lib/widgets/chat/chat_room_tile.dart`)
  - [ ] Display room info, last message, unread count
  - [ ] Handle different room types (direct/group)
  - [ ] Show online status for participants

- [ ] **Update messages page** (`lib/Screens/Community/enhanced_messages_page.dart`)
  - [ ] Replace existing `messages_page.dart` functionality
  - [ ] Add search functionality
  - [ ] Add new chat creation button
  - [ ] Integrate with chat providers

- [ ] **Update chat screen** (`lib/Screens/Community/enhanced_chat_screen.dart`)
  - [ ] Replace existing `chat_screen.dart` functionality
  - [ ] Message input with media buttons
  - [ ] Message display with read receipts
  - [ ] Typing indicators placeholder

## Phase 2: Friends System (Week 3-4)

### Backend Tasks

#### Friends API Implementation
- [ ] **Create friends endpoints** (`backend/app/api/v1/endpoints/friends.py`)
  - [ ] `GET /api/v1/friends/` - Get friends list
  - [ ] `GET /api/v1/friends/requests` - Get friend requests
  - [ ] `POST /api/v1/friends/requests` - Send friend request
  - [ ] `PUT /api/v1/friends/requests/{id}` - Accept/decline request
  - [ ] `DELETE /api/v1/friends/{id}` - Remove friend
  - [ ] `POST /api/v1/friends/block/{user_id}` - Block user

- [ ] **Create user search endpoint** (`backend/app/api/v1/endpoints/users.py`)
  - [ ] `GET /api/v1/users/search` - Search users by username/name
  - [ ] Implement fuzzy search with ILIKE
  - [ ] Pagination support
  - [ ] Privacy controls (hide from search if needed)

- [ ] **Implement friends CRUD** (`backend/app/crud/friends_crud.py`)
  - [ ] `send_friend_request()`
  - [ ] `respond_to_friend_request()`
  - [ ] `get_user_friends()`
  - [ ] `get_friend_requests()`
  - [ ] `remove_friend()`
  - [ ] `block_user()`

### Frontend Tasks

#### Friends Models and Providers
- [ ] **Create friend models** (`lib/models/friends/friend_models.dart`)
  - [ ] `Friend` model with Freezed
  - [ ] `FriendRequest` model with Freezed
  - [ ] Generate necessary files

- [ ] **Create friends providers** (`lib/providers/friends_provider.dart`)
  - [ ] `FriendsNotifier` for friends list
  - [ ] `FriendRequestsNotifier` for managing requests
  - [ ] `UserSearchNotifier` for user search

#### UI Implementation
- [ ] **Enhanced find friends page** (`lib/Screens/Community/enhanced_find_friends_page.dart`)
  - [ ] Replace existing `find_friends_page.dart`
  - [ ] User search with real API integration
  - [ ] Friend suggestions based on mutual connections
  - [ ] Send friend request functionality

- [ ] **Friend requests management screen** (`lib/Screens/Community/friend_requests_screen.dart`)
  - [ ] Separate tabs for sent/received requests
  - [ ] Accept/decline functionality
  - [ ] Request status indicators

- [ ] **Friends list screen** (`lib/Screens/Community/friends_list_screen.dart`)
  - [ ] Display all friends with online status
  - [ ] Quick actions (message, remove, block)
  - [ ] Search within friends list

## Phase 3: Real-time Features (Week 5-6)

### Backend Tasks

#### WebSocket Implementation
- [ ] **Create WebSocket endpoint** (`backend/app/api/v1/endpoints/websocket.py`)
  - [ ] Connection manager for user sessions
  - [ ] Message broadcasting system
  - [ ] Typing indicator handling
  - [ ] Online status tracking

- [ ] **Integrate WebSocket with chat** 
  - [ ] Send real-time message notifications
  - [ ] Update read receipts in real-time
  - [ ] Broadcast typing indicators

- [ ] **Add Redis for session management** (optional)
  - [ ] Store active user sessions
  - [ ] Handle WebSocket scaling across multiple servers

### Frontend Tasks

#### Real-time Integration
- [ ] **Create WebSocket service** (`lib/services/websocket_service.dart`)
  - [ ] Connection management
  - [ ] Message event handling
  - [ ] Automatic reconnection logic
  - [ ] Integration with Riverpod providers

- [ ] **Add typing indicators** to chat screen
  - [ ] Show when other users are typing
  - [ ] Send typing events while user types
  - [ ] Timeout handling for typing status

- [ ] **Implement online status**
  - [ ] Show online/offline status in friends list
  - [ ] Update status in real-time
  - [ ] Last seen timestamps

## Phase 4: Advanced Features (Week 7-8)

### Backend Tasks

#### Media and Advanced Features
- [ ] **Media upload handling**
  - [ ] Integrate with existing Cloudinary setup
  - [ ] Support image/video/document uploads in chat
  - [ ] File size and type validation
  - [ ] Thumbnail generation for media

- [ ] **Message reactions and replies**
  - [ ] Add reactions table and API endpoints
  - [ ] Support threaded replies
  - [ ] Notification system for reactions/replies

- [ ] **Push notifications**
  - [ ] Firebase Cloud Messaging integration
  - [ ] Notification triggers for new messages
  - [ ] User notification preferences

### Frontend Tasks

#### Rich Media Features
- [ ] **Media picker integration**
  - [ ] Image/video selection from gallery
  - [ ] Camera integration for photos
  - [ ] File picker for documents
  - [ ] Upload progress indicators

- [ ] **Rich message UI**
  - [ ] Display images/videos in chat
  - [ ] File download functionality
  - [ ] Message reactions interface
  - [ ] Reply-to-message UI

- [ ] **Notification handling**
  - [ ] Local notifications setup
  - [ ] Push notification handling
  - [ ] Navigate to specific chat from notification

## Integration Tasks

### Community Integration
- [ ] **Link with existing community features**
  - [ ] Create group chats from community groups
  - [ ] Share posts directly to chat
  - [ ] Chat integration in community screens

### Trainer System Integration
- [ ] **Migrate existing trainer chat**
  - [ ] Use new chat infrastructure for trainer chats
  - [ ] Maintain backward compatibility
  - [ ] Enhanced trainer-client communication

### Profile Integration
- [ ] **Update user profiles**
  - [ ] Add friends count to profile
  - [ ] Friend suggestions based on profile data
  - [ ] Privacy settings for friend requests

## Testing and QA

### Backend Testing
- [ ] **Unit tests for all CRUD operations**
- [ ] **API endpoint integration tests**
- [ ] **WebSocket functionality tests**
- [ ] **Load testing for chat performance**

### Frontend Testing
- [ ] **Widget tests for chat components**
- [ ] **Integration tests for chat flows**
- [ ] **WebSocket connection testing**
- [ ] **Offline/online scenario testing**

## Deployment and DevOps

### Database Migration
- [ ] **Create production migration strategy**
- [ ] **Backup existing data before migration**
- [ ] **Test migration on staging environment**
- [ ] **Rollback plan preparation**

### Infrastructure Setup
- [ ] **Configure WebSocket load balancing**
- [ ] **Set up monitoring for WebSocket connections**
- [ ] **Configure Cloudinary for chat media storage**
- [ ] **Set up push notification services**

### Performance Optimization
- [ ] **Database query optimization**
- [ ] **Chat message pagination optimization**
- [ ] **Media caching strategy**
- [ ] **WebSocket connection pooling**

---

## Priority Notes

### High Priority (Must Complete)
- Phase 1: Core chat functionality
- Phase 2: Basic friends system
- Database migration and API endpoints

### Medium Priority (Should Complete)
- Phase 3: Real-time features
- WebSocket integration
- Enhanced UI components

### Lower Priority (Nice to Have)
- Phase 4: Advanced features
- Rich media sharing
- Advanced notification features

### Dependencies
- Complete Phase 1 before starting Phase 2
- Ensure database migration is thoroughly tested before production deployment
- WebSocket infrastructure should be set up before Phase 3
- Media storage configuration needed for Phase 4

### Risk Mitigation
- **Database Migration**: Test extensively on staging, have rollback plan
- **WebSocket Scaling**: Start with simple implementation, optimize later
- **Real-time Performance**: Implement rate limiting and connection management
- **Existing Feature Compatibility**: Ensure new chat system doesn't break trainer chat
