import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onAddToMeals;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onAddToMeals,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserMessage(context);
    } else {
      return _buildAIMessage(context);
    }
  }

  Widget _buildUserMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.neonBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.neonBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: _buildUserContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserContent() {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
          ),
        );
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(message.content),
                width: 200,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 150,
                    color: AppTheme.borderColor,
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        color: AppTheme.textTertiary,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '📷 Image',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        );
      case MessageType.audio:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mic,
              color: AppTheme.neonBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Audio message',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildAIMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: AppTheme.neonGreen,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Analysis',
                        style: TextStyle(
                          color: AppTheme.neonGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (message.nutritionData != null) ...[
                    _buildNutritionInfo(),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onAddToMeals,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add to Today\'s Meals'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonGreen,
                          foregroundColor: AppTheme.darkBackground,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      message.content,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfo() {
    final nutrition = message.nutritionData!;
    final calories = nutrition['calories'] ?? 0;
    final protein = nutrition['protein'] ?? 0;
    final carbs = nutrition['carbs'] ?? 0;
    final fats = nutrition['fats'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.borderColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Found:',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionItem('🍎', '$calories', 'kcal'),
              _buildNutritionItem('🥩', '${protein}g', 'protein'),
              _buildNutritionItem('🍞', '${carbs}g', 'carbs'),
              _buildNutritionItem('🥑', '${fats}g', 'fat'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
