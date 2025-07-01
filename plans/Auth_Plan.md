# Google OAuth Integration Plan

This plan outlines the steps to integrate Google OAuth using Firebase for both the Flutter frontend and FastAPI backend.

## I. Backend (FastAPI) Modifications

### 1. Update `server/app/api/v1/endpoints/auth.py`
*   **Firebase Admin SDK Initialization:** Uncomment and correctly initialize the Firebase Admin SDK using the provided `serviceAccountKey.json` file.
*   **Implement Google Login Endpoint:** Uncomment and complete the `/google-login` endpoint. This endpoint will:
    *   Verify the Google ID token received from the Flutter app using `auth.verify_id_token()`.
    *   Check if a user with the `google_id` (from the decoded token) exists in the database using `get_user_by_google_id()`.
    *   If no user with `google_id` is found, check if a user with the same `email` (from the decoded token) exists.
        *   If an email match is found, update that existing user's `google_id` to link their Google account.
        *   If no email match is found, create a new `User` entry in the database. For Google-authenticated users, the `password_hash` will be set to `None` or a suitable placeholder.
    *   Generate and return standard access and refresh tokens for the authenticated user, similar to the existing email/password login flow.

### 2. Update `server/app/crud/user.py`
*   **`create_user` Adaptation:** Ensure the `create_user` function can handle cases where `password_hash` is `None` (for users authenticating solely via Google).

### 3. Update `server/.env`
*   Add a new environment variable for the path to the Firebase service account key, if needed, or ensure the application can locate it. (Already handled by direct path in code for now).

## II. Frontend (Flutter) Modifications

### 1. Update `fitnation/pubspec.yaml`
*   Add `firebase_auth` and `google_sign_in` packages as dependencies.

### 2. Update `fitnation/lib/main.dart`
*   **Firebase Initialization:** Uncomment and ensure `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` is called correctly at the start of `main()`.

### 3. Update `fitnation/lib/api/API_Services.dart`
*   **Add `googleLogin` Method:** Create a new method, `googleLogin(String idToken)`, which will send the Google ID token to your FastAPI backend's `/auth/google-login` endpoint. It should expect the `Token` response (access and refresh tokens).

### 4. Update `fitnation/lib/providers/auth_provider.dart`
*   **Implement Google Sign-In Logic:**
    *   Add a new method, e.g., `signInWithGoogle()`, to handle the Google Sign-In flow.
    *   Use `GoogleSignIn` to initiate the sign-in process and get `GoogleSignInAuthentication`.
    *   Use `FirebaseAuth` to create a `GoogleAuthCredential` from the Google ID token and access token.
    *   Call the new `_apiService.googleLogin()` method with the obtained Google ID token.
    *   Upon successful response from the backend, store the access and refresh tokens using `_secureStorage` and update the `AuthState` to `Authenticated`.
    *   Handle potential errors during the Google Sign-In process or the backend API call, updating the `AuthState` to `Unauthenticated` with an appropriate message.

### 5. Update `fitnation/lib/Screens/Auth/Login.dart`
*   **Connect Google Button:** Modify the `_loginWithGoogle()` method to call the new `signInWithGoogle()` method from `authProvider.notifier`.
*   Update the UI to reflect loading states during Google Sign-In.

## III. Testing

*   Verify that users can successfully log in using their Google accounts.
*   Ensure new Google users are created correctly in the backend database.
*   Verify existing users can link their Google accounts if they log in with Google using an email that already exists.
*   Test token generation and refresh for Google-authenticated sessions.

This plan addresses the integration of Google OAuth across both your frontend and backend, leveraging your existing Firebase setup and backend structure.



## Update 2: 

The Google OAuth login flow has been updated in your Flutter code. The `LoginScreen` will now correctly call the `signInWithGoogle` method in your `AuthProvider` when the "Log in with Google" button is pressed.

The backend already has the necessary `/auth/google-login` endpoint, user model, and CRUD operations to support this.

__Crucial Next Steps (Configuration):__

To ensure Google Sign-In works correctly, you __must__ verify and complete the following configurations:

1. __Flutter Firebase Setup:__

  [x] - __`google-services.json` (Android):__ Ensure this file (downloaded from your Firebase project settings) is placed in `fitnation/android/app/`.
  [x] - __`GoogleService-Info.plist` (iOS):__ Ensure this file (downloaded from your Firebase project settings) is placed in `fitnation/ios/Runner/`.
  [x] - __SHA-1 Fingerprints (Android):__ In your Firebase Project Settings (Project settings -> General -> Your apps -> Android app), make sure you have added the SHA-1 fingerprints for both your debug and release keystores. You can get your debug SHA-1 by running `cd android && ./gradlew signingReport` in the `fitnation` directory.
   - __iOS Bundle ID:__ Ensure the Bundle ID in your Xcode project matches the one registered in Firebase.

2. __Google Cloud Console OAuth Configuration:__

   [x] - Go to the [Google Cloud Console](https://console.cloud.google.com/).

   [x] - Select your project.

   [x] - Navigate to "APIs & Services" -> "Credentials".

   - __OAuth 2.0 Client IDs:__

    [x] - __Android:__ Verify that an OAuth 2.0 Client ID for Android exists. Its package name must match `your.app.package.name` (from `fitnation/android/app/build.gradle` - `applicationId`) and the SHA-1 fingerprint must match the one you configured in Firebase.
    [~] - __iOS:__ Verify that an OAuth 2.0 Client ID for iOS exists. Its bundle ID must match your app's bundle ID.
    [-] - *(Web client ID for backend is usually handled by `serviceAccountKey.json` when using Firebase Admin SDK for token verification, so this might already be covered).*

   - __OAuth Consent Screen:__

     - Ensure it's configured with your app's name, user support email, developer contact information, and any necessary scopes (though `google_sign_in` usually requests basic profile scopes like email, profile, openid by default).
     - Set the publishing status (e.g., "In production" or "Testing" with test users added if not yet public).

3. __Backend Database Migration:__

   - The `User` model in `server/app/models/user.py` includes `google_id = Column(Text, unique=True, nullable=True)`.
   - __You must ensure this column exists in your actual `users` database table.__ If you added this field after the table was initially created, you need to run a database migration (e.g., using Alembic if you have it set up).
     - If using Alembic, you would typically generate a migration script (`alembic revision -m "add_google_id_to_users"`) that adds this column, then apply it (`alembic upgrade head`).

After these configurations are correctly set up, the Google OAuth login should function as intended.

**
