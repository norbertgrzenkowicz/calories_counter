import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/custom_food.dart';
import '../providers/custom_foods_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_page_route.dart';
import '../utils/app_snackbar.dart';
import 'custom_food_form_screen.dart';

/// Shown in two modes:
///   - picker mode (selectMode = true): user picks a food → returns nutrition map
///   - management mode (selectMode = false): user manages their food library
class CustomFoodsScreen extends ConsumerStatefulWidget {
  final bool selectMode;

  const CustomFoodsScreen({super.key, this.selectMode = false});

  @override
  ConsumerState<CustomFoodsScreen> createState() => _CustomFoodsScreenState();
}

class _CustomFoodsScreenState extends ConsumerState<CustomFoodsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CustomFood> _filtered(List<CustomFood> foods) {
    if (_query.isEmpty) return foods;
    final q = _query.toLowerCase();
    return foods.where((f) => f.displayName.toLowerCase().contains(q)).toList();
  }

  Future<void> _openForm([CustomFood? food]) async {
    final saved = await Navigator.push<bool>(
      context,
      AppPageRoute(
        builder: (_) => CustomFoodFormScreen(food: food),
      ),
    );
    if (saved == true) {
      ref.invalidate(customFoodsProvider);
    }
  }

  Future<void> _delete(CustomFood food) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Delete food?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Delete "${food.displayName}"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    try {
      await ref.read(customFoodsProvider.notifier).deleteFood(food.id!);
      if (mounted) AppSnackbar.success(context, 'Deleted "${food.displayName}"');
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Failed to delete: $e');
    }
  }

  Future<void> _selectFood(CustomFood food) async {
    // Show amount picker
    final amount = await _showAmountDialog(food);
    if (amount == null || !mounted) return;

    final nutrition = food.nutritionForAmount(amount);
    Navigator.of(context).pop({
      'name': food.displayName,
      'calories': nutrition['calories'],
      'proteins': nutrition['proteins'],
      'fats': nutrition['fats'],
      'carbs': nutrition['carbs'],
    });
  }

  Future<double?> _showAmountDialog(CustomFood food) async {
    final defaultAmount = food.servingSizeG ?? 100.0;
    final controller =
        TextEditingController(text: defaultAmount.toStringAsFixed(0));

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: Text(food.displayName,
            style: const TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How much? (${food.servingUnit})',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixText: 'g',
              ),
            ),
            const SizedBox(height: 8),
            _nutritionPreviewBuilder(food, controller),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(
                controller.text.replaceAll(',', '.'),
              );
              Navigator.pop(ctx, v);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonGreen,
              foregroundColor: AppTheme.darkBackground,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  Widget _nutritionPreviewBuilder(
      CustomFood food, TextEditingController controller) {
    return StatefulBuilder(
      builder: (_, setState) {
        controller.addListener(() => setState(() {}));
        final amount =
            double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
        final n = food.nutritionForAmount(amount);
        return Text(
          '${n['calories']} kcal  P: ${n['proteins']}g  C: ${n['carbs']}g  F: ${n['fats']}g',
          style: const TextStyle(color: AppTheme.neonGreen, fontSize: 13),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final foodsAsync = ref.watch(customFoodsProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(widget.selectMode ? 'My Foods' : 'Custom Foods'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!widget.selectMode)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _openForm(),
              tooltip: 'Add food',
            ),
        ],
      ),
      floatingActionButton: widget.selectMode
          ? FloatingActionButton.small(
              onPressed: () => _openForm(),
              backgroundColor: AppTheme.neonGreen,
              foregroundColor: AppTheme.darkBackground,
              tooltip: 'Create new food',
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search foods...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: foodsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: AppTheme.textSecondary)),
              ),
              data: (foods) {
                final filtered = _filtered(foods);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.restaurant,
                            size: 48, color: AppTheme.textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          _query.isNotEmpty
                              ? 'No foods match "$_query"'
                              : 'No custom foods yet.\nCreate one to get started!',
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: AppTheme.textSecondary),
                        ),
                        if (_query.isEmpty) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _openForm(),
                            icon: const Icon(Icons.add),
                            label: const Text('Create Food'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.neonGreen,
                              foregroundColor: AppTheme.darkBackground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _FoodTile(
                    food: filtered[i],
                    selectMode: widget.selectMode,
                    onTap: widget.selectMode
                        ? () => _selectFood(filtered[i])
                        : () => _openForm(filtered[i]),
                    onEdit: () => _openForm(filtered[i]),
                    onDelete: () => _delete(filtered[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodTile extends StatelessWidget {
  final CustomFood food;
  final bool selectMode;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FoodTile({
    required this.food,
    required this.selectMode,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppTheme.neonGreen.withOpacity(0.15),
        child: const Icon(Icons.restaurant, color: AppTheme.neonGreen, size: 20),
      ),
      title: Text(
        food.displayName,
        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${food.caloriesPer100g.round()} kcal  '
        'P: ${food.proteinsPer100g.toStringAsFixed(1)}g  '
        'C: ${food.carbsPer100g.toStringAsFixed(1)}g  '
        'F: ${food.fatsPer100g.toStringAsFixed(1)}g  /100g',
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      trailing: selectMode
          ? const Icon(Icons.chevron_right, color: AppTheme.textSecondary)
          : PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(color: Colors.redAccent))),
              ],
            ),
    );
  }
}
