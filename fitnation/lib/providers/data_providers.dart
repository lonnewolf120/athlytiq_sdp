import 'package:fitnation/models/PostModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/models/Community.dart';
// import 'package:fitnation/models/RideActivity.dart'; // Assuming RideActivity is the Ride class
import 'package:fitnation/models/User.dart';
import 'package:fitnation/models/Workout.dart'; // Import Workout model
import 'package:fitnation/models/CompletedWorkout.dart'; // Import CompletedWorkout model

import 'package:dio/dio.dart'; // Import Dio
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage
import 'package:fitnation/api/API_Services.dart'; // Import your ApiService
// Import other models as needed (User, CompletedWorkout, Community, etc.)
import 'package:equatable/equatable.dart'; // Added Equatable

import 'package:fitnation/models/ProfileModel.dart';
import 'package:fitnation/api/meal_api_service.dart'; // Import MealApiService
import 'package:fitnation/services/nutrition_ai_service.dart'; // Import NutritionAIService
import 'package:fitnation/services/food_database_service.dart'; // Import FoodDatabaseService

import 'package:fitnation/services/database_helper.dart'; // Import DatabaseHelper
import 'package:fitnation/services/connectivity_service.dart'; // Import ConnectivityService
// Removed: import 'package:fitnation/providers/gemini_workout_provider.dart'; // Import geminiServiceProvider

final apiServiceProvider = Provider<ApiService>(
  (ref) => ApiService(Dio(), const FlutterSecureStorage()),
  // Pass only ref to ApiService
);

final mealApiServiceProvider = Provider<MealApiService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MealApiService(apiService);
});

final nutritionAiServiceProvider = Provider<NutritionAIService>((ref) {
  return NutritionAIService();
});

final foodDatabaseServiceProvider = Provider<FoodDatabaseService>((ref) {
  return FoodDatabaseService();
});

// Removed: Expose the geminiServiceProvider from gemini_workout_provider.dart
// Removed: final geminiApiServiceProvider = geminiServiceProvider;

// --- ExerciseDB Related Providers ---

// --- Add your other providers here (User, CompletedWorkouts, Community, etc.) ---
// Example:
// final currentUserProvider = FutureProvider<User>((ref) => ref.watch(apiServiceProvider).getCurrentUser());
// final userCompletedWorkoutsProvider = FutureProvider.family<List<CompletedWorkout>, Map<String, String>>((ref, filters) => ref.watch(apiServiceProvider).getCompletedWorkoutsForUser(filters['userId']!, typeFilter: filters['type'], timeFilter: filters['time']));
// etc.

