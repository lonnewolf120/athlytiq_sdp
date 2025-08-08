Okay, here's the plan for implementing the Workout/Activity tracker and planner backend, APIs

**I. Backend Implementation**

*   **Database Design:**
    *   We'll need tables for `Users`, `Workouts`, `Exercises`, `Sets`, and `WorkoutHistory`.
    *   `Users` will store user information.
    *   `Workouts` will store workout plan details (name, description, equipment, etc.).
    *   `Exercises` will store exercise details (name, body part, equipment, GIF URL).
    *   `Sets` will store set details (weight, reps, isCompleted, linked to `Exercises`).
    *   `WorkoutHistory` will store completed workout data, linking `Users`, `Workouts`, `Exercises`, and `Sets`.
    *   I will create a `schema.sql` file with the SQL schema for these tables.
*   **API Endpoints:**
    *   `/workouts`:
        *   `GET`: Retrieve workout plans for a user.
        *   `POST`: Create a new workout plan.
    *   `/workouts/{workoutId}`:
        *   `GET`: Retrieve a specific workout plan.
        *   `PUT`: Update a workout plan.
        *   `DELETE`: Delete a workout plan.
    *   `/exercises`:
        *   `GET`: Search exercises by name or body part.
    *   `/workoutHistory`:
        *   `GET`: Retrieve workout history for a user.
        *   `POST`: Create a new workout history entry.
    *   `/workoutHistory/{historyId}`:
        *   `GET`: Retrieve a specific workout history entry.
*   **Backend Logic:**
    *   Implement the API endpoints using a framework like Node.js with Express or Python with Flask.
    *   Connect to the database using an ORM like Sequelize or SQLAlchemy.
    *   Implement authentication and authorization to secure the API endpoints.

**III. Implementation Details**

*   **Database:** PostgreSQL with Supabase
*   **Backend Framework:** FastAPI



## Current implementation:

__Backend Summary (FastAPI):__

1. `server/app/api/v1/endpoints/auth.py`:

   - Firebase Admin SDK is initialized.
   - The `/google-login` endpoint is implemented as per the plan (verifies token, checks/creates/links user, generates tokens). A minor correction to the response model of the `/register` endpoint was made (`UserPublic` to `OAuthPublic`).

2. `server/app/crud/user.py`:
   - The `create_user` function correctly handles `password_hash` being `None` and accepts `google_id`.

3. `server/app/schemas/user.py`:
   - The `UserCreate` schema allows `password_hash` to be `Optional[str] = None`.

4. `server/.env`: No changes needed as the service account key path is handled directly in the code.

__Frontend Summary (Flutter):__

1. `fitnation/pubspec.yaml`:
   - `firebase_auth` and `google_sign_in` packages are already listed as dependencies.

2. `fitnation/lib/main.dart`:
   - Firebase is correctly initialized with `Firebase.initializeApp()`.

3. `fitnation/lib/api/API_Services.dart`:
   - The `googleLogin(String idToken)` method is already implemented to call the backend.

4. `fitnation/lib/providers/auth_provider.dart`:
   - The `signInWithGoogle()` method is implemented, handling the Google Sign-In flow, Firebase auth, calling the backend API service, storing tokens, and updating auth state. Logout also handles Google/Firebase sign out.

5. `fitnation/lib/Screens/Auth/Login.dart`:

   - The Google Sign-In button's `_loginWithGoogle()` method correctly calls `authProvider.notifier.signInWithGoogle()`.
   - The UI reflects loading states (e.g., button disabled) during the Google Sign-In process.
