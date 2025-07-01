import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart'; // Import firebase_ai
import 'package:fitnation/models/Workout.dart';
import 'package:fitnation/models/MealPlan.dart'; // Import MealPlan
import 'package:flutter/foundation.dart'; // Import for debugPrint

class GeminiService {
  final GenerativeModel _model;

  GeminiService()
      : _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash-preview-05-20');

  Future<Workout> generateWorkoutPlan(Map<String, dynamic> userInfo) async {
    debugPrint('GeminiService: generateWorkoutPlan called.');
    if (_model == null) {
      debugPrint('GeminiService: Model not initialized.');
      throw Exception('Gemini model failed to initialize. Check Firebase AI setup.');
    }

    final String promptText = _buildWorkoutPrompt(userInfo); // Use specific prompt builder
    debugPrint('GeminiService: Workout Prompt: $promptText');

    try {
      final response = await _model.generateContent([Content.text(promptText)]);
      debugPrint('GeminiService: Raw Workout Response: ${response.text}');

      String rawJsonString = '';
      if (response.candidates != null && response.candidates!.isNotEmpty) {
        final candidate = response.candidates![0];
        if (candidate.content != null && candidate.content!.parts != null) {
          rawJsonString =
              candidate.content!.parts!.map((part) => part.toString()).join();
        }
      }

      if (rawJsonString.isEmpty) {
        debugPrint(
          'GeminiService: Empty workout response from Gemini (no candidates or parts).',
        );
        throw Exception('Gemini returned an empty response.');
      }

      // Clean the rawJsonString if it's wrapped in markdown (e.g., ```json ... ```)
      if (rawJsonString.startsWith('```json') && rawJsonString.endsWith('```')) {
        rawJsonString = rawJsonString.substring(7, rawJsonString.length - 3).trim();
      } else if (rawJsonString.startsWith('```') && rawJsonString.endsWith('```')) {
        // Handle generic markdown code block
        rawJsonString = rawJsonString.substring(3, rawJsonString.length - 3).trim();
      }
      debugPrint('GeminiService: Cleaned Workout JSON: $rawJsonString');

      // Decode the JSON string. It might be a List or a Map.
      final dynamic decodedJson = jsonDecode(rawJsonString);
      debugPrint('GeminiService: Decoded Workout JSON Type: ${decodedJson.runtimeType}');

      Map<String, dynamic> workoutJson;
      if (decodedJson is List) {
        if (decodedJson.isNotEmpty && decodedJson[0] is Map<String, dynamic>) {
          workoutJson = decodedJson[0];
          debugPrint('GeminiService: Using first workout from list.');
        } else {
          debugPrint('GeminiService: Empty or invalid list of workout plans.');
          throw Exception('Gemini returned an empty or invalid list of workout plans.');
        }
      } else if (decodedJson is Map<String, dynamic>) {
        workoutJson = decodedJson;
        debugPrint('GeminiService: Using single workout map.');
      } else if (decodedJson is String) {
        debugPrint(
          'GeminiService: Gemini returned a String instead of JSON. Raw response: $decodedJson',
        );
        throw Exception(
          'Gemini returned a non-JSON string response. Please refine your prompt or check Gemini output.',
        );
      } else {
        debugPrint(
          'GeminiService: Unexpected workout JSON format. Type: ${decodedJson.runtimeType}',
        );
        throw Exception(
          'Gemini returned an unexpected JSON format: Not a Map, List, or String.',
        );
      }

      return Workout.fromJson(workoutJson);
    } on FormatException catch (e) {
      debugPrint(
        'GeminiService: FormatException during workout JSON parsing: $e',
      );
      throw Exception(
        'Gemini returned invalid JSON for workout plan. Error: $e',
      );
    } catch (e) {
      debugPrint('GeminiService: Error during workout API call: $e');
      throw Exception('An unexpected error occurred during Gemini API call: $e');
    }
  }

