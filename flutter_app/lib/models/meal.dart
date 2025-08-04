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
      id: map['id'],
      name: map['name'],
      uid: map['uid'],
      calories: map['calories'],
      proteins: map['proteins'],
      fats: map['fats'],
      carbs: map['carbs'],
      photoUrl: map['photoUrl'],
      date: DateTime.parse(map['date']),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  static Meal fromSupabase(Map<String, dynamic> data) {
    return Meal(
      id: data['id'],
      name: data['name'] ?? '',
      uid: data['uid'],
      calories: data['calories']?.toInt() ?? 0,
      proteins: data['proteins']?.toDouble() ?? 0.0,
      fats: data['fats']?.toDouble() ?? 0.0,
      carbs: data['carbs']?.toDouble() ?? 0.0,
      photoUrl: data['photo_url'],
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : null,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
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
}
