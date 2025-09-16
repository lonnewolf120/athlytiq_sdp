# Manual Workout Creation System - Comprehensive Design Document

## System Overview

This document outlines the complete design for implementing a manual workout creation system that allows users to:
1. Browse and search exercises with advanced filtering
2. Create custom workout plans by selecting multiple exercises
3. Configure sets and reps for each exercise
4. View detailed exercise information with community features
5. Sync data between local storage and backend

## User Flow Design

### 1. WorkoutScreen - Entry Point
```
WorkoutScreen (Updated)
├── Existing workout plans list
├── Floating Action Button (FAB)
    ├── "Add New Workout" → Manual creation flow
    ├── "Import from Backend" → Existing functionality
    └── "Generate with AI" → Existing functionality
```

### 2. Manual Workout Creation Flow
```
Add New Workout Screen
├── Workout name input field
├── Optional description field
└── "Add Exercises" button → Exercise Selection Screen

Exercise Selection Screen
├── Search bar (name, muscle, equipment)
├── Filter chips (body parts, equipment, difficulty)
├── Exercise list with multi-select
├── Each exercise item shows:
    ├── Exercise name
    ├── Target muscles
    ├── Equipment needed
    ├── Thumbnail/GIF preview
    └── Selection checkbox
├── "View Details" on tap → Exercise Detail Modal
└── "Continue" button → Sets/Reps Configuration

Sets/Reps Configuration Screen
├── List of selected exercises
├── For each exercise:
    ├── Exercise name and image
    ├── Sets input field
    ├── Reps input field
    ├── Optional weight field
    └── Optional notes field
└── "Save Workout" button → Save and return to WorkoutScreen
```

### 3. Exercise Detail Modal (Tabs)
```
Exercise Detail Modal
├── Tab 1: Details
    ├── Exercise video/GIF
    ├── Exercise name and description
    ├── Target muscles (primary/secondary)
    ├── Equipment needed
    ├── Preparation instructions
    ├── Execution steps
    └── Key tips
├── Tab 2: Suggestions
    ├── Expert tips
    ├── Community suggestions
    ├── Personal notes (user can add)
    └── Related exercises
└── Tab 3: Records
    ├── Personal best (1RM, max weight, max volume)
    ├── Recent workout history for this exercise
    ├── Performance graphs/charts
    └── Progress tracking
```

## Data Models Design

### Backend Database Schema Updates

#### 1. Enhanced Exercise Table
```sql
-- Updated exercises table
CREATE TABLE exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    gif_url TEXT,
    video_url TEXT,
    image_url TEXT,
    instructions JSONB, -- Array of instruction steps
    preparation_notes TEXT,
    key_tips JSONB, -- Array of key tips
    difficulty_level INTEGER DEFAULT 1, -- 1-5 scale
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Normalized muscle groups table
CREATE TABLE muscle_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50), -- primary_muscle, secondary_muscle
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Exercise muscle relationships
CREATE TABLE exercise_muscles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_id UUID REFERENCES exercises(id) ON DELETE CASCADE,
    muscle_group_id UUID REFERENCES muscle_groups(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(exercise_id, muscle_group_id)
);

-- Normalized equipment table
CREATE TABLE equipment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50), -- weights, machines, bodyweight, etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Exercise equipment relationships
CREATE TABLE exercise_equipment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_id UUID REFERENCES exercises(id) ON DELETE CASCADE,
    equipment_id UUID REFERENCES equipment(id) ON DELETE CASCADE,
    is_required BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(exercise_id, equipment_id)
);

-- Exercise suggestions and tips
CREATE TABLE exercise_suggestions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_id UUID REFERENCES exercises(id) ON DELETE CASCADE,
    title VARCHAR(255),
    content TEXT NOT NULL,
    source VARCHAR(100), -- expert, community, ai
    author_id UUID REFERENCES users(id) ON DELETE SET NULL,
    is_verified BOOLEAN DEFAULT false,
    votes_up INTEGER DEFAULT 0,
    votes_down INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User exercise records and PRs
CREATE TABLE user_exercise_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    exercise_id UUID REFERENCES exercises(id) ON DELETE CASCADE,
    record_type VARCHAR(50) NOT NULL, -- max_weight, max_reps, max_volume, one_rm
    value NUMERIC NOT NULL,
    unit VARCHAR(20), -- kg, lbs, reps
    workout_session_id UUID, -- Optional reference to completed workout
    achieved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 2. Enhanced Workout Plan Schema
```sql
-- Update planned_exercises to remove exercise-specific data
-- (sets, reps should be in workout context, not exercise master data)
CREATE TABLE planned_exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID REFERENCES workouts(id) ON DELETE CASCADE,
    exercise_id UUID REFERENCES exercises(id) ON DELETE CASCADE,
    sets INTEGER DEFAULT 1,
    reps INTEGER,
    weight NUMERIC,
    duration_seconds INTEGER,
    rest_seconds INTEGER DEFAULT 60,
    notes TEXT,
    order_in_workout INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Backend API Enhancements

