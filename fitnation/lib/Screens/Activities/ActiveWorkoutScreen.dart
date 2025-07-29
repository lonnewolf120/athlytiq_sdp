import 'dart:async'; // For Timer
import 'package:fitnation/providers/active_workout_provider.dart'; // Correct import
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:fitnation/models/Exercise.dart';
import 'package:fitnation/models/Workout.dart';
import 'package:fitnation/models/WorkoutPostModel.dart';
import 'package:fitnation/providers/exercise_data_provider.dart';
import 'package:fitnation/widgets/Activities/ActiveWorkout_Items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Assuming Riverpod for state/data
import 'package:intl/intl.dart'; // For time formatting
import 'package:uuid/uuid.dart'; // For generating unique IDs
import 'package:fitnation/services/database_helper.dart'; // Import DatabaseHelper
import 'package:fitnation/models/CompletedWorkout.dart';
// import 'package:fitnation/models/CompletedWorkoutExercise.dart'; // Now in CompletedWorkout.dart
// import 'package:fitnation/models/CompletedWorkoutSet.dart'; // Now in CompletedWorkout.dart
import 'package:fitnation/models/User.dart'; // Assuming User model is available
import 'package:fitnation/providers/data_providers.dart'; // Assuming currentUserProvider is here
import 'package:fitnation/providers/auth_provider.dart'; // Added missing import

