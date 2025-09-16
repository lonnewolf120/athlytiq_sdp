import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/Exercise.dart';
import '../providers/exercise_search_provider.dart';
import '../widgets/exercise_card.dart';
import '../widgets/exercise_filters.dart';

class ExerciseSearchPage extends ConsumerStatefulWidget {
  const ExerciseSearchPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ExerciseSearchPage> createState() => _ExerciseSearchPageState();
}

class _ExerciseSearchPageState extends ConsumerState<ExerciseSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _selectedBodyPart;
  String? _selectedEquipment;
  String? _selectedTargetMuscle;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();

    // Load exercises data when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exerciseSearchProvider.notifier).loadInitialData();
    });

    // Setup infinite scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreExercises();
      }
    });

    // Setup search debouncing
    _searchController.addListener(() {
      ref
          .read(exerciseSearchProvider.notifier)
          .searchExercises(
            query: _searchController.text,
            bodyPart: _selectedBodyPart,
            equipment: _selectedEquipment,
            targetMuscle: _selectedTargetMuscle,
          );
    });
  }

  void _loadMoreExercises() {
    ref
        .read(exerciseSearchProvider.notifier)
        .loadMoreExercises(
          query: _searchController.text,
          bodyPart: _selectedBodyPart,
          equipment: _selectedEquipment,
          targetMuscle: _selectedTargetMuscle,
        );
  }

  void _clearFilters() {
    setState(() {
      _selectedBodyPart = null;
      _selectedEquipment = null;
      _selectedTargetMuscle = null;
    });
    _searchExercises();
  }

  void _searchExercises() {
    ref
        .read(exerciseSearchProvider.notifier)
        .searchExercises(
          query: _searchController.text,
          bodyPart: _selectedBodyPart,
          equipment: _selectedEquipment,
          targetMuscle: _selectedTargetMuscle,
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(exerciseSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Search'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade50,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchExercises();
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Filters Section
          if (_showFilters)
            ExerciseFilters(
              selectedBodyPart: _selectedBodyPart,
              selectedEquipment: _selectedEquipment,
              selectedTargetMuscle: _selectedTargetMuscle,
              onBodyPartChanged: (value) {
                setState(() {
                  _selectedBodyPart = value;
                });
                _searchExercises();
              },
              onEquipmentChanged: (value) {
                setState(() {
                  _selectedEquipment = value;
                });
                _searchExercises();
              },
              onTargetMuscleChanged: (value) {
                setState(() {
                  _selectedTargetMuscle = value;
                });
                _searchExercises();
              },
              onClearFilters: _clearFilters,
            ),

          // Active Filters Chips
          if (_selectedBodyPart != null ||
              _selectedEquipment != null ||
              _selectedTargetMuscle != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Wrap(
                spacing: 8.0,
                children: [
                  if (_selectedBodyPart != null)
                    Chip(
                      label: Text('Body: $_selectedBodyPart'),
                      onDeleted: () {
                        setState(() {
                          _selectedBodyPart = null;
                        });
                        _searchExercises();
                      },
                    ),
                  if (_selectedEquipment != null)
                    Chip(
                      label: Text('Equipment: $_selectedEquipment'),
                      onDeleted: () {
                        setState(() {
                          _selectedEquipment = null;
                        });
                        _searchExercises();
                      },
                    ),
                  if (_selectedTargetMuscle != null)
                    Chip(
                      label: Text('Muscle: $_selectedTargetMuscle'),
                      onDeleted: () {
                        setState(() {
                          _selectedTargetMuscle = null;
                        });
                        _searchExercises();
                      },
                    ),
                ],
              ),
            ),

          // Results
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
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: data.exercises.length + (data.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == data.exercises.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final exercise = data.exercises[index];
                    return ExerciseCard(
                      exercise: exercise,
                      onTap: () => _showExerciseDetails(exercise),
                      onAddToWorkout: () => _addToWorkout(exercise),
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
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(exerciseSearchProvider.notifier)
                                .loadInitialData();
                          },
                          child: const Text('Retry'),
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
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
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
                              child: Text(
                                instruction,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Add to workout button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _addToWorkout(exercise);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Add to Workout'),
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

  void _addToWorkout(Exercise exercise) {
    // TODO: Implement add to workout functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${exercise.name} added to workout!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
