-- Chat and Friends Feature Database Migration
-- Execute this script in your PostgreSQL database after existing tables

-- Create enum types for chat system
CREATE TYPE chat_room_type AS ENUM ('direct', 'group');
CREATE TYPE chat_message_type AS ENUM ('text', 'image', 'file', 'location', 'system');
CREATE TYPE participant_role AS ENUM ('admin', 'member');
CREATE TYPE friend_request_status AS ENUM ('pending', 'accepted', 'declined', 'blocked');

-- Create chat_rooms table
CREATE TABLE IF NOT EXISTS chat_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type chat_room_type NOT NULL DEFAULT 'direct',
    name VARCHAR(255), -- For group chats
    description TEXT, -- For group chats
    image_url VARCHAR(1024), -- For group chat avatars
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_message_at TIMESTAMP WITH TIME ZONE,
    last_message_content TEXT, -- Cache for quick display
    last_message_sender_id UUID REFERENCES users(id) ON DELETE SET NULL,
    is_archived BOOLEAN DEFAULT FALSE
);

-- Create chat_participants table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS chat_participants (
    room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role participant_role DEFAULT 'member',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP WITH TIME ZONE,
    last_read_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    unread_count INTEGER DEFAULT 0,
    is_muted BOOLEAN DEFAULT FALSE,
    is_pinned BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (room_id, user_id)
);

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message_type chat_message_type DEFAULT 'text',
    content TEXT, -- Text content or file description
    media_urls TEXT[], -- Array of media URLs (images, files, etc.)
    metadata JSONB, -- Additional metadata (file sizes, dimensions, etc.)
    reply_to_id UUID REFERENCES chat_messages(id) ON DELETE SET NULL,
    forwarded_from_id UUID REFERENCES chat_messages(id) ON DELETE SET NULL,
    edited_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Create message_read_receipts table
CREATE TABLE IF NOT EXISTS message_read_receipts (
    message_id UUID REFERENCES chat_messages(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    read_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (message_id, user_id)
);

-- Create message_reactions table
CREATE TABLE IF NOT EXISTS message_reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES chat_messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reaction_type VARCHAR(50) NOT NULL, -- 'like', 'love', 'laugh', etc.
    emoji VARCHAR(10) NOT NULL, -- The actual emoji
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(message_id, user_id, reaction_type)
);

-- Enhance existing friend requests (extend buddy system)
-- First, check if friend_requests table exists, if not create it
CREATE TABLE IF NOT EXISTS friend_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    requestee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status friend_request_status DEFAULT 'pending',
    message TEXT, -- Optional message with friend request
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(requester_id, requestee_id)
);

-- Create user_friendships table (accepted friend relationships)
CREATE TABLE IF NOT EXISTS user_friendships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    blocked_by UUID REFERENCES users(id) ON DELETE SET NULL,
    blocked_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user1_id, user2_id),
    CHECK (user1_id < user2_id) -- Ensure consistent ordering
);