// TODO: Define providers for searching/selecting exercises if needed for "Add Exercise" button
// Example:
// final exerciseSearchProvider = FutureProvider.family<List<Exercise>, String>((ref, query) => ref.watch(apiServiceProvider).getExercisesByName(query));
class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final ActiveWorkoutState initialState;

  const ActiveWorkoutScreen({super.key, required this.initialState});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  // late ActiveWorkoutState _currentState; // Removed: Will use provider's state directly or via ref.watch
  Timer? _timer;
  Duration _elapsedDuration = Duration.zero; // Initialize to zero

  @override
  void initState() {
    super.initState();
    _initializeWorkoutStateAndTimer();

    // Listen to startTime changes from the provider to update the timer and duration
    ref.listenManual(
      activeWorkoutProvider.select((state) => state.startTime),
      (previousStartTime, newStartTime) {
        _updateTimerAndDuration(newStartTime);
      },
      fireImmediately: true,
    ); // fireImmediately to catch initial state if already set
  }

  void _initializeWorkoutStateAndTimer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(activeWorkoutProvider.notifier);
      final currentProviderState = ref.read(activeWorkoutProvider);

      // If the provider's startTime is already set (e.g. screen rebuild but workout ongoing)
      // or if widget.initialState has a startTime (resuming a workout perhaps)
      DateTime? effectiveStartTime =
          currentProviderState.startTime ?? widget.initialState.startTime;

      if (effectiveStartTime != null) {
        // Workout is already started or is being resumed with a start time
        debugPrint(
          "ActiveWorkoutScreen initState: Workout already has startTime: $effectiveStartTime. Initializing timer.",
        );
        if (currentProviderState.startTime == null) {
          // If provider isn't set, load initial state
          notifier.loadState(
            widget.initialState,
          ); // Assumes loadState method in provider
        }
        _updateTimerAndDuration(effectiveStartTime);
      } else {
        // New workout, or initial state has no start time.
        // Initialize provider with name/exercises, but don't start timer yet.
        // Timer will start when provider's startTime is set (e.g., by startWorkout call).
        debugPrint(
          "ActiveWorkoutScreen initState: No startTime. Initializing provider with name/exercises from widget.initialState.",
        );
        notifier.initializeNewWorkout(
          // Assumes initializeNewWorkout method in provider
          name: widget.initialState.workoutName,
          initialExercises: widget.initialState.exercises,
        );
        // The actual start (setting startTime and thus starting the timer via listener)
        // should happen explicitly, e.g., when user presses a "Start" button or automatically if desired.
        // For now, let's assume starting immediately if it's a fresh entry to this screen without a startTime.
        // This matches the previous logic of calling startWorkout if _currentState.startTime was null.
        debugPrint(
          "ActiveWorkoutScreen initState: Calling provider.startWorkout() as no effective startTime was found.",
        );
        notifier.startWorkout(
          name: widget.initialState.workoutName,
        ); // This will trigger the listener
      }
    });
  }

  void _updateTimerAndDuration(DateTime? startTime) {
    if (!mounted) return;

    _timer?.cancel();
    if (startTime != null) {
      setState(() {
        _elapsedDuration = DateTime.now().difference(startTime);
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        final currentStartTime = ref.read(activeWorkoutProvider).startTime;
        if (currentStartTime != null) {
          setState(() {
            _elapsedDuration = DateTime.now().difference(currentStartTime);
          });
        } else {
          // startTime became null, stop timer and reset duration
          timer.cancel();
          setState(() {
            _elapsedDuration = Duration.zero;
          });
        }
      });
    } else {
      // No startTime, ensure timer is cancelled and duration is zero
      setState(() {
        _elapsedDuration = Duration.zero;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "${hours == '00' ? '' : '$hours:'}$minutes:$seconds";
  }

  // _onExerciseUpdated is removed as ActiveWorkoutExerciseItem will update the provider directly.
  // void _onExerciseUpdated(ActiveWorkoutExercise updatedExercise) { ... }

  void _addSetToExercise(int exerciseIndex) {
    final currentWorkoutState = ref.read(activeWorkoutProvider);
    if (exerciseIndex >= 0 &&
        exerciseIndex < currentWorkoutState.exercises.length) {
      final activeExerciseId = currentWorkoutState.exercises[exerciseIndex].id;
      ref
          .read(activeWorkoutProvider.notifier)
          .addSetToExercise(activeExerciseId);
    } else {
      debugPrint(
        "Error: Invalid exerciseIndex in _addSetToExercise: $exerciseIndex",
      );
    }
  }

  void _removeExercise(int exerciseIndex) {
    // Corrected signature to int
    final currentWorkoutState = ref.read(activeWorkoutProvider);
    if (exerciseIndex >= 0 &&
        exerciseIndex < currentWorkoutState.exercises.length) {
      final activeExerciseId = currentWorkoutState.exercises[exerciseIndex].id;
      ref.read(activeWorkoutProvider.notifier).removeExercise(activeExerciseId);
    } else {
      debugPrint(
        "Error: Invalid exerciseIndex in _removeExercise: $exerciseIndex",
      );
    }
  }

  // Logic for "Add Exercise" button
  void _addExercise() async {
    final selectedExercise = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ExerciseSelectionModal(),
    );

    if (selectedExercise != null) {
      // No need to create ActiveWorkoutExercise here, provider will handle it.
      // final newActiveExercise = ActiveWorkoutExercise(
      //   baseExercise: selectedExercise,
      //   sets: [ActiveWorkoutSet()],
      // );
      // setState(() { // No longer managing local _currentState for exercises
      //   final updatedExercises = List<ActiveWorkoutExercise>.from(
      //     _currentState.exercises,
      //   );
      //   updatedExercises.add(newActiveExercise);
      //   _currentState = _currentState.copyWith(exercises: updatedExercises);
      // });
      ref.read(activeWorkoutProvider.notifier).addExercise(selectedExercise);
    }
  }

  void _restartWorkout() {
    // setState(() { // No longer managing local _currentState for exercises
    //   _currentState = _currentState.copyWith(
    //     startTime: DateTime.now(),
    //     clearEndTime: true,
    //     exercises: _currentState.exercises.map((activeEx) {
    //       return ActiveWorkoutExercise(
    //         baseExercise: activeEx.baseExercise,
    //         sets: [ActiveWorkoutSet()],
    //       );
    //     }).toList(),
    //   );
    //   _elapsedDuration = Duration.zero;
    //   _timer?.cancel();
    //   if (_currentState.startTime != null) {
    //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //       if (mounted && _currentState.startTime != null) {
    //         setState(() {
    //           _elapsedDuration = DateTime.now().difference(_currentState.startTime!);
    //         });
    //       }
    //     });
    //   }
    // });
    final currentWorkoutName = ref.read(activeWorkoutProvider).workoutName;
    ref
        .read(activeWorkoutProvider.notifier)
        .restartWorkout(name: currentWorkoutName);
    // Timer and _elapsedDuration will be handled by listening to provider's startTime changes in initState/ref.listen
  }

  void _showPauseModal() {
    // Ensure we are using the provider's state for the workout name if needed by the modal,
    // though this modal doesn't directly use it.
    // final currentWorkoutState = ref.read(activeWorkoutProvider);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.7), // Transparent background
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return WorkoutPauseModal(
          onResume: () {
            Navigator.of(context).pop(); // Dismiss modal
          },
          onAwayForAWhile: () {
            Navigator.of(context).pop(); // Dismiss modal
            // TODO: Implement save progress and continue later logic
            print("Workout paused and saved for later.");
            Navigator.pop(context); // Go back to previous screen
          },
          onRestart: () {
            Navigator.of(context).pop(); // Dismiss modal
            _restartWorkout(); // Call restart logic
          },
          onQuit: () {
            Navigator.of(context).pop(); // Dismiss modal
            _finishWorkout(); // Call finish workout logic
          },
        );
      },
    );
  }

  void _finishWorkout() async {
    final providerState = ref.read(
      activeWorkoutProvider,
    ); // providerState is ActiveWorkoutState
    // debugPrint("_finishWorkout: Local _currentState.startTime = ${_currentState.startTime}"); // _currentState removed
    debugPrint(
      "_finishWorkout: Provider providerState.startTime = ${providerState.startTime}",
    );
    debugPrint(
      "_finishWorkout: Provider providerState.isFinished = ${providerState.isFinished}",
    );
    debugPrint(
      "_finishWorkout: Provider providerState.intensityScore = ${providerState.intensityScore}",
    );

    if (providerState.startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout not started (provider state is null).'),
        ),
      );
      return;
    }
    // Call the provider's finishWorkout to set endTime and intensityScore in the state
    // TODO: Get actual intensity score from user input instead of hardcoding
    const intensityScore = 7.5;
    ref.read(activeWorkoutProvider.notifier).finishWorkout(intensityScore);

    // Now that the state in the provider is updated (endTime, intensityScore are set),
    // we can proceed to save. The provider's saveCompletedWorkout will use this updated state.

    // Get current user ID
    final authState = ref.read(authProvider);
    String userId;
    if (authState is Authenticated) {
      userId = authState.user.id;
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated.')));
      return;
    }

    // The conversion to CompletedWorkoutExercise and CompletedWorkoutSet,
    // and the check for empty exercises, are now handled within
    // activeWorkoutProvider.generateCompletedWorkoutData() and activeWorkoutProvider.saveCompletedWorkout().
    // Thus, the local creation of `completedExercises` and its associated checks are removed from here.

    try {
      // debugPrint('Attempting to save workout: ${completedWorkout.workoutName}'); // This object is no longer created here
      final apiService = ref.read(apiServiceProvider);
      final dbHelper = DatabaseHelper();

      final success = await ref
          .read(activeWorkoutProvider.notifier)
          .saveCompletedWorkout(userId, apiService, dbHelper);

      if (mounted) {
        // Check if the widget is still in the tree
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout saved successfully!')),
          );
          Navigator.pop(context); // Go back to previous screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save workout. Please try again.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
      debugPrint('Error in _finishWorkout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentWorkoutState = ref.watch(
      activeWorkoutProvider,
    ); // Watch the provider state

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close), // Changed to close icon
          onPressed: _showPauseModal, // Call the new pause modal
          tooltip: 'Pause Workout',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentWorkoutState.workoutName
                  .toUpperCase(), // Use provider state
              style: textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  _formatDuration(_elapsedDuration),
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.mutedForeground,
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: _finishWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: Text(
                'FINISH',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryForeground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: currentWorkoutState.exercises.length, // Use provider state
        itemBuilder: (context, index) {
          final exercise = currentWorkoutState.exercises[index];
          // _onExerciseUpdated will be removed. ActiveWorkoutExerciseItem will call provider directly.
          // onAddSet and onRemoveExercise will now use exercise.id
          return ActiveWorkoutExerciseItem(
            exercise:
                exercise, // This is ActiveWorkoutExercise from the provider
            exerciseIndex:
                index, // Keep for now, might be used by the item for UI
            // onExerciseUpdated has been removed from ActiveWorkoutExerciseItem's constructor
            // ActiveWorkoutExerciseItem expects VoidCallback for onAddSet.
            // _addSetToExercise takes an int (the index).
            onAddSet: () => _addSetToExercise(index),
            // ActiveWorkoutExerciseItem expects ValueChanged<int> for onRemoveExercise.
            // _removeExercise takes an int (the index).
            onRemoveExercise:
                _removeExercise, // Pass the method reference directly
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExercise,
        label: const Text('Add Exercise'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.mutedBackground,
        foregroundColor: AppColors.foreground,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class WorkoutPauseModal extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onAwayForAWhile;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const WorkoutPauseModal({
    super.key,
    required this.onResume,
    required this.onAwayForAWhile,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pause',
                style: textTheme.displaySmall?.copyWith(
                  color: AppColors.darkPrimaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              _buildModalButton(
                context,
                'AWAY FOR A WHILE',
                'Keep my progress and I\'ll continue later',
                onAwayForAWhile,
                textTheme,
              ),
              const SizedBox(height: 20),
              _buildModalButton(context, 'RESTART', null, onRestart, textTheme),
              const SizedBox(height: 20),
              _buildModalButton(context, 'QUIT', null, onQuit, textTheme),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onResume,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.darkPrimaryText, // White background
                    foregroundColor: AppColors.darkBackground, // Dark text
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'RESUME',
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.darkBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalButton(
    BuildContext context,
    String title,
    String? subtitle,
    VoidCallback onPressed,
    TextTheme textTheme,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkSurface, // Dark surface background
          foregroundColor: AppColors.darkPrimaryText, // White text
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.darkPrimaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.darkSecondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ExerciseSelectionModal extends ConsumerStatefulWidget {
  @override
  ConsumerState<ExerciseSelectionModal> createState() =>
      _ExerciseSelectionModalState();
}

class _ExerciseSelectionModalState
    extends ConsumerState<ExerciseSelectionModal> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      // Debounce the search input to avoid too many API calls
      // You can use a package like `debounce_throttle` or implement manually
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_searchController.text.trim() != _searchQuery) {
          setState(() {
            _searchQuery = _searchController.text.trim();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Watch the search provider based on the query
    final searchResultsAsyncValue = ref.watch(
      exercisesSearchByNameProvider(_searchQuery),
    );

    return Scaffold(
      // Use Scaffold for the modal content
      appBar: AppBar(
        title: const Text('Select Exercise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context), // Close the modal
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                // Use theme decoration
              ),
            ),
          ),
          Expanded(
            child: searchResultsAsyncValue.when(
              data: (exercises) {
                if (_searchQuery.isEmpty) {
                  // Optionally show popular exercises or categories if search is empty
                  return Center(
                    child: Text(
                      'Start typing to search exercises',
                      style: textTheme.bodyMedium,
                    ),
                  );
                }
                if (exercises.isEmpty) {
                  return Center(
                    child: Text(
                      'No exercises found for "$_searchQuery"',
                      style: textTheme.bodyMedium,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return ListTile(
                      leading: CircleAvatar(
                        // Use CircleAvatar for GIF preview
                        backgroundColor: AppColors.mutedBackground,
                        backgroundImage:
                            exercise.gifUrl != null &&
                                    exercise.gifUrl!.isNotEmpty
                                ? CachedNetworkImageProvider(exercise.gifUrl!)
                                : null,
                        child:
                            exercise.gifUrl == null || exercise.gifUrl!.isEmpty
                                ? Icon(
                                  Icons.fitness_center,
                                  color: AppColors.mutedForeground,
                                )
                                : null,
                      ),
                      title: Text(exercise.name, style: textTheme.bodyLarge),
                      subtitle: Text(
                        '${exercise.bodyParts.join(', ')} • ${exercise.equipments.join(', ')}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(
                          context,
                          exercise,
                        ); // Return the selected exercise
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (e, st) =>
                      Center(child: Text('Error searching: ${e.toString()}')),
            ),
          ),
        ],
      ),
    );
  }
}
