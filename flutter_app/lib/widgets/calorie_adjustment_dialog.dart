import 'package:flutter/material.dart';

import '../services/calorie_adjustment_service.dart';
import '../theme/app_theme.dart';

class CalorieAdjustmentDialog extends StatelessWidget {
  const CalorieAdjustmentDialog({
    super.key,
    required this.suggestion,
    required this.onApply,
    required this.onLater,
    required this.onSnooze,
  });

  final CalorieAdjustmentSuggestion suggestion;
  final VoidCallback onApply;
  final VoidCallback onLater;
  final VoidCallback onSnooze;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.tune, color: AppTheme.neonGreen, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Calorie Adjustment',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            suggestion.reasonText,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CalorieChip(
                label: 'Current',
                calories: suggestion.currentCalories,
                color: AppTheme.textSecondary,
              ),
              const Icon(
                Icons.arrow_forward,
                color: AppTheme.textTertiary,
                size: 18,
              ),
              _CalorieChip(
                label: 'Suggested',
                calories: suggestion.suggestedCalories,
                color: AppTheme.neonGreen,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '7-day trend: ${_formatWeeklyChange(suggestion.weeklyActualChange)} kg/week',
            style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              onPressed: onSnooze,
              child: const Text(
                'Snooze 2 weeks',
                style: TextStyle(color: AppTheme.textTertiary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onLater,
                  child: const Text(
                    'Later',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonGreen,
                    foregroundColor: AppTheme.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _formatWeeklyChange(double change) {
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(2)}';
  }
}

class _CalorieChip extends StatelessWidget {
  const _CalorieChip({
    required this.label,
    required this.calories,
    required this.color,
  });

  final String label;
  final int calories;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$calories kcal',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