-- Create user_online_status table
CREATE TABLE IF NOT EXISTS user_online_status (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    is_online BOOLEAN DEFAULT FALSE,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create typing_indicators table (for real-time typing status)
CREATE TABLE IF NOT EXISTS typing_indicators (
    room_id UUID NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    PRIMARY KEY (room_id, user_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_chat_rooms_created_by ON chat_rooms(created_by);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_last_message_at ON chat_rooms(last_message_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_type ON chat_rooms(type);

CREATE INDEX IF NOT EXISTS idx_chat_participants_user_id ON chat_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_participants_room_id ON chat_participants(room_id);
CREATE INDEX IF NOT EXISTS idx_chat_participants_unread ON chat_participants(user_id, unread_count) WHERE unread_count > 0;

CREATE INDEX IF NOT EXISTS idx_chat_messages_room_id_created_at ON chat_messages(room_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_id ON chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_reply_to_id ON chat_messages(reply_to_id) WHERE reply_to_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_message_read_receipts_message_id ON message_read_receipts(message_id);
CREATE INDEX IF NOT EXISTS idx_message_read_receipts_user_id ON message_read_receipts(user_id);

CREATE INDEX IF NOT EXISTS idx_message_reactions_message_id ON message_reactions(message_id);
CREATE INDEX IF NOT EXISTS idx_message_reactions_user_id ON message_reactions(user_id);

CREATE INDEX IF NOT EXISTS idx_friend_requests_requestee_id ON friend_requests(requestee_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_requester_id ON friend_requests(requester_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_status ON friend_requests(status);

CREATE INDEX IF NOT EXISTS idx_user_friendships_user1_id ON user_friendships(user1_id);
CREATE INDEX IF NOT EXISTS idx_user_friendships_user2_id ON user_friendships(user2_id);
CREATE INDEX IF NOT EXISTS idx_user_friendships_blocked ON user_friendships(blocked_by) WHERE blocked_by IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_user_online_status_online ON user_online_status(is_online) WHERE is_online = TRUE;
CREATE INDEX IF NOT EXISTS idx_user_online_status_last_seen ON user_online_status(last_seen DESC);

CREATE INDEX IF NOT EXISTS idx_typing_indicators_room_id ON typing_indicators(room_id);
CREATE INDEX IF NOT EXISTS idx_typing_indicators_expires_at ON typing_indicators(expires_at);

-- Create triggers for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_chat_rooms_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_update_chat_rooms_updated_at
    BEFORE UPDATE ON chat_rooms
    FOR EACH ROW
    EXECUTE FUNCTION update_chat_rooms_updated_at();

-- Function to automatically update last_message info in chat_rooms
CREATE OR REPLACE FUNCTION update_chat_room_last_message()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.is_deleted = FALSE THEN
        UPDATE chat_rooms 
        SET 
            last_message_at = NEW.created_at,
            last_message_content = CASE 
                WHEN NEW.message_type = 'text' THEN NEW.content
                WHEN NEW.message_type = 'image' THEN '📷 Photo'
                WHEN NEW.message_type = 'file' THEN '📎 File'
                WHEN NEW.message_type = 'location' THEN '📍 Location'
                ELSE NEW.content
            END,
            last_message_sender_id = NEW.sender_id,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.room_id;
        
        -- Update unread count for all participants except sender
        UPDATE chat_participants 
        SET unread_count = unread_count + 1
        WHERE room_id = NEW.room_id AND user_id != NEW.sender_id AND left_at IS NULL;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_update_chat_room_last_message
    AFTER INSERT OR UPDATE ON chat_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_chat_room_last_message();

-- Function to update online status
CREATE OR REPLACE FUNCTION update_user_online_status()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    IF NEW.is_online = TRUE THEN
        NEW.last_activity = CURRENT_TIMESTAMP;
    ELSE
        NEW.last_seen = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_update_user_online_status
    BEFORE UPDATE ON user_online_status
    FOR EACH ROW
    EXECUTE FUNCTION update_user_online_status();

-- Function to clean up expired typing indicators
CREATE OR REPLACE FUNCTION cleanup_expired_typing_indicators()
RETURNS void AS $$
BEGIN
    DELETE FROM typing_indicators WHERE expires_at < CURRENT_TIMESTAMP;
END;
$$ language 'plpgsql';

-- Create a function to get or create direct chat room between two users
CREATE OR REPLACE FUNCTION get_or_create_direct_chat(user1_id UUID, user2_id UUID)
RETURNS UUID AS $$
DECLARE
    room_id UUID;
    ordered_user1_id UUID;
    ordered_user2_id UUID;
BEGIN
    -- Ensure consistent ordering for direct chats
    IF user1_id < user2_id THEN
        ordered_user1_id := user1_id;
        ordered_user2_id := user2_id;
    ELSE
        ordered_user1_id := user2_id;
        ordered_user2_id := user1_id;
    END IF;
    
    -- Try to find existing direct chat room
    SELECT cr.id INTO room_id
    FROM chat_rooms cr
    WHERE cr.type = 'direct'
    AND EXISTS (
        SELECT 1 FROM chat_participants cp1 
        WHERE cp1.room_id = cr.id AND cp1.user_id = ordered_user1_id AND cp1.left_at IS NULL
    )
    AND EXISTS (
        SELECT 1 FROM chat_participants cp2 
        WHERE cp2.room_id = cr.id AND cp2.user_id = ordered_user2_id AND cp2.left_at IS NULL
    )
    AND (
        SELECT COUNT(*) FROM chat_participants cp3 
        WHERE cp3.room_id = cr.id AND cp3.left_at IS NULL
    ) = 2;
    
    -- If no room exists, create one
    IF room_id IS NULL THEN
        INSERT INTO chat_rooms (type, created_by) 
        VALUES ('direct', ordered_user1_id) 
        RETURNING id INTO room_id;
        
        -- Add both participants
        INSERT INTO chat_participants (room_id, user_id, role) 
        VALUES 
            (room_id, ordered_user1_id, 'member'),
            (room_id, ordered_user2_id, 'member');
    END IF;
    
    RETURN room_id;
END;
$$ language 'plpgsql';

-- Create a function to add user to online status table when they first connect
CREATE OR REPLACE FUNCTION ensure_user_online_status(target_user_id UUID)
RETURNS void AS $$
BEGIN
    INSERT INTO user_online_status (user_id, is_online, last_seen, last_activity)
    VALUES (target_user_id, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    ON CONFLICT (user_id) DO UPDATE SET
        is_online = TRUE,
        last_activity = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP;
END;
$$ language 'plpgsql';

-- Sample data insertion (optional - for testing)
-- You can uncomment this section for testing purposes

/*
-- Insert sample online status for existing users
INSERT INTO user_online_status (user_id, is_online, last_seen)
SELECT id, FALSE, CURRENT_TIMESTAMP - INTERVAL '1 hour'
FROM users
ON CONFLICT (user_id) DO NOTHING;

-- Create a sample direct chat between first two users (if they exist)
DO $$
DECLARE
    user1_id UUID;
    user2_id UUID;
    room_id UUID;
BEGIN
    SELECT id INTO user1_id FROM users ORDER BY created_at LIMIT 1;
    SELECT id INTO user2_id FROM users ORDER BY created_at LIMIT 1 OFFSET 1;
    
    IF user1_id IS NOT NULL AND user2_id IS NOT NULL THEN
        SELECT get_or_create_direct_chat(user1_id, user2_id) INTO room_id;
        
        -- Insert a sample message
        INSERT INTO chat_messages (room_id, sender_id, content)
        VALUES (room_id, user1_id, 'Hello! This is a test message from the chat system.');
    END IF;
END $$;
*/

COMMIT;
