# Cal AI Feature Implementation Tasks for Athlytiq

This document tracks the progress of implementing Cal AI-like features within the Athlytiq application.

Each task is broken down by the area of implementation: Frontend (FE), Backend (BE), and Database (DB).

## Overall Plan Tasks:

- [x] **Project Setup and Dependencies:** Add necessary Flutter packages for image handling (`image_picker`), barcode scanning (`barcode_scan2`), data visualization (`fl_chart`), and potentially packages for interacting with AI/ML models or external food database APIs.
    - [x] FE
    - [ ] BE
    - [ ] DB

- [ ] **Navigation Update:** Modify the existing bottom navigation bar to include a new "Nutrition" tab.
    - [ ] FE
    - [ ] BE
    - [ ] DB

- [ ] **Develop Nutrition Module UI:** Create new screens and widgets within a dedicated `nutrition/` directory under `lib/Screens/` to handle the various nutrition features (photo upload, manual entry, barcode scanning, progress tracking, personalized plans).
    - [ ] FE
    - [ ] BE
    - [ ] DB

- [x] **Define Data Models:** Create new data models in `lib/models/` for representing meals, individual food items with detailed nutritional information, nutrition plans, and user progress data related to nutrition.
    - [x] FE
    - [x] BE
    - [x] DB

- [ ] **Implement State Management:** Utilize Riverpod to manage the state of nutrition data, user input, and UI updates across the app.
    - [ ] FE
    - [ ] BE
    - [ ] DB

- [ ] **Develop Core Feature Logic:** Implement the logic for handling photo uploads, barcode scanning, manual entry, progress tracking, and fitness tracker integration.
    - [ ] FE
    - [ ] BE
    - [ ] DB

- [x] **Backend Development:** Develop or extend the backend services in the `server/` directory to handle storing, retrieving, and processing all nutrition-related data.
    - [ ] FE
    - [x] BE
    - [x] DB

- [ ] **Extend Community and Trainer Features:** Modify existing features to allow sharing of meal data in the community feed and enable trainers to view and manage client nutrition plans.
    - [ ] FE
    - [ ] BE
    - [ ] DB

- [ ] **Address Privacy and Security:** Ensure all handling of sensitive nutrition data adheres to privacy policies and security best practices.
    - [ ] FE
    - [ ] BE
    - [ ] DB

- [ ] **Implement Multilingual Support:** Ensure all new UI elements and data displays in the nutrition module support multiple languages.
    - [ ] FE
    - [ ] BE
    - [ ] DB

- [ ] **Testing:** Write unit, integration, and widget tests for the new nutrition features and backend services.
    - [ ] FE
    - [ ] BE
    - [ ] DB

## Detailed Feature Implementation Tasks:

### Nutrition Tab:

- [x] Modify `lib/Screens/NavPages.dart` to add a new `NutritionScreen` to the `navPages` list.
    - [x] FE
    - [ ] BE
    - [ ] DB
- [x] Update the `AnimatedNotchBottomBar` in `lib/main.dart` to include an icon and label for the Nutrition tab.
    - [x] FE
    - [ ] BE
    - [ ] DB

### Photo-Based Meal Tracking:

- [x] Create a `NutritionScreen` widget in `lib/Screens/nutrition/`.
    - [x] FE
    - [ ] BE
    - [ ] DB
- [x] Add a button or interface element to trigger photo upload.
    - [x] FE
    - [ ] BE
    - [ ] DB
- [x] Implement image picking functionality (using a package like `image_picker`).
    - [x] FE
    - [ ] BE
    - [ ] DB
- [x] Send the image to the chosen AI service for analysis.
    - [x] FE
    - [ ] BE
    - [ ] DB
- [x] Display the results (food items, calories, macros) to the user, allowing for manual correction.
    - [x] FE
    - [ ] BE
    - [ ] DB
- [x] Save the meal data to the database.
    - [x] FE
    - [ ] BE
    - [ ] DB

### Personalized Nutrition Plans:

- [x] Create a setup quiz flow to gather user lifestyle information.
    - [x] FE
    - [ ] BE
    - [ ] DB
- [x] Develop logic to generate personalized calorie and macro targets based on user input and goals.
    - [ ] FE
    - [x] BE
    - [ ] DB
- [x] Display these targets in the `NutritionScreen` with progress bars.
    - [x] FE
    - [ ] BE
    - [ ] DB
- [x] Create UI for trainers to create and assign nutrition plans.
    - [x] FE
    - [ ] BE
    - [ ] DB

### Barcode and Nutrition Label Scanning:

- [x] Add a barcode scanning feature to the `NutritionScreen` (using a package like `barcode_scan2`).
    - [x] FE
    - [ ] BE
    - [ ] DB
- [x] Implement logic to search for scanned barcodes in a food database (either a local one or an external API).
    - [x] FE
    - [ ] BE
    - [ ] DB
- [x] Allow users to scan nutrition labels and manually input data if not found via barcode.
    - [x] FE
    - [ ] BE
    - [ ] DB
- [x] Save scanned items to the user's food diary.
    - [x] FE
    - [ ] BE
    - [ ] DB

### Progress Tracking:

- [x] Create a dedicated section or screen for nutrition progress tracking.
    - [x] FE
    - [ ] BE
    - [ ] DB
- [x] Fetch historical meal data.
    - [x] FE
    - [ ] BE
    - [ ] DB
- [x] Use a charting library (`fl_chart`) to visualize calorie and macro trends over time.
    - [x] FE
    - [ ] BE
    - [ ] DB
- [x] Display weekly/monthly summaries.
    - [x] FE
    - [ ] BE
    - [ ] DB

### Fitness Tracker Integration:

- [ ] Implement integration with health platforms (using packages like `health` or platform-specific code).
    - [x] FE
    - [ ] BE
    - [ ] DB
- [ ] Request user permission to access workout data.
    - [ ] FE
    - [ ] BE
    - [ ] DB
- [ ] Sync calorie burn data and display net calories in the `NutritionScreen`.
    - [ ] FE
    - [ ] BE
    - [ ] DB

### Manual Entry and Correction:

- [x] Add a form or interface in the `NutritionScreen` for users to manually enter meal details and nutritional information.
    - [x] FE
    - [ ] BE
    - [ ] DB
- [ ] Allow users to edit the results of photo or barcode scanning.
    - [ ] FE
    - [ ] BE
    - [ ] DB
- [ ] Implement functionality to save frequently entered meals for quick access.
    - [ ] FE
    - [ ] BE
    - [ ] DB