  Future<MealPlan> generateMealPlan(Map<String, dynamic> userInfo) async {
    debugPrint('GeminiService: generateMealPlan called.');
    if (_model == null) {
      debugPrint('GeminiService: Model not initialized.');
      throw Exception('Gemini model failed to initialize. Check Firebase AI setup.');
    }

    final String promptText = _buildMealPlanPrompt(userInfo); // Use specific prompt builder
    debugPrint('GeminiService: Meal Plan Prompt: $promptText');

    try {
      final response = await _model.generateContent([Content.text(promptText)]);
      debugPrint('GeminiService: Raw Meal Plan Response: ${response.text}');

      String rawJsonString = '';
      if (response.candidates != null && response.candidates!.isNotEmpty) {
        final candidate = response.candidates![0];
        if (candidate.content != null && candidate.content!.parts != null) {
          rawJsonString =
              candidate.content!.parts!.map((part) => part.toString()).join();
        }
      }

      if (rawJsonString.isEmpty) {
        debugPrint(
          'GeminiService: Empty meal plan response from Gemini (no candidates or parts).',
        );
        throw Exception('Gemini returned an empty response.');
      }

      // Clean the rawJsonString if it's wrapped in markdown (e.g., ```json ... ```)
      if (rawJsonString.startsWith('```json') && rawJsonString.endsWith('```')) {
        rawJsonString = rawJsonString.substring(7, rawJsonString.length - 3).trim();
      } else if (rawJsonString.startsWith('```') && rawJsonString.endsWith('```')) {
        // Handle generic markdown code block
        rawJsonString = rawJsonString.substring(3, rawJsonString.length - 3).trim();
      }
      debugPrint('GeminiService: Cleaned Meal Plan JSON: $rawJsonString');

      // Decode the JSON string. It might be a List or a Map.
      final dynamic decodedJson = jsonDecode(rawJsonString);
      debugPrint('GeminiService: Decoded Meal Plan JSON Type: ${decodedJson.runtimeType}');

      Map<String, dynamic> mealPlanJson;
      if (decodedJson is List) {
        if (decodedJson.isNotEmpty && decodedJson[0] is Map<String, dynamic>) {
          mealPlanJson = decodedJson[0];
          debugPrint('GeminiService: Using first meal plan from list.');
        } else {
          debugPrint('GeminiService: Empty or invalid list of meal plans.');
          throw Exception('Gemini returned an empty or invalid list of meal plans.');
        }
      } else if (decodedJson is Map<String, dynamic>) {
        mealPlanJson = decodedJson;
        debugPrint('GeminiService: Using single meal plan map.');
      } else if (decodedJson is String) {
        debugPrint(
          'GeminiService: Gemini returned a String instead of JSON. Raw response: $decodedJson',
        );
        throw Exception(
          'Gemini returned a non-JSON string response. Please refine your prompt or check Gemini output.',
        );
      } else {
        debugPrint(
          'GeminiService: Unexpected meal plan JSON format. Type: ${decodedJson.runtimeType}',
        );
        throw Exception(
          'Gemini returned an unexpected JSON format: Not a Map, List, or String.',
        );
      }

      return MealPlan.fromJson(mealPlanJson);
    } on FormatException catch (e) {
      debugPrint(
        'GeminiService: FormatException during meal plan JSON parsing: $e',
      );
      throw Exception('Gemini returned invalid JSON for meal plan. Error: $e');
    } catch (e) {
      debugPrint('GeminiService: Error during meal plan API call: $e');
      throw Exception('An unexpected error occurred during Gemini API call: $e');
    }
  }

  String _buildWorkoutPrompt(Map<String, dynamic> userInfo) {
    String prompt = "Generate a workout plan in JSON format. The JSON should strictly adhere to the following structure:\n\n";
    prompt += """
{
  "id": "string",
  "name": "string",
  "icon_url": "string?",
  "equipment_selected": "string?",
  "one_rm_goal": "string?",
  "type": "string?",
  "exercises": [
    {
      "exercise_id": "string",
      "exercise_name": "string",
      "exercise_equipment": ["string?"],
      "exercise_gif_url": "string?",
      "type": "string?",
      "planned_sets": "int",
      "planned_reps": "int",
      "planned_weight": "string?"
    }
  ]
}
""";
    prompt += "\n\nHere is the user's information:\n";
    userInfo.forEach((key, value) {
      prompt += "- $key: $value\n";
    });
    prompt += "\nEnsure the 'id' for the workout and 'exercise_id' for each exercise are unique strings. If an exercise does not have a specific GIF URL, set 'exercise_gif_url' to null. If 'equipment_selected', 'one_rm_goal', or 'type' are not applicable, set them to null. For 'exercise_equipment', provide a list of strings, e.g., [\"Barbell\", \"Dumbbell\"]. If no specific weight is planned, set 'planned_weight' to \"Bodyweight\" or null. Provide a plan suitable for the user's goals and intensity.";

    return prompt;
  }

  String _buildMealPlanPrompt(Map<String, dynamic> userInfo) {
    String prompt = "Generate a meal plan in JSON format. The JSON should strictly adhere to the following structure:\n\n";
    prompt += """
{
  "id": "string",
  "name": "string",
  "description": "string?",
  "user_goals": "string?",
  "linked_workout_plan_id": "string?",
  "meals": [
    {
      "name": "string",
      "ingredients": ["string"],
      "instructions": "string",
      "calories": "int?",
      "macronutrients": {
        "protein": "int?",
        "carbs": "int?",
        "fat": "int?"
      }
    }
  ]
}
""";
    prompt += "\n\nHere is the user's information:\n";
    userInfo.forEach((key, value) {
      prompt += "- $key: $value\n";
    });

    // Add linked workout plan details to the prompt if available
    if (userInfo.containsKey('linked_workout_plan_id') && userInfo['linked_workout_plan_id'] != null) {
      prompt += "\nThis meal plan should complement a workout plan with ID: ${userInfo['linked_workout_plan_id']}.";
      // You might want to add more details from the workout plan if available in userInfo,
      // e.g., workout intensity, main goals from the workout.
      // For example:
      // if (userInfo.containsKey('workout_intensity')) {
      //   prompt += " The workout intensity is: ${userInfo['workout_intensity']}.";
      // }
      // if (userInfo.containsKey('workout_goals')) {
      //   prompt += " The workout goals are: ${userInfo['workout_goals']}.";
      // }
    }

    prompt += "\nEnsure the 'id' for the meal plan is a unique string. Provide a meal plan suitable for the user's goals, dietary preferences, and calorie needs. If 'linked_workout_plan_id' is provided, tailor the meal plan to complement the workout plan.";

    return prompt;
  }
}
