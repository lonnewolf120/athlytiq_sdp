# Tentative APIs

Below is a categorized breakdown of essential APIs. These APIs power various client-side operations including user authentication, data management, and notifications.

## 1 Authentication & User Management
*   **Auth API**
    *   `POST /api/v1/auth/register`: Handles new user registration.
    *   `POST /api/v1/auth/login`: Handles user login.
    *   `POST /api/v1/auth/refresh`: Refreshes access tokens.
    *   `POST /api/v1/auth/logout`: Logs out a user by revoking refresh token.
    *   `POST /api/v1/auth/forgot-password`: Initiates password reset process.
    *   `POST /api/v1/auth/reset-password`: Resets user password using a token.
    *   `POST /api/v1/auth/google-login`: Handles user login/registration via Google OAuth.

*   **User Profile API**
    *   `GET /api/v1/user/me`: Retrieves the current authenticated user's profile.
    *   `POST /api/v1/user/upload-pfp`: Uploads a profile picture for the current user.

### 2 Meal Management
*   **Meal API**
    *   `POST /api/v1/meals/`: Creates a new meal entry for the current user.
    *   `GET /api/v1/meals/{meal_id}`: Retrieves a specific meal by its ID.
    *   `GET /api/v1/meals/users/me/`: Retrieves all meal entries for the current user.
    *   `PUT /api/v1/meals/{meal_id}`: Updates an existing meal entry.
    *   `DELETE /api/v1/meals/{meal_id}`: Deletes a meal entry.

*   **Meal Plan API**
    *   `POST /api/v1/meal_plans/`: Creates a new meal plan for the current user.
    *   `GET /api/v1/meal_plans/history`: Retrieves the current user's meal plan history.
    *   `GET /api/v1/meal_plans/{meal_plan_id}`: Retrieves details for a specific meal plan.

### 3 Nutrition & Health Logging
*   **Food Log API**
    *   `POST /api/v1/nutrition/food_logs`: Creates a new food log entry.
    *   `GET /api/v1/nutrition/food_logs`: Retrieves food log entries for the current user.
    *   `GET /api/v1/nutrition/food_logs/{food_log_id}`: Retrieves a specific food log entry.
    *   `PUT /api/v1/nutrition/food_logs/{food_log_id}`: Updates an existing food log entry.
    *   `DELETE /api/v1/nutrition/food_logs/{food_log_id}`: Deletes a food log entry.

*   **Health Log API**
    *   `POST /api/v1/nutrition/health_logs`: Creates a new health log entry.
    *   `GET /api/v1/nutrition/health_logs`: Retrieves health log entries for the current user.
    *   `GET /api/v1/nutrition/health_logs/{health_log_id}`: Retrieves a specific health log entry.
    *   `PUT /api/v1/nutrition/health_logs/{health_log_id}`: Updates an existing health log entry.
    *   `DELETE /api/v1/nutrition/health_logs/{health_log_id}`: Deletes a health log entry.

*   **Diet Recommendation API**
    *   `GET /api/v1/nutrition/diet_recommendations`: Retrieves diet recommendations for the current user.
    *   `GET /api/v1/nutrition/diet_recommendations/{recommendation_id}`: Retrieves a specific diet recommendation.

### 4 Workout Management
*   **Workout Plan API**
    *   `GET /api/v1/plans/history`: Retrieves the current user's workout plans history.
    *   `POST /api/v1/plans/`: Creates a new workout plan for the current user.
    *   `GET /api/v1/plans/{workout_id}`: Retrieves details for a specific workout plan.

*   **Completed Workout API**
    *   `POST /api/v1/workouts/session`: Creates a new completed workout session.
    *   `GET /api/v1/workouts/history`: Retrieves the current user's completed workout history.
    *   `GET /api/v1/workouts/session/{session_id}`: Retrieves details for a specific completed workout session.

### 5 Post Management
*   **Post API**
    *   `POST /api/v1/posts/`: Creates a new post.
    *   `GET /api/v1/posts/{post_id}`: Retrieves a single post by its ID.
    *   `GET /api/v1/posts/`: Retrieves multiple posts, with optional filtering.
    *   `PUT /api/v1/posts/{post_id}`: Updates an existing post.
    *   `DELETE /api/v1/posts/{post_id}`: Deletes a post.
    *   `GET /api/v1/posts/feed/public`: Retrieves public posts for the main feed.

### 6 *   **ExerciseDB API (RapidAPI)**
The ExerciseDB API provides access to over 1,300 exercises, categorized by body part, target muscle group, and equipment. It includes detailed metadata and high-quality animated demonstrations for each exercise. Ideal for fitness applications, workout planning, and exercise guidance.

    * Base URL: https://exercisedb.p.rapidapi.com
    * Headers:
        * X-RapidAPI-Key: API key
        * X-RapidAPI-Host: exercisedb.p.rapidapi.com
*   **Exercise API**
    *   `GET /exercises`: Retrieves a list of all exercises (1300+).
    *   `GET /exercises/bodyPart/{bodyPart}`: Retrieves exercises for a specific body part (e.g., chest, back, legs).
    *   `GET /exercises/target/{target}`: Retrieves exercises for a specific target muscle (e.g., pectorals, quadriceps).
    *   `GET /exercises/equipment/{equipment}`: Retrieves exercises requiring specific equipment (e.g., barbell, dumbbell, bodyweight).
    *   `GET /exercises/exercise/{id}`: Retrieves details for a specific exercise by ID (e.g., 001).

## 7.0 Backend & Database Infrastructure
*   **Backend API (Framework: FastAPI)**
    Handles all backend routing and business logic such as authentication, data validation, and processing requests.
*   **Database (e.g., PostgreSQL)**
    Stores structured and unstructured data for:
    *   User profiles
    *   Application data records (meals, workouts, posts, etc.)
    *   Nutrition and health logs
    *   System configurations
    Also supports real-time updates and secure access policies.
