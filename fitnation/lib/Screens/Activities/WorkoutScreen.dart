// lib/Screens/Activities/WorkoutScreen.dart
import 'package:fitnation/Screens/Activities/WorkoutHistoryScreen.dart';
import 'package:fitnation/models/PlannedExercise.dart';
import 'package:fitnation/models/Workout.dart';
import 'package:fitnation/models/CompletedWorkout.dart' as completed_workout_model;
import 'package:fitnation/Screens/Activities/WorkoutDetailScreen.dart';
import 'package:fitnation/widgets/Activities/WorkoutCard.dart';
import 'package:fitnation/core/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/active_workout_provider.dart';
import 'package:fitnation/providers/auth_provider.dart';
import 'package:fitnation/providers/data_providers.dart'; // Import apiServiceProvider from data_providers
import 'package:fitnation/services/database_helper.dart';
import 'package:fitnation/models/Exercise.dart' as exercise_db; // For ExerciseDB model
import 'package:fitnation/providers/gemini_workout_provider.dart'; // Import geminiWorkoutPlanProvider
import 'package:fitnation/Screens/Activities/WorkoutPlanGeneratorScreen.dart'; // Import WorkoutPlanGeneratorScreen
import 'package:fitnation/providers/gemini_meal_plan_provider.dart'; // Import geminiMealPlanProvider
import 'package:fitnation/Screens/Activities/MealPlanGeneratorScreen.dart'; // Import MealPlanGeneratorScreen
import 'package:fitnation/models/MealPlan.dart'; // Import MealPlan
import 'package:fitnation/Screens/Activities/MealPlanDetailScreen.dart'; // Import MealPlanDetailScreen

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  // Added a comment to trigger re-analysis
  late TabController _tabController;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    ); // Changed length to 3
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveWorkout() async {
    final activeWorkoutState = ref.read(activeWorkoutProvider);
    final authState = ref.read(authProvider);
    String? currentUserId;

    if (authState is Authenticated) {
      currentUserId = authState.user.id;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated. Cannot save workout.')),
      );
      return;
    }

    const double dummyIntensity = 7.5;
    ref.read(activeWorkoutProvider.notifier).finishWorkout(dummyIntensity);

    final completedWorkoutData = ref.read(activeWorkoutProvider.notifier).generateCompletedWorkoutData(currentUserId);

    if (completedWorkoutData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout data is incomplete or not finished.')),
      );
      return;
    }

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.saveWorkoutSession(completedWorkoutData);

      await _dbHelper.insertCompletedWorkout(completedWorkoutData, synced: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout saved and synced successfully!')),
      );
    } catch (e) {
      try {
        await _dbHelper.insertCompletedWorkout(completedWorkoutData, synced: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Workout saved locally. Will sync later. Error: $e')),
        );
      } catch (dbError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save workout to API and local DB. Error: $dbError')),
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
    final activeWorkout = ref.watch(activeWorkoutProvider);
    final generatedWorkouts = ref.watch(geminiWorkoutPlanProvider); // Watch the generated workouts

    final generatedMealPlans = ref.watch(
      geminiMealPlanProvider,
    ); // Watch the generated meal plans

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workouts & Plans',
          style: textTheme.titleLarge,
        ), // Updated title
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) => const WorkoutHistoryScreen(),
                ),
              );
            },
            icon: Icon(Icons.history, color: AppColors.primaryForeground),
            label: Text(
              'History',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryForeground,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              foregroundColor: AppColors.primaryForeground,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'WORKOUT'), // Renamed tab
            Tab(text: 'MEAL PLANS'), // New tab
            Tab(text: 'ACTIVE SESSION'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Workout Plan Tab
          _buildWorkoutPlanTabContent(generatedWorkouts),

          // Meal Plan Tab
          _buildMealPlanTabContent(generatedMealPlans),

          // Active Session Tab
          _buildActiveWorkoutTab(activeWorkout),
        ],
      ),
      floatingActionButton:
          _tabController.index == 2 &&
                  !activeWorkout
                      .isStarted // FAB for Active Session only
          ? FloatingActionButton.extended(
              onPressed: () {
                ref.read(activeWorkoutProvider.notifier).startWorkout(name: "New Session");
                ref.read(activeWorkoutProvider.notifier).addExercise(
                      exercise_db.Exercise(
                        exerciseId: 'dummyEx001',
                        name: 'Push Ups',
                        gifUrl: '',
                        bodyParts: ['Chest', 'Triceps'],
                        equipments: ['Bodyweight'],
                        targetMuscles: ['Pectoralis Major'],
                        secondaryMuscles: ['Triceps Brachii', 'Deltoids'],
                        instructions: ['1. Get down on all fours...', '2. Lower your body...']
                      ),
                    );
              },
              label: const Text('Start New Workout'),
              icon: const Icon(Icons.fitness_center),
            )
              : null, // No FAB for plan generation tabs
    );
  }

  Widget _buildActiveWorkoutTab(ActiveWorkoutState activeWorkout) {
    if (!activeWorkout.isStarted) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_run, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text("No active workout session.", style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 10),
            Text(
              "Tap the 'Start New Workout' button to begin.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text("Workout: ${activeWorkout.workoutName}", style: Theme.of(context).textTheme.headlineSmall),
        Text("Started: ${activeWorkout.startTime?.toLocal().toString().substring(0,16) ?? 'Not started'}", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 20),
        if (activeWorkout.exercises.isEmpty)
          const Text("No exercises added yet. Add some!"),
        ...activeWorkout.exercises.map((ex) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ex.baseExercise.name, style: Theme.of(context).textTheme.titleLarge),
                  Text("Equipment: ${ex.baseExercise.equipments.join(', ')}", style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  ...ex.sets.asMap().entries.map((entrySet) {
                    int setIndex = entrySet.key;
                    ActiveWorkoutSet currentSet = entrySet.value;
                    return Row(
                      children: [
                        Expanded(child: Text("Set ${setIndex + 1}:")),
                        Expanded(
                          child: TextFormField(
                            initialValue: currentSet.weight ?? '',
                            decoration: const InputDecoration(labelText: "Weight"),
                            onChanged: (val) => ref.read(activeWorkoutProvider.notifier).updateSet(ex.id, setIndex, val, currentSet.reps, currentSet.isCompleted),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: currentSet.reps ?? '',
                            decoration: const InputDecoration(labelText: "Reps"),
                             onChanged: (val) => ref.read(activeWorkoutProvider.notifier).updateSet(ex.id, setIndex, currentSet.weight, val, currentSet.isCompleted),
                          ),
                        ),
                        Checkbox(
                          value: currentSet.isCompleted,
                          onChanged: (bool? value) {
                            ref.read(activeWorkoutProvider.notifier).toggleSetComplete(ex.id, setIndex);
                          },
                        ),
                      ],
                    );
                  }).toList(),
                  TextButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Add Set"),
                    onPressed: () => ref.read(activeWorkoutProvider.notifier).addSetToExercise(ex.id),
                  )
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 20),
        ElevatedButton.icon(
            onPressed: () {
                ref.read(activeWorkoutProvider.notifier).addExercise(
                      exercise_db.Exercise(
                        exerciseId: 'dummyEx002',
                        name: 'Bicep Curls',
                        gifUrl: '',
                        bodyParts: ['Arms'],
                        equipments: ['Dumbbell'],
                        targetMuscles: ['Biceps'],
                        secondaryMuscles: [],
                        instructions: []
                      ),
                    );
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Exercise (Dummy)")
        ),
        const SizedBox(height: 20),
        if (activeWorkout.isStarted && !activeWorkout.isFinished)
          ElevatedButton(
            onPressed: _handleSaveWorkout,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Finish & Save Workout"),
          ),
      ],
    );
  }

  Widget _buildWorkoutListTab(List<WorkoutSummary> workouts) {
    if (workouts.isEmpty) {
      return const Center(child: Text("No workouts found in this section."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return WorkoutCard(
          workout: workout,
          onTap: () {
            // For generated workouts, we need to fetch the full Workout object
            // from the provider's state, as WorkoutSummary doesn't contain all details.
            final fullWorkout = ref.read(geminiWorkoutPlanProvider).firstWhere(
              (w) => w.id == workout.id,
              orElse: () => throw Exception('Workout not found in provider state'),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutDetailScreen(
                  workoutDetail: fullWorkout,
                  workoutPlan: fullWorkout,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWorkoutPlanTabContent(List<Workout> generatedWorkouts) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkoutPlanGeneratorScreen(),
                  ),
                );
              },
              label: const Text('Generate New Workout Plan'),
              icon: const Icon(Icons.add),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
        Expanded(
          child:
              generatedWorkouts.isEmpty
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 80, color: Colors.grey),
                        SizedBox(height: 20),
                        Text(
                          "No generated workout plans yet.",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Tap 'Generate New Workout Plan' above.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : _buildWorkoutListTab(
                    generatedWorkouts
                        .map((w) => WorkoutSummary.fromWorkout(w))
                        .toList(),
                  ),
        ),
      ],
    );
  }

  Widget _buildMealPlanTabContent(List<MealPlan> generatedMealPlans) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MealPlanGeneratorScreen(),
                  ),
                );
              },
              label: const Text('Generate New Meal Plan'),
              icon: const Icon(Icons.add),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
        Expanded(
          child:
              generatedMealPlans.isEmpty
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "No generated meal plans yet.",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Tap 'Generate New Meal Plan' above.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : _buildMealPlanListTab(generatedMealPlans),
        ),
      ],
    );
  }

  Widget _buildMealPlanListTab(List<MealPlan> mealPlans) {
    if (mealPlans.isEmpty) {
      return const Center(child: Text("No meal plans found in this section."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: mealPlans.length,
      itemBuilder: (context, index) {
        final mealPlan = mealPlans[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealPlanDetailScreen(mealPlan: mealPlan),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealPlan.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mealPlan.description ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Calories: ${mealPlan.meals.fold<int>(0, (sum, meal) => sum + (meal.calories ?? 0))}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Total Protein: ${mealPlan.meals.fold<double>(0.0, (sum, meal) => sum + (meal.macronutrients?['protein'] ?? 0.0)).toStringAsFixed(1)}g',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Total Carbs: ${mealPlan.meals.fold<double>(0.0, (sum, meal) => sum + (meal.macronutrients?['carbs'] ?? 0.0)).toStringAsFixed(1)}g',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Total Fat: ${mealPlan.meals.fold<double>(0.0, (sum, meal) => sum + (meal.macronutrients?['fat'] ?? 0.0)).toStringAsFixed(1)}g',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
