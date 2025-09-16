-- Create Database
CREATE DATABASE athlytiq;

-- Connect to the database
\c athlytiq;

-- Enums
CREATE TYPE user_role_enum AS ENUM ('user', 'trainer', 'admin');
CREATE TYPE community_member_role_enum AS ENUM ('member', 'moderator', 'admin');
CREATE TYPE post_type_enum AS ENUM ('text', 'workout', 'challenge');
CREATE TYPE ride_activity_type_enum AS ENUM ('mountain', 'road', 'tandem', 'cyclocross', 'running', 'hiking', 'other_workout');

-- Table: users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL, -- Assuming password hash will be stored here
    role user_role_enum NOT NULL DEFAULT 'user',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: profiles
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    display_name VARCHAR(255),
    bio TEXT,
    profile_picture_url TEXT,
    fitness_goals TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: communities
CREATE TABLE communities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    is_private BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: community_members (Join table for many-to-many between users and communities)
CREATE TABLE community_members (
    community_id UUID NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role community_member_role_enum NOT NULL DEFAULT 'member',
    joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY (community_id, user_id) -- Composite primary key
);

-- Table: challenge_posts
CREATE TABLE challenge_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_days INTEGER NOT NULL,
    cover_image_url TEXT,
    participant_count INTEGER NOT NULL DEFAULT 0,
    -- invited_user_ids TEXT[], -- If storing as array of user IDs
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: stories
CREATE TABLE stories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- Assuming stories are by users
    name VARCHAR(255) NOT NULL, -- Story name (e.g., "Your Story", "Jordan Smith")
    image TEXT, -- URL for story cover/user image
    is_your_story BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW() -- For story updates/expiration
);

