import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

// Enum for different generation steps
enum WorkoutGenerationStep {
  idle,
  requestSent,
  parsing,
  processing,
  handling,
  completed,
  error,
}

// State class for workout generation
class WorkoutGenerationState {
  final WorkoutGenerationStep step;
  final String? message;
  final String? errorMessage;
  final double progress; // 0.0 to 1.0

  const WorkoutGenerationState({
    required this.step,
    this.message,
    this.errorMessage,
    required this.progress,
  });

  WorkoutGenerationState copyWith({
    WorkoutGenerationStep? step,
    String? message,
    String? errorMessage,
    double? progress,
  }) {
    return WorkoutGenerationState(
      step: step ?? this.step,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  bool get isGenerating =>
      step != WorkoutGenerationStep.idle &&
      step != WorkoutGenerationStep.completed &&
      step != WorkoutGenerationStep.error;

  bool get hasError => step == WorkoutGenerationStep.error;
  bool get isCompleted => step == WorkoutGenerationStep.completed;
}

// StateNotifier for managing workout generation progress
class WorkoutGenerationNotifier extends StateNotifier<WorkoutGenerationState> {
  Timer? _autoResetTimer;

  WorkoutGenerationNotifier()
    : super(
        const WorkoutGenerationState(
          step: WorkoutGenerationStep.idle,
          progress: 0.0,
        ),
      );

  @override
  void dispose() {
    _autoResetTimer?.cancel();
    super.dispose();
  }

  void startGeneration() {
    debugPrint('WorkoutGenerationNotifier: Starting generation...');
    state = state.copyWith(
      step: WorkoutGenerationStep.requestSent,
      message: 'Sending request to AI...',
      progress: 0.2,
      errorMessage: null,
    );
  }

  void updateParsingStep() {
    debugPrint('WorkoutGenerationNotifier: Parsing response...');
    state = state.copyWith(
      step: WorkoutGenerationStep.parsing,
      message: 'Parsing AI response...',
      progress: 0.4,
    );
  }

  void updateProcessingStep() {
    debugPrint('WorkoutGenerationNotifier: Processing workout...');
    state = state.copyWith(
      step: WorkoutGenerationStep.processing,
      message: 'Processing workout plan...',
      progress: 0.6,
    );
  }

  void updateHandlingStep() {
    debugPrint('WorkoutGenerationNotifier: Handling final steps...');
    state = state.copyWith(
      step: WorkoutGenerationStep.handling,
      message: 'Finalizing your workout plan...',
      progress: 0.8,
    );
  }

  void completeGeneration() {
    debugPrint('WorkoutGenerationNotifier: Generation completed!');
    state = state.copyWith(
      step: WorkoutGenerationStep.completed,
      message: 'Workout plan generated successfully!',
      progress: 1.0,
    );

    // Auto-reset after 10 seconds
    _startAutoResetTimer();
  }

  void _startAutoResetTimer() {
    _autoResetTimer?.cancel();
    _autoResetTimer = Timer(const Duration(seconds: 10), () {
      if (state.isCompleted) {
        reset();
      }
    });
  }

  void setError(String errorMessage) {
    debugPrint('WorkoutGenerationNotifier: Error occurred: $errorMessage');
    state = state.copyWith(
      step: WorkoutGenerationStep.error,
      message: null,
      errorMessage: errorMessage,
      progress: 0.0,
    );

    // Auto-reset errors after 15 seconds
    _autoResetTimer?.cancel();
    _autoResetTimer = Timer(const Duration(seconds: 15), () {
      if (state.hasError) {
        reset();
      }
    });
  }

  void reset() {
    debugPrint('WorkoutGenerationNotifier: Resetting state...');
    _autoResetTimer?.cancel();
    state = const WorkoutGenerationState(
      step: WorkoutGenerationStep.idle,
      progress: 0.0,
    );
  }
}

// Provider for workout generation state
final workoutGenerationProvider =
    StateNotifierProvider<WorkoutGenerationNotifier, WorkoutGenerationState>((
      ref,
    ) {
      return WorkoutGenerationNotifier();
    });
