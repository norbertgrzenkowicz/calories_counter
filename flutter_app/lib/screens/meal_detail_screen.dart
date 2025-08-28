import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/meal.dart';
import '../services/supabase_service.dart';

class MealDetailScreen extends StatefulWidget {
  final Meal meal;
  final Function() onMealUpdated;

  const MealDetailScreen({
    super.key,
    required this.meal,
    required this.onMealUpdated,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  late Meal currentMeal;
  bool isEditing = false;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinsController;
  late TextEditingController _fatsController;
  late TextEditingController _carbsController;
  String? _newPhotoPath;

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

  Future<void> _pickNewPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _newPhotoPath = pickedFile.path;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final supabaseService = SupabaseService();
      if (!supabaseService.isInitialized) {
        throw Exception('Supabase not initialized');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updating meal...')),
      );

      String? photoUrl = currentMeal.photoUrl;

      // Upload new photo if one was selected
      if (_newPhotoPath != null) {
        final fileName = 'meal_${DateTime.now().millisecondsSinceEpoch}.jpg';
        photoUrl =
            await supabaseService.uploadMealPhoto(_newPhotoPath!, fileName);
      }

      final updatedMeal = Meal(
        id: currentMeal.id,
        name: _nameController.text,
        uid: currentMeal.uid,
        calories: int.parse(_caloriesController.text),
        proteins: double.parse(_proteinsController.text),
        fats: double.parse(_fatsController.text),
        carbs: double.parse(_carbsController.text),
        photoUrl: photoUrl,
        date: currentMeal.date,
        createdAt: currentMeal.createdAt,
      );

      await supabaseService.updateMeal(
          currentMeal.id!, updatedMeal.toSupabase());

      setState(() {
        currentMeal = updatedMeal;
        isEditing = false;
        _newPhotoPath = null;
      });

      widget.onMealUpdated();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update meal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteMeal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text(
            'Are you sure you want to delete this meal? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final supabaseService = SupabaseService();
      if (!supabaseService.isInitialized) {
        throw Exception('Supabase not initialized');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleting meal...')),
      );

      await supabaseService.deleteMeal(currentMeal.id!);

      widget.onMealUpdated();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete meal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
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
                  _newPhotoPath = null;
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
                    color: AppTheme.softGray,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppTheme.charcoal.withOpacity(0.2)),
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
                                        size: 48, color: AppTheme.charcoal),
                                    SizedBox(height: 8),
                                    Text('No photo available'),
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
                                  size: 48, color: AppTheme.charcoal),
                              SizedBox(height: 8),
                              Text('No photo available'),
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
                    'kcal', AppTheme.primaryGreen),
                const SizedBox(height: 12),
                _buildNutritionCard('Proteins',
                    currentMeal.proteins.toStringAsFixed(1), 'g', Colors.red),
                const SizedBox(height: 12),
                _buildNutritionCard('Carbohydrates',
                    currentMeal.carbs.toStringAsFixed(1), 'g', Colors.orange),
                const SizedBox(height: 12),
                _buildNutritionCard('Fats', currentMeal.fats.toStringAsFixed(1),
                    'g', Colors.blue),
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
          // Photo Edit Section
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
                      color: AppTheme.softGray,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppTheme.charcoal.withOpacity(0.2)),
                    ),
                    child: _newPhotoPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_newPhotoPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                    child: Text('Error loading new photo'));
                              },
                            ),
                          )
                        : currentMeal.photoUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  currentMeal.photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.fastfood,
                                              size: 48,
                                              color: AppTheme.charcoal),
                                          SizedBox(height: 8),
                                          Text('No photo available'),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.fastfood,
                                        size: 48, color: AppTheme.charcoal),
                                    SizedBox(height: 8),
                                    Text('No photo available'),
                                  ],
                                ),
                              ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _pickNewPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_newPhotoPath != null
                        ? 'Change Photo'
                        : 'Update Photo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

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
                      if (value == null || value.isEmpty) {
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
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
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
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
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
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
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
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
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
