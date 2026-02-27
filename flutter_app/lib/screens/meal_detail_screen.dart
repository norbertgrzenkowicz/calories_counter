import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../models/meal.dart';
import '../providers/meals_provider.dart';
import '../utils/app_snackbar.dart';
import '../utils/input_sanitizer.dart';

class MealDetailScreen extends ConsumerStatefulWidget {
  final Meal meal;

  const MealDetailScreen({
    super.key,
    required this.meal,
  });

  @override
  ConsumerState<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends ConsumerState<MealDetailScreen> {
  late Meal currentMeal;
  bool isEditing = false;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinsController;
  late TextEditingController _fatsController;
  late TextEditingController _carbsController;

  @override
  void initState() {
    super.initState();
    currentMeal = widget.meal;
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: currentMeal.name);
    _caloriesController =
        TextEditingController(text: currentMeal.calories.toString());
    _proteinsController =
        TextEditingController(text: currentMeal.proteins.toString());
    _fatsController = TextEditingController(text: currentMeal.fats.toString());
    _carbsController =
        TextEditingController(text: currentMeal.carbs.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _fatsController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      AppSnackbar.info(context, 'Updating meal...');

      final sanitizedName =
          InputSanitizer.sanitizeMealName(_nameController.text);
      final sanitizedCalories =
          InputSanitizer.sanitizeCalories(_caloriesController.text) ?? 0;
      final sanitizedProteins =
          InputSanitizer.sanitizeMacroNutrient(_proteinsController.text) ?? 0.0;
      final sanitizedFats =
          InputSanitizer.sanitizeMacroNutrient(_fatsController.text) ?? 0.0;
      final sanitizedCarbs =
          InputSanitizer.sanitizeMacroNutrient(_carbsController.text) ?? 0.0;

      if (sanitizedName.isEmpty) {
        throw Exception('Meal name is required');
      }

      final updatedMeal = Meal(
        id: currentMeal.id,
        name: sanitizedName,
        uid: currentMeal.uid,
        calories: sanitizedCalories,
        proteins: sanitizedProteins,
        fats: sanitizedFats,
        carbs: sanitizedCarbs,
        photoUrl: currentMeal.photoUrl,
        date: currentMeal.date,
        createdAt: currentMeal.createdAt,
      );

      await ref
          .read(mealsNotifierProvider(currentMeal.date).notifier)
          .updateMeal(updatedMeal);

      setState(() {
        currentMeal = updatedMeal;
        isEditing = false;
      });

      if (mounted) {
        AppSnackbar.success(context, 'Meal updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Failed to update meal: $e');
      }
    }
  }

  Future<void> _deleteMeal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Meal', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
            'Are you sure you want to delete this meal? This action cannot be undone.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.neonRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      AppSnackbar.info(context, 'Deleting meal...');

      await ref
          .read(mealsNotifierProvider(currentMeal.date).notifier)
          .deleteMeal(currentMeal.id!);

      if (mounted) {
        AppSnackbar.success(context, 'Meal deleted successfully!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Failed to delete meal: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Meal' : 'Meal Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteMeal,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveChanges,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  isEditing = false;
                  _initializeControllers();
                });
              },
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: isEditing ? _buildEditForm() : _buildDisplayView(),
      ),
    );
  }

  Widget _buildDisplayView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Photo',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: currentMeal.photoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            currentMeal.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.fastfood,
                                        size: 48,
                                        color: AppTheme.textSecondary),
                                    SizedBox(height: 8),
                                    Text('No photo available',
                                        style: TextStyle(
                                            color: AppTheme.textSecondary)),
                                  ],
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fastfood,
                                  size: 48, color: AppTheme.textSecondary),
                              SizedBox(height: 8),
                              Text('No photo available',
                                  style:
                                      TextStyle(color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Basic Info Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meal Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Name', currentMeal.name),
                const SizedBox(height: 12),
                _buildInfoRow('Date',
                    '${currentMeal.date.day}/${currentMeal.date.month}/${currentMeal.date.year}'),
                if (currentMeal.createdAt != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow('Created',
                      '${currentMeal.createdAt!.day}/${currentMeal.createdAt!.month}/${currentMeal.createdAt!.year} at ${currentMeal.createdAt!.hour}:${currentMeal.createdAt!.minute.toString().padLeft(2, '0')}'),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Nutrition Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nutrition Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildNutritionCard('Calories', '${currentMeal.calories}',
                    'kcal', AppTheme.neonGreen),
                const SizedBox(height: 12),
                _buildNutritionCard(
                    'Proteins',
                    currentMeal.proteins.toStringAsFixed(1),
                    'g',
                    AppTheme.neonRed),
                const SizedBox(height: 12),
                _buildNutritionCard(
                    'Carbohydrates',
                    currentMeal.carbs.toStringAsFixed(1),
                    'g',
                    AppTheme.neonYellow),
                const SizedBox(height: 12),
                _buildNutritionCard('Fats', currentMeal.fats.toStringAsFixed(1),
                    'g', AppTheme.neonBlue),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Fields
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meal Information',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Meal Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a meal name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(
                      labelText: 'Calories',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter calories';
                      }
                      final parsed = int.tryParse(value);
                      if (parsed == null) {
                        return 'Please enter a valid number';
                      }
                      if (parsed < 0) {
                        return 'Calories cannot be negative';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _proteinsController,
                    decoration: const InputDecoration(
                      labelText: 'Proteins (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter proteins';
                      }
                      final parsed = double.tryParse(value);
                      if (parsed == null) {
                        return 'Please enter a valid number';
                      }
                      if (parsed < 0) {
                        return 'Proteins cannot be negative';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fatsController,
                    decoration: const InputDecoration(
                      labelText: 'Fats (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter fats';
                      }
                      final parsed = double.tryParse(value);
                      if (parsed == null) {
                        return 'Please enter a valid number';
                      }
                      if (parsed < 0) {
                        return 'Fats cannot be negative';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _carbsController,
                    decoration: const InputDecoration(
                      labelText: 'Carbs (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter carbs';
                      }
                      final parsed = double.tryParse(value);
                      if (parsed == null) {
                        return 'Please enter a valid number';
                      }
                      if (parsed < 0) {
                        return 'Carbs cannot be negative';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildNutritionCard(
      String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$value $unit',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