//------------------------------ MOCK DATA -----------------------------------------------
final _mockUsers = [
  User(
    id: "adsdaavqf-ad-afa-a-fafasa",
    username: 'alexasmith',
    email: 'alexa.smith@example.com',
    role: UserRole.user,
    createdAt: DateTime(2023, 1, 10, 9, 0),
    updatedAt: DateTime(2024, 6, 1, 12, 0),
    profile: Profile(
      id: "profile-1",
      userId: "adsdaavqf-ad-afa-a-fafasa",
      displayName: 'Alexa Smith',
      profilePictureUrl:
          'https://avatar.iran.liara.run/username?username=Alexa+Smith',
      bio: 'Cyclist & fitness enthusiast.',
      fitnessGoals: null,
      createdAt: DateTime(2023, 1, 10, 9, 0),
      updatedAt: DateTime(2024, 6, 1, 12, 0),
    ),
  ),
  User(
    id: "bencarter-uid-123",
    username: 'bencarter',
    email: 'ben.carter@example.com',
    role: UserRole.trainer,
    createdAt: DateTime(2022, 11, 5, 14, 30),
    updatedAt: DateTime(2024, 5, 20, 10, 0),
    profile: Profile(
      id: "profile-2",
      userId: "bencarter-uid-123",
      displayName: 'Ben Carter',
      profilePictureUrl:
          'https://avatar.iran.liara.run/username?username=Ben+Carter',
      bio: 'Mountain bike coach.',
      fitnessGoals: null,
      createdAt: DateTime(2022, 11, 5, 14, 30),
      updatedAt: DateTime(2024, 5, 20, 10, 0),
    ),
  ),
  User(
    id: "lauradavis-uid-456",
    username: 'lauradavis',
    email: 'laura.davis@example.com',
    role: UserRole.user,
    createdAt: DateTime(2023, 3, 18, 8, 15),
    updatedAt: DateTime(2024, 6, 2, 16, 0),
    profile: Profile(
      id: "profile-3",
      userId: "lauradavis-uid-456",
      displayName: 'Laura Davis',
      profilePictureUrl:
          'https://avatar.iran.liara.run/username?username=Laura+Davis',
      bio: 'Urban cycling lover.',
      fitnessGoals: null,
      createdAt: DateTime(2023, 3, 18, 8, 15),
      updatedAt: DateTime(2024, 6, 2, 16, 0),
    ),
  ),
  User(
    id: "mikejohnson-uid-789",
    username: 'mikejohnson',
    email: 'mike.johnson@example.com',
    role: UserRole.admin,
    createdAt: DateTime(2021, 7, 22, 19, 45),
    updatedAt: DateTime(2024, 6, 3, 9, 0),
    profile: Profile(
      id: "profile-4",
      userId: "mikejohnson-uid-789",
      displayName: 'Mike Johnson',
      profilePictureUrl:
          'https://avatar.iran.liara.run/username?username=Mike+Johnson',
      bio: 'App admin & gravel rider.',
      fitnessGoals: null,
      createdAt: DateTime(2021, 7, 22, 19, 45),
      updatedAt: DateTime(2024, 6, 3, 9, 0),
    ),
  ),
  User(
    id: "sarahlee-uid-321",
    username: 'sarahlee',
    email: 'sarah.lee@example.com',
    role: UserRole.user,
    createdAt: DateTime(2022, 9, 12, 11, 0),
    updatedAt: DateTime(2024, 5, 28, 13, 0),
    profile: Profile(
      id: "profile-5",
      userId: "sarahlee-uid-321",
      displayName: 'Sarah Lee',
      profilePictureUrl:
          'https://avatar.iran.liara.run/username?username=Sarah+Lee',
      bio: 'Trail explorer.',
      fitnessGoals: null,
      createdAt: DateTime(2022, 9, 12, 11, 0),
      updatedAt: DateTime(2024, 5, 28, 13, 0),
    ),
  ),
  User(
    id: "davidwilliams-uid-654",
    username: 'davidwilliams',
    email: 'david.williams@example.com',
    role: UserRole.user,
    createdAt: DateTime(2023, 2, 8, 15, 30),
    updatedAt: DateTime(2024, 6, 1, 17, 0),
    profile: Profile(
      id: "profile-6",
      userId: "davidwilliams-uid-654",
      displayName: 'David Williams',
      profilePictureUrl:
          'https://avatar.iran.liara.run/username?username=David+Williams',
      bio: 'Commuter and weekend warrior.',
      fitnessGoals: null,
      createdAt: DateTime(2023, 2, 8, 15, 30),
      updatedAt: DateTime(2024, 6, 1, 17, 0),
    ),
  ),
];

