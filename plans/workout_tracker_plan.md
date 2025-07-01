# Workout Tracker Implementation Plan

This plan details the implementation of the workout tracking features, including saving workout sessions to a Supabase backend, caching data locally using SQLite, and fetching workout history. It also addresses secure API communication using JWT Bearer tokens.

## I. Backend (FastAPI) Enhancements

### 1. Database Schema Review (Supabase/PostgreSQL)
The existing SQLAlchemy models in `server/.env.sql` (which should ideally be in `server/app/models/`) for `Workout` (interpreted as `CompletedWorkout` for this context), `Exercise` (as part of a completed workout), `CompletedWorkout`, `CompletedWorkoutExercise`, and `CompletedWorkoutSet` seem largely sufficient for tracking completed workouts.

*   **`CompletedWorkout`**: Stores overall session details (user, name, start/end times, duration, intensity).
*   **`CompletedWorkoutExercise`**: Stores details of each exercise performed within a session.
*   **`CompletedWorkoutSet`**: Stores details of each set for an exercise (weight, reps).
*   **`User`**: Already exists for linking workouts to users.

No major new tables seem immediately necessary for the core "tracking completed workouts" feature. We will focus on creating API endpoints for these existing structures.

### 2. API Endpoints (FastAPI)

All workout-related endpoints will be secured using JWT Bearer token authentication. The `user_id` will be extracted from the token.

**File to create/modify:** `server/app/api/v1/endpoints/workouts.py` (new file)
**File to modify:** `server/app/main.py` (to include the new `workouts_router`)

*   **A. Create/Save Workout Session**
    *   **Endpoint:** `POST /api/v1/workouts/session`
    *   **Request Body Schema:** `schemas.CompletedWorkoutCreate`
        *   This schema will include details like `workout_name`, `start_time`, `end_time`, `intensity_score`, and a list of `CompletedWorkoutExerciseCreate` objects.
        *   Each `CompletedWorkoutExerciseCreate` will include `exercise_id` (from a global exercise list/API if available, or just `exercise_name`), `exercise_name`, `exercise_equipments`, `exercise_gif_url` (if applicable), and a list of `CompletedWorkoutSetCreate` objects.
        *   Each `CompletedWorkoutSetCreate` will include `weight` and `reps`.
    *   **Response Schema:** `schemas.CompletedWorkoutPublic` (reflecting the saved data with generated IDs and timestamps).
    *   **Logic:**
        1.  Verify JWT, extract `user_id`.
        2.  Validate request payload.
        3.  Call `crud.workout.create_completed_workout` to save data to `completed_workouts`, `completed_workout_exercises`, and `completed_workout_sets` tables, associating with the `user_id`.
        4.  Return the created workout session data.

*   **B. Get Workout History for Current User**
    *   **Endpoint:** `GET /api/v1/workouts/history`
    *   **Request:** Requires authentication. Query parameters for pagination (e.g., `skip: int = 0`, `limit: int = 20`).
    *   **Response Schema:** `List[schemas.CompletedWorkoutPublic]`
    *   **Logic:**
        1.  Verify JWT, extract `user_id`.
        2.  Call `crud.workout.get_completed_workouts_by_user` to fetch all `completed_workouts` (with their exercises and sets) for the `user_id`.
        3.  Return the list of workout sessions.
        *This endpoint will resolve the 404 error in `WorkoutHistoryScreen`.*

*   **C. Get Specific Workout Session Details**
    *   **Endpoint:** `GET /api/v1/workouts/session/{session_id}`
    *   **Request:** Requires authentication. `session_id` as path parameter.
    *   **Response Schema:** `schemas.CompletedWorkoutPublic`
    *   **Logic:**
        1.  Verify JWT, extract `user_id`.
        2.  Call `crud.workout.get_completed_workout_details` to fetch the specific `completed_workout` by `session_id`, ensuring it belongs to the `user_id`.
        3.  Return the workout session data or 404 if not found/not authorized.

### 3. CRUD Operations

**File to create:** `server/app/crud/workout_crud.py` (new file)

*   `create_completed_workout(db: Session, *, user_id: uuid.UUID, workout_in: schemas.CompletedWorkoutCreate) -> models.CompletedWorkout`:
    *   Creates a `CompletedWorkout` record.
    *   Iterates through `workout_in.exercises` to create `CompletedWorkoutExercise` records, linking them to the `CompletedWorkout`.
    *   Iterates through each exercise's sets to create `CompletedWorkoutSet` records, linking them to the respective `CompletedWorkoutExercise`.
*   `get_completed_workouts_by_user(db: Session, *, user_id: uuid.UUID, skip: int = 0, limit: int = 100) -> List[models.CompletedWorkout]`:
    *   Fetches a paginated list of `CompletedWorkout` records for the given `user_id`.
    *   Should eagerly load related `exercises` and their `sets`.
