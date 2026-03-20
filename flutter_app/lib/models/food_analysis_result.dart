/// Typed model for the v2 food-analysis API response.
///
/// Parses both legacy flat responses (only meal_name/calories/protein/carbs/fats)
/// and the new v2 shape (status, confidence, clarifying_question, items, …).
class FoodAnalysisItem {
  final String name;
  final String portionText;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final double confidence;

  const FoodAnalysisItem({
    required this.name,
    required this.portionText,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.confidence,
  });

  factory FoodAnalysisItem.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisItem(
      name: json['name'] as String? ?? 'Unknown',
      portionText: json['portion_text'] as String? ?? '',
      calories: _parseInt(json['calories']),
      protein: _parseInt(json['protein']),
      carbs: _parseInt(json['carbs']),
      fats: _parseInt(json['fats']),
      confidence: _parseDouble(json['confidence'], fallback: 0.5),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'portion_text': portionText,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'confidence': confidence,
      };
}

class FoodAnalysisResult {
  final String status; // 'complete' | 'needs_clarification'
  final String mealName;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final double confidence;
  final String confidenceLabel; // 'low' | 'medium' | 'high'
  final String? clarifyingQuestion;
  final List<String> assumptions;
  final List<String> flags;
  final List<FoodAnalysisItem> items;
  final String estimationMethod; // 'image_only' | 'image_plus_context'
  final String analysisVersion;

  const FoodAnalysisResult({
    required this.status,
    required this.mealName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.confidence,
    required this.confidenceLabel,
    this.clarifyingQuestion,
    required this.assumptions,
    required this.flags,
    required this.items,
    required this.estimationMethod,
    required this.analysisVersion,
  });

  bool get isComplete => status == 'complete';
  bool get needsClarification => status == 'needs_clarification';

  /// Parses both legacy flat maps and v2 maps.
  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String? ?? 'complete';

    final rawItems = json['items'];
    final items = <FoodAnalysisItem>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          items.add(FoodAnalysisItem.fromJson(item));
        }
      }
    }

    final rawAssumptions = json['assumptions'];
    final assumptions = rawAssumptions is List
        ? rawAssumptions.whereType<String>().toList()
        : <String>[];

    final rawFlags = json['flags'];
    final flags =
        rawFlags is List ? rawFlags.whereType<String>().toList() : <String>[];

    return FoodAnalysisResult(
      status: status,
      mealName: json['meal_name'] as String? ?? 'Unknown Meal',
      calories: _parseInt(json['calories']),
      protein: _parseInt(json['protein']),
      carbs: _parseInt(json['carbs']),
      fats: _parseInt(json['fats']),
      confidence: _parseDouble(json['confidence'], fallback: 1.0),
      confidenceLabel: json['confidence_label'] as String? ?? 'high',
      clarifyingQuestion: json['clarifying_question'] as String?,
      assumptions: assumptions,
      flags: flags,
      items: items,
      estimationMethod: json['estimation_method'] as String? ?? 'image_only',
      analysisVersion: json['analysis_version'] as String? ?? 'v1',
    );
  }

  /// Converts to a JSON map suitable for storing in chat_messages.nutrition_data.
  Map<String, dynamic> toJson() => {
        'analysis_version': analysisVersion,
        'status': status,
        'meal_name': mealName,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'confidence': confidence,
        'confidence_label': confidenceLabel,
        'estimation_method': estimationMethod,
        'clarifying_question': clarifyingQuestion,
        'assumptions': assumptions,
        'flags': flags,
        'items': items.map((i) => i.toJson()).toList(),
      };

  /// Convenience: produce the legacy flat map used by older callers.
  Map<String, dynamic> toLegacyMap() => {
        'meal_name': mealName,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
      };
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

int _parseInt(dynamic v, {int fallback = 0}) {
  if (v is int) return v < 0 ? 0 : v;
  if (v is double) return v < 0 ? 0 : v.round();
  if (v is String) {
    final parsed = int.tryParse(v) ?? double.tryParse(v)?.round();
    if (parsed != null) return parsed < 0 ? 0 : parsed;
  }
  return fallback;
}

double _parseDouble(dynamic v, {double fallback = 0.0}) {
  if (v is double) return v.clamp(0.0, 1.0);
  if (v is int) return v.toDouble().clamp(0.0, 1.0);
  if (v is String) {
    final parsed = double.tryParse(v);
    if (parsed != null) return parsed.clamp(0.0, 1.0);
  }
  return fallback;
}
