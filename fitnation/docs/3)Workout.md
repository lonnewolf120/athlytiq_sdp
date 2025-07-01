## 3. Workouts Feature

The Workouts feature screens and widgets are located in `lib/Screens/Activities/` and `lib/widgets/Activities/`, using models from `lib/models/`.

### 3.1 Overview

This feature allows users to plan, track, and review their fitness training sessions.

**Screens (`lib/Screens/Activities/`):**

1.  Workouts Screen (`WorkoutScreen.dart`)
2.  Workout Detail Screen (`WorkoutDetailScreen.dart`)
3.  Active Workout Screen (`ActiveWorkoutScreen.dart`)
4.  Workout History Screen (Likely part of `WorkoutScreen.dart` or a separate screen navigable from it).
5.  Ride Detail Screen (`RideDetailScreen.dart`) - Related activity screen.

### 3.2 Data Models (`lib/models/`)

*   **`Workout.dart`**: Likely represents the core workout plan/template structure. May contain fields for name, icon, planned exercises (`WorkoutDetailExercise` equivalent), equipment, 1RM goals, etc. This model might serve the purpose of both `WorkoutSummary` and `WorkoutDetail` from the previous documentation, or contain nested structures for detail.
*   **`ActiveWorkoutState` (Conceptual)**: Represents the state of a workout currently being performed. This model might be defined within `ActiveWorkoutScreen.dart` or a dedicated provider/model file, but it's not explicitly listed as a separate file in `lib/models/`. It would track the workout being done, start time, and the list of exercises with their actual recorded sets.
*   **`ActiveWorkoutExercise` (Conceptual)**: Represents an exercise being tracked during an active workout. Nested within `ActiveWorkoutState`. Holds reference to the planned exercise and a list of recorded sets.
*   **`ActiveWorkoutSet` (Conceptual)**: Represents a single set recorded during an active workout. Nested within `ActiveWorkoutExercise`. Holds recorded weight, reps, and completion status.
*   **`RideActivity.dart`**: Data model for ride activities.
*   **`RideParticipant`**: Data model for participants in a ride.
*   **`ProfileModel.dart`**: Global user profile data, potentially used here for 1RM or equipment.

### 3.3 Screens (`lib/Screens/Activities/`)

#### 3.3.1 `WorkoutScreen.dart`

*   **Purpose:** Displays lists of workout plans and recent training sessions.
*   **UI:** AppBar (title, History button), TabBar (PLAN, TRAINING), Tab content area (lists of `WorkoutCard.dart`s).
*   **Data/Logic:** Fetches/loads `Workout.dart` summaries via providers, filtered by tab. Uses a `TabController`. Displays `WorkoutCard.dart`s.
*   **Navigation:** To `WorkoutDetailScreen.dart` (from tapping a card), Workout History Screen (from button).

#### 3.3.2 `WorkoutDetailScreen.dart`

