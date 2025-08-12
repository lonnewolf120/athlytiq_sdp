// lib/Screens/ProfileScreen.dart
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
// import 'package:fitnation/models/CompletedWorkoutExercise.dart'; // Now in CompletedWorkout.dart
// import 'package:fitnation/models/CompletedWorkoutSet.dart'; // Now in CompletedWorkout.dart
import 'package:fitnation/models/ProfileModel.dart';
import 'package:fitnation/models/User.dart'; // Assuming User model is here
import 'package:fitnation/models/CompletedWorkout.dart'; // Assuming CompletedWorkout model is here
import 'package:fitnation/providers/auth_provider.dart';
import 'package:fitnation/widgets/Activities/StatsCard.dart'; // Reuse StatsCard
import 'package:fitnation/widgets/Activities/WeeklyActivityChart.dart'; // Import charts
import 'package:fitnation/widgets/Activities/WorkoutDistributionChart.dart';
import 'package:fitnation/widgets/Activities/IntensityTrend.dart';
import 'package:fitnation/widgets/common/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For state management
import 'package:cached_network_image/cached_network_image.dart'; // For avatar
import 'package:image_picker/image_picker.dart'; // For picking new avatar
import 'dart:io'; // For File
import 'package:fitnation/main.dart';
import 'package:fitnation/providers/theme_provider.dart';
import 'package:fitnation/Screens/Auth/Login.dart'; // Import LoginScreen
import 'package:fitnation/providers/auth_provider.dart'
    as auth_provider; // Alias auth_provider
