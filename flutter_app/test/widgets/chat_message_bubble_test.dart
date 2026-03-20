import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_scanner/models/chat_message.dart';
import 'package:food_scanner/widgets/chat_message_bubble.dart';

void main() {
  Widget buildBubble(ChatMessage message) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: ChatMessageBubble(
            message: message,
            onAddToMeals: () {},
            onDiscard: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('shows provisional image analysis card and disables actions', (
    tester,
  ) async {
    final message = ChatMessage.aiResponse(
      content: 'Provisional image analysis',
      nutritionData: {
        'analysis_version': 'v2',
        'status': 'needs_clarification',
        'meal_name': 'Rice bowl',
        'calories': 620,
        'protein': 34,
        'carbs': 67,
        'fats': 18,
        'confidence': 0.58,
        'confidence_label': 'medium',
        'clarifying_question': 'How much oil was used?',
        'assumptions': ['Assumed 1 cup cooked rice'],
        'flags': ['mixed_dish'],
        'items': [],
        'estimation_method': 'image_only',
        'source_user_message_id': 'image-1',
      },
    );

    await tester.pumpWidget(buildBubble(message));

    expect(find.text('Provisional nutrition'), findsOneWidget);
    expect(find.text('Clarification needed'), findsOneWidget);
    expect(find.text('How much oil was used?'), findsOneWidget);
    expect(find.text('Add to Today\'s Meals'), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('shows refined analysis card with add action', (tester) async {
    final message = ChatMessage.aiResponse(
      content: 'Refined image analysis',
      nutritionData: {
        'analysis_version': 'v2',
        'status': 'complete',
        'meal_name': 'Rice bowl',
        'calories': 690,
        'protein': 38,
        'carbs': 61,
        'fats': 26,
        'confidence': 0.82,
        'confidence_label': 'high',
        'clarifying_question': null,
        'assumptions': ['Used 1 tbsp oil and teriyaki sauce'],
        'flags': ['mixed_dish'],
        'items': [
          {
            'name': 'grilled chicken',
            'portion_text': 'about 150 g',
            'calories': 250,
            'protein': 46,
            'carbs': 0,
            'fats': 5,
            'confidence': 0.82,
          },
        ],
        'estimation_method': 'image_plus_context',
        'source_user_message_id': 'image-1',
      },
    );

    await tester.pumpWidget(buildBubble(message));

    expect(find.text('Nutrition found'), findsOneWidget);
    expect(find.text('Add to Today\'s Meals'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.textContaining('grilled chicken'), findsOneWidget);
  });
}
