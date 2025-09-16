import 'package:dio/dio.dart';
import 'package:fitnation/models/Exercise.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fitnation/models/User.dart';
import 'package:fitnation/models/Workout.dart'; // Import Workout model
import 'package:fitnation/models/CompletedWorkout.dart'; // Import CompletedWorkout model
import 'package:fitnation/models/MealPlan.dart'; // Import MealPlan model
import 'package:fitnation/models/PostModel.dart'; // Import Post model
import 'package:fitnation/models/ProfileModel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'dart:io'; // Import for File class
import 'package:fitnation/models/CommunityContentModel.dart' show Group;

final String baseUrl = (dotenv.env['BASE_URL'] ??
        "http://152.42.158.91:8001/api/v1")
    .replaceAll(RegExp(r'/$'), ''); // Ensure no trailing slash
const String exerciseDbBaseUrl =
    'https://exercisedb.p.rapidapi.com'; // Base URL for ExerciseDB API
const String exerciseDbApiKey =
    'f849fea486mshd03f416cc6c7bfcp12aa72jsn3187798e1e93'; // Your actual RapidAPI Key
const String exerciseDbApiHost =
    'exercisedb.p.rapidapi.com'; // Your actual RapidAPI Host

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiService(this._dio, this._secureStorage) {
    _dio.options.baseUrl = baseUrl;
    debugPrint("ApiService: Initializing Dio with baseUrl: $baseUrl");
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint(
            "ApiService: Sending request to ${options.uri}",
          ); // Existing: Good for seeing the target URL

          final token = await _secureStorage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            // ADDED/MODIFIED: Confirm token was found and is being added.
            // For security, logging only a portion of the token is safer during debugging.
            debugPrint(
              "ApiService: Token FOUND. Adding Authorization header for ${options.uri}. Token starts with: ${token.substring(0, token.length > 10 ? 10 : token.length)}...",
            );
          } else {
            // ADDED: Explicitly log if the token is not found. This is key.
            debugPrint(
              "ApiService: Token NOT FOUND in secure storage for ${options.uri}. Authorization header will be MISSING.",
            );
          }

          // Add ExerciseDB headers if the request is for the ExerciseDB API
          // This part seems correct and separate from the JWT token logic for your backend.
          if (options.baseUrl == exerciseDbBaseUrl) {
            // This condition should be false for /workouts/history
            options.headers['x-rapidapi-key'] = exerciseDbApiKey;
            options.headers['x-rapidapi-host'] = exerciseDbApiHost;
            options.headers['Content-Type'] = 'application/json';
            // ADDED: Clarify when ExerciseDB headers are added.
            debugPrint(
              "ApiService: Added ExerciseDB specific headers for ${options.uri}",
            );
          }
          return handler.next(options); // continue
        },
        onResponse: (response, handler) {
          debugPrint(
            "ApiService: Received response from ${response.requestOptions.uri} with status ${response.statusCode}",
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          debugPrint(
            "ApiService: DioError caught for ${e.requestOptions.uri}: ${e.message}",
          );
          if (e.response?.statusCode == 401) {
            // Handle token expiration/invalidation, e.g., logout user or refresh token
            debugPrint(
              "ApiService: Unauthorized error (401) - Token might be expired or invalid for ${e.requestOptions.uri}.",
            );
            // You might want to call a logout method from your auth provider here
            // or attempt a token refresh if you implement that.
            // await _secureStorage.delete(key: 'access_token');
            // await _secureStorage.delete(key: 'refresh_token');
            // debugPrint("ApiService: Deleted access_token and refresh_token due to 401."); // Commented out for now
            debugPrint(
              "ApiService: Token deletion on 401 is currently commented out for debugging.",
            ); // Added for clarity
          }
          return handler.next(e); // continue
        },
      ),
    );
  }

  // --- Auth Endpoints ---
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'username': username, 'email': email, 'password': password},
      );
      return response.data; // Expects User object
    } on DioException catch (e) {
      throw _handleDioError(e, "Registration failed");
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Backend expects JSON body with username and password
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email, // Use email value for username key
          'password': password,
        },
      );
      return response
          .data; // Expects Token object {access_token, refresh_token, token_type}
    } on DioException catch (e) {
      throw _handleDioError(e, "Login failed");
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshTokenValue) async {
    try {
      final response = await _dio.post(
        '/auth/refresh', // Corrected path based on OpenAPI
        queryParameters: {
          'refresh_token': refreshTokenValue,
        }, // Send as query parameter
      );
      return response.data; // Expects new Token object
    } on DioException catch (e) {
      throw _handleDioError(e, "Token refresh failed");
    }
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google-login',
        data: {'token': idToken},
      );
      return response
          .data; // Expects Token object {access_token, refresh_token, token_type}
    } on DioException catch (e) {
      throw _handleDioError(e, "Google login failed");
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to send password reset link");
    }
  }

  // --- User Endpoints ---
  Future<User> getCurrentUser() async {
    final token = await _secureStorage.read(key: 'access_token');
    try {
      final response = await _dio.get(
        '/users/me',
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to fetch current user");
    }
  }

  // --- Community Endpoints ---
  Future<List<Group>> getCommunities({int skip = 0, int limit = 50, bool my = false}) async {
    try {
      final response = await _dio.get(
        '/social/communities',
        queryParameters: {
          'skip': skip,
          'limit': limit,
          if (my) 'my': true,
        },
      );

      final List data = response.data as List;
      // Map backend CommunityListItem -> UI Group model with sensible defaults
      return data.map((e) {
        final Map<String, dynamic> m = e as Map<String, dynamic>;
        final String id = (m['id'] ?? '').toString();
        final String name = (m['name'] ?? 'Community').toString();
        final String desc = (m['description'] ?? '').toString();
        final int memberCount = (m['member_count'] is int)
            ? (m['member_count'] as int)
            : int.tryParse(m['member_count']?.toString() ?? '0') ?? 0;
        final bool joined = (m['joined'] == true);

        // Provide placeholders for fields not in backend yet
        final int postCount = 0;
        final String image = 'https://avatar.iran.liara.run/username?username=' + Uri.encodeComponent(name);
        final bool trending = false;
        final List<String> categories = const [];

        return Group(
          id: id,
          name: name,
          description: desc,
          memberCount: memberCount,
          postCount: postCount,
          image: image,
          trending: trending,
          categories: categories,
          joined: joined,
        );
      }).toList();
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to load communities");
    }
  }

  Future<Group> getCommunityById(String communityId, {Group? fallback}) async {
    try {
      final response = await _dio.get('/social/communities/$communityId');
      final m = response.data as Map<String, dynamic>;

      final String id = (m['id'] ?? '').toString();
      final String name = (m['name'] ?? fallback?.name ?? 'Community').toString();
      final String desc = (m['description'] ?? fallback?.description ?? '').toString();
      // Prefer backend image_url, fallback to existing image if provided
      final String image = (m['image_url']?.toString().isNotEmpty == true)
          ? m['image_url'].toString()
          : (fallback?.image ?? 'https://avatar.iran.liara.run/username?username=' + Uri.encodeComponent(name));

      // Use fallback values for list-only fields not returned by details endpoint
      final int memberCount = fallback?.memberCount ?? 0;
      final bool joined = fallback?.joined ?? false;
      final int postCount = fallback?.postCount ?? 0;
      final bool trending = fallback?.trending ?? false;
      final List<String> categories = fallback?.categories ?? const [];
      final String? coverImage = fallback?.coverImage;
      final DateTime? createdAt = m['created_at'] != null
          ? DateTime.tryParse(m['created_at'].toString())
          : (fallback?.createdAt);
      final List<String>? rules = fallback?.rules;

      return Group(
        id: id,
        name: name,
        description: desc,
        memberCount: memberCount,
        postCount: postCount,
        image: image,
        trending: trending,
        categories: categories,
        joined: joined,
        coverImage: coverImage,
        createdAt: createdAt,
        rules: rules,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to load community details");
    }
  }

  Future<bool> joinCommunity(String communityId) async {
    try {
      final response = await _dio.post('/social/communities/$communityId/join');
      final data = response.data as Map<String, dynamic>;
      return data['joined'] == true;
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to join community");
    }
  }

  Future<bool> leaveCommunity(String communityId) async {
    try {
      final response = await _dio.delete('/social/communities/$communityId/join');
      final data = response.data as Map<String, dynamic>;
      return data['joined'] == false;
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to leave community");
    }
  }

  Future<List<Post>> getCommunityPosts(String communityId, {int skip = 0, int limit = 20}) async {
    try {
      final response = await _dio.get('/social/communities/$communityId/posts', queryParameters: {
        'skip': skip,
        'limit': limit,
      });
      final data = response.data as List;
      return data.map((e) => _mapBackendPostToPost(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to load community posts");
    }
  }

  Future<bool> addPostToCommunity(String communityId, String postId) async {
    try {
      final response = await _dio.post('/social/communities/$communityId/posts/$postId');
      final m = response.data as Map<String, dynamic>;
      return m['ok'] == true;
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to associate post to community");
    }
  }

  // Helper: map minimal backend post row to Post model used by UI
  Post _mapBackendPostToPost(Map<String, dynamic> m) {
    // post_type likely comes as list of strings already
    List<PostType> types = [];
    final pt = m['post_type'];
    if (pt is List) {
      types = pt.map((x) => PostType.values.firstWhere(
            (t) => t.name == (x?.toString() ?? ''),
            orElse: () => PostType.text,
          )).toList();
    }

    final author = User(
      id: (m['user_id'] ?? '').toString(),
      username: (m['username'] ?? '').toString(),
      email: '',
      role: UserRole.user,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      profile: Profile(
        id: '',
        userId: (m['user_id'] ?? '').toString(),
        displayName: (m['username'] ?? '').toString(),
        profilePictureUrl: m['profile_picture_url']?.toString(),
        bio: null,
        fitnessGoals: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Post(
      id: (m['id'] ?? '').toString(),
      userId: (m['user_id'] ?? '').toString(),
      author: author,
      content: (m['content'] ?? '').toString(),
      mediaUrl: (m['media_url'] ?? '').toString(),
      createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: m['updated_at'] != null ? DateTime.tryParse(m['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
      comments: const [],
      reacts: const [],
      commentCount: _asInt(m['comment_count']),
      reactCount: _asInt(m['react_count']),
      workoutData: null,
      challengeData: null,
      postType: types.isNotEmpty ? types : const [PostType.text],
    );
  }

  int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '0') ?? 0;
  }

  Future<User> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Assuming your backend expects /users/{user_id} for profile updates
      // If it's /profiles/{user_id}, adjust the endpoint.
      final response = await _dio.put('/users/$userId', data: data);
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to update profile");
    }
  }

  // --- Workout Plan Endpoints ---

  // Save a workout plan
  Future<Workout> saveWorkoutPlan(
    Workout workoutData,
    Map<String, dynamic> prompt,
  ) async {
    try {
      Map<String, dynamic> theData = workoutData.toJson();
      theData['prompt'] = prompt;
      debugPrint(
        "ApiService.saveWorkoutPlan: Sending data: ${workoutData.toJson()}",
      );
      final response = await _dio.post(
        '/workouts/plans/', // Endpoint for creating planned workouts
        data: theData,
      );
      debugPrint(
        "ApiService.saveWorkoutPlan: Received response status: ${response.statusCode}",
      );
      // Defensive parsing: response.data may be null or missing fields
      final raw = response.data;
      if (raw == null) {
        debugPrint(
          'ApiService.saveWorkoutPlan: Warning - response.data is null, returning original workoutData',
        );
        return workoutData;
      }

      try {
        // Normalize exercises field: if null, use empty list
        if (raw is Map<String, dynamic>) {
          raw['exercises'] = raw['exercises'] ?? [];
        }

        return Workout.fromJson(raw as Map<String, dynamic>);
      } catch (e, st) {
        debugPrint(
          'ApiService.saveWorkoutPlan: Error parsing response into Workout: $e',
        );
        debugPrint('ApiService.saveWorkoutPlan: Stacktrace: $st');
        // If parsing fails, return the original workoutData to avoid breaking the flow
        return workoutData;
      }
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to save workout plan");
    }
  }

  // Fetch workout plans for the current user
  Future<List<Workout>> getWorkoutPlans({int skip = 0, int limit = 20}) async {
    try {
      debugPrint(
        "ApiService: Attempting to fetch workout plans from /workouts/plans/history with skip=$skip, limit=$limit",
      );
      final response = await _dio.get(
        '/workouts/plans/history', // Endpoint for fetching planned workouts
        queryParameters: {'skip': skip, 'limit': limit},
      );
      debugPrint(
        "ApiService: Successfully fetched workout plans. Status: ${response.statusCode}",
      );
      return (response.data as List)
          .map((json) => Workout.fromJson(json))
          .toList();
    } on DioException catch (e) {
      debugPrint("ApiService: DioException in getWorkoutPlans: ${e.message}");
      throw _handleDioError(e, "Failed to fetch workout plans");
    } catch (e) {
      debugPrint("ApiService: Unexpected error in getWorkoutPlans: $e");
      rethrow;
    }
  }

  // Fetch a single workout plan by ID
  Future<Workout?> getWorkoutPlanDetails(String workoutId) async {
    try {
      final response = await _dio.get(
        '/workouts/plans/$workoutId/', // Endpoint for fetching a single planned workout
      );
      if ((response.statusCode! >= 200 && response.statusCode! < 300) &&
          response.data != null) {
        return Workout.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint("Workout plan $workoutId not found.");
        return null;
      }
      throw _handleDioError(e, "Failed to fetch workout plan details");
    }
  }

  // --- End of Workout Plan Endpoints ---

  // --- Completed Workout Session Endpoints ---

  // Save a completed workout session
  Future<CompletedWorkout> saveWorkoutSession(
    CompletedWorkout workoutData,
  ) async {
    try {
      debugPrint(
        "ApiService.saveWorkoutSession: Sending data: ${workoutData.toJson()}",
      );
      final response = await _dio.post(
        '/workouts/sessions', // Endpoint for completed workout sessions
        data: workoutData.toJson(),
      );
      debugPrint(
        "ApiService.saveWorkoutSession: Received response status: ${response.statusCode}",
      );
      debugPrint(
        "ApiService.saveWorkoutSession: Received response data raw: ${response.data}",
      );

      if ((response.statusCode! >= 200 && response.statusCode! < 300)) {
        if (response.data == null) {
          debugPrint(
            "ApiService.saveWorkoutSession: Error - Response data is null for status ${response.statusCode}.",
          );
          throw Exception(
            "Failed to save workout session: Server returned empty response for status ${response.statusCode}.",
          );
        }
        try {
          final parsedData = CompletedWorkout.fromJson(
            response.data as Map<String, dynamic>,
          );
          debugPrint(
            "ApiService.saveWorkoutSession: Successfully parsed response data.",
          );
          return parsedData;
        } catch (e, stackTrace) {
          debugPrint(
            "ApiService.saveWorkoutSession: Error parsing response data: $e. Stacktrace: $stackTrace. Raw data: ${response.data}",
          );
          throw Exception(
            "Failed to save workout session: Could not parse server response. Error: $e",
          );
        }
      } else {
        debugPrint(
          "ApiService.saveWorkoutSession: Received unexpected status code ${response.statusCode}. Body: ${response.data}",
        );
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error:
              "Server returned unexpected status code ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      debugPrint(
        "ApiService.saveWorkoutSession: DioException caught: ${e.message}",
      );
      debugPrint(
        "ApiService.saveWorkoutSession: DioException response data: ${e.response?.data}",
      );
      throw _handleDioError(e, "Failed to save workout session (DioException)");
    } catch (e) {
      debugPrint("ApiService.saveWorkoutSession: General exception caught: $e");
      throw e.toString();
    }
  }

  // Fetch workout history for the current user
  Future<List<CompletedWorkout>> getWorkoutHistory({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      debugPrint(
        "ApiService: Attempting to fetch workout history from /workouts/history with skip=$skip, limit=$limit",
      );
      final response = await _dio.get(
        '/workouts/history',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      debugPrint(
        "ApiService: Successfully fetched workout history. Status: ${response.statusCode}",
      );
      return (response.data as List)
          .map((json) => CompletedWorkout.fromJson(json))
          .toList();
    } on DioException catch (e) {
      debugPrint("ApiService: DioException in getWorkoutHistory: ${e.message}");
      throw _handleDioError(e, "Failed to fetch workout history");
    } catch (e) {
      debugPrint("ApiService: Unexpected error in getWorkoutHistory: $e");
      rethrow;
    }
  }

  // Fetch details for a specific completed workout session
  Future<CompletedWorkout?> getWorkoutSessionDetails(String sessionId) async {
    try {
      final response = await _dio.get('/workouts/sessions/$sessionId');
      if ((response.statusCode! >= 200 && response.statusCode! < 300) &&
          response.data != null) {
        return CompletedWorkout.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint("Completed workout session $sessionId not found.");
        return null;
      }
      throw _handleDioError(
        e,
        "Failed to fetch completed workout session details",
      );
    }
  }

  // --- End of Completed Workout Session Endpoints ---

  // --- Meal Plan Endpoints ---

  // Save a meal plan
  Future<MealPlan> saveMealPlan(MealPlan mealPlanData) async {
    try {
      debugPrint(
        "ApiService.saveMealPlan: Sending data: ${mealPlanData.toJson()}",
      );
      final response = await _dio.post(
        '/meal_plans', // Endpoint for creating meal plans
        data: mealPlanData.toJson(),
      );
      debugPrint(
        "ApiService.saveMealPlan: Received response status: ${response.statusCode}",
      );
      return MealPlan.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to save meal plan");
    }
  }

  // Fetch meal plans for the current user
  Future<List<MealPlan>> getMealPlans({int skip = 0, int limit = 20}) async {
    try {
      debugPrint(
        "ApiService: Attempting to fetch meal plans from /meal_plans/history with skip=$skip, limit=$limit",
      );
      final response = await _dio.get(
        '/meal_plans/history', // Endpoint for fetching meal plans
        queryParameters: {'skip': skip, 'limit': limit},
      );
      debugPrint(
        "ApiService: Successfully fetched meal plans. Status: ${response.statusCode}",
      );
      return (response.data as List)
          .map((json) => MealPlan.fromJson(json))
          .toList();
    } on DioException catch (e) {
      debugPrint("ApiService: DioException in getMealPlans: ${e.message}");
      throw _handleDioError(e, "Failed to fetch meal plans");
    } catch (e) {
      debugPrint("ApiService: Unexpected error in getMealPlans: $e");
      rethrow;
    }
  }

  // Fetch details for a specific meal plan
  Future<MealPlan?> getMealPlanDetails(String mealPlanId) async {
    try {
      final response = await _dio.get(
        '/meal_plans/$mealPlanId', // Endpoint for fetching a single meal plan
      );
      if ((response.statusCode! >= 200 && response.statusCode! < 300) &&
          response.data != null) {
        return MealPlan.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint("Meal plan $mealPlanId not found.");
        return null;
      }
      throw _handleDioError(e, "Failed to fetch meal plan details");
    }
  }

  // --- End of Meal Plan Endpoints ---

  // --- Nutrition Endpoints ---

  Future<List<dynamic>> getFoodLogs({int skip = 0, int limit = 100}) async {
    try {
      final response = await _dio.get(
        '/nutrition/food_logs',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      return response.data; // Assuming backend returns list of maps
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to fetch food logs");
    }
  }

  Future<dynamic> createFoodLog(Map<String, dynamic> foodLogData) async {
    try {
      print("Creating food log with data: $foodLogData");
      final response = await _dio.post(
        '/nutrition/food_logs',
        data: foodLogData,
      );
      return response.data;
    } on DioException catch (e) {
      print("DioException caught: ${e.message}");
      throw _handleDioError(e, "Failed to create food log");
    }
  }

  Future<List<dynamic>> getHealthLogs({int skip = 0, int limit = 100}) async {
    try {
      final response = await _dio.get(
        '/nutrition/health_logs',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      return response.data; // Assuming backend returns list of maps
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to fetch health logs");
    }
  }

  Future<dynamic> createHealthLog(Map<String, dynamic> healthLogData) async {
    try {
      final response = await _dio.post(
        '/nutrition/health_logs',
        data: healthLogData,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to create health log");
    }
  }

  Future<List<dynamic>> getDietRecommendations({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/nutrition/diet_recommendations',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      return response.data; // Assuming backend returns list of maps
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to fetch diet recommendations");
    }
  }

  // --- End of Nutrition Endpoints ---

  // --- Profile Endpoints (Example, assuming /profiles/{user_id}) ---
  // Future<ProfileModel> getProfile(String userId) async { ... }
  // Future<ProfileModel> updateProfile(String userId, Map<String, dynamic> data) async { ... }

  // --- Post Endpoints (Example) ---
  Future<String> uploadFile(File file) async {
    // This is a placeholder for actual file upload logic.
    // In a real application, you would upload the file to a storage service
    // (e.g., Firebase Storage, AWS S3, or your own backend endpoint)
    // and return the URL of the uploaded file.
    // For now, we'll just return a dummy URL or the local path.
    debugPrint("Simulating file upload for: ${file.path}");
    // Example of a real upload (requires a backend endpoint that accepts file uploads):
    /*
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });
      final response = await _dio.post('/upload', data: formData); // Assuming /upload is your endpoint
      if (response.statusCode == 200 && response.data != null && response.data['url'] != null) {
        return response.data['url'];
      } else {
        throw Exception('File upload failed: ${response.data}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to upload file");
    }
    */
    // Returning a dummy URL for demonstration purposes
    return 'https://example.com/uploaded_media/${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  Future<Post> createPost(Post post) async {
    try {
      debugPrint("ApiService.createPost: Sending data: ${post.toCreateJson()}");
      final response = await _dio.post('/posts/', data: post.toCreateJson());
      debugPrint(
        "ApiService.createPost: Received response status: ${response.statusCode}",
      );
      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to create post");
    }
  }

  Future<List<Post>> getPublicFeed({int skip = 0, int limit = 20}) async {
    try {
      debugPrint(
        "ApiService: Attempting to fetch public feed from /posts/feed/public with skip=$skip, limit=$limit",
      );
      // No token needed for this public endpoint, interceptor will handle if it adds one (which is fine)
      final response = await _dio.get(
        '/posts/feed/public',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      debugPrint(
        "ApiService: Successfully fetched public feed. Status: ${response.statusCode}",
      );
      debugPrint(
        "ApiService: Raw response data type: ${response.data.runtimeType}",
      );
      debugPrint(
        "ApiService: Raw response data length: ${response.data is List ? (response.data as List).length : 'not a list'}",
      );

      if (response.data is List) {
        final dataList = response.data as List;
        debugPrint("ApiService: Response contains ${dataList.length} items");

        // Log first few items for debugging
        for (int i = 0; i < (dataList.length > 3 ? 3 : dataList.length); i++) {
          debugPrint("ApiService: Item $i: ${dataList[i]}");
        }

        return dataList.whereType<Map<String, dynamic>>().map((json) {
          try {
            return Post.fromJson(json);
          } catch (e) {
            debugPrint("ApiService: Error parsing post JSON: $e");
            debugPrint("ApiService: Problematic JSON: $json");
            rethrow;
          }
        }).toList();
      } else {
        debugPrint(
          "ApiService: Public feed response data is not a List: ${response.data}",
        );
        throw Exception(
          "Failed to parse public feed: Unexpected response format",
        );
      }
    } on DioException catch (e) {
      debugPrint("ApiService: DioException in getPublicFeed: ${e.message}");
      throw _handleDioError(e, "Failed to fetch public feed");
    } catch (e) {
      debugPrint("ApiService: Unexpected error in getPublicFeed: $e");
      rethrow;
    }
  }

  // NOTE: _handleResponse helper was removed because it's unused. Individual
  // call sites handle response checks and parsing inline to provide better
  // diagnostics.

  String _handleDioError(DioException e, String defaultMessage) {
    String errorMessage = defaultMessage;
    if (e.response != null) {
      errorMessage = "Status: ${e.response!.statusCode}";
      if (e.response!.data != null) {
        if (e.response!.data is Map && e.response!.data['detail'] != null) {
          if (e.response!.data['detail'] is List) {
            errorMessage +=
                " - Details: " +
                (e.response!.data['detail'] as List)
                    .map((err) => err['msg'] ?? 'Validation error')
                    .join(', ');
          } else {
            errorMessage += " - Detail: ${e.response!.data['detail']}";
          }
        } else {
          errorMessage += " - Response: ${e.response!.data.toString()}";
        }
      }
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage =
          "Connection error: Check your internet connection or server availability.";
    } else {
      errorMessage = e.message ?? defaultMessage;
    }
    debugPrint("API Error: $errorMessage"); // Log the detailed error
    return errorMessage;
  }

  // --- ExerciseDB Related Methods (Using full URLs) ---

  // Methods to fetch lists (Body Parts, Equipment, Muscles)
  Future<List<String>> getBodyPartList() async {
    try {
      final response = await _dio.get('$exerciseDbBaseUrl/bodyparts');
      return (response.data as List).cast<String>();
    } catch (e) {
      debugPrint('Error fetching body part list from ExerciseDB: $e');
      rethrow;
    }
  }

  Future<List<String>> getEquipmentList() async {
    try {
      final response = await _dio.get('$exerciseDbBaseUrl/equipments');
      return (response.data as List).cast<String>();
    } catch (e) {
      debugPrint('Error fetching equipment list from ExerciseDB: $e');
      rethrow;
    }
  }

  Future<List<String>> getMuscleList() async {
    try {
      final response = await _dio.get('$exerciseDbBaseUrl/muscles');
      return (response.data as List).cast<String>();
    } catch (e) {
      debugPrint('Error fetching muscle list from ExerciseDB: $e');
      rethrow;
    }
  }

  // Methods to fetch exercises
  Future<List<Exercise>> getExercisesByBodyPartName(
    String bodyPartName, {
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '$exerciseDbBaseUrl/bodypart/$bodyPartName',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return (response.data as List)
          .map((json) => Exercise.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint(
        'Error fetching exercises by body part ($bodyPartName) from ExerciseDB: $e',
      );
      rethrow;
    }
  }

  Future<List<Exercise>> getExercisesByEquipmentName(
    String equipmentName, {
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '$exerciseDbBaseUrl/equipment/$equipmentName',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return (response.data as List)
          .map((json) => Exercise.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint(
        'Error fetching exercises by equipment ($equipmentName) from ExerciseDB: $e',
      );
      rethrow;
    }
  }

  Future<List<Exercise>> getExercisesByMuscleName(
    String muscleName, {
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '$exerciseDbBaseUrl/target/$muscleName',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return (response.data as List)
          .map((json) => Exercise.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching muscle list from ExerciseDB: $e');
      rethrow;
    }
  }

  Future<Exercise> getExerciseById(String exerciseId) async {
    try {
      final response = await _dio.get(
        '$exerciseDbBaseUrl/exercise/$exerciseId',
      );
      return Exercise.fromJson(response.data);
    } catch (e) {
      debugPrint(
        'Error fetching exercise by ID ($exerciseId) from ExerciseDB: $e',
      );
      rethrow;
    }
  }

  Future<List<Exercise>> searchExercisesByName(
    String query, {
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '$exerciseDbBaseUrl/name/$query',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return (response.data as List)
          .map((json) => Exercise.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint(
        'Error searching exercises by name ($query) from ExerciseDB: $e',
      );
      rethrow;
    }
  }

  Future<List<String>> autocompleteExerciseSearch(String query) async {
    // ExerciseDB API might not have a dedicated autocomplete endpoint.
    // You might need to implement client-side filtering or use a different API.
    // For now, returning an empty list or implementing a basic filter on fetched data.
    debugPrint(
      "Autocomplete not directly supported by ExerciseDB API endpoints used here.",
    );
    return []; // Placeholder
  }

  Future<List<Exercise>> getAllExercises({int limit = 100}) async {
    // ExerciseDB API might not have a single endpoint for all exercises.
    // You might need to fetch by body part, equipment, or target and combine.
    // Or if there's a paginated endpoint, use that.
    // For now, this is a placeholder.
    debugPrint(
      "getAllExercises not directly supported by ExerciseDB API endpoints used here.",
    );
    return []; // Placeholder
  }

  // Generic HTTP methods for other services to use
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e, "GET request failed for $path");
    }
  }

  Future<Response> post(String path, dynamic data) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e, "POST request failed for $path");
    }
  }

  Future<Response> put(String path, dynamic data) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e, "PUT request failed for $path");
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleDioError(e, "DELETE request failed for $path");
    }
  }

  // Get user profile by user ID
  Future<User> getUserProfile(String userId) async {
    try {
      debugPrint("ApiService: Fetching user profile for userId: $userId");
      final response = await _dio.get('/users/$userId');
      debugPrint(
        "ApiService: User profile response status: ${response.statusCode}",
      );
      debugPrint("ApiService: User profile response data: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to load user profile');
      }
    } on DioException catch (e) {
      debugPrint("ApiService: Error fetching user profile: ${e.message}");
      throw _handleDioError(e, "Failed to fetch user profile for user $userId");
    }
  }

  // Get post by ID with details
  Future<Post> getPostById(String postId) async {
    try {
      debugPrint("ApiService: Fetching post details for postId: $postId");
      final response = await _dio.get('/posts/$postId');
      debugPrint(
        "ApiService: Post details response status: ${response.statusCode}",
      );
      debugPrint("ApiService: Post details response data: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        return Post.fromJson(response.data);
      } else {
        throw Exception('Failed to load post details');
      }
    } on DioException catch (e) {
      debugPrint("ApiService: Error fetching post details: ${e.message}");
      throw _handleDioError(e, "Failed to fetch post details for post $postId");
    }
  }

  // Get comments for a post
  Future<List<dynamic>> getPostComments(String postId) async {
    try {
      debugPrint("ApiService: Fetching comments for postId: $postId");
      final response = await _dio.get('/posts/$postId/comments');
      debugPrint(
        "ApiService: Comments response status: ${response.statusCode}",
      );
      debugPrint("ApiService: Comments response data: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to load comments');
      }
    } on DioException catch (e) {
      debugPrint("ApiService: Error fetching comments: ${e.message}");
      throw _handleDioError(e, "Failed to fetch comments for post $postId");
    }
  }

  // Add a comment to a post
  Future<dynamic> addComment(String postId, String content) async {
    try {
      debugPrint("ApiService: Adding comment to postId: $postId");
      final response = await _dio.post(
        '/posts/$postId/comments',
        data: {'content': content},
      );
      debugPrint(
        "ApiService: Add comment response status: ${response.statusCode}",
      );
      debugPrint("ApiService: Add comment response data: ${response.data}");

      if (response.statusCode == 201 && response.data != null) {
        return response.data;
      } else {
        throw Exception('Failed to add comment');
      }
    } on DioException catch (e) {
      debugPrint("ApiService: Error adding comment: ${e.message}");
      throw _handleDioError(e, "Failed to add comment to post $postId");
    }
  }
}
