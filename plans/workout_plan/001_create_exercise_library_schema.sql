-- Migration: Create Enhanced Exercise Library Schema
-- Version: 001_create_exercise_library_schema
-- Date: 2025-01-27
-- Description: Create normalized exercise library with proper relationships

-- Create exercise_categories table
CREATE TABLE IF NOT EXISTS exercise_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color_code VARCHAR(7), -- For UI color coding (hex color)
    icon_name VARCHAR(50), -- For UI icons
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create muscle_groups table with hierarchical structure
CREATE TABLE IF NOT EXISTS muscle_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    group_type VARCHAR(20) NOT NULL CHECK (group_type IN ('primary', 'secondary', 'stabilizer')),
    parent_id UUID REFERENCES muscle_groups(id) ON DELETE SET NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create equipment_types table
CREATE TABLE IF NOT EXISTS equipment_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50), -- 'cardio', 'strength', 'bodyweight', 'functional'
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create enhanced exercise_library table
CREATE TABLE IF NOT EXISTS exercise_library (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    instructions TEXT,
    form_tips TEXT,
    gif_url TEXT,
    video_url TEXT,
    category_id UUID REFERENCES exercise_categories(id) ON DELETE SET NULL,
    difficulty_level INTEGER CHECK (difficulty_level >= 1 AND difficulty_level <= 5),
    popularity_score DECIMAL(3,2) DEFAULT 0.0, -- 0.00 to 5.00
    is_compound BOOLEAN DEFAULT FALSE,
    is_unilateral BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Search optimization
    search_vector TSVECTOR GENERATED ALWAYS AS (
        to_tsvector('english', 
            COALESCE(name, '') || ' ' || 
            COALESCE(description, '') || ' ' || 
            COALESCE(instructions, '')
        )
    ) STORED
);

-- Create junction table for exercise-muscle relationships
CREATE TABLE IF NOT EXISTS exercise_muscle_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_id UUID REFERENCES exercise_library(id) ON DELETE CASCADE,
    muscle_group_id UUID REFERENCES muscle_groups(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT TRUE,
    activation_level INTEGER CHECK (activation_level >= 1 AND activation_level <= 5), -- 1=minimal, 5=maximal
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(exercise_id, muscle_group_id)
);

-- Create junction table for exercise-equipment relationships
CREATE TABLE IF NOT EXISTS exercise_equipment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_id UUID REFERENCES exercise_library(id) ON DELETE CASCADE,
    equipment_id UUID REFERENCES equipment_types(id) ON DELETE CASCADE,
    is_required BOOLEAN DEFAULT TRUE,
    is_alternative BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(exercise_id, equipment_id)
);

-- Create exercise_variations table for alternative exercises
CREATE TABLE IF NOT EXISTS exercise_variations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    base_exercise_id UUID REFERENCES exercise_library(id) ON DELETE CASCADE,
    variation_exercise_id UUID REFERENCES exercise_library(id) ON DELETE CASCADE,
    variation_type VARCHAR(50), -- 'easier', 'harder', 'alternative', 'progression'
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(base_exercise_id, variation_exercise_id),
    CHECK (base_exercise_id != variation_exercise_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_exercise_library_category ON exercise_library(category_id);
CREATE INDEX IF NOT EXISTS idx_exercise_library_difficulty ON exercise_library(difficulty_level);
CREATE INDEX IF NOT EXISTS idx_exercise_library_popularity ON exercise_library(popularity_score DESC);
CREATE INDEX IF NOT EXISTS idx_exercise_library_search ON exercise_library USING GIN(search_vector);
CREATE INDEX IF NOT EXISTS idx_exercise_library_name ON exercise_library(name);
CREATE INDEX IF NOT EXISTS idx_exercise_library_active ON exercise_library(is_active);

CREATE INDEX IF NOT EXISTS idx_exercise_muscle_groups_exercise ON exercise_muscle_groups(exercise_id);
CREATE INDEX IF NOT EXISTS idx_exercise_muscle_groups_muscle ON exercise_muscle_groups(muscle_group_id);
CREATE INDEX IF NOT EXISTS idx_exercise_muscle_groups_primary ON exercise_muscle_groups(is_primary);

CREATE INDEX IF NOT EXISTS idx_exercise_equipment_exercise ON exercise_equipment(exercise_id);
CREATE INDEX IF NOT EXISTS idx_exercise_equipment_equipment ON exercise_equipment(equipment_id);
CREATE INDEX IF NOT EXISTS idx_exercise_equipment_required ON exercise_equipment(is_required);

-- Create triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_exercise_categories_updated_at BEFORE UPDATE ON exercise_categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_muscle_groups_updated_at BEFORE UPDATE ON muscle_groups FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_equipment_types_updated_at BEFORE UPDATE ON equipment_types FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_exercise_library_updated_at BEFORE UPDATE ON exercise_library FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
