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
import 'package:fitnation/providers/workout_generation_provider.dart';
import 'package:fitnation/models/PlannedExercise.dart';
import 'package:uuid/uuid.dart';
// PlannedExercise and Uuid will be referenced via models when needed
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
    final generationStatus = ref.watch(
      workoutGenerationProvider,
    ); // Watch generation status

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
          _buildWorkoutPlanTabContent(
            context,
            generatedWorkouts,
            generationStatus,
            colorScheme,
          ),

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
    WorkoutGenerationState generationStatus,
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
          const SizedBox(height: 12),

          // Import from backend button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                // Fetch backend plans and show modal
                final apiService = ref.read(apiServiceProvider);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) {
                    return FutureBuilder<List<Workout>>(
                      future: apiService.getWorkoutPlans(skip: 0, limit: 50),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError) {
                          return SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                'Failed to load plans: ${snapshot.error}',
                              ),
                            ),
                          );
                        }
                        final plans = snapshot.data ?? [];
                        if (plans.isEmpty) {
                          return SizedBox(
                            height: 200,
                            child: Center(
                              child: Text('No plans available from backend.'),
                            ),
                          );
                        }
                        return SafeArea(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Import Workout Plans',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                      ),
                                      IconButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        icon: const Icon(Icons.close_rounded),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: plans.length,
                                    separatorBuilder:
                                        (_, __) => const Divider(height: 1),
                                    itemBuilder: (c, i) {
                                      final p = plans[i];
                                      return ListTile(
                                        title: Text(p.name),
                                        subtitle: Text(
                                          '${p.exercises.length} exercises',
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                // Add to local generated plans
                                                ref
                                                    .read(
                                                      geminiWorkoutPlanProvider
                                                          .notifier,
                                                    )
                                                    .addPlan(p);
                                                Navigator.pop(ctx);
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Plan imported',
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Text('Add'),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) =>
                                                            WorkoutDetailScreen(
                                                              workoutDetail: p,
                                                              workoutPlan: p,
                                                            ),
                                                  ),
                                                );
                                              },
                                              child: const Text('Open'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              icon: const Icon(Icons.cloud_download_rounded, size: 20),
              label: const Text('Import from Backend'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Add manual plan button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                _showAddPlanModal(context);
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add Manual Plan'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Show generation progress card if generating
          if (generationStatus.isGenerating) ...[
            _buildGenerationProgressCard(
              context,
              generationStatus,
              colorScheme,
            ),
            const SizedBox(height: 24),
          ],

          // Show completion card if completed
          if (generationStatus.isCompleted) ...[
            _buildGenerationCompletedCard(context, colorScheme),
            const SizedBox(height: 24),
          ],

          // Show error card if there's an error
          if (generationStatus.hasError) ...[
            _buildGenerationErrorCard(context, generationStatus, colorScheme),
            const SizedBox(height: 24),
          ],

          // Plans List
          Expanded(
            child:
                generatedWorkouts.isEmpty &&
                        !generationStatus.isGenerating &&
                        !generationStatus.isCompleted &&
                        !generationStatus.hasError
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

  Widget _buildGenerationProgressCard(
    BuildContext context,
    WorkoutGenerationState generationStatus,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    Icons.auto_awesome_rounded,
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
                        "Generating Workout",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        generationStatus.message ??
                            "Processing your request...",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Progress",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${(generationStatus.progress * 100).round()}%",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: generationStatus.progress,
                    backgroundColor: colorScheme.onPrimaryContainer.withOpacity(
                      0.2,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Generation steps
            _buildGenerationSteps(context, generationStatus, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerationSteps(
    BuildContext context,
    WorkoutGenerationState generationStatus,
    ColorScheme colorScheme,
  ) {
    final steps = [
      (
        WorkoutGenerationStep.requestSent,
        "Sending request to AI",
        Icons.send_rounded,
      ),
      (
        WorkoutGenerationStep.parsing,
        "Parsing AI response",
        Icons.psychology_rounded,
      ),
      (
        WorkoutGenerationStep.processing,
        "Processing workout plan",
        Icons.settings_rounded,
      ),
      (
        WorkoutGenerationStep.handling,
        "Finalizing your plan",
        Icons.check_circle_rounded,
      ),
    ];

    return Column(
      children:
          steps.map((stepData) {
            final step = stepData.$1;
            final title = stepData.$2;
            final icon = stepData.$3;

            final isCompleted = generationStatus.step.index > step.index;
            final isCurrent = generationStatus.step == step;
            Color stepColor;
            Color iconColor;
            Color textColor;

            if (isCompleted) {
              stepColor = colorScheme.primary;
              iconColor = colorScheme.onPrimary;
              textColor = colorScheme.onPrimaryContainer;
            } else if (isCurrent) {
              stepColor = colorScheme.primary.withOpacity(0.7);
              iconColor = colorScheme.onPrimary;
              textColor = colorScheme.onPrimaryContainer;
            } else {
              stepColor = colorScheme.onPrimaryContainer.withOpacity(0.2);
              iconColor = colorScheme.onPrimaryContainer.withOpacity(0.5);
              textColor = colorScheme.onPrimaryContainer.withOpacity(0.6);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: stepColor,
                      shape: BoxShape.circle,
                    ),
                    child:
                        isCompleted
                            ? Icon(
                              Icons.check_rounded,
                              color: iconColor,
                              size: 18,
                            )
                            : isCurrent
                            ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  iconColor,
                                ),
                              ),
                            )
                            : Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildGenerationCompletedCard(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.tertiaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Workout Generated Successfully!",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Your personalized workout plan is ready. Scroll down to view and start your workout!",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onTertiaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ref.read(workoutGenerationProvider.notifier).reset();
              },
              icon: Icon(
                Icons.close_rounded,
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerationErrorCard(
    BuildContext context,
    WorkoutGenerationState generationStatus,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    color: colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.error_rounded,
                    color: colorScheme.onError,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Generation Failed",
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        generationStatus.errorMessage ??
                            "Something went wrong while generating your workout plan.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onErrorContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref.read(workoutGenerationProvider.notifier).reset();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ref.read(workoutGenerationProvider.notifier).reset();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkoutPlanGeneratorScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modal to add a manual plan with exercises
  void _showAddPlanModal(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _planNameController = TextEditingController();
    final List<PlannedExercise> exercises = [];
    final TextEditingController _exerciseNameController =
        TextEditingController();
    final TextEditingController _exerciseEquipController =
        TextEditingController();
    final TextEditingController _exerciseSetsController =
        TextEditingController();
    final TextEditingController _exerciseRepsController =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create Manual Workout Plan',
                        style: Theme.of(ctx).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _planNameController,
                              decoration: const InputDecoration(
                                labelText: 'Plan Name',
                              ),
                              validator:
                                  (v) =>
                                      (v == null || v.isEmpty)
                                          ? 'Enter plan name'
                                          : null,
                            ),
                            const SizedBox(height: 12),
                            // Exercise input row
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _exerciseNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Exercise Name',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _exerciseEquipController,
                                    decoration: const InputDecoration(
                                      labelText: 'Equipment (comma separated)',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _exerciseSetsController,
                                    decoration: const InputDecoration(
                                      labelText: 'Sets',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _exerciseRepsController,
                                    decoration: const InputDecoration(
                                      labelText: 'Reps',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Add exercise to list
                                    final name =
                                        _exerciseNameController.text.trim();
                                    if (name.isEmpty) return;
                                    final equips =
                                        _exerciseEquipController.text
                                            .split(',')
                                            .map((s) => s.trim())
                                            .where((s) => s.isNotEmpty)
                                            .toList();
                                    final sets =
                                        int.tryParse(
                                          _exerciseSetsController.text,
                                        ) ??
                                        3;
                                    final reps =
                                        int.tryParse(
                                          _exerciseRepsController.text,
                                        ) ??
                                        8;
                                    final pe = PlannedExercise(
                                      exerciseId: const Uuid().v4(),
                                      exerciseName: name,
                                      exerciseEquipments: equips,
                                      exerciseGifUrl: null,
                                      type: null,
                                      plannedSets: sets,
                                      plannedReps: reps,
                                      plannedWeight: null,
                                    );
                                    setState(() {
                                      exercises.add(pe);
                                      _exerciseNameController.clear();
                                      _exerciseEquipController.clear();
                                      _exerciseSetsController.clear();
                                      _exerciseRepsController.clear();
                                    });
                                  },
                                  child: const Text('Add Exercise'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      exercises.clear();
                                    });
                                  },
                                  child: const Text('Clear'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Exercises preview
                            if (exercises.isNotEmpty)
                              Column(
                                children:
                                    exercises
                                        .map(
                                          (e) => ListTile(
                                            title: Text(e.exerciseName),
                                            subtitle: Text(
                                              '${e.exerciseEquipments?.join(', ') ?? ''} • ${e.plannedSets}x${e.plannedReps}',
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  exercises.remove(e);
                                                });
                                              },
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate())
                                    return;
                                  final planId = const Uuid().v4();
                                  final workout = Workout(
                                    id: planId,
                                    name: _planNameController.text.trim(),
                                    iconUrl: null,
                                    equipmentSelected: null,
                                    oneRmGoal: null,
                                    type: null,
                                    prompt: null,
                                    exercises: exercises,
                                  );
                                  // Save locally
                                  try {
                                    await _dbHelper.insertLocalWorkoutPlan(
                                      workout,
                                    );
                                  } catch (e) {
                                    debugPrint(
                                      'Failed to save plan locally: $e',
                                    );
                                  }
                                  // Add to provider and attempt backend save
                                  try {
                                    await ref
                                        .read(
                                          geminiWorkoutPlanProvider.notifier,
                                        )
                                        .savePlanLocally(
                                          workout,
                                          saveToBackend: true,
                                        );
                                  } catch (e) {
                                    debugPrint(
                                      'Failed to save plan to backend: $e',
                                    );
                                  }
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Plan added')),
                                  );
                                },
                                icon: const Icon(Icons.save_rounded),
                                label: const Text('Save Plan'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
