-- Migration: Seed Exercise Library Data
-- Version: 002_seed_exercise_library_data
-- Date: 2025-01-27
-- Description: Insert initial reference data for exercise categories, muscle groups, and equipment

-- Insert exercise categories
INSERT INTO exercise_categories (name, description, color_code, icon_name) VALUES
('Strength Training', 'Resistance exercises to build muscle and strength', '#FF6B6B', 'dumbbell'),
('Cardiovascular', 'Exercises to improve heart health and endurance', '#4ECDC4', 'heart'),
('Flexibility', 'Stretching and mobility exercises', '#45B7D1', 'stretch'),
('Functional', 'Exercises that mimic daily activities', '#96CEB4', 'functional'),
('Plyometrics', 'Explosive movement exercises', '#FFEAA7', 'lightning'),
('Core', 'Exercises targeting the core muscles', '#DDA0DD', 'core'),
('Rehabilitation', 'Therapeutic and recovery exercises', '#98FB98', 'medical')
ON CONFLICT (name) DO NOTHING;

-- Insert primary muscle groups
INSERT INTO muscle_groups (name, group_type, parent_id, description) VALUES
-- Upper Body Primary Groups
('Chest', 'primary', NULL, 'Pectoral muscles'),
('Back', 'primary', NULL, 'Latissimus dorsi, rhomboids, trapezius'),
('Shoulders', 'primary', NULL, 'Deltoid muscles'),
('Arms', 'primary', NULL, 'Biceps, triceps, forearms'),
('Core', 'primary', NULL, 'Abdominals, obliques, lower back'),

-- Lower Body Primary Groups
('Legs', 'primary', NULL, 'Quadriceps, hamstrings, glutes, calves'),
('Glutes', 'primary', NULL, 'Gluteal muscles'),

-- Get IDs for detailed muscle groups
-- Chest subdivisions
('Upper Chest', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Chest'), 'Upper pectoral fibers'),
('Lower Chest', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Chest'), 'Lower pectoral fibers'),
('Inner Chest', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Chest'), 'Inner pectoral region'),

-- Back subdivisions
('Upper Back', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Back'), 'Upper trapezius, rhomboids'),
('Middle Back', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Back'), 'Middle trapezius, latissimus dorsi'),
('Lower Back', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Back'), 'Lower back, erector spinae'),
('Lats', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Back'), 'Latissimus dorsi'),

-- Shoulder subdivisions
('Front Delts', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Shoulders'), 'Anterior deltoid'),
('Side Delts', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Shoulders'), 'Lateral deltoid'),
('Rear Delts', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Shoulders'), 'Posterior deltoid'),

-- Arm subdivisions
('Biceps', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Arms'), 'Biceps brachii'),
('Triceps', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Arms'), 'Triceps brachii'),
('Forearms', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Arms'), 'Forearm muscles'),

-- Core subdivisions
('Abs', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Core'), 'Abdominal muscles'),
('Obliques', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Core'), 'External and internal obliques'),
('Lower Abs', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Core'), 'Lower abdominal region'),

-- Leg subdivisions
('Quadriceps', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Legs'), 'Front thigh muscles'),
('Hamstrings', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Legs'), 'Back thigh muscles'),
('Calves', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Legs'), 'Calf muscles'),
('Glutes', 'secondary', (SELECT id FROM muscle_groups WHERE name = 'Legs'), 'Gluteal muscles')
ON CONFLICT (name) DO NOTHING;

-- Insert equipment types
INSERT INTO equipment_types (name, category, description) VALUES
-- Bodyweight
('Body Weight', 'bodyweight', 'No equipment needed'),
('Pull-up Bar', 'bodyweight', 'For hanging and pulling exercises'),

-- Free Weights
('Barbell', 'strength', 'Long bar with weights on both ends'),
('Dumbbell', 'strength', 'Short weights held in each hand'),
('Kettlebell', 'strength', 'Cast iron weight with handle'),
('Weight Plates', 'strength', 'Individual weight discs'),

-- Machines
('Cable Machine', 'strength', 'Pulley-based resistance system'),
('Smith Machine', 'strength', 'Guided barbell system'),
('Leg Press Machine', 'strength', 'Machine for leg exercises'),
('Lat Pulldown Machine', 'strength', 'Machine for back exercises'),

-- Cardio Equipment
('Treadmill', 'cardio', 'Running/walking machine'),
('Stationary Bike', 'cardio', 'Indoor cycling machine'),
('Elliptical', 'cardio', 'Low-impact cardio machine'),
('Rowing Machine', 'cardio', 'Full-body cardio equipment'),

-- Functional Equipment
('Resistance Bands', 'functional', 'Elastic bands for resistance'),
('Medicine Ball', 'functional', 'Weighted ball for dynamic exercises'),
('Suspension Trainer', 'functional', 'Body weight training system'),
('Battle Ropes', 'functional', 'Heavy ropes for conditioning'),
('Plyometric Box', 'functional', 'Platform for jumping exercises'),

-- Accessories
('Yoga Mat', 'functional', 'Mat for floor exercises'),
('Foam Roller', 'functional', 'Tool for muscle recovery'),
('Stability Ball', 'functional', 'Large inflatable ball'),
('Bench', 'strength', 'Exercise bench for various positions')
ON CONFLICT (name) DO NOTHING;
