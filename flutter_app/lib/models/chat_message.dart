import 'package:uuid/uuid.dart';

enum MessageType {
  text,
  image,
  audio,
}

class ChatMessage {
  final String id;
  final String content; // Text content or file path
  final MessageType type;
  final DateTime timestamp;
  final bool isUser; // true for user messages, false for AI responses
  final Map<String, int>? nutritionData; // Only for AI responses

  ChatMessage({
    String? id,
    required this.content,
    required this.type,
    DateTime? timestamp,
    required this.isUser,
    this.nutritionData,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  /// Create a user message
  factory ChatMessage.user({
    required String content,
    required MessageType type,
  }) {
    return ChatMessage(
      content: content,
      type: type,
      isUser: true,
    );
  }

  /// Create an AI response message with nutrition data
  factory ChatMessage.aiResponse({
    required String content,
    required Map<String, int> nutritionData,
  }) {
    return ChatMessage(
      content: content,
      type: MessageType.text,
      isUser: false,
      nutritionData: nutritionData,
    );
  }

  /// Get display text for the message type
  String get typeDisplay {
    switch (type) {
      case MessageType.text:
        return 'Text';
      case MessageType.image:
        return 'Image';
      case MessageType.audio:
        return 'Audio';
    }
  }

  /// Get formatted nutrition summary
  String get nutritionSummary {
    if (nutritionData == null) return '';

    final calories = nutritionData!['calories'] ?? 0;
    final protein = nutritionData!['protein'] ?? 0;
    final carbs = nutritionData!['carbs'] ?? 0;
    final fats = nutritionData!['fats'] ?? 0;

    return '$calories cal • ${protein}g protein • ${carbs}g carbs • ${fats}g fat';
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, type: $type, isUser: $isUser, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
  }
}
