## 0 Technical Considerations

*   **Supabase:** Used for authentication, database, and storage. Row Level Security (RLS) should be configured in Supabase for data protection.
*   **Riverpod:** Provides unidirectional data flow and efficient state management. Use `AsyncValue` to handle asynchronous data states (loading, data, error). Use `ref.watch` in widgets and providers, `ref.read` for one-off access, and `ref.invalidate`/`ref.refresh` to trigger data re-fetching after mutations.
*   **API Service (`API_Services.dart`):** All backend calls should go through this layer. Implement error handling within these methods.
*   **Local Storage:** Use `shared_preferences` for simple key-value data (like user settings) or `sqflite` for structured local data (essential for saving/resuming active workout state).
*   **Error Handling:** Implement comprehensive error handling in `API_Services.dart`, propagate errors through providers (`AsyncValue.error`), and display user-friendly error messages in the UI.
*   **Loading States:** Always show loading indicators when fetching data (`AsyncValue.isLoading`).
*   **Responsiveness:** Utilize `lib/core/components/ResponsiveCenter.dart` and Flutter's layout widgets (`Expanded`, `Flexible`, `GridView`, `ListView`) along with theme values for spacing and padding to ensure the UI adapts across different screen sizes.
*   **Image Handling:** Use `cached_network_image` for displaying network images efficiently. Use `image_picker` for selecting images from the device. Handle image uploads via `API_Services.uploadImage` (a method you'll need to add) to Supabase Storage.
*   **Date/Time:** Use the `intl` package for formatting dates and times.
*   **Charts:** `fl_chart` is used for rendering charts. Data needs to be transformed into the specific formats required by `fl_chart`'s data models (`BarChartData`, `PieChartData`, `LineChartData`).
*   **Testing:** Implement unit tests for providers and API service methods. Implement widget tests for reusable widgets and screens.


## 0.1 Project Setup

1.  Clone the repository.
2.  Run `flutter pub get` to install dependencies.
3.  Set up your Supabase project.
4.  Update `lib/main.dart` with your Supabase URL and Anon Key.
5.  Update `lib/api/API_Services.dart` to connect to your Supabase tables and implement the necessary query/mutation methods.
6.  Implement the Riverpod providers in `lib/providers/data_providers.dart` and `lib/providers/auth_provider.dart`.
7.  Start implementing the screens and widgets, connecting them to the providers using `ref.watch` and calling notifier methods for actions.