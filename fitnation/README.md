# fitnation

## 0.1 Flutter App Setup

1.  Clone the repository.
2.  do `cd ${cloned-dir}/App/fitnation`
3.  Use flutter 3.29.1+ version with Dart 3+ and if multiple versions available in your machine, use `fvm`  
4.  Run `flutter pub get` or `fvm flutter pub get` to install dependencies.
5.  Set up your Supabase project.
6.  Update `.env` with your Supabase URL and Anon Key.
7.  Update `lib/api/API_Services.dart` to connect to your Supabase tables and implement the necessary query/mutation methods.
8.  Implement the Riverpod providers in `lib/providers/data_providers.dart` and `lib/providers/auth_provider.dart`.
9.  Start implementing the screens and widgets, connecting them to the providers using `ref.watch` and calling notifier methods for actions.



## FitNation App Features
### 1. Workouts
Workout Plans: Create, view, and manage workout plans.
Training History: Track completed workouts with detailed stats.
Workout Details: View detailed plans, including exercises, sets, and reps.
Active Workout Tracking: Real-time tracking of workouts with timers and progress saving.
Charts & Stats: Visualize workout intensity, distribution, and trends.
### 2. Community
Community Feed: View posts, stories, and updates from groups.
Groups: Explore, join, and manage community groups.
Create Posts: Share updates, workouts, or challenges with the community.
Group Details: View group-specific posts, members, and information.
### 3. Profile
User Profile: Manage personal details, including name, avatar, and preferences.
Progress Tracking: View workout stats and achievements.
Customization: Update themes and settings for a personalized experience.
### 4. Authentication
Login/Signup: Secure user authentication with email verification.
Password Management: Reset and update passwords.
### 5. Data Management
Offline Support: Save data locally using sqflite for offline access.
Cloud Sync: Sync data with the backend for seamless access across devices.
### 6. Navigation
Bottom Navigation: Easily switch between Home, Workouts, Community, and Profile.
Responsive Design: Optimized for various screen sizes and orientations.
### 7. Theming
Dark Mode: A sleek black and red theme for better visibility and aesthetics.
Customizable UI: Consistent design with reusable components like buttons, cards, and charts.

## Getting Started

1.  Clone the repository.
2.  Run `flutter pub get` to install dependencies.
3.  Set up your Supabase project and add them in env file
4.  Update `lib/api/API_Services.dart` to connect to the backend
5.  Implement the Riverpod providers in `lib/providers/data_providers.dart` and `lib/providers/auth_provider.dart`.
6.  Start implementing the screens and widgets, connecting them to the providers using `ref.watch` and calling notifier methods for actions.



This document provides development details for the Community and Workouts features within the FitNation Flutter application, aligned with the provided project structure.

## 1. Overall Project Structure & Common Elements

The project is organized into logical directories for core components, API services, models, providers, screens, and widgets.

### 1.1 Project Structure

