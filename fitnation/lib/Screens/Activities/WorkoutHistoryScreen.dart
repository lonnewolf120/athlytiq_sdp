import 'package:fitnation/models/CompletedWorkout.dart';
// import 'package:fitnation/models/CompletedWorkoutExercise.dart'; // Now in CompletedWorkout.dart
// import 'package:fitnation/models/CompletedWorkoutSet.dart'; // Now in CompletedWorkout.dart
import 'package:fitnation/models/User.dart';
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:fitnation/widgets/Activities/CompletedWorkoutListItem.dart';
import 'package:fitnation/widgets/Activities/StatsCard.dart';
import 'package:fitnation/widgets/Activities/WorkoutCalendar.dart';
import 'package:fitnation/services/database_helper.dart'; // Import DatabaseHelper
import 'package:fitnation/Screens/Activities/CompletedWorkoutDetailScreen.dart'; // Import CompletedWorkoutDetailScreen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fitnation/providers/data_providers.dart'; // Import the actual data providers

// Removed _dummyCompletedWorkouts list as data will now come from SQLite

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  // Local state for filters
  String _selectedWorkoutType = 'All Workouts';
  String _selectedTimeRange = 'This Month'; // Default to 'This Month' as per UI

  // Options for time range filter
  final List<String> _timeRangeOptions = [
    'This Month',
    'This Year',
    'Last 30 Days',
    'Last 90 Days',
    'All Time',
  ];

  // TODO: Calculate stats based on filtered workouts (moved from build)
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

    // Dummy streak calculation (requires sorting by date and checking consecutive days)
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

  // TODO: Extract workout dates for the calendar (moved from build)
  List<DateTime> _getWorkoutDates(List<CompletedWorkout> workouts) {
    return workouts
        .map((w) => DateTime(w.endTime.year, w.endTime.month, w.endTime.day))
        .toSet()
        .toList(); // Use end time for the date, get unique days
  }

  // TODO: Navigate to full completed workout detail screen
  void _navigateToCompletedWorkoutDetail(CompletedWorkout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletedWorkoutDetailScreen(workout: workout),
      ),
    );
  }

  Future<void> _refreshWorkouts() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      final filters = WorkoutHistoryFilters(
        userId: currentUser.id,
        workoutType: _selectedWorkoutType,
        timeRange: _selectedTimeRange,
      );
      ref.invalidate(completedWorkoutsProvider(filters));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Watch the current user provider to get the user ID
    final currentUserAsyncValue = ref.watch(currentUserProvider);

    // Watch the workout types provider for filter options
    final workoutTypesAsyncValue = ref.watch(workoutTypesProvider);

    // Watch the completed workouts provider, passing the selected filters
    // Need the user ID first. Handle loading/error states for the user.
    final completedWorkoutsAsyncValue = currentUserAsyncValue.when(
      data: (user) {
        // If user data is available, watch the workouts provider with filters
        // Create an instance of WorkoutHistoryFilters
        final filters = WorkoutHistoryFilters(
          userId: user.id, // Still needed for the filter object's identity
          workoutType: _selectedWorkoutType,
          timeRange: _selectedTimeRange,
          // skip and limit can be added here if pagination is controlled from the screen
          // For now, using default skip/limit from the provider's API call.
        );
        debugPrint(
          "WorkoutHistoryScreen: Watching completedWorkoutsProvider with userId=${user.id}, type: ${filters.workoutType}, time: ${filters.timeRange}",
        );
        return ref.watch(
          completedWorkoutsProvider(filters),
        ); // Pass the filters object
      },
      loading:
          () => const AsyncValue.loading(), // Still loading if user is loading
      error: (e, st) => AsyncValue.error(e, st), // Propagate user error
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: Text('Workout History', style: textTheme.titleLarge),
        centerTitle: true,
        actions: [
          IconButton(
            // Graph/Stats Icon
            icon: Icon(Icons.bar_chart_rounded, color: AppColors.primary),
            onPressed: () {
              /* TODO: Handle stats icon tap */
            },
            tooltip: 'View Stats',
          ),
          IconButton(
            // Calendar Icon
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () {
              /* TODO: Handle calendar icon tap */
            },
            tooltip: 'View Calendar',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWorkouts,
            tooltip: 'Refresh Workouts',
          ),
          const SizedBox(width: 8), // Padding on the right
        ],
      ),
      body: completedWorkoutsAsyncValue.when(
        data: (workouts) {
          // Calculate stats and calendar dates from the *displayed* (filtered) workouts
          final stats = _calculateStats(workouts);
          final workoutDates = _getWorkoutDates(workouts);

          return RefreshIndicator(
            onRefresh: _refreshWorkouts,
            child: ListView(
              // Use ListView for overall scrollability
              padding: const EdgeInsets.all(16.0), // Section padding
              children: [
                // Filter Dropdowns
                Row(
                  children: [
                    // Workout Type Filter
                    Expanded(
                      child: workoutTypesAsyncValue.when(
                        data: (types) {
                          // Ensure 'All Workouts' is always an option
                          final allTypes =
                              [
                                'All Workouts',
                                ...types.where(
                                  (type) => type != 'All Workouts',
                                ),
                              ].toSet().toList();

                          // If the currently selected type is no longer in the list, reset it
                          // This needs to be done carefully to avoid setState during build if not necessary
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!allTypes.contains(_selectedWorkoutType) &&
                                mounted) {
                              setState(() {
                                _selectedWorkoutType = 'All Workouts';
                              });
                            }
                          });

                          return DropdownButtonFormField<String>(
                            value:
                                allTypes.contains(_selectedWorkoutType)
                                    ? _selectedWorkoutType
                                    : 'All Workouts',
                            items:
                                allTypes.map<DropdownMenuItem<String>>((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value.length > 10
                                          ? value
                                              .replaceAllMapped(
                                                RegExp(r'.{1,10}'),
                                                (match) =>
                                                    '${match.group(0)}\n',
                                              )
                                              .trim()
                                          : value,
                                      softWrap: true,
                                      maxLines: null,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedWorkoutType = newValue;
                                });
                                // Client-side filtering will apply based on this state change
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              labelText: 'Workout Type',
                              labelStyle: textTheme.bodyMedium,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (e, st) => Text('Error loading types: $e'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Time Range Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedTimeRange,
                        items:
                            _timeRangeOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedTimeRange = newValue;
                            });
                            // Riverpod will automatically re-fetch/filter when _selectedTimeRange changes
                          }
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Time Range',
                          labelStyle: textTheme.bodyMedium,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.5, // Adjust as needed
                  children: [
                    StatsCard(
                      icon: Icons.fitness_center,
                      label: 'Workouts',
                      value: stats['totalWorkouts'].toString(),
                    ),
                    StatsCard(
                      icon: Icons.timer,
                      label: 'Total Minutes',
                      value: '${stats['totalMinutes']} min',
                    ),
                    StatsCard(
                      icon: Icons.local_fire_department,
                      label: 'Avg. Intensity',
                      value: '${stats['avgIntensity'].toStringAsFixed(1)}/10',
                    ),
                    StatsCard(
                      icon:
                          Icons
                              .star, // Using star icon as a placeholder for streak
                      label: 'Day Streak',
                      value: stats['dayStreak'].toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Workout Calendar
                Text('Workout Calendar', style: textTheme.titleLarge),
                const SizedBox(height: 16),
                WorkoutCalendar(
                  workoutDates: workoutDates,
                  onMonthChanged: (month) {
                    // Handle month change if needed, e.g., refetch data for the month
                    print('Month changed to: $month');
                  },
                ),
                const SizedBox(height: 24),

                // Recent Workouts List
                Text('Recent Workouts', style: textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildFilteredWorkoutList(
                  workouts,
                ), // Use helper for filtered list
              ],
            ),
          );
        },
        loading: () {
          print(
            "WorkoutHistoryScreen: completedWorkoutsProvider is in loading state.",
          );
          return const Center(
            child: CircularProgressIndicator(key: ValueKey("history_loading")),
          );
        },
        error: (e, st) {
          print("WorkoutHistoryScreen: Error in completedWorkoutsProvider: $e");
          print("WorkoutHistoryScreen: StackTrace: $st");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading workouts: ${e.toString()}',
                  style: AppTextStyles.bodyMedium?.copyWith(
                    color: Colors.redAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "The backend endpoint for workout history might be returning an error or is not reachable. Please check server logs.",
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ), // Used textTheme
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ); // Correctly ends Center
        }, // Correctly ends error callback
      ), // Correctly ends when()
    ); // Correctly ends Scaffold
  }

  // Helper widget to build the list of workouts.
  // The 'workouts' list is now pre-filtered by the completedWorkoutsProvider.
  Widget _buildFilteredWorkoutList(List<CompletedWorkout> workouts) {
    final textTheme = Theme.of(context).textTheme;

    if (workouts.isEmpty) {
      return Center(
        child: Padding(
          // Added padding for better spacing
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Text(
            'No completed workouts found for the selected filters.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return CompletedWorkoutListItem(
          workout: workout,
          onViewDetails: () => _navigateToCompletedWorkoutDetail(workout),
        );
      },
    );
  }
}