#### 1. Enhanced Exercise Endpoints
```python
# New exercise endpoints
@router.get("/", response_model=List[ExerciseResult])
def get_exercises(
    db: Session = Depends(get_db),
    name: Optional[str] = Query(None),
    muscle_groups: Optional[List[str]] = Query(None),
    equipment: Optional[List[str]] = Query(None),
    difficulty: Optional[int] = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    sort_by: Optional[str] = Query("name"), # name, difficulty, created_at
    sort_order: Optional[str] = Query("asc") # asc, desc
)

@router.get("/{exercise_id}/details", response_model=ExerciseDetailResult)
def get_exercise_details(exercise_id: UUID, db: Session = Depends(get_db))

@router.get("/{exercise_id}/suggestions", response_model=List[ExerciseSuggestionResult])
def get_exercise_suggestions(exercise_id: UUID, db: Session = Depends(get_db))

@router.get("/{exercise_id}/records", response_model=List[UserExerciseRecordResult])
def get_user_exercise_records(
    exercise_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
)

@router.post("/sync", response_model=ExerciseSyncResult)
def sync_exercises(
    last_sync: Optional[datetime] = Query(None),
    db: Session = Depends(get_db)
)
```

#### 2. Enhanced Response Models
```python
class ExerciseResult(BaseModel):
    id: UUID
    name: str
    description: Optional[str]
    gif_url: Optional[str]
    image_url: Optional[str]
    difficulty_level: int
    muscle_groups: List[MuscleGroupResult]
    equipment: List[EquipmentResult]
    created_at: datetime
    updated_at: datetime

class ExerciseDetailResult(ExerciseResult):
    video_url: Optional[str]
    instructions: List[str]
    preparation_notes: Optional[str]
    key_tips: List[str]

class ExerciseSuggestionResult(BaseModel):
    id: UUID
    title: Optional[str]
    content: str
    source: str
    author_name: Optional[str]
    is_verified: bool
    votes_up: int
    votes_down: int
    created_at: datetime

class UserExerciseRecordResult(BaseModel):
    id: UUID
    record_type: str
    value: float
    unit: str
    achieved_at: datetime
```

### Frontend Data Models Updates

#### 1. Enhanced Exercise Model
```dart
class Exercise {
  final String id;
  final String name;
  final String? description;
  final String? gifUrl;
  final String? videoUrl;
  final String? imageUrl;
  final List<String> instructions;
  final String? preparationNotes;
  final List<String> keyTips;
  final int difficultyLevel;
  final List<MuscleGroup> muscleGroups;
  final List<Equipment> equipment;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor and fromJson/toJson methods
}

class MuscleGroup {
  final String id;
  final String name;
  final String category;
  final bool isPrimary;
}

class Equipment {
  final String id;
  final String name;
  final String category;
  final bool isRequired;
}

class ExerciseSuggestion {
  final String id;
  final String? title;
  final String content;
  final String source;
  final String? authorName;
  final bool isVerified;
  final int votesUp;
  final int votesDown;
  final DateTime createdAt;
}

class UserExerciseRecord {
  final String id;
  final String recordType;
  final double value;
  final String unit;
  final DateTime achievedAt;
}
```

