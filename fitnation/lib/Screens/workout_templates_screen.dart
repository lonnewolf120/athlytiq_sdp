import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/WorkoutTemplate.dart';
import '../providers/workout_templates_provider.dart';
import 'workout_template_detail_screen.dart';

class WorkoutTemplatesScreen extends ConsumerStatefulWidget {
  const WorkoutTemplatesScreen({super.key});

  @override
  ConsumerState<WorkoutTemplatesScreen> createState() =>
      _WorkoutTemplatesScreenState();
}

class _WorkoutTemplatesScreenState
    extends ConsumerState<WorkoutTemplatesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedAuthor;
  String? _selectedDifficulty;
  String? _selectedMuscleGroup;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutTemplatesProvider.notifier).loadTemplates();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = TemplateFilters(
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
      author: _selectedAuthor,
      difficultyLevel: _selectedDifficulty,
      muscleGroups: _selectedMuscleGroup,
    );
    ref.read(workoutTemplatesProvider.notifier).applyFilters(filters);
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedAuthor = null;
      _selectedDifficulty = null;
      _selectedMuscleGroup = null;
    });
    ref.read(workoutTemplatesProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templatesState = ref.watch(workoutTemplatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Templates'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(workoutTemplatesProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search templates...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilters();
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.background,
                  ),
                  onChanged: (value) {
                    // Debounce search
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_searchController.text == value) {
                        _applyFilters();
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        'Author',
                        _selectedAuthor,
                        () => _showAuthorFilter(),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Difficulty',
                        _selectedDifficulty,
                        () => _showDifficultyFilter(),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Muscle Group',
                        _selectedMuscleGroup,
                        () => _showMuscleGroupFilter(),
                      ),
                      const SizedBox(width: 8),
                      if (_hasActiveFilters())
                        ActionChip(
                          label: const Text('Clear All'),
                          onPressed: _clearFilters,
                          backgroundColor: theme.colorScheme.errorContainer,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Templates List
          Expanded(child: _buildTemplatesList(templatesState)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, VoidCallback onTap) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(value ?? label),
      selected: value != null,
      onSelected: (_) => onTap(),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
    );
  }

  bool _hasActiveFilters() {
    return _searchController.text.isNotEmpty ||
        _selectedAuthor != null ||
        _selectedDifficulty != null ||
        _selectedMuscleGroup != null;
  }

  Widget _buildTemplatesList(WorkoutTemplatesState state) {
    if (state.isLoading && state.templates.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load templates',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(workoutTemplatesProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No templates found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your filters or search terms',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            state.hasMore &&
            !state.isLoading) {
          ref.read(workoutTemplatesProvider.notifier).loadMoreTemplates();
        }
        return false;
      },
      child: _isGridView ? _buildGridView(state) : _buildListView(state),
    );
  }

  Widget _buildGridView(WorkoutTemplatesState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: state.templates.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.templates.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildTemplateCard(state.templates[index]);
      },
    );
  }

  Widget _buildListView(WorkoutTemplatesState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.templates.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.templates.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return _buildTemplateListItem(state.templates[index]);
      },
    );
  }

  Widget _buildTemplateCard(WorkoutTemplate template) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _navigateToDetail(template),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with difficulty and duration
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    template.difficultyEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    template.displayDuration,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${template.author}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      template.primaryMuscleGroupsDisplay,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (template.exerciseCount != null)
                      Row(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${template.exerciseCount} exercises',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateListItem(WorkoutTemplate template) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            template.difficultyEmoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          template.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('by ${template.author}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  template.primaryMuscleGroupsDisplay,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(template.displayDuration),
                if (template.exerciseCount != null) ...[
                  const SizedBox(width: 8),
                  Text('${template.exerciseCount} exercises'),
                ],
              ],
            ),
          ],
        ),
        onTap: () => _navigateToDetail(template),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  void _navigateToDetail(WorkoutTemplate template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => WorkoutTemplateDetailScreen(templateId: template.id),
      ),
    );
  }

  void _showAuthorFilter() async {
    final authors = await ref.read(templateAuthorsProvider.future);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder:
          (context) => _buildFilterBottomSheet(
            'Select Author',
            authors,
            _selectedAuthor,
            (value) {
              setState(() {
                _selectedAuthor = value;
              });
              _applyFilters();
            },
          ),
    );
  }

  void _showDifficultyFilter() {
    final difficulties = ['beginner', 'intermediate', 'advanced'];
    showModalBottomSheet(
      context: context,
      builder:
          (context) => _buildFilterBottomSheet(
            'Select Difficulty',
            difficulties,
            _selectedDifficulty,
            (value) {
              setState(() {
                _selectedDifficulty = value;
              });
              _applyFilters();
            },
          ),
    );
  }

  void _showMuscleGroupFilter() async {
    final muscleGroups = await ref.read(templateMuscleGroupsProvider.future);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder:
          (context) => _buildFilterBottomSheet(
            'Select Muscle Group',
            muscleGroups,
            _selectedMuscleGroup,
            (value) {
              setState(() {
                _selectedMuscleGroup = value;
              });
              _applyFilters();
            },
          ),
    );
  }

  Widget _buildFilterBottomSheet(
    String title,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('All'),
            trailing: selectedValue == null ? const Icon(Icons.check) : null,
            onTap: () {
              onChanged(null);
              Navigator.pop(context);
            },
          ),
          ...options.map(
            (option) => ListTile(
              title: Text(StringCapitalize(option).capitalize()),
              trailing:
                  selectedValue == option ? const Icon(Icons.check) : null,
              onTap: () {
                onChanged(option);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
