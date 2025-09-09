# Manual Workout Creation - Development Todo List

## Immediate Implementation Tasks (Phase 1)

### Backend Database Migration Tasks
- [ ] **Create database migration script for new tables**
  - [ ] Create `muscle_groups` table with id, name, category
  - [ ] Create `equipment` table with id, name, category
  - [ ] Create `exercise_muscles` junction table
  - [ ] Create `exercise_equipment` junction table
  - [ ] Create `exercise_suggestions` table
  - [ ] Create `user_exercise_records` table
  - [ ] Add indices for performance optimization

- [ ] **Update existing Exercise model**
  - [ ] Add description, video_url, image_url fields
  - [ ] Add instructions (JSONB), preparation_notes, key_tips (JSONB)
  - [ ] Add difficulty_level field
  - [ ] Remove workout-specific fields (sets, reps, weight) from exercise table
  - [ ] Update existing data to new schema

- [ ] **Create new SQLAlchemy models**
  - [ ] Create `MuscleGroup` model in `models_db.py`
  - [ ] Create `Equipment` model in `models_db.py`
  - [ ] Create `ExerciseMuscle` relationship model
  - [ ] Create `ExerciseEquipment` relationship model
  - [ ] Create `ExerciseSuggestion` model
  - [ ] Create `UserExerciseRecord` model
  - [ ] Add relationships to existing `Exercise` model

### Backend API Enhancement Tasks
- [ ] **Update Exercise schemas**
  - [ ] Create `MuscleGroupResult` schema in `schemas/exercise.py`
  - [ ] Create `EquipmentResult` schema in `schemas/exercise.py`
  - [ ] Update `ExerciseResult` schema with new fields
  - [ ] Create `ExerciseDetailResult` schema for detailed view
  - [ ] Create `ExerciseSuggestionResult` schema
  - [ ] Create `UserExerciseRecordResult` schema

- [ ] **Enhance Exercise endpoints**
  - [ ] Update `/exercises/` endpoint with advanced filtering:
    - [ ] Add muscle_groups parameter (List[str])
    - [ ] Add equipment parameter (List[str])
    - [ ] Add difficulty parameter (int)
    - [ ] Add sort_by parameter (name, difficulty, created_at)
    - [ ] Add sort_order parameter (asc, desc)
    - [ ] Add pagination (skip, limit)
  - [ ] Create `/exercises/{id}/details` endpoint
  - [ ] Create `/exercises/{id}/suggestions` endpoint
  - [ ] Create `/exercises/{id}/records` endpoint for user PRs

- [ ] **Create CRUD operations**
  - [ ] Create `exercise_crud.py` with enhanced search functions
  - [ ] Add functions for muscle group and equipment operations
  - [ ] Add functions for exercise suggestions CRUD
  - [ ] Add functions for user exercise records CRUD

### Frontend Model Updates
- [ ] **Create new Dart models**
  - [ ] Create `MuscleGroup.dart` model with fromJson/toJson
  - [ ] Create `Equipment.dart` model with fromJson/toJson
  - [ ] Create `ExerciseSuggestion.dart` model
  - [ ] Create `UserExerciseRecord.dart` model
  - [ ] Update `Exercise.dart` model with new fields:
    - [ ] Add description, videoUrl, imageUrl
    - [ ] Add instructions (List<String>)
    - [ ] Add preparationNotes, keyTips (List<String>)
    - [ ] Add difficultyLevel
    - [ ] Add muscleGroups (List<MuscleGroup>)
    - [ ] Add equipment (List<Equipment>)

- [ ] **Update local database schema**
  - [ ] Update `DatabaseHelper` with new tables:
    - [ ] `local_exercises` table with new fields
    - [ ] `local_muscle_groups` table
    - [ ] `local_equipment` table
    - [ ] `local_exercise_suggestions` table
    - [ ] `local_exercise_records` table
    - [ ] `sync_status` table for tracking sync
  - [ ] Create migration logic for existing local data
  - [ ] Add CRUD methods for new entities

