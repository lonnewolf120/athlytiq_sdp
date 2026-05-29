import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/models/CompletedWorkout.dart';
import 'package:fitnation/models/PostModel.dart';
import 'package:fitnation/models/WorkoutPostModel.dart';
import 'package:fitnation/models/Exercise.dart' as ex_db;
import 'package:fitnation/providers/data_providers.dart';

class WorkoutCompletionScreen extends ConsumerStatefulWidget {
  final CompletedWorkout completedWorkout;

  const WorkoutCompletionScreen({super.key, required this.completedWorkout});

  @override
  ConsumerState<WorkoutCompletionScreen> createState() => _WorkoutCompletionScreenState();
}

class _WorkoutCompletionScreenState extends ConsumerState<WorkoutCompletionScreen>
    with SingleTickerProviderStateMixin {
  bool _sharing = false;
  bool _shared = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  CompletedWorkout get w => widget.completedWorkout;

  int get _durationMinutes => (w.durationSeconds / 60).round();
  int get _exerciseCount => w.exercises.length;
  int get _totalSets => w.exercises.fold(0, (sum, ex) => sum + ex.sets.length);

  int get _totalVolume {
    int vol = 0;
    for (final ex in w.exercises) {
      for (final s in ex.sets) {
        final weight = double.tryParse(
              s.weight.replaceAll(RegExp(r'[a-zA-Z\s]'), ''),
            ) ??
            0;
        final reps = int.tryParse(s.reps) ?? 0;
        vol += (weight * reps).toInt();
      }
    }
    return vol;
  }

  String get _intensityLabel {
    final score = w.intensityScore;
    if (score >= 9) return 'Max Effort';
    if (score >= 7) return 'Hard';
    if (score >= 5) return 'Moderate';
    return 'Easy';
  }

  Future<void> _shareToFeed() async {
    setState(() => _sharing = true);
    try {
      final apiService = ref.read(apiServiceProvider);

      // Build exercise list for the post (name + equipment only)
      final exercises = w.exercises
          .map((ex) => ex_db.Exercise(
                exerciseId: ex.exerciseId,
                name: ex.exerciseName,
                gifUrl: ex.exerciseGifUrl,
                bodyParts: const [],
                equipments: ex.exerciseEquipments ?? const [],
                targetMuscles: const [],
                secondaryMuscles: const [],
                instructions: const [],
              ))
          .toList();

      final post = Post.create(
        content: '💪 Just finished ${w.workoutName}!\n'
            '$_durationMinutes min · $_exerciseCount exercises · $_totalSets sets',
        postType: [PostType.workout],
        workoutData: WorkoutPostData(
          workoutType: w.workoutName,
          durationMinutes: _durationMinutes,
          caloriesBurned: 0, // not tracked yet
          exercises: exercises,
        ),
      );

      await apiService.createPost(post);
      if (mounted) setState(() => _shared = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                    child: const Text('Done'),
                  ),
                ],
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Animated trophy icon
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            size: 48,
                            color: cs.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text('Workout Complete!', style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        w.workoutName,
                        style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Stats card
                      Container(
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                              value: '$_durationMinutes',
                              unit: 'min',
                              label: 'Duration',
                              icon: Icons.timer_outlined,
                              color: cs.primary,
                            ),
                            _Divider(),
                            _StatItem(
                              value: '$_exerciseCount',
                              unit: '',
                              label: 'Exercises',
                              icon: Icons.fitness_center_rounded,
                              color: cs.secondary,
                            ),
                            _Divider(),
                            _StatItem(
                              value: '$_totalSets',
                              unit: '',
                              label: 'Sets',
                              icon: Icons.repeat_rounded,
                              color: cs.tertiary,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Volume + intensity row
                      Row(
                        children: [
                          Expanded(
                            child: _InfoTile(
                              label: 'Total Volume',
                              value: _totalVolume > 0 ? '${_totalVolume} kg' : '—',
                              icon: Icons.bar_chart_rounded,
                              cs: cs,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoTile(
                              label: 'Intensity',
                              value: _intensityLabel,
                              icon: Icons.bolt_rounded,
                              cs: cs,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Exercise list
                      if (w.exercises.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Exercises', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 8),
                        ...w.exercises.map((ex) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(ex.exerciseName, style: tt.bodyMedium)),
                                  Text(
                                    '${ex.sets.length} sets',
                                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),

              // Share button
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: _shared
                    ? FilledButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Shared to Community'),
                      )
                    : FilledButton.icon(
                        onPressed: _sharing ? null : _shareToFeed,
                        icon: _sharing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.share_rounded),
                        label: const Text('Share to Community'),
                      ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.value,
    required this.unit,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            text: value,
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: color),
            children: [
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: tt.bodySmall?.copyWith(color: color),
                ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: tt.bodySmall),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 48, color: Theme.of(context).colorScheme.outlineVariant);
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ColorScheme cs;

  const _InfoTile({required this.label, required this.value, required this.icon, required this.cs});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                Text(value, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
