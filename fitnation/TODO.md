# FitNation Flutter App - TODO List (Data Fetching & State Management)

This document outlines the remaining tasks related to data fetching, state management, and API integration using Riverpod, Supabase, and your `API_Services.dart`.

**Key:**
*   `[ ]` - Task not started
*   `[x]` - Task completed
*   `[~]` - Task in progress or partially completed

---
## API Service Implementation (`lib/api/API_Services.dart`)
*   `[ ]` **Implement Specific Methods:**
    *   `[ ]` `updateUserProfile({String? name, String? username, File? avatarFile})`: Update user details, handle avatar file upload to Supabase Storage.
    *   `[ ]` `getCommunityStories()`: Fetch a list of story data.
    *   `[ ]` `getCommunityGroups({String? query, String? filter})`: Fetch `Community.dart` list with optional search/filter.
    *   `[ ]` `getCommunityDetail(String communityId)`: Fetch a specific `Community.dart` including embedded posts and members if possible via Supabase joins/RPCs.
    *   `[ ]` `joinCommunity(String communityId)`: Call Supabase to add a `CommunityMember.dart` entry.
    *   `[ ]` `leaveCommunity(String communityId)`: Call Supabase to remove a `CommunityMember.dart` entry.
    *   `[ ]` `createPost({PostModel data, File? mediaFile})`: Handle file upload if `mediaFile` exists, then insert the `PostModel.dart` record.
    *   `[ ]` `createCommunity({Community data, File? profileImage, File? coverImage})`: Handle image uploads, then insert the `Community.dart` record.
    *   `[ ]` `reactToPost(String postId, String reactType)`: Insert/update `PostReact.dart`.
    *   `[ ]` `addPostComment(String postId, String content)`: Insert `PostComment.dart`.
    *   `[ ]` `getWorkoutPlans()`: Fetch `Workout.dart` list for the "PLAN" tab.
    *   `[ ]` `getWorkoutDetail(String workoutId)`: Fetch a specific `Workout.dart` including planned exercises.
    *   `[ ]` `saveCompletedWorkout(CompletedWorkout data)`: Insert the `CompletedWorkout.dart` record.
    *   `[ ]` `getCompletedWorkoutsForUser(String userId, {String? workoutTypeFilter, String? timeRangeFilter})`: Fetch `CompletedWorkout.dart` list for history and profile, applying filters.
    *   `[ ]` `getCompletedWorkoutDetail(String completedWorkoutId)`: Fetch a specific `CompletedWorkout.dart` with all sets/reps.
    *   `[ ]` `createWorkoutPlan(...)`: Save a new `Workout.dart` plan.
    *   `[ ]` `updateWorkoutPlan(...)`: Update an existing `Workout.dart` plan.
    *   `[ ]` `deleteWorkoutPlan(...)`: Delete a `Workout.dart` plan.
    *   `[ ]` `getWorkoutTypes()`: Fetch available workout types for filters.
    *   `[ ]` `getWorkoutHistoryStats(...)`: Fetch aggregated stats for the history/profile screen (consider if this is done client-side or via a backend function/view).

## Riverpod Providers (`lib/providers/data_providers.dart`)

*   `[ ]` **Define Providers:** Create Riverpod providers to expose data streams or futures fetched via `API_Services.dart`.
    *   `[ ]` `communityFeedProvider`: `FutureProvider<List<PostModel>>`
    *   `[ ]` `communityGroupsProvider(String query, String filter)`: `FutureProvider<List<Community>>` (use `family` for parameters)
    *   `[ ]` `communityDetailProvider(String communityId)`: `FutureProvider<Community>` (use `family`)
    *   `[ ]` `workoutPlansProvider`: `FutureProvider<List<Workout>>`
    *   `[ ]` `workoutDetailProvider(String workoutId)`: `FutureProvider<Workout>` (use `family`)
    *   `[ ]` `userCompletedWorkoutsProvider(String userId, String typeFilter, String timeFilter)`: `FutureProvider<List<CompletedWorkout>>` (use `family`)
    *   `[ ]` `completedWorkoutDetailProvider(String completedWorkoutId)`: `FutureProvider<CompletedWorkout>` (use `family`)
