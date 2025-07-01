class FoodItem {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double quantity; // e.g., in grams, ml, or number of items
  final String unit; // e.g., "g", "ml", "item"

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.quantity = 1.0,
    this.unit = 'item',
  });

  // Factory constructor for creating a new FoodItem object from a map
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
      quantity: json['quantity']?.toDouble() ?? 1.0,
      unit: json['unit'] ?? 'item',
    );
  }

  // Method for converting a FoodItem object to a map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'quantity': quantity,
      'unit': unit,
    };
  }
}