*   `get_completed_workout_details(db: Session, *, user_id: uuid.UUID, session_id: uuid.UUID) -> Optional[models.CompletedWorkout]`:
    *   Fetches a single `CompletedWorkout` by its `id` and `user_id`.
    *   Should eagerly load related `exercises` and their `sets`.

### 4. Pydantic Schemas

**File to create:** `server/app/schemas/workout_schemas.py` (new file)

*   **`CompletedWorkoutSetBase` / `CompletedWorkoutSetCreate` / `CompletedWorkoutSetPublic`**:
    *   Fields: `weight: str`, `reps: str`, (Public also includes `id`, `created_at`).
*   **`CompletedWorkoutExerciseBase` / `CompletedWorkoutExerciseCreate` / `CompletedWorkoutExercisePublic`**:
    *   Fields: `exercise_id: str` (can be a reference to a global exercise DB or just a name if no global DB), `exercise_name: str`, `exercise_equipments: Optional[List[str]] = None`, `exercise_gif_url: Optional[str] = None`, `sets: List[CompletedWorkoutSetCreate]` (for Create) / `List[CompletedWorkoutSetPublic]` (for Public).
    *   (Public also includes `id`, `created_at`).
*   **`CompletedWorkoutBase` / `CompletedWorkoutCreate` / `CompletedWorkoutPublic`**:
    *   Fields: `workout_name: str`, `start_time: datetime`, `end_time: datetime`, `duration_seconds: int`, `intensity_score: float`, `exercises: List[CompletedWorkoutExerciseCreate]` (for Create) / `List[CompletedWorkoutExercisePublic]` (for Public).
    *   (Public also includes `id`, `user_id`, `created_at`).

## II. Frontend (Flutter) Enhancements

### 1. API Service (`fitnation/lib/api/API_Services.dart`)

**File to modify:** `fitnation/lib/api/API_Services.dart`

*   Add new methods to interact with the backend workout endpoints:
    *   `Future<CompletedWorkout?> saveWorkoutSession(CompletedWorkout workoutData)`:
        *   Retrieves token using `await _authNotifier.getToken()`.
        *   Makes a `POST` request to `/api/v1/workouts/session`.
        *   Includes the token in the `Authorization: Bearer $token` header.
    *   `Future<List<CompletedWorkout>> getWorkoutHistory({int skip = 0, int limit = 20})`:
        *   Retrieves token.
        *   Makes a `GET` request to `/api/v1/workouts/history`.
        *   Includes token in header.
    *   `Future<CompletedWorkout?> getWorkoutSessionDetails(String sessionId)`:
        *   Retrieves token.
        *   Makes a `GET` request to `/api/v1/workouts/session/{sessionId}`.
        *   Includes token in header.
*   **Token Handling:** Ensure the `Dio` instance used by `APIServices` is configured to include the `Authorization: Bearer $token` header. The `AuthInterceptor` or direct header manipulation in `APIServices` should handle this. The `getToken()` method from `AuthProvider` will be used.

### 2. State Management (Riverpod)

*   **`WorkoutProvider` (New or existing):**
    *   A `StateNotifierProvider` for managing the state of the currently active workout in `WorkoutScreen.dart`. This will hold the list of exercises, their sets, reps, weights as they are being performed.
    *   A `FutureProvider` or `StateNotifierProvider` for fetching and caching workout history in `WorkoutHistoryScreen.dart`.
*   **Token Access:** Utilize `ref.read(authProvider.notifier).getToken()` to get the access token when making API calls.

### 3. `WorkoutScreen.dart` (Assumed path: `fitnation/lib/Screens/Activities/WorkoutScreen.dart`)

*   **UI:**
    *   Allow users to select exercises (either from a predefined list/search or add custom).
    *   For each exercise, allow users to add/edit sets with weight and reps.
    *   Track workout start time.
*   **Functionality:**
    *   **Start Workout:** Initialize workout state (start time, empty list of performed exercises).
    *   **Add Exercise:** Add an exercise to the current session.
    *   **Log Set:** For each exercise, log weight and reps for completed sets. Mark sets as completed.
    *   **Finish Workout:**
        1.  Record end time, calculate duration.
        2.  Prompt for overall workout intensity (e.g., RPE scale 1-10).
        3.  Construct a `CompletedWorkout` object (from `fitnation/lib/models/CompletedWorkout.dart`) with all `CompletedWorkoutExercise` and `CompletedWorkoutSet` data.
        4.  Call `ref.read(apiServiceProvider).saveWorkoutSession(completedWorkoutData)`.
        5.  **On API Success:**
            *   Save the `CompletedWorkout` data to the local SQLite database (see section II.5).
            *   Show a success message and navigate or clear the screen.
        6.  **On API Failure (e.g., no internet):**
            *   Save the `CompletedWorkout` data to a "pending sync" queue in SQLite.
            *   Inform the user that the workout is saved locally and will sync later.
            *   Show an error message if local save also fails.

