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
  final Map<String, dynamic>? nutritionData; // Only for AI responses (includes meal_name, calories, protein, carbs, fats)
  final bool isDiscarded; // true if the message has been discarded
  final bool isAdded; // true if the meal has been added to today's meals
  final String? mealName; // Name of the meal (set when discarded)

  ChatMessage({
    String? id,
    required this.content,
    required this.type,
    DateTime? timestamp,
    required this.isUser,
    this.nutritionData,
    this.isDiscarded = false,
    this.isAdded = false,
    this.mealName,
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
    required Map<String, dynamic> nutritionData,
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

  /// Create a copy with updated fields
  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isUser,
    Map<String, dynamic>? nutritionData,
    bool? isDiscarded,
    bool? isAdded,
    String? mealName,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isUser: isUser ?? this.isUser,
      nutritionData: nutritionData ?? this.nutritionData,
      isDiscarded: isDiscarded ?? this.isDiscarded,
      isAdded: isAdded ?? this.isAdded,
      mealName: mealName ?? this.mealName,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, type: $type, isUser: $isUser, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
  }
}
