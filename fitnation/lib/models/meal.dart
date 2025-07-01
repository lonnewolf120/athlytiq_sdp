import 'package:fitnation/models/food_item.dart';

class Meal {
  final String id;
  final String userId;
  final DateTime date;
  final String mealType; // e.g., Breakfast, Lunch, Dinner, Snack
  final List<FoodItem> foodItems;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  Meal({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.foodItems,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  // Factory constructor for creating a new Meal object from a map
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      mealType: json['mealType'],
      foodItems: (json['foodItems'] as List)
          .map((item) => FoodItem.fromJson(item))
          .toList(),
      totalCalories: json['totalCalories'].toDouble(),
      totalProtein: json['totalProtein'].toDouble(),
      totalCarbs: json['totalCarbs'].toDouble(),
      totalFat: json['totalFat'].toDouble(),
    );
  }

  // Method for converting a Meal object to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'mealType': mealType,
      'foodItems': foodItems.map((item) => item.toJson()).toList(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
    };
  }
}
