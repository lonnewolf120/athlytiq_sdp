# Workout Templates Feature Implementation Plan

## Overview
This document outlines the implementation plan for adding default workout routines from famous bodybuilders and fitness personalities that users can import into their personal workout plans.

## Database Design

### 1. workout_templates Table
```sql
CREATE TABLE workout_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    author VARCHAR(255) NOT NULL, -- e.g., "Ronnie Coleman", "Arnold Schwarzenegger"
    difficulty_level VARCHAR(50) NOT NULL, -- "Beginner", "Intermediate", "Advanced"
    primary_muscle_groups JSONB DEFAULT '[]', -- ["back", "biceps", "chest"]
    estimated_duration_minutes INTEGER,
    equipment_required JSONB DEFAULT '[]', -- ["barbell", "dumbbells", "cables"]
    tags JSONB DEFAULT '[]', -- ["mass_building", "strength", "classic", "powerlifting"]
    icon_url VARCHAR(1024),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 2. workout_template_exercises Table
```sql
CREATE TABLE workout_template_exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_id UUID NOT NULL REFERENCES workout_templates(id) ON DELETE CASCADE,
    exercise_id VARCHAR(255) NOT NULL, -- Reference to exercise library
    exercise_name VARCHAR(255) NOT NULL,
    exercise_equipments JSONB DEFAULT '[]',
    exercise_gif_url VARCHAR(1024),
    exercise_order INTEGER NOT NULL, -- Order in the workout
    default_sets INTEGER NOT NULL,
    default_reps VARCHAR(50) NOT NULL, -- "8-10", "12-15", "AMRAP"
    default_weight VARCHAR(100), -- "bodyweight", "60-70% 1RM", "Heavy"
    rest_time_seconds INTEGER DEFAULT 60,
    notes TEXT, -- Special instructions
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Backend Implementation

### 1. SQLAlchemy Models (models_db.py)

```python
class WorkoutTemplate(Base):
    __tablename__ = "workout_templates"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    author = Column(String(255), nullable=False)
    difficulty_level = Column(String(50), nullable=False)
    primary_muscle_groups = Column(JSONB, default=list)
    estimated_duration_minutes = Column(Integer)
    equipment_required = Column(JSONB, default=list)
    tags = Column(JSONB, default=list)
    icon_url = Column(String(1024))
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    exercises = relationship("WorkoutTemplateExercise", back_populates="template", cascade="all, delete-orphan")

class WorkoutTemplateExercise(Base):
    __tablename__ = "workout_template_exercises"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    template_id = Column(UUID(as_uuid=True), ForeignKey('workout_templates.id', ondelete='CASCADE'), nullable=False)
    exercise_id = Column(String(255), nullable=False)
    exercise_name = Column(String(255), nullable=False)
    exercise_equipments = Column(JSONB, default=list)
    exercise_gif_url = Column(String(1024))
    exercise_order = Column(Integer, nullable=False)
    default_sets = Column(Integer, nullable=False)
    default_reps = Column(String(50), nullable=False)
    default_weight = Column(String(100))
    rest_time_seconds = Column(Integer, default=60)
    notes = Column(Text)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
    template = relationship("WorkoutTemplate", back_populates="exercises")
```

### 2. API Endpoints (main.py)

```python
# GET /workout-templates - Get all templates with optional filters
@app.get("/workout-templates")
async def get_workout_templates(
    author: Optional[str] = None,
    difficulty_level: Optional[str] = None,
    muscle_groups: Optional[str] = None,
    tags: Optional[str] = None,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    # Implementation with filtering and pagination

# GET /workout-templates/{template_id} - Get specific template with exercises
@app.get("/workout-templates/{template_id}")
async def get_workout_template(
    template_id: str,
    db: Session = Depends(get_db)
):
    # Implementation to return template with exercises

# POST /workout-templates/{template_id}/import - Import template to user's plans
@app.post("/workout-templates/{template_id}/import")
async def import_workout_template(
    template_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Implementation to create a new Workout from template
```

