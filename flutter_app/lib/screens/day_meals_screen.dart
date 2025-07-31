import 'package:flutter/material.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../models/meal.dart';

class DayMealsScreen extends StatelessWidget {
  final DateTime date;
  final List<Meal> meals;

  const DayMealsScreen({super.key, required this.date, required this.meals});

  @override
  Widget build(BuildContext context) {
    int totalCalories = meals.fold(0, (sum, meal) => sum + meal.calories);
    double totalProteins = meals.fold(0, (sum, meal) => sum + meal.proteins);
    double totalCarbs = meals.fold(0, (sum, meal) => sum + meal.carbs);
    double totalFats = meals.fold(0, (sum, meal) => sum + meal.fats);

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        title: Text('${date.day}/${date.month}/${date.year}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Summary',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildNutritionBar(context, '$totalCalories kcal', 1.0),
                    const SizedBox(height: 16),
                    _buildNutritionBar(context, '${totalProteins.toStringAsFixed(1)}g Proteins', 0.8),
                    const SizedBox(height: 16),
                    _buildNutritionBar(context, '${totalCarbs.toStringAsFixed(1)}g Carbs', 0.6),
                    const SizedBox(height: 16),
                    _buildNutritionBar(context, '${totalFats.toStringAsFixed(1)}g Fats', 0.4),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Meals',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.softGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: meal.photoPath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(meal.photoPath!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.fastfood, color: AppTheme.charcoal),
                      ),
                      title: Text(meal.name),
                      subtitle: Text('${meal.calories} kcal'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('P: ${meal.proteins.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 10)),
                          Text('C: ${meal.carbs.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 10)),
                          Text('F: ${meal.fats.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionBar(BuildContext context, String label, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.softGray,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          minHeight: 8,
        ),
      ],
    );
  }
}
