import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/Exercise.dart';
import '../../models/PlannedExercise.dart';
import '../../models/Workout.dart';
import '../../providers/gemini_workout_provider.dart';
import '../../providers/exercise_search_provider.dart';
import '../../widgets/exercise_card.dart';

class AddManualPlanScreen extends ConsumerStatefulWidget {
  const AddManualPlanScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddManualPlanScreen> createState() =>
      _AddManualPlanScreenState();
}

class _AddManualPlanScreenState extends ConsumerState<AddManualPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _planNameController = TextEditingController();
  final _searchController = TextEditingController();
  final List<PlannedExercise> _selectedExercises = [];

  String? _selectedBodyPart;
  String? _selectedEquipment;
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    // Load exercise database when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exerciseSearchProvider.notifier).loadInitialData();
    });

    // Setup search listener
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      setState(() {
        _showSearchResults = query.isNotEmpty;
      });

      if (query.isNotEmpty) {
        ref
            .read(exerciseSearchProvider.notifier)
            .searchExercises(
              query: query,
              bodyPart: _selectedBodyPart,
              equipment: _selectedEquipment,
            );
      }
    });
  }

  @override
  void dispose() {
    _planNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addExerciseToWorkout(Exercise exercise) {
    // Check if exercise is already added
    final existingIndex = _selectedExercises.indexWhere(
      (e) => e.exerciseId == exercise.exerciseId,
    );

    if (existingIndex != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${exercise.name} is already in your workout plan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show dialog to configure sets, reps, etc.
    _showExerciseConfigDialog(exercise);
  }

  void _showExerciseConfigDialog(Exercise exercise) {
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');
    final weightController = TextEditingController();
    final restController = TextEditingController(text: '60');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Configure ${exercise.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Exercise info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Body Parts: ${exercise.bodyParts.join(', ')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Equipment: ${exercise.equipments.join(', ')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Target: ${exercise.targetMuscles.join(', ')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sets input
                  TextFormField(
                    controller: setsController,
                    decoration: const InputDecoration(
                      labelText: 'Sets',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  // Reps input
                  TextFormField(
                    controller: repsController,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  // Weight input (optional)
                  TextFormField(
                    controller: weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (optional)',
                      border: OutlineInputBorder(),
                      suffixText: 'kg',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  // Rest time input
                  TextFormField(
                    controller: restController,
                    decoration: const InputDecoration(
                      labelText: 'Rest Time (seconds)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final sets = int.tryParse(setsController.text) ?? 3;
                  final reps = int.tryParse(repsController.text) ?? 10;
                  final weight = weightController.text.trim();
                  final restTime = int.tryParse(restController.text) ?? 60;

                  final plannedExercise = PlannedExercise(
                    exerciseId: exercise.exerciseId ?? '',
                    exerciseName: exercise.name,
                    plannedSets: sets,
                    plannedReps: reps,
                    plannedWeight: weight.isNotEmpty ? weight : null,
                    exerciseEquipments: exercise.equipments,
                    exerciseGifUrl: exercise.gifUrl,
                  );
                  setState(() {
                    _selectedExercises.add(plannedExercise);
                  });

                  Navigator.pop(context);

                  // Clear search to hide results
                  _searchController.clear();
                  setState(() {
                    _showSearchResults = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${exercise.name} added to workout plan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Add Exercise'),
              ),
            ],
          ),
    );
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
    });
  }

  void _savePlan() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise to the plan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final workout = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _planNameController.text.trim(),
      exercises: _selectedExercises,
    );

    // Add to the workout plans provider
    ref.read(geminiWorkoutPlanProvider.notifier).addPlan(workout);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Workout plan created successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final searchState = ref.watch(exerciseSearchProvider);
    final bodyPartsAsync = ref.watch(exerciseBodyPartsProvider);
    final equipmentsAsync = ref.watch(exerciseEquipmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Manual Plan'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          FilledButton(
            onPressed: _savePlan,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Save Plan'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Plan details section
            Container(
              padding: const EdgeInsets.all(16),
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan name input
                  TextFormField(
                    controller: _planNameController,
                    decoration: InputDecoration(
                      labelText: 'Workout Plan Name',
                      hintText: 'e.g., Upper Body Strength',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a plan name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Selected exercises count
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Exercises: ${_selectedExercises.length}',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Exercise search section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Exercises',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for exercises...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _showSearchResults = false;
                                  });
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Filters row
                  Row(
                    children: [
                      // Body part filter
                      Expanded(
                        child: bodyPartsAsync.when(
                          data:
                              (bodyParts) => DropdownButtonFormField<String>(
                                value: _selectedBodyPart,
                                decoration: InputDecoration(
                                  labelText: 'Body Part',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('All'),
                                  ),
                                  ...bodyParts.map(
                                    (part) => DropdownMenuItem<String>(
                                      value: part,
                                      child: Text(
                                        part
                                            .split(' ')
                                            .map(
                                              (word) =>
                                                  word[0].toUpperCase() +
                                                  word.substring(1),
                                            )
                                            .join(' '),
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedBodyPart = value;
                                  });
                                  if (_searchController.text.isNotEmpty) {
                                    ref
                                        .read(exerciseSearchProvider.notifier)
                                        .searchExercises(
                                          query: _searchController.text,
                                          bodyPart: _selectedBodyPart,
                                          equipment: _selectedEquipment,
                                        );
                                  }
                                },
                              ),
                          loading: () => const SizedBox(height: 56),
                          error: (_, __) => const SizedBox(height: 56),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Equipment filter
                      Expanded(
                        child: equipmentsAsync.when(
                          data:
                              (equipments) => DropdownButtonFormField<String>(
                                value: _selectedEquipment,
                                decoration: InputDecoration(
                                  labelText: 'Equipment',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('All'),
                                  ),
                                  ...equipments.map(
                                    (equipment) => DropdownMenuItem<String>(
                                      value: equipment,
                                      child: Text(
                                        equipment
                                            .split(' ')
                                            .map(
                                              (word) =>
                                                  word[0].toUpperCase() +
                                                  word.substring(1),
                                            )
                                            .join(' '),
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEquipment = value;
                                  });
                                  if (_searchController.text.isNotEmpty) {
                                    ref
                                        .read(exerciseSearchProvider.notifier)
                                        .searchExercises(
                                          query: _searchController.text,
                                          bodyPart: _selectedBodyPart,
                                          equipment: _selectedEquipment,
                                        );
                                  }
                                },
                              ),
                          loading: () => const SizedBox(height: 56),
                          error: (_, __) => const SizedBox(height: 56),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Results section
            Expanded(
              child:
                  _showSearchResults
                      ? _buildSearchResults(searchState, colorScheme)
                      : _buildSelectedExercises(colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    AsyncValue<ExerciseSearchState> searchState,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Results',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: searchState.when(
              data: (data) {
                if (data.exercises.isEmpty && !data.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No exercises found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: data.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = data.exercises[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ExerciseCard(
                        exercise: exercise,
                        onTap: () => _showExerciseDetails(exercise),
                        onAddToWorkout: () => _addExerciseToWorkout(exercise),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading exercises',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedExercises(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Exercises (${_selectedExercises.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (_selectedExercises.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedExercises.clear();
                    });
                  },
                  child: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child:
                _selectedExercises.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center_outlined,
                            size: 64,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No exercises selected yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Search and add exercises to build your workout plan',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _selectedExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _selectedExercises[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.fitness_center,
                                color: colorScheme.onPrimaryContainer,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              exercise.exerciseName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${exercise.plannedSets} sets × ${exercise.plannedReps} reps'
                              '${exercise.plannedWeight != null ? ' @ ${exercise.plannedWeight}' : ''}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // TODO: Implement edit exercise functionality
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Edit functionality coming soon',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _removeExercise(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  void _showExerciseDetails(Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exercise name and GIF
                        Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        if (exercise.gifUrl != null)
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                exercise.gifUrl!,
                                fit: BoxFit.contain,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Exercise details
                        _buildDetailRow('Body Parts', exercise.bodyParts),
                        _buildDetailRow('Equipment', exercise.equipments),
                        _buildDetailRow(
                          'Target Muscles',
                          exercise.targetMuscles,
                        ),
                        if (exercise.secondaryMuscles.isNotEmpty)
                          _buildDetailRow(
                            'Secondary Muscles',
                            exercise.secondaryMuscles,
                          ),

                        if (exercise.instructions.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Instructions',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...exercise.instructions.map(
                            (instruction) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(instruction),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Add to workout button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _addExerciseToWorkout(exercise);
                            },
                            child: const Text('Add to Workout Plan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailRow(String label, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children:
                  items
                      .map(
                        (item) => Chip(
                          label: Text(
                            item,
                            style: const TextStyle(fontSize: 12),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