import 'package:fitnation/providers/data_providers.dart'
    as data_providers; // Alias data_providers

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _profileFormKey = GlobalKey<FormState>();

  // Controllers for editable fields
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _healthConditionsController;
  late TextEditingController _injuriesController;

  // Dropdown values
  String? _selectedGender;
  String? _selectedActivityLevel;
  String? _selectedFitnessGoal;
  List<String> _selectedDietaryPreferences = [];

  File? _newAvatarImage; // To hold a newly picked avatar image

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize controllers with placeholder text or default values
    // These should be populated with actual user data when fetched
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _healthConditionsController = TextEditingController();
    _injuriesController = TextEditingController();

    // Fetch initial user data and populate controllers
    ref.read(data_providers.currentUserProvider).whenData((user) {
      _fullNameController.text = user.profile?.displayName ?? user.username;
      _usernameController.text = user.username;
      _heightController.text = user.profile?.height_cm?.toString() ?? '';
      _weightController.text = user.profile?.weight_kg?.toString() ?? '';
      _healthConditionsController.text = ''; // TODO: Add to Profile model
      _injuriesController.text = ''; // TODO: Add to Profile model
      _selectedGender = user.profile?.gender;
      _selectedActivityLevel = user.profile?.activity_level;
      _selectedFitnessGoal = user.profile?.fitnessGoals;
      _selectedDietaryPreferences = []; // TODO: Add to Profile model
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _healthConditionsController.dispose();
    _injuriesController.dispose();
    super.dispose();
  }

  // --- Profile Tab Logic ---

  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _newAvatarImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfileChanges() async {
    if (_profileFormKey.currentState!.validate()) {
      _profileFormKey.currentState!
          .save(); // Save form fields (if using onSaved)

      // Check if any changes were actually made
      final currentUser = ref.read(auth_provider.currentUserProvider);
      final bool nameChanged =
          _fullNameController.text.trim() !=
          (currentUser?.profile?.displayName ?? currentUser?.username);
      final bool usernameChanged =
          _usernameController.text.trim() != (currentUser?.username ?? '');
      final bool heightChanged =
          _heightController.text.trim() !=
          (currentUser?.profile?.height_cm?.toString() ?? '');
      final bool weightChanged =
          _weightController.text.trim() !=
          (currentUser?.profile?.weight_kg?.toString() ?? '');
      final bool genderChanged =
          _selectedGender != currentUser?.profile?.gender;
      final bool activityLevelChanged =
          _selectedActivityLevel != currentUser?.profile?.activity_level;
      final bool fitnessGoalChanged =
          _selectedFitnessGoal != currentUser?.profile?.fitnessGoals;
      final bool avatarChanged = _newAvatarImage != null;
      final bool healthConditionsChanged =
          _healthConditionsController.text.trim().isNotEmpty;
      final bool injuriesChanged = _injuriesController.text.trim().isNotEmpty;
      final bool dietaryPreferencesChanged =
          _selectedDietaryPreferences.isNotEmpty;

      if (!nameChanged &&
          !usernameChanged &&
          !heightChanged &&
          !weightChanged &&
          !genderChanged &&
          !activityLevelChanged &&
          !fitnessGoalChanged &&
          !avatarChanged &&
          !healthConditionsChanged &&
          !injuriesChanged &&
          !dietaryPreferencesChanged) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No changes to save.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        return;
      }

      // Create profile update data
      final profileUpdateData = {
        if (nameChanged) 'display_name': _fullNameController.text.trim(),
        if (usernameChanged) 'username': _usernameController.text.trim(),
        if (heightChanged && _heightController.text.trim().isNotEmpty)
          'height_cm': double.tryParse(_heightController.text.trim()),
        if (weightChanged && _weightController.text.trim().isNotEmpty)
          'weight_kg': double.tryParse(_weightController.text.trim()),
        if (genderChanged) 'gender': _selectedGender,
        if (activityLevelChanged) 'activity_level': _selectedActivityLevel,
        if (fitnessGoalChanged) 'fitness_goals': _selectedFitnessGoal,
        if (healthConditionsChanged)
          'health_conditions': _healthConditionsController.text.trim(),
        if (injuriesChanged) 'injuries': _injuriesController.text.trim(),
        if (dietaryPreferencesChanged)
          'dietary_preferences': _selectedDietaryPreferences,
      };

      // TODO: Implement actual profile update logic using a provider
      // For now, just show what would be saved
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile would be updated with: ${profileUpdateData.keys.join(', ')}',
          ),
          backgroundColor: Colors.blueAccent,
        ),
      );
      print("Profile update data: $profileUpdateData");
    }
  }

  void _signOut() {
    // Call authentication provider to sign out
    ref.read(authProvider.notifier).logout();
  }

  // --- Progress Tab Logic ---

  List<WeeklyActivityData> _processWeeklyActivityData(
    List<CompletedWorkout> workouts,
  ) {
    // Group workouts by day and sum minutes for the last 7 days
    final now = DateTime.now();
    final last7Days = List.generate(
      7,
      (index) => DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - index)),
    ); // Dates for the last 7 days (Mon to Sun or Sun to Sat depending on locale)

    final Map<DateTime, double> dailyMinutes = {};
    for (var date in last7Days) {
      dailyMinutes[date] = 0.0; // Initialize with 0
    }

    for (var workout in workouts) {
      final workoutDay = DateTime(
        workout.endTime.year,
        workout.endTime.month,
        workout.endTime.day,
      );
      // Only include workouts from the last 7 days
      if (dailyMinutes.containsKey(workoutDay)) {
        dailyMinutes[workoutDay] =
            dailyMinutes[workoutDay]! + workout.duration.inMinutes;
      }
    }

    // Sort data points by date
    final processedData =
        dailyMinutes.entries
            .map(
              (entry) =>
                  WeeklyActivityData(date: entry.key, minutes: entry.value),
            )
            .toList();
    processedData.sort(
      (a, b) => a.date.compareTo(b.date),
    ); // Ensure chronological order

    return processedData;
  }

  List<WorkoutDistributionData> _processWorkoutDistributionData(
    List<CompletedWorkout> workouts,
  ) {
    // Count workouts by name/type and calculate percentages
    final Map<String, int> workoutCounts = {};
    for (var workout in workouts) {
      workoutCounts[workout.workoutName] =
          (workoutCounts[workout.workoutName] ?? 0) + 1;
    }

    final totalWorkouts = workouts.length;
    if (totalWorkouts == 0) return [];

    return workoutCounts.entries
        .map(
          (entry) => WorkoutDistributionData(
            type: entry.key,
            percentage: (entry.value / totalWorkouts) * 100,
          ),
        )
        .toList();
  }

  List<IntensityTrendData> _processIntensityTrendData(
    List<CompletedWorkout> workouts,
  ) {
    // Sort workouts by date and extract date and intensity
    final sortedWorkouts = List<CompletedWorkout>.from(workouts);
    sortedWorkouts.sort((a, b) => a.endTime.compareTo(b.endTime));

    // Limit to a reasonable number of recent workouts for the trend line
    const int maxTrendPoints = 10; // Example: show last 10 workouts
    final trendWorkouts =
        sortedWorkouts.length > maxTrendPoints
            ? sortedWorkouts.sublist(sortedWorkouts.length - maxTrendPoints)
            : sortedWorkouts;

    return trendWorkouts
        .map(
          (workout) => IntensityTrendData(
            date: workout.endTime,
            intensity: workout.intensityScore,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(
      auth_provider.authProvider,
    ); // Watch the auth state

    // Handle different authentication states
    if (authState is AuthLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (authState is Unauthenticated) {
      // If unauthenticated, navigate to LoginScreen and remove previous routes
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'You need to login or sign up to view your progress and save/sync them.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text('Login / Sign Up'),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (authState is Authenticated) {
      // If authenticated, display the ProfileScreen content
      final User currentUser = authState.user; // Get the authenticated user

      // final profileUpdateState = ref.watch(profileUpdateProvider);
      // final isSaving = profileUpdateState.isLoading;
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Profile',
          showProfileMenu:
              false, // Don't show profile menu on profile screen itself
          showMenuButton: false,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Progress'), Tab(text: 'Settings')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProgressTab(context, currentUser),
            _buildProfileTab(
              context,
              currentUser,
              isSaving: false,
            ), // Pass actual user, replace with actual data
          ],
        ),
      );
    }
    return const SizedBox.shrink(); // Fallback, should not be reached
  }

  // --- Build Methods for Tabs ---

  Widget _buildProgressTab(
    BuildContext context,
    User currentUser, // Pass currentUser to this method
  ) {
    // Handle loading/error states from providers
    final userCompletedWorkoutsAsyncValue =
        currentUser.id != null
            ? ref.watch(
              data_providers.completedWorkoutsProvider(
                data_providers.WorkoutHistoryFilters(
                  userId: currentUser.id!,
                  workoutType: 'All Workouts', // Fetch all workout types
                  timeRange: 'All Time', // Fetch all time
                ),
              ),
            )
            : const AsyncValue.data([]); // No user, no workouts

    if (userCompletedWorkoutsAsyncValue.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (userCompletedWorkoutsAsyncValue.hasError) {
      return Center(
        child: Text(
          'Error loading progress: ${userCompletedWorkoutsAsyncValue.error}',
        ),
      );
    }
    final workouts =
        userCompletedWorkoutsAsyncValue.value as List<CompletedWorkout>;
    final stats = _calculateStats(
      workouts,
    ); // Calculate stats from fetched data
    final weeklyActivityData = _processWeeklyActivityData(workouts);
    final workoutDistributionData = _processWorkoutDistributionData(workouts);
    final intensityTrendData = _processIntensityTrendData(workouts);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0), // Section padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards (Reuse GridView layout from WorkoutHistoryScreen)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.5,
            children: [
              StatsCard(
                icon: Icons.fitness_center_outlined,
                label: 'Workouts',
                value: '${stats['totalWorkouts']}',
              ),
              StatsCard(
                icon: Icons.access_time_outlined,
                label: 'Total Minutes',
                value: '${stats['totalMinutes']}',
              ),
              StatsCard(
                icon: Icons.local_fire_department_outlined,
                label: 'Avg Intensity',
                value: stats['avgIntensity'].toStringAsFixed(1),
                iconColor: AppColors.primary,
              ),
              StatsCard(
                icon: Icons.emoji_events_outlined,
                label: 'Day Streak',
                value: '${stats['dayStreak']}',
                iconColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 24), // Margin between sections
          // Weekly Activity Chart
          WeeklyActivityChart(data: weeklyActivityData),
          const SizedBox(height: 24),

          // Workout Distribution Chart
          WorkoutDistributionChart(data: workoutDistributionData),
          const SizedBox(height: 24),

          // Intensity Trend Chart
          IntensityTrendChart(data: intensityTrendData),
          const SizedBox(height: 24),

          // TODO: Add other charts/graphs here
          // Example: Volume Trend (Total weight lifted over time)
          // Example: Exercise PRs (Personal Records)
        ],
      ),
    );
  }

  Widget _buildProfileTab(
    BuildContext context,
    User user, {
    required bool isSaving,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final currentAppThemeMode =
        ref.watch(themeNotifierProvider.notifier).currentAppThemeMode;
    // debugPrint("User profile: ${user.profile!.profilePictureUrl ?? ''}");
    // debugPrint("${user.profile}");
    // TODO: Handle loading/error states from providers
    // final currentUserAsyncValue = ref.watch(currentUserProvider);
    // if (currentUserAsyncValue.isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    // if (currentUserAsyncValue.hasError) {
    //   return Center(child: Text('Error loading profile: ${currentUserAsyncValue.error}'));
    // }
    // final user = currentUserAsyncValue.value!; // Get the actual user data

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0), // Section padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center avatar and name
        children: [
          // Avatar Section
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.mutedBackground,
                backgroundImage:
                    _newAvatarImage != null
                        ? FileImage(_newAvatarImage!)
                            as ImageProvider // Use new image if picked
                        : ((user.profile != null &&
                                user.profile!.profilePictureUrl != null)
                            ? CachedNetworkImageProvider(
                              user.profile!.profilePictureUrl!,
                            )
                            : CachedNetworkImageProvider(
                              user.avatarUrl,
                            )), // Use existing URL if available
                child:
                    _newAvatarImage == null &&
                            (user.profile == null ||
                                user.profile!.profilePictureUrl == null)
                        ? Icon(
                          Icons.person_outline,
                          size: 50,
                          color: AppColors.mutedForeground,
                        ) // Default icon
                        : null,
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  // Make camera icon tappable
                  onTap:
                      isSaving ? null : _pickAvatarImage, // Disable if saving
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        AppColors.primary, // Red background for camera icon
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            (user.profile != null && user.profile!.displayName != null)
                ? user.profile!.displayName!
                : user.username,
            style: AppTextStyles.headlineMedium?.copyWith(
              color: AppColors.foreground,
            ),
          ),
          Text(
            '@${user.username ?? 'nousername'}',
            style: AppTextStyles.bodyMedium?.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 24), // Margin before form card
          // Account Information Card
          Card(
            margin: EdgeInsets.zero, // No margin needed for this card
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Card padding
              child: Form(
                key: _profileFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Information',
                      style: AppTextStyles.headlineSmall?.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email Field (Read-only)
                    Text(
                      'Email',
                      style: AppTextStyles.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue:
                          user.email ??
                          'N/A', // Assuming email is in User model
                      readOnly: true,
                      decoration: InputDecoration(
                        // Use theme's input decoration, but maybe no border for readOnly
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor:
                            AppColors
                                .mutedBackground, // Slightly different background for read-only
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      style: AppTextStyles.bodyMedium?.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Email cannot be changed',
                      style: AppTextStyles.labelSmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Full Name Field (Editable)
                    Text(
                      'Full Name',
                      style: AppTextStyles.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your full name',
                      ),
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name cannot be empty';
                        }
                        return null;
                      },
                      enabled: !isSaving, // Disable while saving
                    ),
                    const SizedBox(height: 16),

                    // Username Field (Editable)
                    Text(
                      'Username',
                      style: AppTextStyles.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your username',
                      ),
                      keyboardType: TextInputType.text,
                      // Add input formatter for username format if needed
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username cannot be empty';
                        }
                        // TODO: Add username format validation (e.g., no spaces, allowed characters)
                        return null;
                      },
                      enabled: !isSaving, // Disable while saving
                    ),
                    const SizedBox(height: 24),

                    // Physical Information Section
                    Text(
                      'Physical Information',
                      style: AppTextStyles.headlineSmall?.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Height and Weight Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Height (cm)',
                                style: AppTextStyles.bodyMedium?.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _heightController,
                                decoration: const InputDecoration(
                                  hintText: '170',
                                  suffixText: 'cm',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final height = double.tryParse(value);
                                    if (height == null ||
                                        height <= 0 ||
                                        height > 300) {
                                      return 'Enter valid height';
                                    }
                                  }
                                  return null;
                                },
                                enabled: !isSaving,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weight (kg)',
                                style: AppTextStyles.bodyMedium?.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _weightController,
                                decoration: const InputDecoration(
                                  hintText: '70',
                                  suffixText: 'kg',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final weight = double.tryParse(value);
                                    if (weight == null ||
                                        weight <= 0 ||
                                        weight > 500) {
                                      return 'Enter valid weight';
                                    }
                                  }
                                  return null;
                                },
                                enabled: !isSaving,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Gender Dropdown
                    Text(
                      'Gender',
                      style: AppTextStyles.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        hintText: 'Select your gender',
                      ),
                      items:
                          ['Male', 'Female', 'Other', 'Prefer not to say']
                              .map(
                                (gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ),
                              )
                              .toList(),
                      onChanged:
                          isSaving
                              ? null
                              : (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                    ),
                    const SizedBox(height: 16),

                    // Activity Level Dropdown
                    Text(
                      'Activity Level',
                      style: AppTextStyles.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedActivityLevel,
                      decoration: const InputDecoration(
                        hintText: 'Select your activity level',
                      ),
                      items:
                          [
                                'Sedentary',
                                'Lightly active',
                                'Moderately active',
                                'Very active',
                                'Extremely active',
                              ]
                              .map(
                                (level) => DropdownMenuItem(
                                  value: level,
                                  child: Text(
                                    level,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged:
                          isSaving
                              ? null
                              : (value) {
                                setState(() {
                                  _selectedActivityLevel = value;
                                });
                              },
                    ),
                    const SizedBox(height: 16),

                    // Fitness Goal Dropdown
                    Text(
                      'Fitness Goal',
                      style: AppTextStyles.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedFitnessGoal,
                      decoration: const InputDecoration(
                        hintText: 'Select your fitness goal',
                      ),
                      items:
                          [
                                'Lose Weight',
                                'Maintain Weight',
                                'Gain Weight',
                                'Build Muscle',
                                'Improve Endurance',
                                'General Fitness',
                              ]
                              .map(
                                (goal) => DropdownMenuItem(
                                  value: goal,
                                  child: Text(goal),
                                ),
                              )
                              .toList(),
                      onChanged:
                          isSaving
                              ? null
                              : (value) {
                                setState(() {
                                  _selectedFitnessGoal = value;
                                });
                              },
                    ),
                    const SizedBox(height: 24),

                    // Health Information Section
                    Text(
                      'Health Information',
                      style: AppTextStyles.headlineSmall?.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dietary Preferences
                    Text(
                      'Dietary Preferences',
                      style: AppTextStyles.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                            'Vegetarian',
                            'Vegan',
                            'Keto',
                            'Paleo',
                            'Mediterranean',
                            'Low Carb',
                            'High Protein',
                            'Gluten Free',
                            'Dairy Free',
                            'Halal',
                            'Kosher',
                          ].map((preference) {
                            final isSelected = _selectedDietaryPreferences
                                .contains(preference);
                            return FilterChip(
                              label: Text(preference),
                              selected: isSelected,
                              onSelected:
                                  isSaving
                                      ? null
                                      : (selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedDietaryPreferences.add(
                                              preference,
                                            );
                                          } else {
                                            _selectedDietaryPreferences.remove(
                                              preference,
                                            );
                                          }
                                        });
                                      },
                              selectedColor: AppColors.primary.withOpacity(0.2),
                              checkmarkColor: AppColors.primary,
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Health Conditions
                    Text(
                      'Health Conditions',
                      style: AppTextStyles.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _healthConditionsController,
                      decoration: const InputDecoration(
                        hintText:
                            'e.g., diabetes, hypertension, allergies (optional)',
                      ),
                      maxLines: 3,
                      enabled: !isSaving,
                    ),
                    const SizedBox(height: 16),

                    // Injuries
                    Text(
                      'Injuries or Physical Limitations',
                      style: AppTextStyles.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _injuriesController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., knee injury, back problems (optional)',
                      ),
                      maxLines: 3,
                      enabled: !isSaving,
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons (Sign Out, Save Changes)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          // Use Expanded to make buttons take equal space
                          child: OutlinedButton(
                            // Sign Out button
                            onPressed:
                                isSaving ? null : _signOut, // Disable if saving
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  AppColors.primary, // Red text/border
                              side: BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ), // Match ElevatedButton height
                            ),
                            child: Row(
                              // Icon and text
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.logout_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('Sign Out'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          // Use Expanded
                          child: ElevatedButton(
                            // Save Changes button
                            onPressed: isSaving ? null : _saveProfileChanges,
                            child:
                                isSaving
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Trainer-specific section
          if (user.role == 'trainer') ...[
            const SizedBox(height: 24),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trainer Tools',
                      style: AppTextStyles.headlineSmall?.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/trainer_nutrition_plans',
                        );
                      },
                      icon: Icon(Icons.restaurant_menu),
                      label: Text('Manage Nutrition Plans'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<AppThemeMode>(
              value: currentAppThemeMode,
              items:
                  AppThemeMode.values.map((AppThemeMode mode) {
                    return DropdownMenuItem<AppThemeMode>(
                      value: mode,
                      child: Text(mode.toString().split('.').last.capitalize()),
                    );
                  }).toList(),
              onChanged: (AppThemeMode? newMode) {
                if (newMode != null) {
                  ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(newMode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper methods (from WorkoutHistoryScreen) ---
  // --- Helper methods (from WorkoutHistoryScreen) ---
  // TODO: Move these to a shared helper or provider if used elsewhere
  Map<String, dynamic> _calculateStats(List<CompletedWorkout> workouts) {
    if (workouts.isEmpty) {
      return {
        'totalWorkouts': 0,
        'totalMinutes': 0,
        'avgIntensity': 0.0,
        'dayStreak': 0,
      };
    }

    final totalWorkouts = workouts.length;
    final totalMinutes = workouts.fold<int>(
      0,
      (sum, item) => sum + item.duration.inMinutes,
    );
    final avgIntensity =
        workouts.fold<double>(0.0, (sum, item) => sum + item.intensityScore) /
        totalWorkouts;

    // Streak calculation (copied from WorkoutHistoryScreen)
    final uniqueWorkoutDates =
        workouts
            .map(
              (w) => DateTime(w.endTime.year, w.endTime.month, w.endTime.day),
            )
            .toSet()
            .toList();
    uniqueWorkoutDates.sort((a, b) => a.compareTo(b));
    int currentStreak = 0;
    if (uniqueWorkoutDates.isNotEmpty) {
      int tempStreak = 0;
      DateTime checkDay = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ); // Start checking from today

      // Check backwards from today/yesterday
      for (int i = 0; i < uniqueWorkoutDates.length + 2; i++) {
        // Check today, yesterday, etc.
        bool found = uniqueWorkoutDates.any(
          (d) => d.isAtSameMomentAs(checkDay),
        );
        if (found) {
          tempStreak++;
          checkDay = checkDay.subtract(const Duration(days: 1));
        } else {
          // If the gap is exactly one day (i.e., we checked today, didn't find, check yesterday, found)
          // the streak continues. If the gap is more than one day, the streak is broken.
          // Check if the *previous* day had a workout. If not, the streak is broken.
          bool foundPreviousDay = uniqueWorkoutDates.any(
            (d) =>
                d.isAtSameMomentAs(checkDay.subtract(const Duration(days: 1))),
          );
          if (!foundPreviousDay && tempStreak > 0) {
            // Streak ended yesterday or earlier
            break;
          } else if (!foundPreviousDay && tempStreak == 0 && i > 0) {
            // No workout today or yesterday, streak is 0
            break;
          }
          // If foundPreviousDay is true, the loop continues checking backwards
          checkDay = checkDay.subtract(
            const Duration(days: 1),
          ); // Continue checking backwards
        }
        // Avoid infinite loop if something goes wrong or dates are very old
        if (checkDay.year < DateTime.now().year - 5) break;
      }
      currentStreak = tempStreak;
    }

    return {
      'totalWorkouts': totalWorkouts,
      'totalMinutes': totalMinutes,
      'avgIntensity': avgIntensity,
      'dayStreak': currentStreak, // Dummy streak
    };
  }
}