### Frontend Provider Implementation
- [ ] **Create ExerciseProvider**
  - [ ] Create `ExerciseProvider` class extending StateNotifier
  - [ ] Add state class `ExerciseState` with:
    - [ ] List of cached exercises
    - [ ] Current search query
    - [ ] Active filters
    - [ ] Loading state
    - [ ] Error state
  - [ ] Implement basic search functionality
  - [ ] Add local caching mechanism
  - [ ] Add basic sync functionality

- [ ] **Create ExerciseService**
  - [ ] Create `ExerciseService` class for API communication
  - [ ] Add methods for exercise search with filters
  - [ ] Add methods for exercise details fetching
  - [ ] Add methods for suggestions and records
  - [ ] Handle API errors and offline scenarios

### API Service Updates
- [ ] **Update ApiService class**
  - [ ] Add `getExercises()` method with filter parameters
  - [ ] Add `getExerciseDetails(String id)` method
  - [ ] Add `getExerciseSuggestions(String id)` method
  - [ ] Add `getUserExerciseRecords(String id)` method
  - [ ] Add error handling and retry logic

### Initial UI Components
- [ ] **Update WorkoutScreen with FAB**
  - [ ] Add FloatingActionButton to WorkoutScreen
  - [ ] Create action menu with three options:
    - [ ] "Add New Workout" (manual creation)
    - [ ] "Import from Backend" (existing functionality)
    - [ ] "Generate with AI" (existing functionality)
  - [ ] Handle navigation to new workout creation flow

- [ ] **Create basic ExerciseSelectionScreen**
  - [ ] Create screen structure with AppBar
  - [ ] Add basic search bar
  - [ ] Add placeholder for exercise list
  - [ ] Add basic navigation back to WorkoutScreen

### Testing Tasks
- [ ] **Unit Tests**
  - [ ] Test new model serialization/deserialization
  - [ ] Test ExerciseProvider state management
  - [ ] Test local database operations
  - [ ] Test API service methods

- [ ] **Integration Tests**
  - [ ] Test database migration
  - [ ] Test API endpoints with new parameters
  - [ ] Test local storage integration
  - [ ] Test provider-service integration

## Priority Order
1. **Backend database migration** (Foundation)
2. **Backend API updates** (Data layer)
3. **Frontend model updates** (Data models)
4. **Frontend provider setup** (State management)
5. **Basic UI components** (User interface)
6. **Testing** (Quality assurance)

## Estimated Timeline
- **Backend tasks**: 3-4 days
- **Frontend models and providers**: 2-3 days
- **Basic UI**: 1-2 days
- **Testing**: 1-2 days
- **Total Phase 1**: 7-11 days

## Success Criteria for Phase 1
- [ ] Database migration completed without data loss
- [ ] Enhanced exercise API returns filtered results
- [ ] Frontend can fetch and cache exercises locally
- [ ] WorkoutScreen has FAB with action menu
- [ ] Basic exercise selection screen navigates correctly
- [ ] All tests pass with good coverage

## Next Phase Preview
After completing Phase 1, Phase 2 will focus on:
- Advanced search and filtering UI
- Multi-select exercise functionality
- Exercise list with thumbnails and details
- Filter chips and search optimization
- Infinite scroll and pagination

---

## Technical Notes

### Database Migration Strategy
1. Create new tables first
2. Migrate existing exercise data to new schema
3. Update foreign key relationships
4. Remove old columns from exercise table
5. Add indices for performance

### Error Handling Strategy
- Graceful degradation when backend is unavailable
- Fall back to cached data for offline scenarios
- Proper error messages for user feedback
- Retry mechanisms for failed operations

### Performance Considerations
- Use database indices for search optimization
- Implement proper pagination for large datasets
- Cache frequently accessed data locally
- Use lazy loading for exercise images
