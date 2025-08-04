class Meal {
  final int? id;
  final String name;
  final int calories;
  final double proteins;
  final double fats;
  final double carbs;
  final String? photoPath;
  final DateTime date;

  Meal({
    this.id,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    this.photoPath,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
      'photoPath': photoPath,
      'date': date.toIso8601String(),
    };
  }

  static Meal fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      proteins: map['proteins'],
      fats: map['fats'],
      carbs: map['carbs'],
      photoPath: map['photoPath'],
      date: DateTime.parse(map['date']),
    );
  }

  static Meal fromSupabase(Map<String, dynamic> data) {
    return Meal(
      id: data['id'],
      name: data['name'] ?? '',
      calories: data['calories']?.toInt() ?? 0,
      proteins: data['proteins']?.toDouble() ?? 0.0,
      fats: data['fats']?.toDouble() ?? 0.0,
      carbs: data['carbs']?.toDouble() ?? 0.0,
      photoPath: data['photo_path'],
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'name': name,
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
      'photo_path': photoPath,
      'date': date.toIso8601String(),
    };
  }
}
