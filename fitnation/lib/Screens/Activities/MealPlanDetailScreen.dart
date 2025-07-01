import 'package:flutter/material.dart';
import 'package:fitnation/models/MealPlan.dart';

class MealPlanDetailScreen extends StatelessWidget {
  final MealPlan mealPlan;

  const MealPlanDetailScreen({Key? key, required this.mealPlan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalCalories = mealPlan.meals.fold(0, (sum, meal) => sum + (meal.calories ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text(mealPlan.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mealPlan.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8.0),
            if (mealPlan.description != null)
              Text(
                mealPlan.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 16.0),
            Text(
              'Total Calories: $totalCalories kcal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Meals:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mealPlan.meals.length,
              itemBuilder: (context, index) {
                final meal = mealPlan.meals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (meal.calories != null)
                          Text(
                            'Calories: ${meal.calories} kcal',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Ingredients:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        ...meal.ingredients.map((ingredient) => Text('- $ingredient')).toList(),
                        const SizedBox(height: 8.0),
                        Text(
                          'Instructions:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(meal.instructions),
                        if (meal.macronutrients != null && meal.macronutrients!.isNotEmpty) ...[
                          const SizedBox(height: 8.0),
                          Text(
                            'Macronutrients:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          ...meal.macronutrients!.entries.map((entry) => Text('${entry.key}: ${entry.value}')).toList(),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
