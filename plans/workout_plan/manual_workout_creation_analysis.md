# Manual Workout Creation System - Technical Analysis

## Current Backend Exercise API Analysis

### Exercise Endpoint (`/api/v1/exercise/`)
- **Current capabilities**: Basic search by name and body part
- **Response model**: `ExerciseResult` with basic fields
- **Limitations identified**:
  - No search by equipment, target muscles, or secondary muscles
  - No pagination support
  - No sorting options
  - Limited fields in response (missing instructions, tips, variations)

### Current Exercise Model (Backend)
```python
class Exercise(Base):
    __tablename__="exercises"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(Text, nullable=False)
    gifUrl = Column(Text,nullable=False)
    bodyParts = Column(Text)  # Stored as text, not normalized
    equipments = Column(Text)  # Stored as text, not normalized
    
    # Workout plan specific fields (should be moved to a separate table)
    sets = Column(Integer)
    reps = Column(Integer)
    weight = Column(Float)
    duration_seconds = Column(Integer)
    notes = Column(Text)
    order_in_workout = Column(Integer)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow)
```

**Issues with current model**:
1. Missing fields: `targetMuscles`, `secondaryMuscles`, `instructions`, `exerciseTips`, `variations`
2. `bodyParts` and `equipments` stored as text instead of proper normalized data
3. Workout-specific fields (sets, reps, weight) should not be in Exercise table

### Current Workout Plan API Analysis

#### Plans Endpoint (`/api/v1/plans/`)
- **Available endpoints**:
  - `GET /history` - Get user's workout plans
  - `POST /` - Create new workout plan
  - `GET /{workout_id}` - Get specific workout plan details

### Frontend Exercise Model Analysis

The Flutter `Exercise` model is much more comprehensive than the backend:
- Supports lists for `bodyParts`, `equipments`, `targetMuscles`, `secondaryMuscles`
- Includes `instructions`, `exerciseTips`, `variations`
- Has video and image URL support
- Includes metadata like `keywords`, `overview`

**Gap**: Frontend model expects more data than backend provides.

## Current Data Flow

1. **Exercise Data**: Currently limited backend exercise API
2. **Workout Plans**: Basic CRUD operations exist
3. **Local Storage**: Limited local caching in frontend
4. **Sync Strategy**: No comprehensive sync mechanism

## Requirements Summary

Based on user workflow requirements:

1. **Enhanced Exercise Search/Filter**
   - Search by name, target muscles, equipment, body parts
   - Filter by multiple criteria simultaneously
   - Pagination and sorting

2. **Comprehensive Exercise Details**
   - Instructions, tips, variations
   - Video tutorials, images
   - Community suggestions and personal records

3. **Multi-select Exercise Addition**
   - Select multiple exercises at once
   - Configure sets/reps for each selected exercise

4. **Offline-First Architecture**
   - Local caching of all exercises
   - Local storage of workout plans
   - Background sync when online

5. **Enhanced UI Components**
   - Exercise selection with search/filter
   - Exercise detail modal with tabs
   - Sets/reps configuration screen

## Identified Gaps

### Backend Gaps
1. Exercise model needs more fields
2. Search/filter API needs enhancement
3. No exercise suggestions/tips/community data
4. No user exercise records/PR tracking

### Frontend Gaps
1. No comprehensive exercise caching
2. Limited search/filter UI
3. No exercise detail modal with tabs
4. No multi-select exercise picker

### Database Schema Gaps
1. Exercise table needs normalization
2. Need separate tables for exercise tips/suggestions
3. Need user exercise records table
4. Need equipment and muscle group normalization

## Next Steps
1. Design enhanced database schema
2. Plan API enhancements
3. Design UI/UX components
4. Plan implementation phases