-- Table: story_content_items (Nested content for stories)
CREATE TABLE story_content_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- "image", "text", "workout", "location"
    content TEXT NOT NULL,
    completed_workout_session TEXT, -- For workout stories
    gym_location TEXT, -- For workout/location stories
    time TIMESTAMP WITH TIME ZONE, -- Specific time for this content item
    location_details JSONB, -- For location stories (e.g., address, lat/lng)
    workout_details JSONB, -- For workout stories (e.g., duration, intensity, exercises)
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: exercises (Master list of exercises, potentially from external API)
CREATE TABLE exercises IF NOT EXISTS (
    exercise_id VARCHAR(255) PRIMARY KEY, -- Use external ID as PK
    name VARCHAR(255) NOT NULL,
    gif_url TEXT NOT NULL,
    body_parts TEXT[],
    equipments TEXT[],
    target_muscles TEXT[],
    secondary_muscles TEXT[],
    instructions TEXT[],
    image_url TEXT,
    exercise_type VARCHAR(50),
    keywords TEXT[],
    overview TEXT,
    video_url TEXT,
    exercise_tips TEXT[],
    variations TEXT[],
    related_exercise_ids TEXT[], -- Array of external exercise IDs
    sets VARCHAR(50), -- These seem to be default/example values, not actual planned sets
    reps VARCHAR(50),
    weight VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: workouts (Workout plans created by users)
CREATE TABLE workouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    icon_url TEXT,
    equipment_selected TEXT,
    one_rm_goal TEXT,
    type VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: planned_exercises (Exercises within a workout plan)
CREATE TABLE planned_exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
    exercise_id VARCHAR(255) NOT NULL, -- Reference to exercises.exercise_id (external)
    exercise_name VARCHAR(255) NOT NULL,
    exercise_equipments TEXT[],
    exercise_gif_url TEXT,
    type VARCHAR(50),
    planned_sets INTEGER NOT NULL,
    planned_reps INTEGER NOT NULL,
    planned_weight VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: completed_workouts (Completed workout sessions)
CREATE TABLE completed_workouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    original_workout_id UUID REFERENCES workouts(id) ON DELETE SET NULL, -- If original plan is deleted, set to NULL
    workout_name VARCHAR(255) NOT NULL,
    workout_icon_url TEXT,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_seconds INTEGER NOT NULL, -- Storing duration in seconds
    intensity_score DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: completed_workout_exercises (Exercises performed in a completed workout)
CREATE TABLE completed_workout_exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    completed_workout_id UUID NOT NULL REFERENCES completed_workouts(id) ON DELETE CASCADE,
    exercise_id VARCHAR(255) NOT NULL, -- Reference to exercises.exercise_id (external)
    exercise_name VARCHAR(255) NOT NULL,
    exercise_equipments TEXT[],
    exercise_gif_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: completed_workout_sets (Sets performed for an exercise in a completed workout)
CREATE TABLE completed_workout_sets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    completed_workout_exercise_id UUID NOT NULL REFERENCES completed_workout_exercises(id) ON DELETE CASCADE,
    weight VARCHAR(50) NOT NULL,
    reps VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: workout_posts (Specific data for posts of type 'workout')
CREATE TABLE workout_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_type VARCHAR(255) NOT NULL,
    duration_minutes INTEGER NOT NULL,
    calories_burned INTEGER NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: workout_post_exercises (Exercises included in a workout post)
CREATE TABLE workout_post_exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_post_id UUID NOT NULL REFERENCES workout_posts(id) ON DELETE CASCADE,
    exercise_id VARCHAR(255) NOT NULL, -- Reference to exercises.exercise_id (external)
    name VARCHAR(255) NOT NULL,
    gif_url TEXT NOT NULL,
    body_parts TEXT[],
    equipments TEXT[],
    target_muscles TEXT[],
    secondary_muscles TEXT[],
    instructions TEXT[],
    image_url TEXT,
    exercise_type VARCHAR(50),
    keywords TEXT[],
    overview TEXT,
    video_url TEXT,
    exercise_tips TEXT[],
    variations TEXT[],
    related_exercise_ids TEXT[],
    sets VARCHAR(50),
    reps VARCHAR(50),
    weight VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: posts (Main feed posts, can link to specific content types)
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT,
    media_url TEXT,
    post_type post_type_enum[] NOT NULL, -- Array of enum values
    workout_post_id UUID REFERENCES workout_posts(id) ON DELETE SET NULL,
    challenge_post_id UUID REFERENCES challenge_posts(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: post_comments
CREATE TABLE post_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: post_reacts
CREATE TABLE post_reacts (
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    react_type VARCHAR(50) NOT NULL, -- e.g., 'like', 'heart', 'laugh'
    emoji VARCHAR(10), -- Store the actual emoji character
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY (post_id, user_id) -- A user can only react once per post
);

-- Table: ride_activities
CREATE TABLE ride_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organizer_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    distance_km DOUBLE PRECISION,
    elevation_meters INTEGER,
    type ride_activity_type_enum NOT NULL,
    route_coordinates JSONB, -- Array of {lat, lng} objects
    location_name VARCHAR(255),
    park_name VARCHAR(255),
    start_time TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: ride_activity_participants (Join table for many-to-many between users and ride_activities)
CREATE TABLE ride_activity_participants (
    ride_activity_id UUID NOT NULL REFERENCES ride_activities(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY (ride_activity_id, user_id) -- Composite primary key
);

-- Indexes for performance
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_communities_creator_user_id ON communities(creator_user_id);
CREATE INDEX idx_community_members_community_id ON community_members(community_id);
CREATE INDEX idx_community_members_user_id ON community_members(user_id);
CREATE INDEX idx_stories_user_id ON stories(user_id);
CREATE INDEX idx_story_content_items_story_id ON story_content_items(story_id);
CREATE INDEX idx_workouts_name ON workouts(name);
CREATE INDEX idx_planned_exercises_workout_id ON planned_exercises(workout_id);
CREATE INDEX idx_completed_workouts_user_id ON completed_workouts(user_id);
CREATE INDEX idx_completed_workout_exercises_completed_workout_id ON completed_workout_exercises(completed_workout_id);
CREATE INDEX idx_completed_workout_sets_completed_workout_exercise_id ON completed_workout_sets(completed_workout_exercise_id);
CREATE INDEX idx_workout_posts_id ON workout_posts(id);
CREATE INDEX idx_workout_post_exercises_workout_post_id ON workout_post_exercises(workout_post_id);
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_workout_post_id ON posts(workout_post_id);
CREATE INDEX idx_posts_challenge_post_id ON posts(challenge_post_id);
CREATE INDEX idx_post_comments_post_id ON post_comments(post_id);
CREATE INDEX idx_post_comments_user_id ON post_comments(user_id);
CREATE INDEX idx_post_reacts_post_id ON post_reacts(post_id);
CREATE INDEX idx_post_reacts_user_id ON post_reacts(user_id);
CREATE INDEX idx_ride_activities_organizer_user_id ON ride_activities(organizer_user_id);
CREATE INDEX idx_ride_activity_participants_ride_activity_id ON ride_activity_participants(ride_activity_id);
CREATE INDEX idx_ride_activity_participants_user_id ON ride_activity_participants(user_id);

-- Add triggers for updated_at columns
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_users_timestamp
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_profiles_timestamp
BEFORE UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_communities_timestamp
BEFORE UPDATE ON communities
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_challenge_posts_timestamp
BEFORE UPDATE ON challenge_posts
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_stories_timestamp
BEFORE UPDATE ON stories
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_workouts_timestamp
BEFORE UPDATE ON workouts
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_workout_posts_timestamp
BEFORE UPDATE ON workout_posts
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_posts_timestamp
BEFORE UPDATE ON posts
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_post_comments_timestamp
BEFORE UPDATE ON post_comments
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_ride_activities_timestamp
BEFORE UPDATE ON ride_activities
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

-- ========================================
-- CHALLENGES SYSTEM TABLES
-- ========================================

-- Enums for challenges
CREATE TYPE challenge_status_enum AS ENUM ('draft', 'active', 'completed', 'cancelled');
CREATE TYPE activity_type_enum AS ENUM ('run', 'ride', 'swim', 'walk', 'hike', 'workout', 'other');
CREATE TYPE participant_status_enum AS ENUM ('joined', 'active', 'completed', 'dropped_out');

-- Table: challenges
CREATE TABLE challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(500) NOT NULL,
    description TEXT,
    brand VARCHAR(255),
    brand_logo TEXT, -- URL to brand logo image
    background_image TEXT, -- URL to background image
    distance DECIMAL(10,2), -- Distance in kilometers
    duration INTEGER, -- Duration in days
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    activity_type activity_type_enum NOT NULL,
    status challenge_status_enum NOT NULL DEFAULT 'draft',
    brand_color VARCHAR(7), -- Hex color code like #FF5733
    max_participants INTEGER, -- NULL means unlimited
    is_public BOOLEAN NOT NULL DEFAULT TRUE,
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT check_valid_dates CHECK (end_date > start_date),
    CONSTRAINT check_positive_distance CHECK (distance IS NULL OR distance > 0),
    CONSTRAINT check_positive_duration CHECK (duration IS NULL OR duration > 0),
    CONSTRAINT check_positive_max_participants CHECK (max_participants IS NULL OR max_participants > 0)
);

-- Table: challenge_participants
CREATE TABLE challenge_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status participant_status_enum NOT NULL DEFAULT 'joined',
    progress DECIMAL(10,2) NOT NULL DEFAULT 0.0, -- Progress value (e.g., km completed)
    progress_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.0, -- Progress as percentage (0-100)
    completion_proof_url TEXT, -- URL to proof of completion (image/video)
    joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    notes TEXT, -- Optional notes from participant
    
    -- Constraints
    UNIQUE(challenge_id, user_id), -- User can only join a challenge once
    CONSTRAINT check_progress_percentage CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    CONSTRAINT check_positive_progress CHECK (progress >= 0),
    CONSTRAINT check_completion_date CHECK (completed_at IS NULL OR completed_at >= joined_at)
);

-- Table: challenge_updates (for progress tracking)
CREATE TABLE challenge_updates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    participant_id UUID NOT NULL REFERENCES challenge_participants(id) ON DELETE CASCADE,
    previous_progress DECIMAL(10,2) NOT NULL,
    new_progress DECIMAL(10,2) NOT NULL,
    update_description TEXT,
    proof_url TEXT, -- URL to proof of this specific update
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT check_progress_increase CHECK (new_progress >= previous_progress)
);

-- Indexes for better performance
CREATE INDEX idx_challenges_status ON challenges(status);
CREATE INDEX idx_challenges_activity_type ON challenges(activity_type);
CREATE INDEX idx_challenges_start_date ON challenges(start_date);
CREATE INDEX idx_challenges_end_date ON challenges(end_date);
CREATE INDEX idx_challenges_created_by ON challenges(created_by);
CREATE INDEX idx_challenges_is_public ON challenges(is_public);

CREATE INDEX idx_challenge_participants_challenge_id ON challenge_participants(challenge_id);
CREATE INDEX idx_challenge_participants_user_id ON challenge_participants(user_id);
CREATE INDEX idx_challenge_participants_status ON challenge_participants(status);
CREATE INDEX idx_challenge_participants_joined_at ON challenge_participants(joined_at);

CREATE INDEX idx_challenge_updates_participant_id ON challenge_updates(participant_id);
CREATE INDEX idx_challenge_updates_created_at ON challenge_updates(created_at);

-- Triggers for automatic timestamp updates
CREATE TRIGGER set_challenges_timestamp
BEFORE UPDATE ON challenges
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

-- Functions for challenge statistics
CREATE OR REPLACE FUNCTION get_challenge_participant_count(challenge_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM challenge_participants
        WHERE challenge_id = challenge_uuid
        AND status IN ('joined', 'active', 'completed')
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_challenge_completion_rate(challenge_uuid UUID)
RETURNS DECIMAL(5,2) AS $$
DECLARE
    total_participants INTEGER;
    completed_participants INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_participants
    FROM challenge_participants
    WHERE challenge_id = challenge_uuid
    AND status IN ('joined', 'active', 'completed');
    
    SELECT COUNT(*) INTO completed_participants
    FROM challenge_participants
    WHERE challenge_id = challenge_uuid
    AND status = 'completed';
    
    IF total_participants = 0 THEN
        RETURN 0.0;
    END IF;
    
    RETURN (completed_participants::DECIMAL / total_participants::DECIMAL * 100);
END;
$$ LANGUAGE plpgsql;

-- View: challenge_summary (for easy querying with participant counts)
CREATE VIEW challenge_summary AS
SELECT 
    c.*,
    u.username as creator_username,
    u.email as creator_email,
    get_challenge_participant_count(c.id) as participant_count,
    get_challenge_completion_rate(c.id) as completion_rate,
    CASE 
        WHEN c.end_date < NOW() THEN 'expired'
        WHEN c.start_date > NOW() THEN 'upcoming'
        ELSE c.status::text
    END as computed_status
FROM challenges c
JOIN users u ON c.created_by = u.id;

-- View: user_challenge_participation (for user's challenge history)
CREATE VIEW user_challenge_participation AS
SELECT 
    cp.*,
    c.title as challenge_title,
    c.description as challenge_description,
    c.activity_type,
    c.start_date,
    c.end_date,
    c.distance as target_distance,
    c.duration as target_duration,
    u.username as creator_username
FROM challenge_participants cp
JOIN challenges c ON cp.challenge_id = c.id
JOIN users u ON c.created_by = u.id;

-- Sample data insertion (uncomment to use)
/*
-- Insert sample challenges
INSERT INTO challenges (title, description, activity_type, start_date, end_date, distance, created_by, brand, brand_color, is_public) VALUES
('July 5K Challenge', 'Complete a 5km run every day for a week', 'run', '2025-07-01', '2025-07-07', 5.0, (SELECT id FROM users LIMIT 1), 'FitNation', '#FF5733', true),
('Summer Cycling Challenge', 'Cycle 100km total during summer', 'ride', '2025-06-01', '2025-08-31', 100.0, (SELECT id FROM users LIMIT 1), 'CycleClub', '#33A1FF', true),
('Daily Steps Challenge', 'Walk 10,000 steps daily for 30 days', 'walk', '2025-08-01', '2025-08-31', NULL, (SELECT id FROM users LIMIT 1), 'StepTracker', '#33FF57', true);
*/
