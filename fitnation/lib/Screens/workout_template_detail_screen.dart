import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/WorkoutTemplate.dart';
import '../providers/workout_templates_provider.dart';

class WorkoutTemplateDetailScreen extends ConsumerStatefulWidget {
  final String templateId;

  const WorkoutTemplateDetailScreen({super.key, required this.templateId});

  @override
  ConsumerState<WorkoutTemplateDetailScreen> createState() =>
      _WorkoutTemplateDetailScreenState();
}

class _WorkoutTemplateDetailScreenState
    extends ConsumerState<WorkoutTemplateDetailScreen> {
  final TextEditingController _customNameController = TextEditingController();

  @override
  void dispose() {
    _customNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templateAsync = ref.watch(workoutTemplateProvider(widget.templateId));
    final importState = ref.watch(importTemplateProvider);

    return Scaffold(
      body: templateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load template',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
        data:
            (template) => Stack(
              children: [
                _buildTemplateDetail(template, importState),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.extended(
                    onPressed:
                        importState.isLoading
                            ? null
                            : () => _showImportDialog(template),
                    icon:
                        importState.isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.download),
                    label: Text(
                      importState.isLoading
                          ? 'Importing...'
                          : 'Import Template',
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildTemplateDetail(
    WorkoutTemplate template,
    AsyncValue<ImportTemplateResponse?> importState,
  ) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        // App Bar with Template Info
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              template.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withOpacity(0.8),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60), // Space for app bar
                    Row(
                      children: [
                        Text(
                          template.difficultyEmoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          template.difficultyLevel.toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          template.displayDuration,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Template Details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author and Basic Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Text(
                                template.author[0].toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Created by',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    template.author,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (template.description != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            template.description!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildInfoChip(
                              Icons.fitness_center,
                              '${template.exercises.length} exercises',
                              theme,
                            ),
                            _buildInfoChip(
                              Icons.schedule,
                              template.displayDuration,
                              theme,
                            ),
                            _buildInfoChip(
                              Icons.trending_up,
                              template.difficultyLevel.capitalize(),
                              theme,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Target Muscle Groups
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target Muscle Groups',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              template.primaryMuscleGroups
                                  .map(
                                    (group) => Chip(
                                      label: Text(group.capitalize()),
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Equipment Required
                if (template.equipmentRequired.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Equipment Required',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                template.equipmentRequired
                                    .map(
                                      (equipment) => Chip(
                                        label: Text(equipment.capitalize()),
                                        backgroundColor:
                                            theme.colorScheme.surfaceVariant,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Tags
                if (template.tags.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tags',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                template.tags
                                    .map(
                                      (tag) => Chip(
                                        label: Text('#$tag'),
                                        backgroundColor:
                                            theme.colorScheme.tertiaryContainer,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Exercises List
                Text(
                  'Exercises',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        // Exercises List
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final exercise = template.exercises[index];
            return _buildExerciseCard(exercise, index + 1, theme);
          }, childCount: template.exercises.length),
        ),
        // Bottom padding for FAB
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, ThemeData theme) {
    return Chip(
      avatar: Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
      label: Text(label),
      backgroundColor: theme.colorScheme.surfaceVariant,
      labelStyle: theme.textTheme.bodySmall,
    );
  }

  Widget _buildExerciseCard(
    WorkoutTemplateExercise exercise,
    int order,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    order.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exercise.exerciseName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildExerciseInfo(
                  'Sets',
                  exercise.defaultSets.toString(),
                  theme,
                ),
                const SizedBox(width: 16),
                _buildExerciseInfo('Reps', exercise.defaultReps, theme),
                if (exercise.defaultWeight != null) ...[
                  const SizedBox(width: 16),
                  _buildExerciseInfo('Weight', exercise.defaultWeight!, theme),
                ],
              ],
            ),
            if (exercise.restTimeSeconds != null) ...[
              const SizedBox(height: 8),
              _buildExerciseInfo(
                'Rest',
                '${exercise.restTimeSeconds! ~/ 60}:${(exercise.restTimeSeconds! % 60).toString().padLeft(2, '0')} min',
                theme,
              ),
            ],
            if (exercise.notes != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  exercise.notes!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            if (exercise.exerciseEquipments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    exercise.exerciseEquipments
                        .map(
                          (equipment) => Chip(
                            label: Text(equipment),
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            labelStyle: theme.textTheme.bodySmall,
                          ),
                        )
                        .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseInfo(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showImportDialog(WorkoutTemplate template) {
    _customNameController.text = template.name;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Import Template'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Import "${template.name}" to your workout plans?'),
                const SizedBox(height: 16),
                TextField(
                  controller: _customNameController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Name (Optional)',
                    hintText: 'Leave empty to use original name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _importTemplate(template.id);
                },
                child: const Text('Import'),
              ),
            ],
          ),
    );
  }

  void _importTemplate(String templateId) async {
    final customName = _customNameController.text.trim();
    await ref
        .read(importTemplateProvider.notifier)
        .importTemplate(
          templateId,
          customName: customName.isEmpty ? null : customName,
        );

    if (mounted) {
      final importState = ref.read(importTemplateProvider);
      importState.when(
        data: (response) {
          if (response?.success == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response!.message),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'View',
                  onPressed: () {
                    // Navigate to workout plans or back to workout screen
                    Navigator.pop(context);
                  },
                ),
              ),
            );
            // Reset the import state
            ref.read(importTemplateProvider.notifier).resetState();
          }
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Import failed: $error'),
              backgroundColor: Colors.red,
            ),
          );
          // Reset the import state
          ref.read(importTemplateProvider.notifier).resetState();
        },
        loading: () {},
      );
    }
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