// List<Post> _mockPosts = [
//   Post(
//     id: 'p_workout_1',
//     userId: _mockUsers[0].id,
//     author: _mockUsers[0],
//     postType: [PostType.workout],
//     createdAt: DateTime.now().subtract(const Duration(hours: 2)),
//     updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
//     reactCount: 42,
//     commentCount: 8,
//     workoutData: WorkoutPostData(
//       workoutType: 'Strength Training',
//       durationMinutes: 45,
//       caloriesBurned: 320,
//       exercises: [
//         Exercise(
//           exerciseId: 'bench-press',
//           name: 'Bench Press',
//           bodyParts: ['chest'],
//           equipments: ['barbell'],
//           targetMuscles: ['pectorals'],
//           secondaryMuscles: [],
//           instructions: [],
//           gifUrl: '',
//           sets: '10',
//           reps: '4',
//           weight: '10kg',
//         ),
//         Exercise(
//           exerciseId: 'squats',
//           name: 'Squats',
//           bodyParts: ['legs'],
//           equipments: ['barbell'],
//           targetMuscles: ['quadriceps'],
//           secondaryMuscles: [],
//           instructions: [],
//           gifUrl: '',
//           sets: '10',
//           reps: '4',
//           weight: '10kg',
//         ),
//         Exercise(
//           exerciseId: 'deadlifts',
//           name: 'Deadlifts',
//           bodyParts: ['back'],
//           equipments: ['barbell'],
//           targetMuscles: ['glutes'],
//           secondaryMuscles: [],
//           instructions: [],
//           gifUrl: '',
//           sets: '10',
//           reps: '4',
//           weight: '10kg',
//         ),
//         Exercise(
//           exerciseId: 'pull-ups',
//           name: 'Pull-ups',
//           bodyParts: ['back'],
//           equipments: ['body weight'],
//           targetMuscles: ['lats'],
//           secondaryMuscles: [],
//           instructions: [],
//           gifUrl: '',
//           sets: '10',
//           reps: '4',
//           weight: '10kg',
//         ),
//       ],
//       notes: null,
//     ),
//   ),
//   Post(
//     id: 'p_challenge_1',
//     userId: _mockUsers[1].id,
//     author: _mockUsers[1],
//     postType: [PostType.challenge],
//     createdAt: DateTime.now().subtract(const Duration(hours: 3)),
//     updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
//     reactCount: 152,
//     commentCount: 12,
//     challengeData: ChallengePostData(
//       title: '10K Steps Challenge',
//       description:
//           'Complete 10,000 steps every day for a week! Join us and boost your cardiovascular health.',
//       startDate: DateTime(2024, 5, 25),
//       durationDays: 7,
//       coverImageUrl:
//           'https://images.unsplash.com/photo-1543946207-39bd91e70c48?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8c3RlcHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
//       participantCount: 24,
//     ),
//   ),
//   // Standard Text Post (Similar to original example)
//   Post(
//     id: 'p_text_1',
//     userId: _mockUsers[2].id,
//     author: _mockUsers[2],
//     postType: [PostType.text],
//     content:
//         'Just hit a new personal record on my deadlift! 💪 Feeling stronger every day. What\'s your recent fitness win?',
//     createdAt: DateTime.now().subtract(const Duration(hours: 5)),
//     updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
//     reactCount: 88,
//     commentCount: 15,
//   ),
//   Post(
//     id: 'p_text_2',
//     userId: _mockUsers[3].id,
//     author: _mockUsers[3],
//     postType: [PostType.text],
//     content: 'Great workout today! Feeling energized. #fitness #motivation',
//     mediaUrl:
//         'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8Zml0bmVzc3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=500&q=60',
//     createdAt: DateTime.now().subtract(const Duration(days: 1)),
//     updatedAt: DateTime.now().subtract(const Duration(days: 1)),
//     reactCount: 230,
//     commentCount: 35,
//   ),
//   // Another Workout Post
//   Post(
//     id: 'p_workout_2',
//     userId: _mockUsers[4].id,
//     author: _mockUsers[4],
//     postType: [PostType.workout],
//     createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
//     updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
//     reactCount: 95,
//     commentCount: 10,
//     workoutData: WorkoutPostData(
//       workoutType: 'HIIT Cardio',
//       durationMinutes: 30,
//       caloriesBurned: 450,
//       exercises: [
//         Exercise(
//           exerciseId: 'burpees',
//           name: 'Burpees',
//           bodyParts: ['legs'],
//           equipments: ['body weight'],
//           targetMuscles: ['quadriceps'],
//           secondaryMuscles: [],
//           instructions: [],
//           gifUrl: '',
//           sets: '3',
//           reps: '10'
//         ),
//         Exercise(
//           exerciseId: 'mountain-climbers',
//           name: 'Mountain Climbers',
//           bodyParts: ['legs'],
//           equipments: ['body weight'],
//           targetMuscles: ['quadriceps'],
//           secondaryMuscles: [],
//           instructions: [],
//           gifUrl: '',
//         ),
//         Exercise(
//           exerciseId: 'jump-squats',
//           name: 'Jump Squats',
//           bodyParts: ['legs'],
//           equipments: ['body weight'],
//           targetMuscles: ['quadriceps'],
//           secondaryMuscles: [],
//           instructions: [],
//           gifUrl: '',
//           sets: '4',
//           reps: '12',
//           weight: '10kg'
//         ),
//         Exercise(
//           exerciseId: 'plank',
//           name: 'Plank',
//           bodyParts: ['core'],
//           equipments: ['body weight'],
//           targetMuscles: ['abs'],
//           secondaryMuscles: [],
//           instructions: [],
//           gifUrl: '',
//           sets: '3',
//           reps: '10'