*   `[ ]` **Define Notifiers for Mutations:** Create `StateNotifier` or `AsyncNotifier` classes for operations that change data (create, update, delete, join, react).
    *   `[ ]` `postCreationNotifier`: Handles creating new posts.
    *   `[ ]` `communityCreationNotifier`: Handles creating new communities.
    *   `[ ]` `communityJoinToggleNotifier`: Handles joining/leaving communities.
    *   `[ ]` `postReactionNotifier`: Handles liking/unliking posts.
    *   `[ ]` `postCommentNotifier`: Handles adding comments.
    *   `[ ]` `completedWorkoutSaverNotifier`: Handles saving completed workouts.
    *   `[ ]` `profileUpdateNotifier`: Handles updating user profile.
*   `[ ]` **Implement Provider Logic:** Connect providers to `API_Services.dart`. Handle `AsyncValue` states (`loading`, `data`, `error`). Use `ref.watch` to depend on other providers (e.g., `userCompletedWorkoutsProvider` might depend on `currentUserProvider`). Use `ref.invalidate` or `ref.refresh` on relevant providers after successful mutations to update the UI.

## Screen Implementation (Using Providers)

*   `[ ]` **CommunityHome.dart:**
    *   `[ ]` Watch `communityFeedProvider` and `communityStoriesProvider` (if separate) using `ref.watch`.
    *   `[ ]` Handle `AsyncValue` states (show loading indicators, error messages, or data).
    *   `[ ]` Implement navigation to `CommunityGroups.dart` and `CreatePostScreen.dart`.
    *   `[ ]` Implement tap actions on `PostCard.dart` (like, comment, share) by calling methods on relevant notifiers (`postReactionNotifier`, `postCommentNotifier`) or navigating to `PostDetailScreen`.
*   `[ ]` **CommunityGroups.dart:**
    *   `[ ]` Manage filter/search state (e.g., using `StateProvider`s or `StateNotifier`).
    *   `[ ]` Watch `communityGroupsProvider` using `ref.watch`, passing current filter/search state.
    *   `[ ]` Handle `AsyncValue`.
    *   `[ ]` Implement tap on "Join/Joined" button by calling `communityJoinToggleNotifier`.
    *   `[ ]` Implement navigation to `GroupDetailsScreen.dart` and `CreateCommunity.dart`.
*   `[ ]` **GroupDetailsScreen.dart:**
    *   `[ ]` Get `communityId` from navigation arguments.
    *   `[ ]` Watch `communityDetailProvider(communityId)` using `ref.watch`.
    *   `[ ]` Handle `AsyncValue`.
    *   `[ ]` Watch community posts provider (if separate, e.g., `groupPostsProvider(communityId)`).
    *   `[ ]` Implement join/notify toggle using `communityJoinToggleNotifier`.
    *   `[ ]` Implement tap on "Create Post" button (if joined) navigating to `CreatePostScreen.dart` with the `communityId`.
    *   `[ ]` Implement post actions on `PostCard.dart`.
*   `[ ]` **CreatePostScreen.dart:**
    *   `[ ]` Use `StateNotifier`s or local `useState` for form state within each tab widget (`CreatePostTab`, `CreateWorkoutTab`, `CreateChallengeTab`).
    *   `[ ]` Call `ref.read(postCreationNotifier.notifier).createPost(...)` from the submit logic of each tab.
    *   `[ ]` Watch `postCreationNotifier` state to show loading and handle success/error (show messages, pop screen on success).
*   `[ ]` **CreateCommunity.dart:**
    *   `[ ]` Use local `useState` or `StateNotifier` for form state.
    *   `[ ]` Call `ref.read(communityCreationNotifier.notifier).createCommunity(...)` from the submit logic.
    *   `[ ]` Watch `communityCreationNotifier` state to show loading and handle success/error.