#### 2. Enhanced Local Database Schema (SQLite)
```sql
-- Local exercises cache
CREATE TABLE local_exercises (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    gif_url TEXT,
    video_url TEXT,
    image_url TEXT,
    instructions TEXT, -- JSON string
    preparation_notes TEXT,
    key_tips TEXT, -- JSON string
    difficulty_level INTEGER DEFAULT 1,
    muscle_groups TEXT, -- JSON string
    equipment TEXT, -- JSON string
    created_at TEXT,
    updated_at TEXT,
    last_synced TEXT
);

-- Local exercise suggestions cache
CREATE TABLE local_exercise_suggestions (
    id TEXT PRIMARY KEY,
    exercise_id TEXT,
    title TEXT,
    content TEXT NOT NULL,
    source TEXT,
    author_name TEXT,
    is_verified INTEGER DEFAULT 0,
    votes_up INTEGER DEFAULT 0,
    votes_down INTEGER DEFAULT 0,
    created_at TEXT,
    last_synced TEXT,
    FOREIGN KEY (exercise_id) REFERENCES local_exercises (id)
);

-- Local user exercise records
CREATE TABLE local_exercise_records (
    id TEXT PRIMARY KEY,
    exercise_id TEXT,
    record_type TEXT NOT NULL,
    value REAL NOT NULL,
    unit TEXT,
    achieved_at TEXT,
    created_at TEXT,
    synced INTEGER DEFAULT 0,
    FOREIGN KEY (exercise_id) REFERENCES local_exercises (id)
);

-- Sync status tracking
CREATE TABLE sync_status (
    table_name TEXT PRIMARY KEY,
    last_sync TEXT,
    sync_in_progress INTEGER DEFAULT 0
);
```

## Provider Architecture

### 1. ExerciseProvider
```dart
class ExerciseProvider extends StateNotifier<ExerciseState> {
  // Exercise search and filtering
  Future<List<Exercise>> searchExercises({
    String? query,
    List<String>? muscleGroups,
    List<String>? equipment,
    int? difficulty,
    String sortBy = 'name',
    String sortOrder = 'asc',
  });

  // Exercise details
  Future<ExerciseDetails> getExerciseDetails(String exerciseId);
  Future<List<ExerciseSuggestion>> getExerciseSuggestions(String exerciseId);
  Future<List<UserExerciseRecord>> getExerciseRecords(String exerciseId);

  // Local caching and sync
  Future<void> syncExercises();
  Future<void> cacheExercise(Exercise exercise);
  List<Exercise> getCachedExercises();
}
```

### 2. WorkoutCreationProvider
```dart
class WorkoutCreationProvider extends StateNotifier<WorkoutCreationState> {
  // Workout creation flow
  void setWorkoutName(String name);
  void addSelectedExercise(Exercise exercise);
  void removeSelectedExercise(String exerciseId);
  void updateExerciseConfig(String exerciseId, ExerciseConfig config);
  
  // Save workout
  Future<bool> saveWorkout();
  
  // Reset state
  void resetCreation();
}

class WorkoutCreationState {
  final String workoutName;
  final String? description;
  final List<SelectedExercise> selectedExercises;
  final bool isLoading;
  final String? error;
}

class SelectedExercise {
  final Exercise exercise;
  final int sets;
  final int? reps;
  final double? weight;
  final String? notes;
}
```

## Sync Strategy

### 1. Exercise Data Sync
- **Initial sync**: Download all exercises on first app launch
- **Incremental sync**: Sync only updated/new exercises based on timestamps
- **Offline support**: Use cached exercises when offline
- **Conflict resolution**: Server data takes precedence

### 2. Workout Plan Sync
- **Local-first**: Save locally immediately
- **Background sync**: Sync to server when online
- **Conflict resolution**: Show user merge UI for conflicts

### 3. User Data Sync
- **Exercise records**: Sync PRs and workout history
- **Personal notes**: Sync user-created suggestions and notes

## UI Components Design

### 1. ExerciseSelectionScreen
```dart
class ExerciseSelectionScreen extends StatefulWidget {
  final Function(List<Exercise>) onExercisesSelected;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Exercises'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBar(onSearch: _handleSearch),
          FilterChips(filters: _activeFilters),
          Expanded(
            child: ExerciseList(
              exercises: _filteredExercises,
              selectedExercises: _selectedExercises,
              onExerciseToggle: _toggleExercise,
              onExerciseTap: _showExerciseDetails,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedExercises.isNotEmpty ? _continueToConfig : null,
        label: Text('Continue (${_selectedExercises.length})'),
        icon: Icon(Icons.arrow_forward),
      ),
    );
  }
}
```