//         ),
//       ],
//       notes: null,
//     ),
//   ),

//   // ... add more dummy posts of different types
// ];

// // Export _mockPosts for use in other files
// List<Post> get mockPosts => _mockPosts;

final mockCommunitiesProvider = Provider<List<Community>>((ref) {
  return [
    Community(
      id: 'c1',
      creatorUserId: _mockUsers[0].id, // Example creator
      creator: _mockUsers[0],
      name: 'Local Cycling Club',
      imageUrl: 'assets/images/community_club.jpg',
      description: 'The main cycling club for enthusiasts in the area.',
      isPrivate: false,
      memberCount: 250,
      members: [
        _mockUsers[0],
        _mockUsers[1],
        _mockUsers[3],
        _mockUsers[4],
        _mockUsers[5],
      ]..shuffle(), // Use 'members' and shuffle for variety
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Community(
      id: 'c2',
      creatorUserId: _mockUsers[1].id, // Example creator
      creator: _mockUsers[1],
      name: 'Trail Riding Enthusiasts',
      imageUrl: 'assets/images/community_trail.jpg',
      description: 'For those who love mountain biking and off-road trails.',
      isPrivate: false,
      memberCount: 180,
      members: [_mockUsers[1], _mockUsers[2], _mockUsers[5], _mockUsers[4]]
        ..shuffle(), // Use 'members' and shuffle for variety
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Community(
      id: 'c3',
      creatorUserId: _mockUsers[2].id, // Example creator
      creator: _mockUsers[2],
      name: 'Urban Commuters Group',
      imageUrl: 'assets/images/community_urban.jpg',
      description: 'Daily commuters and city riders sharing tips and routes.',
      isPrivate: false,
      memberCount: 320,
      members: [
        _mockUsers[0],
        _mockUsers[3],
        _mockUsers[4],
        _mockUsers[5],
        _mockUsers[2],
        _mockUsers[1],
      ]..shuffle(), // Use 'members' and shuffle for variety
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];
});

final currentUserProvider = FutureProvider<User>((ref) async {
  // Fetch the current user from the backend using the ApiService
  try {
    return await ref.watch(apiServiceProvider).getCurrentUser();
  } on NoInternetException catch (e) {
    throw Exception(
      e.message,
    ); // Re-throw as a generic Exception for FutureProvider to catch
  }
});

// final _mockPostReacts = [
//   PostReact(
//     postId: _mockPosts[0].id,
//     userId: _mockUsers[0].id, // Alexa reacts to post1
//     createdAt: DateTime.now().subtract(const Duration(hours: 3)),
//     reactType: 'like',
//     emoji: '👍',
//   ),
//   PostReact(
//     postId: _mockPosts[1].id,
//     userId: _mockUsers[2].id, // Laura reacts to post1
//     createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
//     reactType: 'love',
//     emoji: '❤️',
//   ),
//   PostReact(
//     postId: _mockPosts[2].id,
//     userId: _mockUsers[1].id, // Ben reacts to post2
//     createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
//     reactType: 'like',
//     emoji: '👍',
//   ),
//   PostReact(
//     postId: _mockPosts[3].id,
//     userId: _mockUsers[3].id, // Mike reacts to post2
//     createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
//     reactType: 'haha',
//     emoji: '😂',
//   ),
//   PostReact(
//     postId: _mockPosts[4].id,
//     userId: _mockUsers[5].id, // David reacts to post3
//     createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
//     reactType: 'like',
//     emoji: '👍',
//   ),
// ];

// final _mockPostComments = [
//   PostComment(
//     id: 'comm1',
//     postId: _mockPosts[0].id,
//     userId: _mockUsers[3].id, // Mike comments on post1
//     content: 'Awesome ride, Alexa! Where is this?',
//     createdAt: DateTime.now().subtract(const Duration(hours: 2)),
//     updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
//   ),
//   PostComment(
//     id: 'comm2',
//     postId: _mockPosts[1].id,
//     userId: _mockUsers[0].id, // Alexa comments on post2
//     content: 'Looks epic, Ben! Wish I could join!',
//     createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
//     updatedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
//   ),
//   PostComment(
//     id: 'comm3',
//     postId: _mockPosts[2].id,
//     userId: _mockUsers[1].id, // Ben comments on post3
//     content: 'Great scenery!',
//     createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
//     updatedAt: DateTime.now().subtract(const Duration(minutes: 40)),
//   ),
// ];

// final mockPostsProvider = Provider<List<Post>>((ref) {
//   return _mockPosts;
// });

// final mockPostReactsProvider = Provider<List<PostReact>>((ref) {
//   return _mockPostReacts;
// });

// final mockPostCommentsProvider = Provider<List<PostComment>>((ref) {
//   return _mockPostComments;
// });

// --- Workout Related Providers (Using ApiService) ---

// Provider for fetching the list of workout plans for the current user
final workoutPlansProvider = FutureProvider<List<Workout>>((ref) async {
  // Assuming ApiService has a method like getWorkoutPlans()
  // The backend endpoint now handles user association via token
  try {
    return await ref.watch(apiServiceProvider).getWorkoutPlans();
  } on NoInternetException catch (e) {
    throw Exception(e.message);
  }
});

// Provider to fetch a single workout plan by ID
final workoutPlanDetailProvider = FutureProvider.family<Workout?, String>((
  ref,
  workoutId,
) async {
  // Assuming ApiService has a method like getWorkoutPlanDetails()
  try {
    return await ref.watch(apiServiceProvider).getWorkoutPlanDetails(workoutId);
  } on NoInternetException catch (e) {
    throw Exception(e.message);
  }
});

// Provider to fetch completed workouts for the current user with filters
// This replaces the dummy userCompletedWorkoutsProvider in WorkoutHistoryScreen.dart

// Define a class for filters to ensure proper equality checks by Riverpod's .family
class WorkoutHistoryFilters extends Equatable {
  final String
  userId; // Kept for potential future use or if provider logic changes
  final String workoutType;
  final String timeRange;
  final int skip;
  final int limit;

  const WorkoutHistoryFilters({
    required this.userId,
    required this.workoutType,
    required this.timeRange,
    this.skip = 0,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [userId, workoutType, timeRange, skip, limit];
}

final completedWorkoutsProvider = FutureProvider.family<
  List<CompletedWorkout>,
  WorkoutHistoryFilters
>((ref, filters) async {
  final apiService = ref.watch(apiServiceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final db = DatabaseHelper();

  // Require a userId for user-specific history
  if (filters.userId.isEmpty) return [];

  // Load local workouts first (offline-first)
  List<CompletedWorkout> localWorkouts = await db.getCompletedWorkouts(
    filters.userId,
  );

  // If we have internet, try to sync unsynced local workouts and merge remote entries
  bool online = false;
  try {
    online = await connectivity.hasInternetConnection();
  } catch (e) {
    online = false;
  }

  if (online) {
    // Sync unsynced workouts to server
    try {
      final unsynced = await db.getUnsyncedWorkouts(filters.userId);
      for (var w in unsynced) {
        try {
          await apiService.saveWorkoutSession(w);
          await db.updateWorkoutSyncedStatus(w.id, true);
        } catch (e) {
          // keep unsynced if upload fails for any workout
        }
      }

      // Fetch remote workouts and merge any that are not present locally
      List<CompletedWorkout> remoteWorkouts = await apiService
          .getWorkoutHistory(skip: filters.skip, limit: filters.limit);
      final Map<String, CompletedWorkout> merged = {
        for (var lw in localWorkouts) lw.id: lw,
      };
      for (var rw in remoteWorkouts) {
        if (!merged.containsKey(rw.id)) merged[rw.id] = rw;
      }
      localWorkouts = merged.values.toList();
    } on NoInternetException {
      // no-op: fall back to local only
    } catch (_) {
      // ignore and return local results
    }
  }

  // Apply workoutType filter client-side (same behavior as before)
  List<CompletedWorkout> allUserWorkouts = localWorkouts;
  if (filters.workoutType != 'All Workouts') {
    allUserWorkouts =
        allUserWorkouts
            .where((w) => w.workoutName == filters.workoutType)
            .toList();
  }

  // Apply timeRange filter client-side
  DateTime now = DateTime.now();
  if (filters.timeRange == 'This Month') {
    allUserWorkouts =
        allUserWorkouts
            .where(
              (w) => w.endTime.year == now.year && w.endTime.month == now.month,
            )
            .toList();
  } else if (filters.timeRange == 'This Year') {
    allUserWorkouts =
        allUserWorkouts.where((w) => w.endTime.year == now.year).toList();
  } else if (filters.timeRange == 'Last 30 Days') {
    DateTime thirtyDaysAgo = now.subtract(const Duration(days: 30));
    allUserWorkouts =
        allUserWorkouts.where((w) => w.endTime.isAfter(thirtyDaysAgo)).toList();
  } else if (filters.timeRange == 'Last 90 Days') {
    DateTime ninetyDaysAgo = now.subtract(const Duration(days: 90));
    allUserWorkouts =
        allUserWorkouts.where((w) => w.endTime.isAfter(ninetyDaysAgo)).toList();
  }

  return allUserWorkouts;
});

final workoutTypesProvider = FutureProvider<List<String>>((ref) async {
  final workoutNames = await DatabaseHelper().getDistinctWorkoutNames();
  return ['All Workouts', ...workoutNames];
});

// Utility: Trigger a one-off sync of unsynced local workouts for a user
final syncUnsyncedWorkoutsProvider =
    Provider.family<Future<void> Function(), String>((ref, userId) {
      return () async {
        if (userId.isEmpty) return;
        final connectivity = ref.watch(connectivityServiceProvider);
        final online = await connectivity.hasInternetConnection();
        if (!online) return;
        final apiService = ref.watch(apiServiceProvider);
        final db = DatabaseHelper();
        final unsynced = await db.getUnsyncedWorkouts(userId);
        for (var w in unsynced) {
          try {
            await apiService.saveWorkoutSession(w);
            await db.updateWorkoutSyncedStatus(w.id, true);
          } catch (_) {
            // keep unsynced if upload fails
          }
        }
      };
    });

// final mockRideActivitiesProvider = Provider<List<RideActivity>>((ref) {
//   // Using a consistent organizer for simplicity, or vary by activity type
//   final benCarter = _mockUsers.firstWhere((u) => u.id == "bencarter-uid-123");
//   final mikeJohnson = _mockUsers.firstWhere((u) => u.id == "mikejohnson-uid-789");

//   return [
//     RideActivity(
//       id: 'ra1',
//       organizerUserId: benCarter.id,
//       organizer: benCarter,
//       name: 'Coastal Road Challenge',
//       imageUrl: 'assets/images/ride_coastal.jpg',
//       distanceKm: 150.0, // Updated to double
//       elevationMeters: 850, // Updated to int
//       type: RideActivityType.road, // Using the new enum
//       description:
//           'A challenging long-distance road ride along the beautiful coastline with significant climbs.',
//       participants: [
//         _mockUsers[0],
//         _mockUsers[1],
//         _mockUsers[3],
//         _mockUsers[4]
//       ], // List<User>
//       routeCoordinates: const [
//         LatLng(34.0522, -118.2437), // Los Angeles
//         LatLng(34.4208, -119.6902), // Santa Barbara
//         LatLng(35.3046, -120.6683), // San Luis Obispo area
//       ],
//       locationName: "California Coast",
//       parkName: "Pacific Coast Route",
//       startTime: DateTime.now().add(const Duration(days: 7, hours: 10)), // Example future time
//       createdAt: DateTime.now().subtract(const Duration(days: 30)),
//       updatedAt: DateTime.now().subtract(const Duration(days: 5)),
//     ),
//     RideActivity(
//       id: 'ra2',
//       organizerUserId: benCarter.id,
//       organizer: benCarter,
//       name: 'Forest Singletrack Adventure',
//       imageUrl: 'assets/images/ride_forest.jpg',
//       distanceKm: 45.0, // Updated to double
//       elevationMeters: 1200, // Updated to int
//       type: RideActivityType.mountain, // Using the new enum
//       description:
//           'Technical singletrack trails through dense forest, perfect for experienced mountain bikers.',
//       participants: [
//         _mockUsers[1],
//         _mockUsers[5],
//         _mockUsers[2]
//       ], // List<User>
//       routeCoordinates: const [
//         LatLng(47.6062, -122.3321), // Seattle area forest
//         LatLng(47.5500, -122.2500),
//         LatLng(47.5000, -122.1500),
//       ],
//       locationName: "Cascadia Forest",
//       parkName: "Green River State Park",
//       startTime: DateTime.now().add(const Duration(days: 14, hours: 14)), // Example future time
//       createdAt: DateTime.now().subtract(const Duration(days: 45)),
//       updatedAt: DateTime.now().subtract(const Duration(days: 10)),
//     ),
//     RideActivity(
//       id: 'ra3',
//       organizerUserId: mikeJohnson.id,
//       organizer: benCarter,
//       name: 'City Park Loop',
//       imageUrl: 'assets/images/ride_citypark.jpg',
//       distanceKm: 25.0, // Updated to double
//       elevationMeters: 150, // Updated to int
//       type: RideActivityType.road, // Using road for paved paths
//       description:
//           'A relaxed ride through the city parks and riverside paths. Suitable for all skill levels.',
//       participants: [
//         _mockUsers[0],
//         _mockUsers[2],
//         _mockUsers[3],
//         _mockUsers[5],
//         _mockUsers[4]
//       ], // List<User>
//       routeCoordinates: const [
//         LatLng(40.7128, -74.0060), // NYC Central Park area
//         LatLng(40.7829, -73.9654),
//         LatLng(40.7680, -73.9810),
//       ],
//       locationName: "Metropolitan Park",
//       parkName: 'City Central Park',
//       startTime: DateTime.now().subtract(const Duration(days: 2, hours: 11)), // Example past time
//       createdAt: DateTime.now().subtract(const Duration(days: 25)),
//       updatedAt: DateTime.now().subtract(const Duration(days: 1)),
//     ),
//     RideActivity(
//       id: 'ra4',
//       organizerUserId: mikeJohnson.id,
//       organizer: benCarter,
//       name: 'Gravel Grinder Plains',
//       imageUrl: 'assets/images/ride_gravel.jpg',
//       distanceKm: 90.0, // Updated to double
//       elevationMeters: 300, // Updated to int
//       type: RideActivityType.cyclocross, // Using cyclocross for gravel/mixed terrain
//       description:
//           'Explore the open plains and rolling hills on mixed gravel and dirt roads.',
//       participants: [_mockUsers[1], _mockUsers[3], _mockUsers[5]], // List<User>
//       routeCoordinates: const [
//       routeCoordinates: const [
//         LatLng(39.7392, -104.9903), // Denver area plains
//         LatLng(39.8000, -105.1000),
//         LatLng(39.7500, -105.2000),
//       ],
//       locationName: "Eastern Plains",
//       parkName: 'Highland Open Space',
//       startTime: DateTime.now().subtract(const Duration(days: 9, hours: 8)), // Example past time
//       createdAt: DateTime.now().subtract(const Duration(days: 50)),
//       updatedAt: DateTime.now().subtract(const Duration(days: 3)),
//     ),
//   ];
// });

// final mockPostsProvider = Provider<List<Post>>((ref) {
//   return _mockPosts;
// });

// final mockPostReactsProvider = Provider<List<PostReact>>((ref) {
//   return _mockPostReacts;
// });

// final mockPostCommentsProvider = Provider<List<PostComment>>((ref) {
//   return _mockPostComments;
// });

final postsFeedProvider = FutureProvider<List<Post>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  debugPrint("postsFeedProvider: Fetching posts");
  // Fetch posts from the public feed endpoint
  try {
    final posts = await apiService.getPublicFeed();
    debugPrint("postsFeedProvider: Successfully fetched ${posts.length} posts");
    return posts;
  } on NoInternetException catch (e) {
    debugPrint("postsFeedProvider: No internet exception: ${e.message}");
    throw Exception(e.message);
  } catch (e) {
    debugPrint("postsFeedProvider: Error fetching posts: $e");
    throw Exception("Failed to fetch posts: $e");
  }
});

final createPostProvider = FutureProvider.family<Post, Post>((ref, post) async {
  debugPrint("=== createPostProvider called ===");
  debugPrint("Post data: ${post.toCreateJson()}");

  final apiService = ref.watch(apiServiceProvider);
  try {
    debugPrint("Calling apiService.createPost...");
    final created = await apiService.createPost(post);
    debugPrint("Post created successfully with id: ${created.id}");
    return created;
  } on NoInternetException catch (e) {
    debugPrint("No internet exception: ${e.message}");
    throw Exception(e.message);
  } catch (e) {
    debugPrint("Error creating post: $e");
    throw Exception("Failed to create post: $e");
  }
});
