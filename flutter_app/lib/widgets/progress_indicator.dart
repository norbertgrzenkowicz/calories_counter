import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const CustomProgressIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step counter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${currentStep + 1}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                ' of $totalSteps',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.charcoal.withOpacity(0.6),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: AppTheme.softGray,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (currentStep + 1) / totalSteps,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.accentOrange],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Current step label
          if (currentStep < stepLabels.length)
            Text(
              stepLabels[currentStep],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.charcoal.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
            ),
        ],
      ),
    );
  }
}