### 2. ExerciseDetailModal
```dart
class ExerciseDetailModal extends StatefulWidget {
  final Exercise exercise;
  final bool allowSelection;
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(exercise.name),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Suggestions'),
              Tab(text: 'Records'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ExerciseDetailsTab(exercise: exercise),
            ExerciseSuggestionsTab(exercise: exercise),
            ExerciseRecordsTab(exercise: exercise),
          ],
        ),
        floatingActionButton: allowSelection
            ? FloatingActionButton.extended(
                onPressed: () => Navigator.pop(context, exercise),
                label: Text('Select Exercise'),
                icon: Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
```

### 3. SetsRepsConfigScreen
```dart
class SetsRepsConfigScreen extends StatefulWidget {
  final List<Exercise> selectedExercises;
  final String workoutName;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configure Workout'),
      ),
      body: ListView.builder(
        itemCount: selectedExercises.length,
        itemBuilder: (context, index) {
          return ExerciseConfigCard(
            exercise: selectedExercises[index],
            onConfigChanged: (config) => _updateConfig(index, config),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _saveWorkout,
          child: Text('Save Workout'),
        ),
      ),
    );
  }
}
```

## Performance Considerations

### 1. Exercise List Optimization
- **Lazy loading**: Load exercises in batches
- **Image caching**: Cache exercise GIFs and images
- **Search debouncing**: Debounce search input to reduce API calls

### 2. Local Storage Optimization
- **Indexed queries**: Create indices for common search patterns
- **Data compression**: Compress large text fields (instructions, tips)
- **Cleanup strategy**: Remove old cached data periodically

### 3. Memory Management
- **Dispose providers**: Properly dispose providers when not needed
- **Image memory**: Use appropriate image caching strategies
- **List virtualization**: Use virtual scrolling for large exercise lists

## Error Handling

### 1. Network Errors
- **Graceful degradation**: Fall back to cached data
- **Retry mechanisms**: Implement exponential backoff for failed requests
- **User feedback**: Show appropriate error messages

### 2. Data Validation
- **Input validation**: Validate sets, reps, weight inputs
- **Model validation**: Validate API responses before parsing
- **Fallback data**: Provide default values for missing data

### 3. Sync Errors
- **Conflict resolution**: Handle data conflicts gracefully
- **Partial sync**: Allow partial sync success
- **User intervention**: Prompt user for conflict resolution when needed

## Testing Strategy

### 1. Unit Tests
- Provider logic testing
- Model serialization/deserialization
- Local database operations

### 2. Integration Tests
- API integration testing
- Sync mechanism testing
- Local storage integration

### 3. Widget Tests
- UI component testing
- User interaction testing
- Navigation flow testing

### 4. End-to-End Tests
- Complete workout creation flow
- Exercise search and selection
- Sync scenarios

## Security Considerations

### 1. Data Privacy
- **User data encryption**: Encrypt sensitive local data
- **API security**: Use proper authentication headers
- **Data anonymization**: Anonymize user data in analytics

### 2. Input Validation
- **SQL injection prevention**: Use parameterized queries
- **XSS prevention**: Sanitize user input
- **Data size limits**: Limit input sizes to prevent DoS

## Deployment Strategy

### 1. Backend Deployment
- **Database migration**: Safely migrate existing data
- **API versioning**: Maintain backward compatibility
- **Feature flags**: Use feature flags for gradual rollout

### 2. Frontend Deployment
- **App store release**: Coordinate with backend deployment
- **Data migration**: Migrate existing local data to new schema
- **Rollback strategy**: Plan for rollback if issues occur

## Monitoring and Analytics

### 1. Performance Monitoring
- **API response times**: Monitor exercise search performance
- **Local database performance**: Monitor query execution times
- **App performance**: Monitor memory usage and crash rates

### 2. User Analytics
- **Feature usage**: Track which exercises are most selected
- **Search patterns**: Analyze common search queries
- **User flow**: Track completion rates for workout creation

### 3. Error Monitoring
- **API errors**: Monitor and alert on API failures
- **App crashes**: Track and analyze crash reports
- **Sync failures**: Monitor sync success rates
