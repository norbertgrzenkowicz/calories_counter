import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/meal.dart';

class PersistenceService {
  static final PersistenceService _instance = PersistenceService._internal();
  factory PersistenceService() => _instance;
  PersistenceService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'food_scanner.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE meals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        calories INTEGER,
        proteins REAL,
        fats REAL,
        carbs REAL,
        photoPath TEXT,
        date TEXT
      )
    ''');
  }

  Future<void> insertMeal(Meal meal) async {
    final db = await database;
    await db.insert('meals', meal.toMap());
  }

  Future<List<Meal>> getMeals() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('meals');
      print('Meals loaded successfully: $maps');
      return List.generate(maps.length, (i) {
        return Meal.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error loading meals: $e');
      return [];
    }
  }
}


extension on Meal {
  Map<String, dynamic> toMap() {
    return {
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
      name: map['name'],
      calories: map['calories'],
      proteins: map['proteins'],
      fats: map['fats'],
      carbs: map['carbs'],
      photoPath: map['photoPath'],
      date: DateTime.parse(map['date']),
    );
  }
}
