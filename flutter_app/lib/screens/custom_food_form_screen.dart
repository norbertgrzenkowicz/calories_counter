import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/custom_food.dart';
import '../providers/custom_foods_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_snackbar.dart';
import '../utils/input_sanitizer.dart';

class CustomFoodFormScreen extends ConsumerStatefulWidget {
  final CustomFood? food; // null = create, non-null = edit

  const CustomFoodFormScreen({super.key, this.food});

  @override
  ConsumerState<CustomFoodFormScreen> createState() =>
      _CustomFoodFormScreenState();
}

class _CustomFoodFormScreenState extends ConsumerState<CustomFoodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinsController;
  late final TextEditingController _fatsController;
  late final TextEditingController _carbsController;
  late final TextEditingController _servingSizeController;

  bool _isSaving = false;

  bool get _isEditing => widget.food != null;

  @override
  void initState() {
    super.initState();
    final f = widget.food;
    _nameController = TextEditingController(text: f?.name ?? '');
    _brandController = TextEditingController(text: f?.brand ?? '');
    _caloriesController =
        TextEditingController(text: f != null ? f.caloriesPer100g.toString() : '');
    _proteinsController =
        TextEditingController(text: f != null ? f.proteinsPer100g.toString() : '');
    _fatsController =
        TextEditingController(text: f != null ? f.fatsPer100g.toString() : '');
    _carbsController =
        TextEditingController(text: f != null ? f.carbsPer100g.toString() : '');
    _servingSizeController =
        TextEditingController(text: f?.servingSizeG?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _fatsController.dispose();
    _carbsController.dispose();
    _servingSizeController.dispose();
    super.dispose();
  }

  String? _validateNonNegativeDouble(String? value, String fieldName) {
    if (value == null || value.isEmpty) return 'Enter $fieldName';
    final n = InputSanitizer.parseDouble(value);
    if (n == null) return 'Invalid number';
    if (n < 0) return '$fieldName cannot be negative';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final name = InputSanitizer.sanitizeMealName(_nameController.text);
      if (name.isEmpty) throw Exception('Name is required');

      final food = CustomFood(
        id: widget.food?.id,
        name: name,
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        caloriesPer100g:
            InputSanitizer.parseDouble(_caloriesController.text) ?? 0,
        proteinsPer100g:
            InputSanitizer.parseDouble(_proteinsController.text) ?? 0,
        fatsPer100g: InputSanitizer.parseDouble(_fatsController.text) ?? 0,
        carbsPer100g: InputSanitizer.parseDouble(_carbsController.text) ?? 0,
        servingSizeG: _servingSizeController.text.trim().isEmpty
            ? null
            : InputSanitizer.parseDouble(_servingSizeController.text),
      );

      final notifier = ref.read(customFoodsProvider.notifier);
      if (_isEditing) {
        await notifier.updateFood(food);
      } else {
        await notifier.addFood(food);
      }

      if (mounted) {
        AppSnackbar.success(
            context, _isEditing ? 'Food updated!' : 'Custom food saved!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Failed to save: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Food' : 'New Custom Food'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                controller: _nameController,
                label: 'Food Name',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              _field(
                controller: _brandController,
                label: 'Brand (optional)',
              ),
              const SizedBox(height: 20),
              const Text(
                'Nutrition per 100g',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              _field(
                controller: _caloriesController,
                label: 'Calories (kcal)',
                numeric: true,
                validator: (v) => _validateNonNegativeDouble(v, 'Calories'),
              ),
              const SizedBox(height: 12),
              _field(
                controller: _proteinsController,
                label: 'Protein (g)',
                numeric: true,
                validator: (v) => _validateNonNegativeDouble(v, 'Protein'),
              ),
              const SizedBox(height: 12),
              _field(
                controller: _carbsController,
                label: 'Carbs (g)',
                numeric: true,
                validator: (v) => _validateNonNegativeDouble(v, 'Carbs'),
              ),
              const SizedBox(height: 12),
              _field(
                controller: _fatsController,
                label: 'Fats (g)',
                numeric: true,
                validator: (v) => _validateNonNegativeDouble(v, 'Fats'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Default Serving (optional)',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              _field(
                controller: _servingSizeController,
                label: 'Serving size (g)',
                numeric: true,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isSaving ? Colors.grey : AppTheme.neonGreen,
                  foregroundColor: AppTheme.darkBackground,
                  padding: const EdgeInsets.all(16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Update Food' : 'Save Food'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool numeric = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType:
          numeric ? const TextInputType.numberWithOptions(decimal: true) : null,
      validator: validator,
    );
  }
}
