import 'package:fitnation/Screens/Activities/WorkoutHistoryScreen.dart';
import 'package:fitnation/models/Workout.dart';
import 'package:fitnation/Screens/Activities/WorkoutDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/active_workout_provider.dart';
import 'package:fitnation/providers/auth_provider.dart';
import 'package:fitnation/providers/data_providers.dart';
import 'package:fitnation/services/database_helper.dart';
import 'package:fitnation/models/Exercise.dart' as exercise_db;
import 'package:fitnation/providers/gemini_workout_provider.dart';
import 'package:fitnation/Screens/Activities/WorkoutPlanGeneratorScreen.dart';
import 'package:fitnation/widgets/common/CustomAppBar.dart';
import 'package:fitnation/Screens/Trainer/TrainerRegistrationScreen.dart';
import 'package:fitnation/Screens/Trainer/TrainerApplicationStatusScreen.dart';
import 'package:fitnation/Screens/Trainer/TrainerListScreen.dart';
import 'package:fitnation/Screens/Trainer/MySessionsScreen.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    ); // Changed length to 3 to include Trainer tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveWorkout() async {
    final authState = ref.read(authProvider);
    String? currentUserId;

    if (authState is Authenticated) {
      currentUserId = authState.user.id;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated. Cannot save workout.'),
        ),
      );
      return;
    }

    const double dummyIntensity = 7.5;
    ref.read(activeWorkoutProvider.notifier).finishWorkout(dummyIntensity);

    final completedWorkoutData = ref
        .read(activeWorkoutProvider.notifier)
        .generateCompletedWorkoutData(currentUserId);

    if (completedWorkoutData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout data is incomplete or not finished.'),
        ),
      );
      return;
    }

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.saveWorkoutSession(completedWorkoutData);

      await _dbHelper.insertCompletedWorkout(
        completedWorkoutData,
        synced: true,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout saved and synced successfully!')),
      );
    } catch (e) {
      try {
        await _dbHelper.insertCompletedWorkout(
          completedWorkoutData,
          synced: false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workout saved locally. Will sync later. Error: $e'),
          ),
        );
      } catch (dbError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save workout to API and local DB. Error: $dbError',
            ),
          ),
        );
      }
    } finally {
      ref.read(activeWorkoutProvider.notifier).resetWorkout();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('WorkoutScreen: build method called.');
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final activeWorkout = ref.watch(activeWorkoutProvider);
    final generatedWorkouts = ref.watch(
      geminiWorkoutPlanProvider,
    ); // Watch the generated workouts

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Workout Planner',
        showLogo: false,
        showMenuButton: false, // Disable menu button
        showProfileMenu: true, // Enable profile menu
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          FilledButton.tonalIcon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) => const WorkoutHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history_rounded, size: 18),
            label: const Text('History'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'PLANS'),
            Tab(text: 'TRAINER'),
            Tab(text: 'SESSION'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Workout Plan Tab
          _buildWorkoutPlanTabContent(context, generatedWorkouts, colorScheme),

          // Trainer Tab
          _buildTrainerTabContent(context, colorScheme),

          // Active Session Tab
          _buildActiveWorkoutTab(context, activeWorkout, colorScheme),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(
        activeWorkout,
        colorScheme,
      ),
    );
  }

  Widget? _buildFloatingActionButton(
    ActiveWorkoutState activeWorkout,
    ColorScheme colorScheme,
  ) {
    // Only show FAB on active workout tab (index 2)
    if (_tabController.index != 2) return null;

    return !activeWorkout.isStarted
        ? FloatingActionButton.extended(
          onPressed: () {
            ref.read(activeWorkoutProvider.notifier).startWorkout();
            ref
                .read(activeWorkoutProvider.notifier)
                .addExercise(
                  exercise_db.Exercise(
                    exerciseId: 'dummyEx001',
                    name: 'Push Ups',
                    gifUrl: '',
                    bodyParts: ['Chest', 'Triceps'],
                    equipments: ['Bodyweight'],
                    targetMuscles: ['Pectoralis Major'],
                    secondaryMuscles: ['Triceps Brachii', 'Deltoids'],
                    instructions: [
                      '1. Get down on all fours...',
                      '2. Lower your body...',
                    ],
                  ),
                );
          },
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          label: const Text('Start New Workout'),
          icon: const Icon(Icons.fitness_center),
        )
        : null;
  }

  Widget _buildActiveWorkoutTab(
    BuildContext context,
    ActiveWorkoutState activeWorkout,
    ColorScheme colorScheme,
  ) {
    if (!activeWorkout.isStarted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_run_rounded,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No active workout session",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Tap the 'Start New Workout' button to begin your fitness journey.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout Header Card
          Card(
            elevation: 0,
            color: colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        color: colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Workout: ${activeWorkout.workoutName}",
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Started: ${activeWorkout.startTime?.toLocal().toString().substring(0, 16) ?? 'Not started'}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Exercises List
          Expanded(
            child:
                activeWorkout.exercises.isEmpty
                    ? _buildEmptyExerciseState(context, colorScheme)
                    : _buildExercisesList(context, activeWorkout, colorScheme),
          ),

          // Action Buttons
          const SizedBox(height: 16),
          _buildActionButtons(context, activeWorkout, colorScheme),
        ],
      ),
    );
  }

  Widget _buildEmptyExerciseState(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_circle_outline_rounded,
              size: 48,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No exercises added yet",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add some exercises to get started!",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(
    BuildContext context,
    ActiveWorkoutState activeWorkout,
    ColorScheme colorScheme,
  ) {
    return ListView.separated(
      itemCount: activeWorkout.exercises.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final exercise = activeWorkout.exercises[index];
        return _buildExerciseCard(context, exercise, colorScheme);
      },
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    ActiveWorkoutExercise exercise,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.baseExercise.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Equipment: ${exercise.baseExercise.equipments.join(', ')}",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sets
            ...exercise.sets.asMap().entries.map((entrySet) {
              int setIndex = entrySet.key;
              ActiveWorkoutSet currentSet = entrySet.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      currentSet.isCompleted
                          ? colorScheme.primaryContainer.withOpacity(0.3)
                          : colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        currentSet.isCompleted
                            ? colorScheme.primary.withOpacity(0.3)
                            : colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Set Number
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color:
                            currentSet.isCompleted
                                ? colorScheme.primary
                                : colorScheme.outline.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${setIndex + 1}",
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            color:
                                currentSet.isCompleted
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Weight Input
                    Expanded(
                      child: TextFormField(
                        initialValue: currentSet.weight,
                        decoration: InputDecoration(
                          labelText: "Weight",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged:
                            (val) => ref
                                .read(activeWorkoutProvider.notifier)
                                .updateSet(
                                  exercise.id,
                                  setIndex,
                                  val,
                                  currentSet.reps,
                                  currentSet.isCompleted,
                                ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Reps Input
                    Expanded(
                      child: TextFormField(
                        initialValue: currentSet.reps,
                        decoration: InputDecoration(
                          labelText: "Reps",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged:
                            (val) => ref
                                .read(activeWorkoutProvider.notifier)
                                .updateSet(
                                  exercise.id,
                                  setIndex,
                                  currentSet.weight,
                                  val,
                                  currentSet.isCompleted,
                                ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Completion Checkbox
                    Checkbox(
                      value: currentSet.isCompleted,
                      onChanged: (bool? value) {
                        ref
                            .read(activeWorkoutProvider.notifier)
                            .toggleSetComplete(exercise.id, setIndex);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            // Add Set Button
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    () => ref
                        .read(activeWorkoutProvider.notifier)
                        .addSetToExercise(exercise.id),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text("Add Set"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ActiveWorkoutState activeWorkout,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        // Add Exercise Button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              ref
                  .read(activeWorkoutProvider.notifier)
                  .addExercise(
                    exercise_db.Exercise(
                      exerciseId: 'dummyEx002',
                      name: 'Bicep Curls',
                      gifUrl: '',
                      bodyParts: ['Arms'],
                      equipments: ['Dumbbell'],
                      targetMuscles: ['Biceps'],
                      secondaryMuscles: [],
                      instructions: [],
                    ),
                  );
            },
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text("Add Exercise (Demo)"),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Finish Workout Button
        if (activeWorkout.isStarted && !activeWorkout.isFinished) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _handleSaveWorkout,
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              label: const Text("Finish & Save Workout"),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWorkoutPlanTabContent(
    BuildContext context,
    List<Workout> generatedWorkouts,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Generate Plan Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkoutPlanGeneratorScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome_rounded, size: 20),
              label: const Text('Generate New Workout Plan'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 20),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Plans List
          Expanded(
            child:
                generatedWorkouts.isEmpty
                    ? _buildEmptyWorkoutState(context, colorScheme)
                    : _buildWorkoutPlansList(
                      context,
                      generatedWorkouts,
                      colorScheme,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWorkoutState(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 64,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No workout plans yet",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Generate your first AI-powered workout plan tailored to your goals and equipment.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutPlansList(
    BuildContext context,
    List<Workout> workouts,
    ColorScheme colorScheme,
  ) {
    final workoutSummaries =
        workouts.map((w) => WorkoutSummary.fromWorkout(w)).toList();

    return ListView.separated(
      itemCount: workoutSummaries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final workout = workoutSummaries[index];
        return _buildWorkoutPlanCard(
          context,
          workout,
          workouts[index],
          colorScheme,
        );
      },
    );
  }

  Widget _buildWorkoutPlanCard(
    BuildContext context,
    WorkoutSummary workout,
    Workout fullWorkout,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => WorkoutDetailScreen(
                    workoutDetail: fullWorkout,
                    workoutPlan: fullWorkout,
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${workout.exerciseCount} exercises",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Exercise Preview
              if (workout.exercisesPreview.isNotEmpty) ...[
                Text(
                  "Exercises Preview:",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ...workout.exercisesPreview
                    .take(3)
                    .map(
                      (exercise) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "${exercise.name} (${exercise.setsReps})",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (workout.exerciseCount > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "+${workout.exerciseCount - 3} more exercises",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainerTabContent(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Personal Trainer Card
          Card(
            elevation: 0,
            color: colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_4_rounded,
                          color: colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Personal AI Trainer",
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Get personalized guidance and tips",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Trainer Features
          Expanded(
            child: ListView(
              children: [
                _buildTrainerFeatureCard(
                  context,
                  colorScheme,
                  Icons.fitness_center_rounded,
                  "Exercise Form Analysis",
                  "Get real-time feedback on your exercise form",
                  () {
                    // Navigate to form analysis screen
                  },
                ),
                const SizedBox(height: 12),
                _buildTrainerFeatureCard(
                  context,
                  colorScheme,
                  Icons.psychology_rounded,
                  "Find Personal Trainer",
                  "Connect with certified trainers in your area",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TrainerListScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildTrainerFeatureCard(
                  context,
                  colorScheme,
                  Icons.app_registration_rounded,
                  "Become a Trainer",
                  "Apply to become a certified trainer on our platform",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TrainerRegistrationScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildTrainerFeatureCard(
                  context,
                  colorScheme,
                  Icons.schedule_rounded,
                  "My Sessions",
                  "View and manage your booked training sessions",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MySessionsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildTrainerFeatureCard(
                  context,
                  colorScheme,
                  Icons.assignment_rounded,
                  "Application Status",
                  "Check your trainer application status",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const TrainerApplicationStatusScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainerFeatureCard(
    BuildContext context,
    ColorScheme colorScheme,
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onSecondaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
