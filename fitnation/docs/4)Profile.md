## 4 Profile Feature Implementation

*   **Screens:** `lib/Screens/` - `ProfileScreen.dart` (likely the main profile screen).
    *   `ProfileScreen.dart`: User profile and progress view, tabs (Progress, Profile).
        *   **Profile Tab:** Displays user info (`User.dart`), allows editing name/username and changing avatar. Uses a `Form`. Calls `API_Services.updateUserProfile`.
        *   **Progress Tab:** Displays workout stats (`StatsCard.dart`) and charts (`WeeklyActivityChart.dart`, `WorkoutDistributionChart.dart`, `IntensityTrendChart.dart`) based on the user's `CompletedWorkout.dart` history.
*   **Models:** `lib/models/` - `User.dart`, `ProfileModel.dart` (potentially an extension or specific view of `User.dart`), `CompletedWorkout.dart`, and the chart data models (`WeeklyActivityData.dart`, etc.).
*   **Widgets:** Reuses `lib/widgets/Activities/StatsCard.dart` and the chart widgets. Uses standard form widgets.
*   **Data Flow:** Watches `currentUserProvider` and `userCompletedWorkoutsProvider`. Processes `CompletedWorkout.dart` data client-side to generate data for stats and charts. Profile updates call `API_Services.updateUserProfile` via a notifier. Sign out calls the auth provider.