class CustomFood {
  final int? id;
  final String name;
  final String? brand;
  final double caloriesPer100g;
  final double proteinsPer100g;
  final double fatsPer100g;
  final double carbsPer100g;
  final String servingUnit;
  final double? servingSizeG;
  final DateTime? createdAt;

  const CustomFood({
    this.id,
    required this.name,
    this.brand,
    required this.caloriesPer100g,
    required this.proteinsPer100g,
    required this.fatsPer100g,
    required this.carbsPer100g,
    this.servingUnit = 'g',
    this.servingSizeG,
    this.createdAt,
  });

  static CustomFood fromSupabase(Map<String, dynamic> data) => CustomFood(
        id: data['id'] as int?,
        name: data['name'] as String,
        brand: data['brand'] as String?,
        caloriesPer100g: (data['calories_per_100g'] as num).toDouble(),
        proteinsPer100g: (data['proteins_per_100g'] as num).toDouble(),
        fatsPer100g: (data['fats_per_100g'] as num).toDouble(),
        carbsPer100g: (data['carbs_per_100g'] as num).toDouble(),
        servingUnit: data['serving_unit'] as String? ?? 'g',
        servingSizeG: data['serving_size_g'] != null
            ? (data['serving_size_g'] as num).toDouble()
            : null,
        createdAt: data['created_at'] != null
            ? DateTime.parse(data['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toSupabase() => {
        if (id != null) 'id': id,
        'name': name,
        if (brand != null && brand!.isNotEmpty) 'brand': brand,
        'calories_per_100g': caloriesPer100g,
        'proteins_per_100g': proteinsPer100g,
        'fats_per_100g': fatsPer100g,
        'carbs_per_100g': carbsPer100g,
        'serving_unit': servingUnit,
        if (servingSizeG != null) 'serving_size_g': servingSizeG,
      };

  /// Calculate nutrition for a given amount in grams.
  Map<String, num> nutritionForAmount(double amountG) {
    final f = amountG / 100.0;
    return {
      'calories': (caloriesPer100g * f).round(),
      'proteins': double.parse((proteinsPer100g * f).toStringAsFixed(1)),
      'fats': double.parse((fatsPer100g * f).toStringAsFixed(1)),
      'carbs': double.parse((carbsPer100g * f).toStringAsFixed(1)),
    };
  }

  String get displayName => (brand != null && brand!.isNotEmpty) ? '$name ($brand)' : name;

  CustomFood copyWith({
    int? id,
    String? name,
    String? brand,
    double? caloriesPer100g,
    double? proteinsPer100g,
    double? fatsPer100g,
    double? carbsPer100g,
    String? servingUnit,
    double? servingSizeG,
    DateTime? createdAt,
  }) =>
      CustomFood(
        id: id ?? this.id,
        name: name ?? this.name,
        brand: brand ?? this.brand,
        caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
        proteinsPer100g: proteinsPer100g ?? this.proteinsPer100g,
        fatsPer100g: fatsPer100g ?? this.fatsPer100g,
        carbsPer100g: carbsPer100g ?? this.carbsPer100g,
        servingUnit: servingUnit ?? this.servingUnit,
        servingSizeG: servingSizeG ?? this.servingSizeG,
        createdAt: createdAt ?? this.createdAt,
      );
}