*   `[ ]` **WorkoutDetailScreen.dart:**
    *   `[ ]` Get `workoutId` from navigation arguments.
    *   `[ ]` Watch `workoutDetailProvider(workoutId)` using `ref.watch`.
    *   `[ ]` Handle `AsyncValue`.
    *   `[ ]` Implement navigation to `ActiveWorkoutScreen.dart`, passing the necessary initial state derived from the `WorkoutDetail`.

## General

*   `[ ]` **Implement Loading States:** Ensure all screens watching `AsyncValue` display appropriate loading indicators (e.g., `CircularProgressIndicator`) when `asyncValue.isLoading` is true.
*   `[ ]` **Implement Error Handling:** Ensure all screens watching `AsyncValue` display informative error messages when `asyncValue.hasError` is true. Add `try/catch` blocks in API service methods and notifiers.
*   `[ ]` **Implement "No Data" States:** Display appropriate messages (e.g., "No posts yet", "No workouts found") when fetched lists are empty.
*   `[ ]` **Refine Model Parsing:** Double-check `fromJson` and `toJson` methods in all models (`lib/models/`) match your actual API response/Supabase structure. Handle nulls and missing fields gracefully.
*   `[ ]` **Local Storage Integration:** Implement saving/loading for `ActiveWorkoutState` using `shared_preferences` or `sqflite` in `ActiveWorkoutScreen.dart` or a dedicated service/provider.
*   `[ ]` **Testing:** Write unit and widget tests for providers, API service methods, and key widgets/screens.


## Features (suggested by mentors):

*   `[ ]` Workouts divided into Days, for this we can easily implement it by adding dayNumber, dayName fields to the PlannedExercise or exercise that is being generated from the Exercise field generator by Gemini, 

* `[x]` I have successfully implemented the functionality to save Workout Plans (with their exercises) and Meal Plans to your Supabase backend.

Here's a summary of the changes made:

**Backend:**
*   **Database Schema:** Added the `meal_plans` table, its index, and `updated_at` trigger to `server/app/database/tables.sql`.
*   **SQLAlchemy Models:** Defined `MealPlan` and `PlannedExercise` models, and updated the `Workout` model in `server/app/models_db.py` to include a relationship to `PlannedExercise`.
*   **Pydantic Schemas:** Created `server/app/schemas/meal_plan.py` for Meal Plan data validation. Updated `server/app/schemas/workout.py` to include `PlannedExercise` schemas and to allow `WorkoutCreate` to accept nested exercises.
*   **CRUD Operations:** Created `server/app/crud/meal_crud.py` for Meal Plan CRUD operations. Created `server/app/crud/workout_plan_crud.py` to handle CRUD for Workout Plans and their associated exercises.
*   **API Endpoints:** Created `server/app/api/v1/endpoints/meal_plans.py` for Meal Plan API endpoints. Updated `server/app/api/v1/endpoints/workout.py` to handle Workout Plan creation and retrieval with nested exercises, and adjusted its endpoint prefix. Registered the new `meal_plans` router and updated the `workout` router prefix in `server/app/main.py`.

**Frontend:**
*   **API Service:** Updated `fitnation/lib/api/API_Services.dart` with new methods (`saveWorkoutPlan`, `getWorkoutPlans`, `saveMealPlan`, `getMealPlans`, etc.) and adjusted endpoint paths to interact with the new backend structure.
*   **Providers:** Modified `fitnation/lib/providers/gemini_workout_provider.dart` and `fitnation/lib/providers/gemini_meal_plan_provider.dart` to use the new API service methods for saving and fetching data from the backend. Also updated `fitnation/lib/providers/data_providers.dart` and `fitnation/lib/Screens/Activities/WorkoutScreen.dart` to reflect the API service method name changes.
*   **Local Database:** Removed the local SQLite CRUD operations for Meal Plans from `fitnation/lib/services/database_helper.dart`, as these are now handled by the backend.

To run the backend, navigate to the `server` directory and execute: