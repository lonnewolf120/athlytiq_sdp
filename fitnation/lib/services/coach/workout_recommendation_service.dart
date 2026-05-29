import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:fitnation/models/PlannedExercise.dart';
import 'package:fitnation/models/Workout.dart';
import 'package:fitnation/services/coach/ai_json.dart';
import 'package:fitnation/services/coach/exercise_resolver.dart';
import 'package:fitnation/services/coach/history/workout_history_summarizer.dart';
import 'package:uuid/uuid.dart';

/// Injectable interface so tests avoid network/Firebase.
abstract class ContentGenerator {
  Future<String?> generate(String prompt);
}

class GeminiContentGenerator implements ContentGenerator {
  final GenerativeModel _model;
  GeminiContentGenerator(this._model);

  @override
  Future<String?> generate(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    if (response.candidates.isEmpty) return null;
    final candidate = response.candidates[0];
    final parts = candidate.content?.parts;
    if (parts == null) return null;
    return parts.whereType<TextPart>().map((p) => p.text).join();
  }
}

class WorkoutRecommendationService {
  final ContentGenerator _generator;
  final ExerciseResolver _resolver;
  final ExerciseCatalog _catalog;
  static const _uuid = Uuid();

  WorkoutRecommendationService({
    required ContentGenerator generator,
    required ExerciseCatalog catalog,
  })  : _generator = generator,
        _resolver = ExerciseResolver(catalog),
        _catalog = catalog;

  factory WorkoutRecommendationService.withFirebase(ExerciseCatalog catalog) {
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash-preview-05-20',
    );
    return WorkoutRecommendationService(
      generator: GeminiContentGenerator(model),
      catalog: catalog,
    );
  }

  Future<Workout?> generate({
    required Map<String, dynamic> userProfile,
    required Map<String, ExerciseProgressHint> progressHints,
  }) async {
    final bodyParts = await _catalog.getUniqueBodyParts();
    final userEquipment = _parseEquipment(userProfile);
    final candidateNames = await _buildCandidateNames(userEquipment, bodyParts);

    final prompt = _buildPrompt(
      userProfile: userProfile,
      progressHints: progressHints,
      bodyParts: bodyParts,
      availableEquipment: userEquipment,
      candidateNames: candidateNames,
    );

    debugPrint('WorkoutRecommendationService: sending prompt (${prompt.length} chars)');
    final raw = await _generator.generate(prompt);
    if (raw == null || raw.trim().isEmpty) {
      debugPrint('WorkoutRecommendationService: empty model response');
      return null;
    }

    final String jsonStr;
    try {
      jsonStr = AiJson.extract(raw);
    } catch (e) {
      debugPrint('WorkoutRecommendationService: JSON extraction failed: $e');
      return null;
    }

    final List<AiExerciseItem> aiItems;
    try {
      aiItems = _parseItems(jsonStr);
    } catch (e) {
      debugPrint('WorkoutRecommendationService: item parse failed: $e');
      return null;
    }

    if (aiItems.isEmpty) return null;

    final result = await _resolver.resolve(
      aiItems: aiItems,
      fallbackBodyParts: bodyParts.take(3).toList(),
    );

    debugPrint(
        'WorkoutRecommendationService: resolved ${result.resolved.length}, unresolved ${result.unresolved.length}');

    if (result.resolved.isEmpty) return null;

    final exercises = result.resolved
        .map((r) => PlannedExercise(
              exerciseId: r.exercise.exerciseId ?? '',
              exerciseName: r.exercise.name,
              exerciseGifUrl: r.exercise.gifUrl,
              exerciseEquipments: r.exercise.equipments,
              plannedSets: r.plannedSets,
              plannedReps: r.plannedReps,
              plannedWeight: r.plannedWeight.isEmpty ? null : r.plannedWeight,
            ))
        .toList();

    final goal = userProfile['goal']?.toString() ?? 'General Fitness';
    return Workout(
      id: _uuid.v4(),
      name: 'AI Workout — $goal',
      exercises: exercises,
    );
  }

  List<String> _parseEquipment(Map<String, dynamic> profile) {
    final raw = profile['equipment'];
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is String) {
      return raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  Future<List<String>> _buildCandidateNames(
    List<String> equipment,
    List<String> bodyParts,
  ) async {
    final names = <String>{};
    for (final bp in bodyParts.take(6)) {
      final equipment0 = equipment.isNotEmpty ? equipment.first : null;
      final exercises = await _catalog.searchByName('', bodyPart: bp, equipment: equipment0, limit: 5);
      final fallback = exercises.isEmpty ? await _catalog.getByBodyPart(bp, limit: 5) : exercises;
      for (final e in fallback) {
        names.add(e.name);
      }
    }
    return names.toList();
  }

  String _buildPrompt({
    required Map<String, dynamic> userProfile,
    required Map<String, ExerciseProgressHint> progressHints,
    required List<String> bodyParts,
    required List<String> availableEquipment,
    required List<String> candidateNames,
  }) {
    final sb = StringBuffer()
      ..writeln('Generate a workout plan as a JSON array.')
      ..writeln('Use ONLY exercise names from the catalog list below.')
      ..writeln('Return ONLY valid JSON — no markdown, no explanation.\n')
      ..writeln('Required format per element:')
      ..writeln('{'
          '"exercise_id":"<id from catalog>",'
          '"exercise_name":"<name from catalog>",'
          '"exercise_equipment":["<equipment>"],'
          '"planned_sets":<int>,'
          '"planned_reps":<int>,'
          '"planned_weight":"<string or null>"'
          '}\n')
      ..writeln('--- User Profile ---');
    userProfile.forEach((k, v) => sb.writeln('$k: $v'));

    sb
      ..writeln('\n--- Available Equipment ---')
      ..writeln(availableEquipment.isEmpty ? 'bodyweight only' : availableEquipment.join(', '))
      ..writeln('\n--- Body Parts ---')
      ..writeln(bodyParts.join(', '))
      ..writeln('\n--- Exercise Catalog (ONLY pick from this list) ---');
    for (final n in candidateNames) {
      sb.writeln('• $n');
    }

    if (progressHints.isNotEmpty) {
      sb.writeln('\n--- Progress History (use for progressive overload) ---');
      for (final h in progressHints.values.take(10)) {
        if (h.isBodyweight) {
          sb.writeln('${h.exerciseName}: last ${h.lastTopReps} reps → suggest ${h.suggestedNextReps} reps');
        } else {
          sb.writeln('${h.exerciseName}: last ${h.lastTopWeight}kg×${h.lastTopReps} → suggest ${h.suggestedNextWeight}kg×${h.suggestedNextReps}');
        }
      }
    }

    sb.writeln('\nGenerate 6–8 exercises. Apply progressive overload where history exists.');
    return sb.toString();
  }

  List<AiExerciseItem> _parseItems(String jsonStr) {
    final decoded = json.decode(jsonStr);
    final list = decoded is List ? decoded : [decoded];

    return list.whereType<Map<String, dynamic>>().map((item) {
      int parseInt(dynamic v, {int fallback = 0}) {
        if (v is int) return v;
        if (v is double) return v.toInt();
        if (v is String) return int.tryParse(v) ?? fallback;
        return fallback;
      }

      return AiExerciseItem(
        id: item['exercise_id']?.toString() ?? '',
        name: item['exercise_name']?.toString() ?? '',
        sets: parseInt(item['planned_sets'], fallback: 3),
        reps: parseInt(item['planned_reps'], fallback: 10),
        weight: item['planned_weight']?.toString() ?? '',
      );
    }).where((i) => i.name.isNotEmpty).toList();
  }
}