The provided structure is:
| Filename                                   | Purpose/Description                                                                                   |
|---------------------------------------------|-------------------------------------------------------------------------------------------------------|
| `firebase_options.dart`                     | Firebase configuration (if used alongside Supabase)                                                   |
| `main.dart`                                | App entry point, initializes Supabase, defines theme and root widget                                  |
| `api/API_Services.dart`                     | Handles all interactions with the backend (Supabase, etc.)                                            |
| `core/components/PrimaryButton.dart`        | Standard primary action button                                                                        |
| `core/components/ResponsiveCenter.dart`     | Widget for centering content on larger screens                                                        |
| `core/themes/colors.dart`                   | Defines the color palette                                                                             |
| `core/themes/text_styles.dart`              | Defines typography styles (font family, sizes, weights)                                               |
| `core/themes/themes.dart`                   | Configures ThemeData for the entire application                                                       |
| `models/ChallengePostModel.dart`            | Data specific to a challenge post type                                                                |
| `models/Community.dart`                     | Represents a community group                                                                          |
| `models/CommunityContentModel.dart`         | Potentially content types within a community (purpose needs clarification)                            |
| `models/CommunityMember.dart`               | Represents a user's membership in a community                                                         |
| `models/PostComment.dart`                   | Represents a comment on a post                                                                        |
| `models/PostModel.dart`                     | Represents a general post (can be text, workout, challenge)                                           |
| `models/PostReact.dart`                     | Represents a user's reaction (like) to a post                                                         |
| `models/ProfileModel.dart`                  | Represents the user's profile data (global)                                                           |
| `models/RideActivity.dart`                  | Data for a completed ride activity                                                                    |
| `models/RideParticipant`                    | Data for a participant in a ride                                                                      |
| `models/User.dart`                          | Core user data model                                                                                  |
| `models/Workout.dart`                       | Represents a workout plan or template                                                                 |
| `models/WorkoutPostModel.dart`              | Data specific to a workout post type                                                                  |
| `models/CompletedWorkout.dart`              | Represents a completed workout session                                                                |
| `models/CompletedWorkoutExercise.dart`      | Exercise data recorded during a completed workout                                                     |
| `models/CompletedWorkoutSet.dart`           | Set data recorded during a completed workout                                                          |
| `models/WeeklyActivityData.dart`            | Data structure for the weekly activity chart                                                          |
| `models/WorkoutDistributionData.dart`       | Data structure for the workout distribution chart                                                     |
| `models/IntensityTrendData.dart`            | Data structure for the intensity trend chart                                                          |
| `models/Exercise.dart`                      | Represents a single exercise (used in workout plans/posts)                                            |
| `providers/auth_provider.dart`              | Manages authentication state                                                                          |
| `providers/data_providers.dart`             | Provides access to fetched data (lists, details)                                                      |
| `providers/theme_provider.dart`             | (Optional) Manages theme switching if implemented                                                     |
| `providers/ui_providers.dart`               | (Optional) Manages UI-specific states (e.g., loading, error, filter state)                            |
| `Screens/HomeScreen.dart`                   | The main dashboard screen                                                                             |
| `Screens/NavPages.dart`                     | Container for bottom navigation                                                                       |
| `Screens/OnboardingScreen.dart`             | App onboarding flow                                                                                   |
| `Screens/SettingsScreen.dart`               | App settings screen                                                                                   |
| `Screens/Activities/ActiveWorkoutScreen.dart`         | Screen for tracking a workout in real-time                                                  |
| `Screens/Activities/RideDetailScreen.dart`           | Detail screen for a ride activity                                                           |
| `Screens/Activities/WorkoutDetailScreen.dart`        | Detail screen for a workout plan                                                            |
| `Screens/Activities/WorkoutScreen.dart`              | Screen displaying workout plans and training history                                        |
| `Screens/Activities/WorkoutHistoryScreen.dart`       | Screen displaying completed workout history and stats                                      |
| `Screens/Auth/ChangePass.dart`                       | Change password screen                                                                    |
| `Screens/Auth/FP.dart`                               | Forgot Password screen                                                                    |
| `Screens/Auth/Login.dart`                            | Login screen                                                                              |
| `Screens/Auth/OTP_Screen.dart`                       | OTP verification screen                                                                   |
| `Screens/Auth/Signup.dart`                           | Signup screen                                                                             |
| `Screens/Community/CommunityGroups.dart`             | Screen listing community groups                                                           |
| `Screens/Community/CommunityHome.dart`               | Main community feed screen                                                                |
| `Screens/Community/CreateCommunity.dart`             | Screen for creating a new community                                                       |
| `Screens/Community/CreatePostScreen.dart`            | Screen for creating a new post (multiple types)                                           |
| `Screens/Community/GroupDetailsScreen.dart`          | Detail screen for a specific community group                                              |
| `widgets/CategoryChip.dart`                          | Widget to display a category tag                                                          |
| `widgets/CommunityCard.dart`                         | Potentially a general community preview (purpose needs clarification)                     |
| `widgets/ParticipantAvatar.dart`                     | Widget for displaying participant avatars (used in Rides?)                                |
| `widgets/Activities/ActiveWorkout_Items.dart`        | Widget for an exercise row in Active Workout screen                                       |
| `widgets/Activities/ActiveWorkout_Row.dart`          | Widget for a set row within an exercise in Active Workout screen                          |
| `widgets/Activities/RideCard.dart`                   | Widget for a ride activity summary                                                        |
| `widgets/Activities/WorkoutCard.dart`                | Widget for a workout plan/summary card                                                    |
| `widgets/Activities/WorkoutDetail.dart`              | Potentially a widget within WorkoutDetailScreen (purpose needs clarification)             |
| `widgets/Activities/StatsCard.dart`                  | Widget to display a single statistic card                                                 |
| `widgets/Activities/WorkoutCalendar.dart`            | Widget to display the workout calendar                                                    |
| `widgets/Activities/CompletedWorkoutListItem.dart`   | Widget for a completed workout summary in history list                                    |
| `widgets/Activities/CompletedWorkoutExerciseItem.dart`| Widget for displaying an exercise within a completed workout summary                      |
| `widgets/Activities/WeeklyActivityChart.dart`        | Widget for the weekly activity bar chart                                                  |
| `widgets/Activities/WorkoutDistributionChart.dart`   | Widget for the workout distribution pie chart                                             |
| `widgets/Activities/IntensityTrendChart.dart`        | Widget for the intensity trend line chart                                                 |
| `widgets/community/GroupCard.dart`                   | Widget for a community group card                                                         |
| `widgets/community/PostCard.dart`                    | Widget for a community post card (handles different types)                                |
| `widgets/community/StoryBubble.dart`                 | Widget for a user story avatar bubble                                                     |
| `widgets/home/home_header.dart`                      | Home screen header widget                                                                 |
| `widgets/home/home_nav_grid.dart`                    | Home screen navigation grid widget                                                        |
| `widgets/home/recent_activity.dart`                  | Widget for recent activity display on HomeScreen                                          |
