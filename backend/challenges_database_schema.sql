-- SQL script to create challenges tables for Athlytiq backend
-- Execute this script in your PostgreSQL database after the shop tables

-- Create challenges table
CREATE TABLE IF NOT EXISTS challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    brand VARCHAR(255),
    brand_logo VARCHAR(500),
    background_image VARCHAR(500),
    distance DECIMAL(10, 2), -- Distance in km or miles
    duration INTEGER, -- Duration in minutes
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    activity_type VARCHAR(50) NOT NULL DEFAULT 'running' CHECK (activity_type IN (
        'running', 'cycling', 'swimming', 'walking', 'hiking', 'gym', 'yoga', 'other'
    )),
    status VARCHAR(50) NOT NULL DEFAULT 'active' CHECK (status IN (
        'draft', 'active', 'completed', 'cancelled'
    )),
    brand_color VARCHAR(7), -- Hex color code
    max_participants INTEGER DEFAULT 100,
    is_public BOOLEAN NOT NULL DEFAULT true,
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create challenge_participants table
CREATE TABLE IF NOT EXISTS challenge_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'joined' CHECK (status IN (
        'joined', 'completed', 'abandoned'
    )),
    progress DECIMAL(10, 2) DEFAULT 0.0, -- Progress value (e.g., distance covered)
    progress_percentage DECIMAL(5, 2) DEFAULT 0.0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    completion_proof_url VARCHAR(500), -- URL to proof of completion (image, etc.)
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    notes TEXT, -- User notes about their participation
    
    -- Unique constraint to prevent duplicate participation
    CONSTRAINT unique_challenge_participant UNIQUE (challenge_id, user_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_challenges_activity_type ON challenges(activity_type);
CREATE INDEX IF NOT EXISTS idx_challenges_status ON challenges(status);
CREATE INDEX IF NOT EXISTS idx_challenges_created_by ON challenges(created_by);
CREATE INDEX IF NOT EXISTS idx_challenges_start_date ON challenges(start_date);
CREATE INDEX IF NOT EXISTS idx_challenges_end_date ON challenges(end_date);
CREATE INDEX IF NOT EXISTS idx_challenges_is_public ON challenges(is_public);
CREATE INDEX IF NOT EXISTS idx_challenges_created_at ON challenges(created_at);

CREATE INDEX IF NOT EXISTS idx_challenge_participants_challenge_id ON challenge_participants(challenge_id);
CREATE INDEX IF NOT EXISTS idx_challenge_participants_user_id ON challenge_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_challenge_participants_status ON challenge_participants(status);
CREATE INDEX IF NOT EXISTS idx_challenge_participants_joined_at ON challenge_participants(joined_at);
CREATE INDEX IF NOT EXISTS idx_challenge_participants_completed_at ON challenge_participants(completed_at);

-- Add trigger to update updated_at column
CREATE OR REPLACE FUNCTION update_challenges_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS trigger_update_challenges_updated_at ON challenges;
CREATE TRIGGER trigger_update_challenges_updated_at
    BEFORE UPDATE ON challenges
    FOR EACH ROW
    EXECUTE FUNCTION update_challenges_updated_at();

-- Insert sample challenges data
INSERT INTO challenges (
    id,
    title,
    description,
    brand,
    brand_logo,
    background_image,
    distance,
    duration,
    start_date,
    end_date,
    activity_type,
    status,
    brand_color,
    max_participants,
    is_public,
    created_by
) VALUES 
(
    gen_random_uuid(),
    'Nike Run Club 5K Challenge',
    'Join thousands of runners worldwide in completing a 5K run. Track your progress, share your achievements, and connect with fellow runners in this exciting challenge brought to you by Nike.',
    'Nike',
    'https://logoeps.com/wp-content/uploads/2013/03/nike-vector-logo.png',
    'https://images.unsplash.com/photo-1544717297-fa95b6ee9643?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    5.0,
    30,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '30 days',
    'running',
    'active',
    '#FF6B35',
    1000,
    true,
    (SELECT id FROM users LIMIT 1)
),
(
    gen_random_uuid(),
    'Adidas Cycling Century',
    'Push your limits with our 100km cycling challenge. Complete the distance within the challenge period and earn exclusive Adidas rewards.',
    'Adidas',
    'https://logoeps.com/wp-content/uploads/2013/03/adidas-vector-logo.png',
    'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    100.0,
    300,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '60 days',
    'cycling',
    'active',
    '#3B82F6',
    500,
    true,
    (SELECT id FROM users LIMIT 1)
),
(
    gen_random_uuid(),
    'Under Armour Strength Challenge',
    'Build strength and endurance with our comprehensive gym challenge. Complete various strength training exercises and track your progress.',
    'Under Armour',
    'https://logoeps.com/wp-content/uploads/2013/03/under-armour-vector-logo.png',
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    NULL,
    60,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '45 days',
    'gym',
    'active',
    '#DC2626',
    300,
    true,
    (SELECT id FROM users LIMIT 1)
),
(
    gen_random_uuid(),
    'Lululemon Yoga Flow',
    'Find your zen with our 21-day yoga challenge. Practice mindfulness and flexibility with guided sessions from Lululemon experts.',
    'Lululemon',
    'https://logoeps.com/wp-content/uploads/2017/05/lululemon-athletica-vector-logo.png',
    'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    NULL,
    45,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '21 days',
    'yoga',
    'active',
    '#10B981',
    200,
    true,
    (SELECT id FROM users LIMIT 1)
),
(
    gen_random_uuid(),
    'Puma Swimming Sprint',
    'Dive into our swimming challenge! Complete 2km of swimming across the challenge period and improve your technique.',
    'Puma',
    'https://logoeps.com/wp-content/uploads/2013/03/puma-vector-logo.png',
    'https://images.unsplash.com/photo-1530549387789-4c1017266635?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    2.0,
    120,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '30 days',
    'swimming',
    'active',
    '#8B5CF6',
    150,
    true,
    (SELECT id FROM users LIMIT 1)
) ON CONFLICT (id) DO NOTHING;

-- Verify the challenges were created
SELECT COUNT(*) as total_challenges FROM challenges;
SELECT COUNT(*) as total_participants FROM challenge_participants;

-- Show sample challenges
SELECT 
    id,
    title,
    brand,
    activity_type,
    status,
    distance,
    duration,
    max_participants,
    start_date,
    end_date
FROM challenges 
ORDER BY created_at DESC 
LIMIT 5;
