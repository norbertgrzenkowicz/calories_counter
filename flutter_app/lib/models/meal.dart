/// Extension for safe number parsing with proper type checking
extension SafeNumParsing on Object? {
  double toSafeDouble() {
    final self = this;
    if (self == null) return 0.0;

    if (self is double) {
      return self.isFinite ? self : 0.0;
    }

    if (self is int) {
      return self.toDouble();
    }

    if (self is String) {
      final parsed = double.tryParse(self);
      return parsed?.isFinite == true ? parsed! : 0.0;
    }

    if (self is num) {
      final asDouble = self.toDouble();
      return asDouble.isFinite ? asDouble : 0.0;
    }

    return 0.0;
  }

  int toSafeInt() {
    final self = this;
    if (self == null) return 0;

    if (self is int) {
      return self;
    }

    if (self is double) {
      return self.isFinite ? self.round() : 0;
    }

    if (self is String) {
      return int.tryParse(self) ?? 0;
    }

    if (self is num) {
      return self.round();
    }

    return 0;
  }

  String toSafeString() {
    final self = this;
    return self?.toString() ?? '';
  }
}

class Meal {
  final int? id;
  final String name;
  final String? uid;
  final int calories;
  final double proteins;
  final double fats;
  final double carbs;
  final String? photoUrl;
  final DateTime date;
  final DateTime? createdAt;

  Meal({
    this.id,
    required this.name,
    this.uid,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    this.photoUrl,
    DateTime? date,
    this.createdAt,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'uid': uid,
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
      'photoUrl': photoUrl,
      'date': date.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static Meal fromMap(Map<String, dynamic> map) {
    return Meal(
      id: (map['id'] as Object?) == null
          ? null
          : (map['id'] as Object?).toSafeInt(),
      name: (map['name'] as Object?).toSafeString(),
      uid: map['uid']?.toString(),
      calories: (map['calories'] as Object?).toSafeInt(),
      proteins: (map['proteins'] as Object?).toSafeDouble(),
      fats: (map['fats'] as Object?).toSafeDouble(),
      carbs: (map['carbs'] as Object?).toSafeDouble(),
      photoUrl: map['photoUrl']?.toString(),
      date: _parseDate(map['date']),
      createdAt: map['createdAt'] != null ? _parseDate(map['createdAt']) : null,
    );
  }

  static Meal fromSupabase(Map<String, dynamic> data) {
    return Meal(
      id: (data['id'] as Object?) == null
          ? null
          : (data['id'] as Object?).toSafeInt(),
      name: (data['name'] as Object?).toSafeString(),
      uid: data['uid']?.toString(),
      calories: (data['calories'] as Object?).toSafeInt(),
      proteins: (data['proteins'] as Object?).toSafeDouble(),
      fats: (data['fats'] as Object?).toSafeDouble(),
      carbs: (data['carbs'] as Object?).toSafeDouble(),
      photoUrl: data['photo_url']?.toString(),
      date: _parseDate(data['date']),
      createdAt:
          data['created_at'] != null ? _parseDate(data['created_at']) : null,
    );
  }

  /// Safely parse date with fallback
  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    if (dateValue is DateTime) return dateValue;

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  Map<String, dynamic> toSupabase() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'uid': uid,
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
      'photo_url': photoUrl,
      'date': date.toIso8601String(),
    };
  }

  /// Create a copy of this Meal with the given fields replaced with new values
  Meal copyWith({
    int? id,
    String? name,
    String? uid,
    int? calories,
    double? proteins,
    double? fats,
    double? carbs,
    String? photoUrl,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      uid: uid ?? this.uid,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      fats: fats ?? this.fats,
      carbs: carbs ?? this.carbs,
      photoUrl: photoUrl ?? this.photoUrl,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
