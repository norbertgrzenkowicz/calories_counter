import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../models/chat_message.dart';
import '../providers/meals_provider.dart';
import '../utils/app_snackbar.dart';

/// Animated user message bubble with pop effect on long press
class _AnimatedUserBubble extends StatefulWidget {
  final Widget child;
  final VoidCallback? onLongPress;

  const _AnimatedUserBubble({
    required this.child,
    this.onLongPress,
  });

  @override
  State<_AnimatedUserBubble> createState() => _AnimatedUserBubbleState();
}

class _AnimatedUserBubbleState extends State<_AnimatedUserBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Pop-up animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Scale: grow UP first (1.0 -> 1.08) on press - like bubble popping up
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    // Grow up when pressed
    _controller.forward();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    // Settle back down with elastic bounce
    _controller.animateBack(
      0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut, // Bouncy spring-back effect
    );
    widget.onLongPress?.call();
  }

  void _onLongPressCancel() {
    // Settle back down with same bounce if cancelled
    _controller.animateBack(
      0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: widget.onLongPress != null ? _onLongPressStart : null,
      onLongPressEnd: widget.onLongPress != null ? _onLongPressEnd : null,
      onLongPress: () {}, // Required for long press to work
      onLongPressCancel: widget.onLongPress != null ? _onLongPressCancel : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Animated loading bubble with 3-dot bounce animation
class _LoadingBubble extends StatefulWidget {
  const _LoadingBubble();

  @override
  State<_LoadingBubble> createState() => _LoadingBubbleState();
}

class _LoadingBubbleState extends State<_LoadingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showDots = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    // Delay showing dots by 300ms
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showDots = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(width: 12),
                  if (_showDots)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDot(0),
                        const SizedBox(width: 4),
                        _buildDot(1),
                        const SizedBox(width: 4),
                        _buildDot(2),
                      ],
                    )
                  else
                    const SizedBox(width: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double phase = index * 0.33;
        final double value = (_controller.value + phase) % 1.0;
        final double scale = 0.5 + 0.5 * (1 - (value * 2 - 1).abs());

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.neonGreen,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class ChatMessageBubble extends ConsumerWidget {
  final ChatMessage message;
  final VoidCallback? onAddToMeals;
  final VoidCallback? onDiscard;
  final VoidCallback? onEditMessage;
  // Called when user taps "Answer" on a provisional clarification bubble.
  // The outer widget handles routing the next text to image refinement;
  // we only need to signal that the user wants to reply.
  final VoidCallback? onAnswerClarification;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onAddToMeals,
    this.onDiscard,
    this.onEditMessage,
    this.onAnswerClarification,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (message.isLoading) {
      return const _LoadingBubble();
    }
    if (message.isUser) {
      return _buildUserMessage(context);
    } else {
      return _buildAIMessage(context, ref);
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
            child: _AnimatedUserBubble(
              onLongPress: message.type == MessageType.text && onEditMessage != null
                  ? onEditMessage
                  : null,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildUserContent(),
                    if (message.isEdited) ...[
                      const SizedBox(height: 4),
                      Text(
                        'edited',
                        style: TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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

  bool get _isProvisional {
    final status = message.nutritionData?['status'] as String?;
    return status == 'needs_clarification';
  }

  Widget _buildAIMessage(BuildContext context, WidgetRef ref) {
    // If message is deleted, show red deleted version (highest priority)
    if (message.isDeleted) {
      return _buildDeletedMessage();
    }

    // If message is discarded, show compact version
    if (message.isDiscarded) {
      return _buildDiscardedMessage();
    }

    // If message is added, show compact added version
    if (message.isAdded) {
      return _buildAddedMessage(context, ref);
    }

    final provisional = _isProvisional;
    final borderColor = provisional
        ? AppTheme.neonYellow.withOpacity(0.4)
        : AppTheme.borderColor;
    final headerColor = provisional ? AppTheme.neonYellow : AppTheme.neonGreen;
    final headerLabel = provisional ? 'Provisional Analysis' : 'AI Analysis';

    // Clarifying question from stored nutrition data
    final clarifyingQuestion =
        message.nutritionData?['clarifying_question'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: headerColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              provisional ? Icons.help_outline : Icons.psychology,
                              color: headerColor,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            headerLabel,
                            style: TextStyle(
                              color: headerColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (provisional) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.neonYellow.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: AppTheme.neonYellow.withOpacity(0.4)),
                              ),
                              child: const Text(
                                'NEEDS CLARIFICATION',
                                style: TextStyle(
                                  color: AppTheme.neonYellow,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (message.nutritionData != null) ...[
                        _buildNutritionInfo(),
                        // Clarification question block
                        if (provisional && clarifyingQuestion != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.neonYellow.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppTheme.neonYellow.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clarifyingQuestion,
                                  style: const TextStyle(
                                    color: AppTheme.neonYellow,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (onAnswerClarification != null) ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: onAnswerClarification,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.neonYellow,
                                        side: const BorderSide(
                                            color: AppTheme.neonYellow),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                      ),
                                      child: const Text(
                                        'Answer this question',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        // Add button — only for final (complete) results
                        if (!provisional) ...[
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
                        ],
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
                // X button — only for final (non-provisional) messages with nutrition data
                if (message.nutritionData != null && onDiscard != null && !provisional)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onDiscard,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.darkBackground.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscardedMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.borderColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.borderColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.block,
                  size: 14,
                  color: AppTheme.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Discarded: ${message.mealName ?? "Meal"}',
                  style: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddedMessage(BuildContext context, WidgetRef ref) {
    final nutrition = message.nutritionData!;
    final mealName = nutrition['meal_name'] as String? ?? 'Meal';
    final calories = nutrition['calories'] ?? 0;
    final protein = nutrition['protein'] ?? 0;
    final carbs = nutrition['carbs'] ?? 0;
    final fats = nutrition['fats'] ?? 0;

    final messageContent = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.neonGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.neonGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.neonGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 16,
              color: AppTheme.neonGreen,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✓ Added: $mealName',
                  style: const TextStyle(
                    color: AppTheme.neonGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$calories cal • ${protein}g protein • ${carbs}g carbs • ${fats}g fat',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Only make dismissible if we have a valid mealId and it's not deleted
    if (message.mealId != null && !message.isDeleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Dismissible(
                key: Key('meal_${message.mealId}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.neonRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppTheme.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        'Delete Meal?',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      content: Text(
                        'This will remove "$mealName" from your meal log.',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.neonRed,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  try {
                    // Get the meal date from the message timestamp
                    final mealDate = DateTime(
                      message.timestamp.year,
                      message.timestamp.month,
                      message.timestamp.day,
                    );

                    await ref
                        .read(mealsNotifierProvider(mealDate).notifier)
                        .deleteMeal(message.mealId!);

                    // Refresh the meals list
                    ref.invalidate(mealsNotifierProvider(mealDate));
                    ref.invalidate(allUserMealsProvider);

                    if (context.mounted) {
                      AppSnackbar.success(context, 'Meal deleted');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      AppSnackbar.error(context, 'Failed to delete: $e');
                    }
                  }
                },
                child: messageContent,
              ),
            ),
          ],
        ),
      );
    }

    // Not dismissible - just show the content
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(child: messageContent),
        ],
      ),
    );
  }

  Widget _buildDeletedMessage() {
    final nutrition = message.nutritionData!;
    final mealName = nutrition['meal_name'] as String? ?? 'Meal';
    final calories = nutrition['calories'] ?? 0;
    final protein = nutrition['protein'] ?? 0;
    final carbs = nutrition['carbs'] ?? 0;
    final fats = nutrition['fats'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neonRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.neonRed.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.neonRed.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: AppTheme.neonRed,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deleted: $mealName',
                          style: const TextStyle(
                            color: AppTheme.neonRed,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$calories cal • ${protein}g protein • ${carbs}g carbs • ${fats}g fat',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withOpacity(0.7),
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ),
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
              _buildNutritionItem(Icons.local_fire_department, AppTheme.neonGreen, '$calories', 'kcal'),
              _buildNutritionItem(Icons.fitness_center, AppTheme.neonRed, '${protein}g', 'protein'),
              _buildNutritionItem(Icons.grain, AppTheme.neonYellow, '${carbs}g', 'carbs'),
              _buildNutritionItem(Icons.water_drop, AppTheme.neonBlue, '${fats}g', 'fat'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(IconData icon, Color color, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
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
