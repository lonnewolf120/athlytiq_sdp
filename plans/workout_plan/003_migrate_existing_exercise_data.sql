-- Migration: Migrate Existing Exercise Data
-- Version: 003_migrate_existing_exercise_data
-- Date: 2025-01-27
-- Description: Migrate existing exercise data to the new normalized structure

-- First, let's create some popular exercises in the exercise_library
-- We'll migrate the existing exercises and add some additional popular ones

-- Insert exercises into exercise_library based on existing data
INSERT INTO exercise_library (
    name, 
    description, 
    category_id, 
    difficulty_level, 
    gif_url,
    is_compound,
    is_unilateral,
    popularity_score
) VALUES
-- From existing exercises
(
    'Pull-ups', 
    'A compound upper body exercise that targets the back, biceps, and core muscles by pulling your body weight up to a bar.',
    (SELECT id FROM exercise_categories WHERE name = 'Strength Training'),
    3,
    '',
    true,
    false,
    4.5
),
(
    'Burpees', 
    'A full-body exercise that combines a squat, plank, push-up, and jump into one fluid movement.',
    (SELECT id FROM exercise_categories WHERE name = 'Plyometrics'),
    4,
    '',
    true,
    false,
    4.2
),
(
    'Mountain Climbers', 
    'A cardio exercise performed in plank position, alternating bringing knees toward the chest.',
    (SELECT id FROM exercise_categories WHERE name = 'Cardiovascular'),
    2,
    '',
    false,
    true,
    4.0
),
(
    'Jump Squats', 
    'An explosive lower body exercise that adds a jump to the traditional squat movement.',
    (SELECT id FROM exercise_categories WHERE name = 'Plyometrics'),
    3,
    '',
    true,
    false,
    4.3
),
(
    'Plank', 
    'An isometric core exercise that involves maintaining a position similar to a push-up.',
    (SELECT id FROM exercise_categories WHERE name = 'Core'),
    2,
    '',
    false,
    false,
    4.7
),

-- Additional popular exercises to expand the library
(
    'Push-ups', 
    'A compound upper body exercise that targets chest, shoulders, and triceps.',
    (SELECT id FROM exercise_categories WHERE name = 'Strength Training'),
    2,
    '',
    true,
    false,
    4.8
),
(
    'Squats', 
    'A fundamental lower body exercise that targets quadriceps, glutes, and hamstrings.',
    (SELECT id FROM exercise_categories WHERE name = 'Strength Training'),
    2,
    '',
    true,
    false,
    4.9
),
(
    'Deadlift', 
    'A compound exercise that involves lifting a weight from the ground to hip level.',
    (SELECT id FROM exercise_categories WHERE name = 'Strength Training'),
    4,
    '',
    true,
    false,
    4.6
),
(
    'Bench Press', 
    'A upper body strength exercise performed lying on a bench, pressing weight away from the chest.',
    (SELECT id FROM exercise_categories WHERE name = 'Strength Training'),
    3,
    '',
    true,
    false,
    4.7
),
(
    'Lunges', 
    'A lower body exercise that targets legs and glutes with a stepping movement.',
    (SELECT id FROM exercise_categories WHERE name = 'Strength Training'),
    2,
    '',
    true,
    true,
    4.4
);

-- Create muscle group associations for the exercises
-- Pull-ups: Back (primary), Biceps (secondary), Core (stabilizer)
INSERT INTO exercise_muscle_groups (exercise_id, muscle_group_id, is_primary, activation_level)
SELECT 
    el.id,
    mg.id,
    CASE 
        WHEN mg.name IN ('Back', 'Lats') THEN true
        ELSE false
    END,
    CASE 
        WHEN mg.name = 'Back' THEN 5
        WHEN mg.name = 'Lats' THEN 5
        WHEN mg.name = 'Biceps' THEN 4
        WHEN mg.name = 'Core' THEN 3
        ELSE 3
    END
FROM exercise_library el, muscle_groups mg
WHERE el.name = 'Pull-ups' 
AND mg.name IN ('Back', 'Lats', 'Biceps', 'Core');

-- Burpees: Full body exercise
INSERT INTO exercise_muscle_groups (exercise_id, muscle_group_id, is_primary, activation_level)
SELECT 
    el.id,
    mg.id,
    CASE 
        WHEN mg.name IN ('Legs', 'Core', 'Chest') THEN true
        ELSE false
    END,
    4
FROM exercise_library el, muscle_groups mg
WHERE el.name = 'Burpees' 
AND mg.name IN ('Legs', 'Core', 'Chest', 'Shoulders', 'Arms');

-- Mountain Climbers: Core (primary), Legs (secondary)
INSERT INTO exercise_muscle_groups (exercise_id, muscle_group_id, is_primary, activation_level)
SELECT 
    el.id,
    mg.id,
    CASE 
        WHEN mg.name = 'Core' THEN true
        ELSE false
    END,
    CASE 
        WHEN mg.name = 'Core' THEN 5
        WHEN mg.name = 'Legs' THEN 4
        WHEN mg.name = 'Shoulders' THEN 3
        ELSE 3
    END
FROM exercise_library el, muscle_groups mg
WHERE el.name = 'Mountain Climbers' 
AND mg.name IN ('Core', 'Legs', 'Shoulders');