### 4. `WorkoutHistoryScreen.dart` (Assumed path: `fitnation/lib/Screens/Activities/WorkoutHistoryScreen.dart`)

*   **Functionality:**
    *   On screen load, attempt to fetch workout history using `ref.read(apiServiceProvider).getWorkoutHistory()`.
    *   **On API Success:**
        *   Display the fetched list of `CompletedWorkout` summaries (name, date, duration).
        *   Update the local SQLite cache with the fetched data (e.g., clear old cache and save new).
    *   **On API Failure (e.g., no internet or 404 initially if no history):**
        *   Load workout history from the local SQLite database.
        *   Display a message indicating that offline data is shown.
    *   Allow users to tap on a workout entry to view its full details (exercises, sets, reps, weight). This might involve another API call (`getWorkoutSessionDetails`) or loading detailed data from SQLite.

### 5. Local Caching - SQLite (`fitnation/lib/services/database_helper.dart` - New or existing)

*   **Database Schema:**
    *   `completed_workouts` table:
        *   `id (TEXT PRIMARY KEY)`
        *   `user_id (TEXT)`
        *   `workout_name (TEXT)`
        *   `start_time (TEXT)` (ISO8601)
        *   `end_time (TEXT)` (ISO8601)
        *   `duration_seconds (INTEGER)`
        *   `intensity_score (REAL)`
        *   `created_at (TEXT)` (ISO8601)
        *   `synced (INTEGER DEFAULT 0)` (0 for not synced, 1 for synced)
    *   `completed_workout_exercises` table:
        *   `id (TEXT PRIMARY KEY)`
        *   `completed_workout_id (TEXT)` (FK to `completed_workouts.id`)
        *   `exercise_id (TEXT)`
        *   `exercise_name (TEXT)`
        *   `exercise_equipments (TEXT)` (comma-separated or JSON)
        *   `exercise_gif_url (TEXT)`
    *   `completed_workout_sets` table:
        *   `id (TEXT PRIMARY KEY)`
        *   `completed_workout_exercise_id (TEXT)` (FK to `completed_workout_exercises.id`)
        *   `weight (TEXT)`
        *   `reps (TEXT)`
*   **CRUD Operations:**
    *   `Future<void> insertCompletedWorkout(CompletedWorkout workout, {bool synced = false})`
    *   `Future<List<CompletedWorkout>> getCompletedWorkouts(String userId)` (load exercises and sets)
    *   `Future<CompletedWorkout?> getCompletedWorkoutById(String id)`
    *   `Future<void> updateWorkoutSyncedStatus(String id, bool synced)`
    *   `Future<List<CompletedWorkout>> getUnsyncedWorkouts(String userId)`
    *   `Future<void> clearSyncedWorkouts(String userId)` (optional, for cache management)
*   **Sync Logic:**
    *   Implement a mechanism (e.g., on app start, or periodically if app is open with network) to check for unsynced workouts and attempt to send them to the backend. Update `synced` status on success.

### 6. Models (`fitnation/lib/models/`)

*   Ensure `CompletedWorkout.dart`, `CompletedWorkoutExercise.dart`, `CompletedWorkoutSet.dart` have robust `toJson()`, `fromJson()`, `toMap()`, and `fromMap()` methods for API and SQLite interaction. The existing models are a good starting point.

## III. Security and Authorization

*   **Backend:**
    *   All new workout API endpoints must use the FastAPI dependency `Depends(get_current_active_user)` (or equivalent) to ensure only authenticated users can access them.
    *   CRUD operations must always use the `user_id` from the authenticated user to scope data access (e.g., a user can only fetch or save their own workouts).
*   **Frontend:**
    *   The access token obtained after login (and stored in `flutter_secure_storage` via `AuthProvider`) must be included in the `Authorization: Bearer <token>` header for all calls to the new workout API endpoints.
    *   Implement logic to handle token expiration and refresh if necessary (this might be a broader enhancement to `API_Services.dart` or `AuthProvider`).

## IV. Error Handling and User Feedback

*   **Frontend:**
    *   Display loading indicators during API calls and database operations.
    *   Show clear success messages (e.g., "Workout saved!") or error messages (e.g., "Failed to save workout. Please try again.").
    *   Handle network errors gracefully, informing the user if data is being saved locally due to lack of connectivity.
*   **Backend:**
    *   Return appropriate HTTP status codes (e.g., 200, 201, 400, 401, 403, 404, 500).
    *   Provide meaningful error messages in JSON responses for client-side display where appropriate.

This plan should guide the implementation of the workout tracker. The next step would be to start implementing these changes, beginning with the backend API endpoints.