## Flutter Implementation

### 1. Models (lib/models/)

**WorkoutTemplate.dart**
```dart
class WorkoutTemplate {
  final String id;
  final String name;
  final String? description;
  final String author;
  final String difficultyLevel;
  final List<String> primaryMuscleGroups;
  final int? estimatedDurationMinutes;
  final List<String> equipmentRequired;
  final List<String> tags;
  final String? iconUrl;
  final bool isActive;
  final List<WorkoutTemplateExercise> exercises;
  
  // Constructor, fromJson, toJson methods
}

class WorkoutTemplateExercise {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final List<String> exerciseEquipments;
  final String? exerciseGifUrl;
  final int exerciseOrder;
  final int defaultSets;
  final String defaultReps;
  final String? defaultWeight;
  final int? restTimeSeconds;
  final String? notes;
  
  // Constructor, fromJson, toJson methods
}
```

### 2. Providers (lib/providers/)

**workout_templates_provider.dart**
```dart
// Provider for fetching all workout templates
final workoutTemplatesProvider = FutureProvider.family<List<WorkoutTemplate>, TemplateFilters>(
  (ref, filters) async {
    final apiService = ref.watch(apiServiceProvider);
    return await apiService.getWorkoutTemplates(filters);
  },
);

// Provider for fetching a specific template
final workoutTemplateProvider = FutureProvider.family<WorkoutTemplate, String>(
  (ref, templateId) async {
    final apiService = ref.watch(apiServiceProvider);
    return await apiService.getWorkoutTemplate(templateId);
  },
);
```

### 3. UI Screens (lib/Screens/Activities/)

**WorkoutTemplatesScreen.dart** - Browse all templates
**WorkoutTemplateDetailScreen.dart** - View specific template details
**ImportTemplateDialog.dart** - Confirmation dialog for importing

### 4. Integration Points

- Add "Browse Templates" button/tab in WorkoutScreen
- Add template import functionality to create new personal workout plans
- Update API service with new endpoints

## Sample Data Structure

### Famous Workout Routines to Include:

1. **Ronnie Coleman's Back & Biceps**
   - Author: "Ronnie Coleman"
   - Difficulty: "Advanced"
   - Muscle Groups: ["back", "biceps"]
   - Exercises: Bent-over rows, T-bar rows, Lat pulldowns, Barbell curls, etc.

2. **Arnold's Classic Chest & Back**
   - Author: "Arnold Schwarzenegger"
   - Difficulty: "Intermediate"
   - Muscle Groups: ["chest", "back"]
   - Exercises: Bench press, Incline press, Pull-ups, Rows, etc.

3. **Jeff Nippard's Science-Based Push**
   - Author: "Jeff Nippard"
   - Difficulty: "Intermediate"
   - Muscle Groups: ["chest", "shoulders", "triceps"]
   - Exercises: Based on scientific research and optimal muscle activation

4. **Jay Cutler's Leg Destroyer**
   - Author: "Jay Cutler"
   - Difficulty: "Advanced"
   - Muscle Groups: ["quadriceps", "hamstrings", "glutes", "calves"]
   - Exercises: Squats, Leg press, Romanian deadlifts, etc.

## Implementation Order

1. Database schema creation and migration
2. Backend models and API endpoints
3. Flutter models and providers
4. UI screens and integration
5. Seed data population
6. Testing and refinement

## Technical Considerations

- Templates are read-only for users (no editing, only importing)
- Importing creates a copy in user's personal workout plans
- Templates can be versioned for updates
- Search and filtering capabilities for easy discovery
- Caching strategy for frequently accessed templates
- Image optimization for template icons and exercise GIFs

## Future Enhancements

- User ratings and reviews for templates
- Template difficulty ratings based on user feedback
- Personalized template recommendations
- Community-submitted templates (with moderation)
- Template variations (e.g., beginner version of advanced routines)