import 'package:uuid/uuid.dart';

class MealPlan {
  final String id;
  final String name;
  final String? description;
  final List<Meal> meals;
  final String? userGoals; // To connect with user's goals
  final String? linkedWorkoutPlanId; // To connect with workout plan

  MealPlan({
    required this.id,
    required this.name,
    this.description,
    required this.meals,
    this.userGoals,
    this.linkedWorkoutPlanId,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    var mealsList = json['meals'] as List;
    List<Meal> meals = mealsList.map((i) => Meal.fromJson(i)).toList();

    return MealPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      meals: meals,
      userGoals: json['user_goals'],
      linkedWorkoutPlanId: json['linked_workout_plan_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'user_goals': userGoals,
      'linked_workout_plan_id': linkedWorkoutPlanId,
    };
  }
}

class Meal {
  final String name;
  final List<String> ingredients;
  final String instructions;
  final int? calories;
  final Map<String, dynamic>? macronutrients; // e.g., {'protein': 30, 'carbs': 40, 'fat': 15}

  Meal({
    required this.name,
    required this.ingredients,
    required this.instructions,
    this.calories,
    this.macronutrients,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'],
      ingredients: List<String>.from(json['ingredients']),
      instructions: json['instructions'],
      calories: json['calories'],
      macronutrients: json['macronutrients'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ingredients': ingredients,
      'instructions': instructions,
      'calories': calories,
      'macronutrients': macronutrients,
    };
  }
}
