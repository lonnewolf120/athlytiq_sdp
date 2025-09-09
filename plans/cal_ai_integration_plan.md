# Cal AI Feature Implementation Plan for Pulse

This document outlines the plan to implement features similar to Cal AI directly within the Pulse mobile application.

## Revised Overall Plan:

1.  **Project Setup and Dependencies:** Add necessary Flutter packages for image handling (`image_picker`), barcode scanning (`barcode_scan2`), data visualization (`fl_chart`), and potentially packages for interacting with AI/ML models or external food database APIs.
2.  **Navigation Update:** Modify the existing bottom navigation bar to include a new "Nutrition" tab.
3.  **Develop Nutrition Module UI:** Create new screens and widgets within a dedicated `nutrition/` directory under `lib/Screens/` to handle the various nutrition features (photo upload, manual entry, barcode scanning, progress tracking, personalized plans).
4.  **Define Data Models:** Create new data models in `lib/models/` for representing meals, individual food items with detailed nutritional information, nutrition plans, and user progress data related to nutrition.
5.  **Implement State Management:** Utilize Riverpod to manage the state of nutrition data, user input, and UI updates across the app.
6.  **Develop Core Feature Logic:**
    *   Implement the logic for handling photo uploads and sending them for analysis using a chosen AI/ML approach (e.g., integrating with a cloud-based vision API like Google Cloud Vision or exploring on-device ML options). This will involve identifying food items and estimating nutritional content.
    *   Integrate a barcode scanning library (`barcode_scan2`) and implement logic to look up nutritional data based on scanned barcodes using a food database API (e.g., Open Food Facts API) or a local database.
    *   Develop the functionality for manual meal entry and editing of AI-generated or barcode-scanned data.
    *   Implement the logic for tracking daily calorie and macro intake against personalized goals.
    *   Integrate with fitness tracking platforms (Apple Health, Google Fit, etc.) using relevant packages (`health`) to sync workout data and calculate net calories.
    *   Develop the nutrition progress tracking dashboard using `fl_chart` for visualizations of calorie and macro trends.
7.  **Backend Development:** Develop or extend the backend services in the `server/` directory to handle storing, retrieving, and processing all nutrition-related data. This includes user meal logs, personalized plans, food item data (potentially cached from external APIs), and progress metrics.
8.  **Extend Community and Trainer Features:** Modify existing features to allow sharing of meal data in the community feed and enable trainers to view and manage client nutrition plans, interacting with the new backend nutrition services.
9.  **Address Privacy and Security:** Ensure all handling of sensitive nutrition data adheres to privacy policies and security best practices, including secure storage, transmission, and user consent for accessing health data.
10. **Implement Multilingual Support:** Ensure all new UI elements and data displays in the nutrition module support multiple languages.
11. **Testing:** Write unit, integration, and widget tests for the new nutrition features and backend services to ensure stability and correctness.

## Detailed Steps for Key Features:

### Nutrition Tab:

*   Modify `lib/Screens/NavPages.dart` to add a new `NutritionScreen` to the `navPages` list.
*   Update the `AnimatedNotchBottomBar` in `lib/main.dart` to include an icon and label for the Nutrition tab.

### Photo-Based Meal Tracking:

*   Create a `NutritionScreen` widget in `lib/Screens/nutrition/`.
*   Add a button or interface element to trigger photo upload.
*   Implement image picking functionality (using a package like `image_picker`).
*   Send the image to the chosen AI service for analysis.
*   Display the results (food items, calories, macros) to the user, allowing for manual correction.
*   Save the meal data to the database.

### Personalized Nutrition Plans:

*   Create a setup quiz flow (perhaps in `lib/Screens/Auth/` or a dedicated onboarding section) to gather user lifestyle information.
*   Develop logic to generate personalized calorie and macro targets based on user input and goals.
*   Display these targets in the `NutritionScreen` with progress bars.
*   Create UI for trainers to create and assign nutrition plans.

### Barcode and Nutrition Label Scanning:

*   Add a barcode scanning feature to the `NutritionScreen` (using a package like `barcode_scan2`).
*   Implement logic to search for scanned barcodes in a food database (either a local one or an external API).
*   Allow users to scan nutrition labels and manually input data if not found via barcode.
*   Save scanned items to the user's food diary.

### Progress Tracking:

*   Create a dedicated section or screen for nutrition progress tracking.
*   Fetch historical meal data.
*   Use a charting library (`fl_chart`) to visualize calorie and macro trends over time.
*   Display weekly/monthly summaries.

### Fitness Tracker Integration:

*   Implement integration with health platforms (using packages like `health` or platform-specific code).
*   Request user permission to access workout data.
*   Sync calorie burn data and display net calories in the `NutritionScreen`.

### Manual Entry and Correction:

*   Add a form or interface in the `NutritionScreen` for users to manually enter meal details and nutritional information.
*   Allow users to edit the results of photo or barcode scanning.
*   Implement functionality to save frequently entered meals for quick access.