-- Jump Squats: Legs (primary), Glutes (primary), Core (stabilizer)
INSERT INTO exercise_muscle_groups (exercise_id, muscle_group_id, is_primary, activation_level)
SELECT 
    el.id,
    mg.id,
    CASE 
        WHEN mg.name IN ('Legs', 'Glutes', 'Quadriceps') THEN true
        ELSE false
    END,
    CASE 
        WHEN mg.name IN ('Legs', 'Quadriceps') THEN 5
        WHEN mg.name = 'Glutes' THEN 5
        WHEN mg.name = 'Core' THEN 3
        ELSE 3
    END
FROM exercise_library el, muscle_groups mg
WHERE el.name = 'Jump Squats' 
AND mg.name IN ('Legs', 'Glutes', 'Quadriceps', 'Core');

-- Plank: Core (primary)
INSERT INTO exercise_muscle_groups (exercise_id, muscle_group_id, is_primary, activation_level)
SELECT 
    el.id,
    mg.id,
    CASE 
        WHEN mg.name IN ('Core', 'Abs') THEN true
        ELSE false
    END,
    CASE 
        WHEN mg.name = 'Core' THEN 5
        WHEN mg.name = 'Abs' THEN 5
        WHEN mg.name = 'Shoulders' THEN 3
        ELSE 3
    END
FROM exercise_library el, muscle_groups mg
WHERE el.name = 'Plank' 
AND mg.name IN ('Core', 'Abs', 'Shoulders');

-- Equipment associations
-- Pull-ups: Pull-up Bar
INSERT INTO exercise_equipment (exercise_id, equipment_id, is_required, is_alternative)
SELECT el.id, et.id, true, false
FROM exercise_library el, equipment_types et
WHERE el.name = 'Pull-ups' AND et.name = 'Pull-up Bar';

-- Burpees, Mountain Climbers, Jump Squats, Plank: Body Weight
INSERT INTO exercise_equipment (exercise_id, equipment_id, is_required, is_alternative)
SELECT el.id, et.id, true, false
FROM exercise_library el, equipment_types et
WHERE el.name IN ('Burpees', 'Mountain Climbers', 'Jump Squats', 'Plank') 
AND et.name = 'Body Weight';

-- Add muscle groups for additional exercises
-- Push-ups: Chest (primary), Shoulders (secondary), Triceps (secondary), Core (stabilizer)
INSERT INTO exercise_muscle_groups (exercise_id, muscle_group_id, is_primary, activation_level)
SELECT 
    el.id,
    mg.id,
    CASE 
        WHEN mg.name = 'Chest' THEN true
        ELSE false
    END,
    CASE 
        WHEN mg.name = 'Chest' THEN 5
        WHEN mg.name = 'Triceps' THEN 4
        WHEN mg.name = 'Shoulders' THEN 4
        WHEN mg.name = 'Core' THEN 3
        ELSE 3
    END
FROM exercise_library el, muscle_groups mg
WHERE el.name = 'Push-ups' 
AND mg.name IN ('Chest', 'Shoulders', 'Triceps', 'Core');

-- Squats: Legs (primary), Glutes (primary), Core (stabilizer)
INSERT INTO exercise_muscle_groups (exercise_id, muscle_group_id, is_primary, activation_level)
SELECT 
    el.id,
    mg.id,
    CASE 
        WHEN mg.name IN ('Legs', 'Quadriceps', 'Glutes') THEN true
        ELSE false
    END,
    CASE 
        WHEN mg.name IN ('Legs', 'Quadriceps') THEN 5
        WHEN mg.name = 'Glutes' THEN 5
        WHEN mg.name = 'Core' THEN 3
        ELSE 3
    END
FROM exercise_library el, muscle_groups mg
WHERE el.name = 'Squats' 
AND mg.name IN ('Legs', 'Quadriceps', 'Glutes', 'Core');

-- Equipment for new exercises
INSERT INTO exercise_equipment (exercise_id, equipment_id, is_required, is_alternative)
SELECT el.id, et.id, true, false
FROM exercise_library el, equipment_types et
WHERE el.name IN ('Push-ups', 'Squats', 'Lunges') 
AND et.name = 'Body Weight';

INSERT INTO exercise_equipment (exercise_id, equipment_id, is_required, is_alternative)
SELECT el.id, et.id, true, false
FROM exercise_library el, equipment_types et
WHERE el.name = 'Deadlift' AND et.name = 'Barbell';

INSERT INTO exercise_equipment (exercise_id, equipment_id, is_required, is_alternative)
SELECT el.id, et.id, true, false
FROM exercise_library el, equipment_types et
WHERE el.name = 'Bench Press' AND et.name IN ('Barbell', 'Bench');

-- Alternative equipment options
INSERT INTO exercise_equipment (exercise_id, equipment_id, is_required, is_alternative)
SELECT el.id, et.id, false, true
FROM exercise_library el, equipment_types et
WHERE el.name = 'Deadlift' AND et.name = 'Dumbbell';

INSERT INTO exercise_equipment (exercise_id, equipment_id, is_required, is_alternative)
SELECT el.id, et.id, false, true
FROM exercise_library el, equipment_types et
WHERE el.name = 'Bench Press' AND et.name = 'Dumbbell';

-- Update the original exercises table to reference the new exercise_library
-- First add the new column
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS exercise_library_id UUID REFERENCES exercise_library(id);

-- Update existing exercises to link to exercise_library
UPDATE exercises 
SET exercise_library_id = el.id
FROM exercise_library el
WHERE exercises.name = el.name;

-- Create index for the new foreign key
CREATE INDEX IF NOT EXISTS idx_exercises_exercise_library ON exercises(exercise_library_id);
