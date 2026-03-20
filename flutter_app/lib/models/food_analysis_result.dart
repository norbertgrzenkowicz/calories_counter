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
      name: _asString(json['name'], fallback: 'Unknown item'),
      portionText: _asString(json['portion_text']),
      calories: _asInt(json['calories']),
      protein: _asInt(json['protein']),
      carbs: _asInt(json['carbs']),
      fats: _asInt(json['fats']),
      confidence: _clampConfidence(_asDouble(json['confidence'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'portion_text': portionText,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'confidence': confidence,
    };
  }
}

class FoodAnalysisResult {
  final String status;
  final String mealName;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final double confidence;
  final String confidenceLabel;
  final String? clarifyingQuestion;
  final List<String> assumptions;
  final List<String> flags;
  final List<FoodAnalysisItem> items;
  final String estimationMethod;
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
    required this.clarifyingQuestion,
    required this.assumptions,
    required this.flags,
    required this.items,
    required this.estimationMethod,
    required this.analysisVersion,
  });

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    final confidence = _clampConfidence(_asDouble(json['confidence']));
    final status = _normalizeStatus(json['status']);

    return FoodAnalysisResult(
      status: status,
      mealName: _asString(json['meal_name'], fallback: 'Unknown Meal'),
      calories: _asInt(json['calories']),
      protein: _asInt(json['protein']),
      carbs: _asInt(json['carbs']),
      fats: _asInt(json['fats']),
      confidence: confidence,
      confidenceLabel: _normalizeConfidenceLabel(json['confidence_label']) ??
          _deriveConfidenceLabel(confidence),
      clarifyingQuestion: _nullableString(json['clarifying_question']),
      assumptions: _stringList(json['assumptions']),
      flags: _stringList(json['flags']),
      items: _itemsFromJson(json['items']),
      estimationMethod: _normalizeEstimationMethod(json['estimation_method']),
      analysisVersion: _nullableString(json['analysis_version']) ?? 'legacy',
    );
  }

  bool get needsClarification => status == 'needs_clarification';
  bool get isComplete => status == 'complete';

  Map<String, dynamic> toJson() {
    return {
      'analysis_version': analysisVersion,
      'status': status,
      'meal_name': mealName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'confidence': confidence,
      'confidence_label': confidenceLabel,
      'clarifying_question': clarifyingQuestion,
      'assumptions': assumptions,
      'flags': flags,
      'items': items.map((item) => item.toJson()).toList(),
      'estimation_method': estimationMethod,
    };
  }

  static List<FoodAnalysisItem> _itemsFromJson(dynamic value) {
    if (value is! List) {
      return const [];
    }

    final items = <FoodAnalysisItem>[];
    for (final item in value) {
      if (item is Map) {
        items.add(
          FoodAnalysisItem.fromJson(
            Map<String, dynamic>.from(item),
          ),
        );
      }
    }
    return items;
  }
}

String _normalizeStatus(dynamic value) {
  final status = _nullableString(value);
  if (status == 'needs_clarification') {
    return 'needs_clarification';
  }
  return 'complete';
}

String? _normalizeConfidenceLabel(dynamic value) {
  final label = _nullableString(value);
  if (label == 'low' || label == 'medium' || label == 'high') {
    return label;
  }
  return null;
}

String _normalizeEstimationMethod(dynamic value) {
  final method = _nullableString(value);
  if (method == 'image_plus_context') {
    return 'image_plus_context';
  }
  return 'image_only';
}

String _deriveConfidenceLabel(double confidence) {
  if (confidence < 0.45) {
    return 'low';
  }
  if (confidence < 0.75) {
    return 'medium';
  }
  return 'high';
}

List<String> _stringList(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

String _asString(dynamic value, {String fallback = ''}) {
  final text = _nullableString(value);
  return text ?? fallback;
}

String? _nullableString(dynamic value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int _asInt(dynamic value) {
  if (value is int) {
    return value < 0 ? 0 : value;
  }
  if (value is num) {
    final rounded = value.round();
    return rounded < 0 ? 0 : rounded;
  }
  if (value is String) {
    final parsed = num.tryParse(value);
    if (parsed != null) {
      final rounded = parsed.round();
      return rounded < 0 ? 0 : rounded;
    }
  }
  return 0;
}

double _asDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}

double _clampConfidence(double value) {
  if (value < 0) {
    return 0;
  }
  if (value > 1) {
    return 1;
  }
  return value;
}
