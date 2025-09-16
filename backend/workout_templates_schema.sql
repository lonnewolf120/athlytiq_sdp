-- ===================================================================
-- WORKOUT TEMPLATES SCHEMA
-- ===================================================================
-- This schema defines tables for storing default workout routines from 
-- famous bodybuilders and fitness personalities that users can import
-- into their personal workout plans.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===================================================================
-- WORKOUT TEMPLATES TABLE
-- ===================================================================
-- Stores global workout templates (not user-specific)
CREATE TABLE IF NOT EXISTS workout_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    author VARCHAR(255) NOT NULL, -- e.g., "Ronnie Coleman", "Arnold Schwarzenegger"
    difficulty_level VARCHAR(50) NOT NULL CHECK (difficulty_level IN ('Beginner', 'Intermediate', 'Advanced')),
    primary_muscle_groups JSONB DEFAULT '[]'::jsonb, -- ["back", "biceps", "chest"]
    estimated_duration_minutes INTEGER CHECK (estimated_duration_minutes > 0),
    equipment_required JSONB DEFAULT '[]'::jsonb, -- ["barbell", "dumbbells", "cables"]
    tags JSONB DEFAULT '[]'::jsonb, -- ["mass_building", "strength", "classic", "powerlifting"]
    icon_url VARCHAR(1024),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for workout_templates
CREATE INDEX IF NOT EXISTS idx_workout_templates_author ON workout_templates(author);
CREATE INDEX IF NOT EXISTS idx_workout_templates_difficulty ON workout_templates(difficulty_level);
CREATE INDEX IF NOT EXISTS idx_workout_templates_active ON workout_templates(is_active);
CREATE INDEX IF NOT EXISTS idx_workout_templates_muscle_groups ON workout_templates USING gin(primary_muscle_groups);
CREATE INDEX IF NOT EXISTS idx_workout_templates_tags ON workout_templates USING gin(tags);
CREATE INDEX IF NOT EXISTS idx_workout_templates_name ON workout_templates USING gin(to_tsvector('english', name));

-- ===================================================================
-- WORKOUT TEMPLATE EXERCISES TABLE
-- ===================================================================
-- Stores exercises within each workout template
CREATE TABLE IF NOT EXISTS workout_template_exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_id UUID NOT NULL,
    exercise_id VARCHAR(255) NOT NULL, -- Reference to exercise library
    exercise_name VARCHAR(255) NOT NULL,
    exercise_equipments JSONB DEFAULT '[]'::jsonb,
    exercise_gif_url VARCHAR(1024),
    exercise_order INTEGER NOT NULL CHECK (exercise_order > 0), -- Order in the workout
    default_sets INTEGER NOT NULL CHECK (default_sets > 0),
    default_reps VARCHAR(50) NOT NULL, -- "8-10", "12-15", "AMRAP", "Till failure"
    default_weight VARCHAR(100), -- "bodyweight", "60-70% 1RM", "Heavy", "Moderate"
    rest_time_seconds INTEGER DEFAULT 60 CHECK (rest_time_seconds >= 0),
    notes TEXT, -- Special instructions or form cues
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Foreign Key Constraints
    CONSTRAINT fk_template_exercise_template
        FOREIGN KEY (template_id) 
        REFERENCES workout_templates(id) 
        ON DELETE CASCADE
);

-- Indexes for workout_template_exercises
CREATE INDEX IF NOT EXISTS idx_template_exercises_template_id ON workout_template_exercises(template_id);
CREATE INDEX IF NOT EXISTS idx_template_exercises_order ON workout_template_exercises(template_id, exercise_order);
CREATE INDEX IF NOT EXISTS idx_template_exercises_exercise_id ON workout_template_exercises(exercise_id);

-- ===================================================================
-- SAMPLE DATA COMMENTS
-- ===================================================================
-- This schema will be populated with famous workout routines such as:
-- 
-- 1. Ronnie Coleman's routines:
--    - "Ronnie's Back & Biceps Massacre"
--    - "Yeah Buddy Leg Day"
--    - "Classic Chest & Triceps"
--
-- 2. Arnold Schwarzenegger's routines:
--    - "Arnold's Classic Chest & Back"
--    - "Austrian Oak Arm Destroyer"
--    - "Golden Era Shoulders & Arms"
--
-- 3. Jeff Nippard's routines:
--    - "Science-Based Push Workout"
--    - "Evidence-Based Pull Day"
--    - "Fundamentals Upper Body"
--
-- 4. Jay Cutler's routines:
--    - "Mass Monster Leg Day"
--    - "Cutler's Quad Stomp"
--    - "Big Back Builder"
--
-- Each routine will include:
-- - Specific exercises with sets/reps
-- - Rest times between sets
-- - Form cues and notes
-- - Equipment requirements
-- - Estimated duration
--
-- ===================================================================
-- TEMPLATE METADATA EXAMPLES
-- ===================================================================
--
-- Example difficulty levels:
-- - Beginner: 3-4 exercises, basic movements, moderate volume
-- - Intermediate: 5-6 exercises, some advanced techniques, higher volume
-- - Advanced: 7+ exercises, advanced techniques, high volume/intensity
--
-- Example muscle group tags:
-- - Primary: ["chest", "back", "shoulders", "biceps", "triceps", "quadriceps", "hamstrings", "glutes", "calves", "core"]
-- - Secondary: ["upper_body", "lower_body", "full_body", "pull", "push", "legs"]
--
-- Example equipment tags:
-- - ["barbell", "dumbbells", "cables", "machines", "bodyweight", "resistance_bands", "kettlebells"]
--
-- Example workout tags:
-- - ["mass_building", "strength", "powerlifting", "bodybuilding", "classic", "old_school", "science_based", "high_volume", "intensity_techniques"]
--
-- ===================================================================

-- Add update trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_workout_templates_updated_at 
    BEFORE UPDATE ON workout_templates 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();