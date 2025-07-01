import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fitnation/api/API_Services.dart'; // Import ApiService class
import 'package:fitnation/providers/data_providers.dart'; // Import apiServiceProvider from data_providers
import 'package:fitnation/models/User.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Added
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Added
import 'package:fitnation/services/connectivity_service.dart'; // Import ConnectivityService

// --- Auth State ---
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  final String? message; // Optional error message
  Unauthenticated({this.message});
}

class PasswordResetSent extends AuthState {
  final String? message;
  PasswordResetSent({this.message});
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// --- Auth Notifier ---
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage;

  AuthNotifier(this._apiService, this._secureStorage) : super(AuthInitial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = AuthLoading();
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      if (accessToken != null && accessToken.isNotEmpty) {
        // Optionally validate token by fetching user data
        final user = await _apiService.getCurrentUser();
        state = Authenticated(user);
      } else {
        state = Unauthenticated();
      }
    } on NoInternetException catch (e) {
      debugPrint("Auth check failed due to no internet: $e");
      state = Unauthenticated(message: e.message);
    } catch (e, st) {
      debugPrint("Auth check failed: $e\nStackTrace: $st");
      await _secureStorage.delete(
        key: 'access_token',
      ); // Clear potentially invalid token
      await _secureStorage.delete(key: 'refresh_token');
      state = Unauthenticated(
        message: "Session expired. Please login again. Error: ${e.toString()}",
      );
    }
  }

  Future<void> login(String username, String password) async {
    state = AuthLoading();
    try {
      final tokenData = await _apiService.login(username, password);
      await _secureStorage.write(
        key: 'access_token',
        value: tokenData['access_token'],
      );
      if (tokenData['refresh_token'] != null) {
        await _secureStorage.write(
          key: 'refresh_token',
          value: tokenData['refresh_token'],
        );
      }

      // Fetch user data after successful login
      final user = await _apiService.getCurrentUser();
      state = Authenticated(user);
    } on NoInternetException catch (e) {
      debugPrint("Login failed due to no internet: $e");
      state = Unauthenticated(message: e.message);
    } catch (e, st) {
      debugPrint("Login failed: $e\nStackTrace: $st");
      state = Unauthenticated(message: "Login failed: ${e.toString()}");
    }
  }

  Future<void> register(String username, String email, String password) async {
    state = AuthLoading();
    try {
      // API's register endpoint might return the created user directly or just a success message.
      // If it returns the user, you can proceed to login or fetch user data.
      // For simplicity, let's assume it doesn't auto-login.
      await _apiService.register(username, email, password);
      // After successful registration, you might want to auto-login or prompt user to login.
      // For this example, we'll just transition to Unauthenticated for them to login.
      state = Unauthenticated(
        message: "Registration successful! Please login.",
      );
    } on NoInternetException catch (e) {
      debugPrint("Registration failed due to no internet: $e");
      state = Unauthenticated(message: e.message);
    } catch (e, st) {
      debugPrint("Registration failed: $e\nStackTrace: $st");
      state = Unauthenticated(message: "Registration failed: ${e.toString()}");
    } 
  }

  Future<void> logout() async {
    state = AuthLoading();
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    // Sign out from Firebase and Google as well
    // await firebase_auth.FirebaseAuth.instance.signOut();
    // await GoogleSignIn().signOut();
    state = Unauthenticated();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = AuthLoading();
    try {
      await _apiService.resetPassword(email);

      state = PasswordResetSent(message: "Password reset link sent to your email!");
    } on NoInternetException catch (e) {
      debugPrint("Password reset failed due to no internet: $e");
      state = AuthError(e.message);
    } catch (e, st) {
      debugPrint("Password reset failed: $e\nStackTrace: $st");
      state = AuthError("Failed to send reset link: ${e.toString()}");
    }
  }

  Future<void> signInWithGoogle() async {
    state = AuthLoading();
    final GoogleSignIn googleSignIn = GoogleSignIn(); // Instance for potential signOut
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint("Google Sign-In: User cancelled or failed to select account.");
        state = Unauthenticated(message: "Google Sign-In aborted by user.");
        return;
      }
      debugPrint("Google Sign-In: User account selected: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      debugPrint("Google Sign-In: Authentication object obtained.");
      debugPrint("Google Sign-In: Access Token is ${googleAuth.accessToken == null ? 'null' : 'present'}");
      debugPrint("Google Sign-In: ID Token is ${googleAuth.idToken == null ? 'null' : 'present'}"); // <<< THIS IS THE KEY LINE
      debugPrint("Google Sign-In: Server Auth Code is ${googleAuth.serverAuthCode == null ? 'null' : 'present'}");

      final String? idToken = googleAuth.idToken; // Use the variable
      if (idToken == null) {
        debugPrint("Google Sign-In: ID Token is NULL. This is the cause of 'Failed to get Google ID Token'.");
        debugPrint("Google Sign-In: Verify SHA-1 and Package Name in Firebase & Google Cloud Console for your Android OAuth Client.");
        state = Unauthenticated(message: "Failed to get Google ID Token. Check Android client configurations (SHA-1/Package).");
        // Attempt to sign out to clear any partial state
        await googleSignIn.signOut();
        await firebase_auth.FirebaseAuth.instance.signOut(); // Also sign out from Firebase if partially signed in
        return;
      }
      debugPrint("Google Sign-In: ID Token successfully retrieved: ${idToken.substring(0, (idToken.length > 30 ? 30 : idToken.length))}..."); // Print a snippet, ensure not out of bounds

      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, // Can be null, idToken is more important for Firebase
        idToken: idToken,
      );

      // Sign in to Firebase with the credential
      await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint("Google Sign-In: Successfully signed into Firebase.");

      // Get the Firebase ID token from the current Firebase user
      firebase_auth.User? firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        debugPrint("Google Sign-In: Firebase user is null after successful sign-in with Google credential.");
        throw Exception("Firebase user is null after successful sign-in with Google credential.");
      }

      final String? firebaseIdToken = await firebaseUser.getIdToken(true); // true to force refresh if needed
      if (firebaseIdToken == null) {
        debugPrint("Google Sign-In: Failed to get Firebase ID Token from current user.");
        throw Exception("Failed to get Firebase ID Token from current user.");
      }
      debugPrint("Google Sign-In: Firebase ID Token successfully retrieved: ${firebaseIdToken.substring(0, (firebaseIdToken.length > 30 ? 30 : firebaseIdToken.length))}...");

      // Send the FIREBASE ID token to your backend
      final tokenData = await _apiService.googleLogin(firebaseIdToken);
      debugPrint("Google Sign-In: Successfully called custom backend with Firebase ID token.");
      await _secureStorage.write(
        key: 'access_token',
        value: tokenData['access_token'],
      );
      if (tokenData['refresh_token'] != null) {
        await _secureStorage.write(
          key: 'refresh_token',
          value: tokenData['refresh_token'],
        );
      }

      final user = await _apiService.getCurrentUser();
      state = Authenticated(user);
      debugPrint("Google Sign-In: Successfully authenticated with backend and fetched user.");
    } on NoInternetException catch (e) {
      debugPrint("Google Sign-In failed due to no internet: $e");
      await googleSignIn.signOut();
      await firebase_auth.FirebaseAuth.instance.signOut();
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
      state = Unauthenticated(message: e.message);
    } catch (e, st) {
      debugPrint("Google Sign-In Provider Error: $e\nStackTrace: $st");
      // Ensure full logout on failure
      await googleSignIn.signOut();
      await firebase_auth.FirebaseAuth.instance.signOut();
      // We don't call the full `logout()` method here as it might set state to AuthLoading again,
      // and we want to preserve the Unauthenticated state with the specific error message.
      // Clear tokens manually if necessary, though logout() in AuthProvider already does this.
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
      state = Unauthenticated(message: "Google Sign-In failed: ${e.toString()}");
    }
  }

  // Optional: Attempt to refresh token
  Future<bool> attemptTokenRefresh() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

    try {
      final tokenData = await _apiService.refreshToken(refreshToken);
      await _secureStorage.write(
        key: 'access_token',
        value: tokenData['access_token'],
      );
      if (tokenData['refresh_token'] != null) {
        // Handle token rotation
        await _secureStorage.write(
          key: 'refresh_token',
          value: tokenData['refresh_token'],
        );
      }
      // Optionally re-fetch user data to confirm
      final user = await _apiService.getCurrentUser();
      state = Authenticated(user);
      return true;
    } on NoInternetException catch (e) {
      debugPrint("Token refresh failed due to no internet: $e");
      await logout(); // Force logout if refresh fails
      state = Unauthenticated(message: e.message);
      return false;
    } catch (e, st) {
      debugPrint("Token refresh failed: $e\nStackTrace: $st");
      await logout(); // Force logout if refresh fails
      return false;
    }
  }
}

// --- Auth Provider ---
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(apiService, const FlutterSecureStorage());
});

// Provider to easily access the current user if authenticated
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is Authenticated) {
    return authState.user;
  }
  return null;
});