*   **Purpose:** Displays the detailed plan for a specific workout before starting.
*   **UI:** AppBar (back button, title + edit icon, workout icon), Info section (Profile/Equipment, 1RM Goal), Exercise list section (count, list of exercise items), Action buttons (START, Regenerate, Edit).
*   **Data/Logic:** Receives or fetches detailed `Workout.dart` data. Displays planned exercises using a relevant widget (potentially `widgets/Activities/WorkoutDetail.dart` if that's what it contains, or a custom item widget).
*   **Navigation:** Back to `WorkoutScreen.dart`, to `ActiveWorkoutScreen.dart` (passing an initialized `ActiveWorkoutState`), potentially to an Edit Workout screen.

#### 3.3.3 `ActiveWorkoutScreen.dart`

*   **Purpose:** Interactive screen for tracking a workout in progress.
*   **UI:** AppBar (back button, workout name + timer + edit icon, options button), Exercise list (vertical list of `ActiveWorkout_Items.dart`), Floating Action Button (Add Exercise).
*   **Data/Logic:** Manages the `ActiveWorkoutState` (conceptual) using `setState` or a provider. Uses a `Timer` for elapsed time. Displays exercises using `ActiveWorkout_Items.dart`. `ActiveWorkout_Items.dart` contains `ActiveWorkout_Row.dart` for individual sets. Receives callbacks from child widgets to update the state. Includes logic for adding sets/exercises and **TODO** saving/resuming state.
*   **Navigation:** Back to previous screen (with confirmation), potentially to a Workout Summary/History screen upon completion.

#### 3.3.4 Ride Detail Screen (`RideDetailScreen.dart`)

*   **Purpose:** Displays details for a specific ride activity.
*   **UI:** (Based on name) Likely shows ride stats, map, participants, etc.
*   **Data/Logic:** Fetches/loads `RideActivity.dart` and `RideParticipant` data. Uses `widgets/Activities/RideCard.dart` for list view? Uses `widgets/ParticipantAvatar.dart`?
*   **Navigation:** Implies a list screen for rides exists (maybe in `WorkoutScreen.dart` or `HomeScreen.dart`) and navigation from there.

### 3.4 Reusable Workouts Widgets (`lib/widgets/Activities/`)

*   **`WorkoutCard.dart`**: Renders a summary view of a workout for the lists in `WorkoutScreen.dart`.
*   **`ActiveWorkout_Items.dart`**: Renders a single exercise being tracked in `ActiveWorkoutScreen.dart`. It's likely expandable and contains `ActiveWorkout_Row.dart`s.
*   **`ActiveWorkout_Row.dart`**: Renders a single set's tracking row within `ActiveWorkout_Items.dart`. Contains set number, completion checkbox, and text fields for weight/reps.
*   **`RideCard.dart`**: Renders a summary view of a ride activity.
*   **`WorkoutDetail.dart`**: The purpose is slightly ambiguous given `WorkoutDetailScreen.dart`. It might be a widget that renders the *content* of the detail screen (like the exercise list section) or specifically the `WorkoutDetailExerciseItem` from the previous documentation. Clarification needed for precise role.

### 3.5 Workouts Feature Implementation

*   **Screens:** `lib/Screens/Activities/`
    *   `WorkoutScreen.dart`: Workout plans and training history lists, tabs (PLAN, TRAINING). Displays `WorkoutCard.dart` (from `widgets/Activities/`). Navigates to `WorkoutDetailScreen.dart` and `WorkoutHistoryScreen.dart`.
    *   `WorkoutDetailScreen.dart`: Detailed workout plan view. Displays `Workout.dart` details and planned exercises (potentially using `widgets/Activities/WorkoutDetail.dart` or a custom item widget). Navigates to `ActiveWorkoutScreen.dart`.
    *   `ActiveWorkoutScreen.dart`: Real-time workout tracking. Manages `ActiveWorkoutState` (conceptual runtime state). Displays exercises using `ActiveWorkout_Items.dart` which contains `ActiveWorkout_Row.dart` for sets. Handles timer, adding sets/exercises. Calls `API_Services.saveCompletedWorkout` upon completion. **TODO:** Implement local storage for saving/resuming workout state.
    *   `WorkoutHistoryScreen.dart`: Completed workout history, stats, calendar, recent workouts list. Displays `StatsCard.dart`, `WorkoutCalendar.dart`, and `CompletedWorkoutListItem.dart` (from `widgets/Activities/`). Uses dropdowns for filtering (`_selectedWorkoutType`, `_selectedTimeRange`). Data is fetched via providers (`data_providers.dart`) from `CompletedWorkout.dart` records.
*   **Models:** `lib/models/` - `Workout.dart` (for plans/templates), `CompletedWorkout.dart`, `CompletedWorkoutExercise.dart`, `CompletedWorkoutSet.dart` (for completed sessions), `User.dart`, `Exercise.dart` (used within Workout plans/posts). Also data models for charts: `WeeklyActivityData.dart`, `WorkoutDistributionData.dart`, `IntensityTrendData.dart`.
*   **Widgets:** `lib/widgets/Activities/` - `WorkoutCard.dart`, `ActiveWorkout_Items.dart`, `ActiveWorkout_Row.dart`, `StatsCard.dart`, `WorkoutCalendar.dart`, `CompletedWorkoutListItem.dart`, `CompletedWorkoutExerciseItem.dart`, `WeeklyActivityChart.dart`, `WorkoutDistributionChart.dart`, `IntensityTrendChart.dart`. Also uses `lib/core/components/`.
*   **Data Flow:** Screens watch providers fetching `Workout.dart` or `CompletedWorkout.dart` data. `ActiveWorkoutScreen.dart` manages runtime state and saves final data via `API_Services.saveCompletedWorkout`. Filtering in `WorkoutHistoryScreen.dart` is handled by passing filter parameters to the data provider.