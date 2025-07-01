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
CREATE TABLE exercises (
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
