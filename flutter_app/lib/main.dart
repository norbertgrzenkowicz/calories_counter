import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'theme/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';

class Meal {
  final String name;
  final int calories;
  final double proteins;
  final double fats;
  final double carbs;
  final String? photoPath;
  final DateTime date;

  Meal({
    required this.name,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    this.photoPath,
    DateTime? date,
  }) : date = date ?? DateTime.now();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    print('Camera error: $e');
  }
  runApp(FoodScannerApp(cameras: cameras));
}

class FoodScannerApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const FoodScannerApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Scanner',
      theme: AppTheme.theme,
      home: DashboardScreen(cameras: cameras),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  
  const DashboardScreen({super.key, required this.cameras});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  List<Meal> meals = [];
  DateTime _selectedDate = DateTime.now();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day - 1);
    });
  }

  void _goToNextDay() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day + 1);
    });
  }

  bool _isToday() {
    final today = DateTime.now();
    return _selectedDate.year == today.year && 
           _selectedDate.month == today.month && 
           _selectedDate.day == today.day;
  }

  String _getFormattedDate() {
    if (_isToday()) {
      return 'Today';
    }
    return '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
  }

  List<Meal> _getMealsForSelectedDate() {
    return meals.where((meal) {
      return meal.date.year == _selectedDate.year &&
             meal.date.month == _selectedDate.month &&
             meal.date.day == _selectedDate.day;
    }).toList();
  }

  void _onMealTapped(int mealIndex) {
    if (mealIndex < meals.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${meals[mealIndex].name} was clicked'))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meal ${mealIndex + 1} was clicked'))
      );
    }
  }

  void _openCalendar() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalendarScreen(meals: meals),
      ),
    );
  }

  void _addMeal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMealScreen(
          selectedDate: _selectedDate,
          onMealAdded: (meal) {
            setState(() {
              meals.add(meal);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _goToPreviousDay,
          icon: const Icon(Icons.arrow_back_ios),
          tooltip: 'Previous Day',
        ),
        title: Text(_getFormattedDate()),
        centerTitle: true,
        actions: [
          if (!_isToday())
            IconButton(
              onPressed: _goToNextDay,
              icon: const Icon(Icons.arrow_forward_ios),
              tooltip: 'Next Day',
            ),
          Row(
            children: [
              IconButton(
                onPressed: _openCalendar,
                icon: const Icon(Icons.calendar_today),
                tooltip: 'Calendar',
              ),
              IconButton(
                onPressed: _addMeal,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add Meal',
              ),
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryGreen,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNutritionSummary(),
            const SizedBox(height: 32),
            _buildMealsSection(),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildNutritionSummary() {
    final selectedDateMeals = _getMealsForSelectedDate();
    final totalCalories = selectedDateMeals.fold(0, (sum, meal) => sum + meal.calories);
    final totalProteins = selectedDateMeals.fold(0.0, (sum, meal) => sum + meal.proteins);
    final totalCarbs = selectedDateMeals.fold(0.0, (sum, meal) => sum + meal.carbs);
    final totalFats = selectedDateMeals.fold(0.0, (sum, meal) => sum + meal.fats);
    
    const targetCalories = 2000;
    const targetProteins = 150.0;
    const targetCarbs = 250.0;
    const targetFats = 65.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNutritionBar('$totalCalories kcal / $targetCalories kcal', totalCalories / targetCalories),
            const SizedBox(height: 16),
            _buildNutritionBar('${totalProteins.toStringAsFixed(1)}g Proteins / ${targetProteins.toStringAsFixed(0)}g Proteins', totalProteins / targetProteins),
            const SizedBox(height: 16),
            _buildNutritionBar('${totalCarbs.toStringAsFixed(1)}g Carbs / ${targetCarbs.toStringAsFixed(0)}g Carbs', totalCarbs / targetCarbs),
            const SizedBox(height: 16),
            _buildNutritionBar('${totalFats.toStringAsFixed(1)}g Fat / ${targetFats.toStringAsFixed(0)}g Fat', totalFats / targetFats),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionBar(String label, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.softGray,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildMealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Meals',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        _getMealsForSelectedDate().isEmpty
            ? _buildEmptyMealsRow()
            : _buildMealsGrid(),
      ],
    );
  }

  Widget _buildEmptyMealsRow() {
    return Row(
      children: [
        Expanded(child: _buildMealCard(0, 'Meal 1 Date')),
        const SizedBox(width: 12),
        Expanded(child: _buildMealCard(1, 'Meal 2 Date')),
        const SizedBox(width: 12),
        Expanded(child: _buildMealCard(2, 'Meal 3 Date')),
      ],
    );
  }

  Widget _buildMealsGrid() {
    final selectedDateMeals = _getMealsForSelectedDate();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: selectedDateMeals.asMap().entries.map((entry) {
        int index = entry.key;
        Meal meal = entry.value;
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 56) / 3,
          child: _buildActualMealCard(index, meal),
        );
      }).toList(),
    );
  }

  Widget _buildMealCard(int index, String date) {
    return GestureDetector(
      onTap: () => _onMealTapped(index),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.softGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.charcoal.withOpacity(0.2)),
                ),
                child: const Center(
                  child: Text(
                    'Photo',
                    style: TextStyle(
                      color: AppTheme.charcoal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActualMealCard(int index, Meal meal) {
    return GestureDetector(
      onTap: () => _onMealTapped(index),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.softGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.charcoal.withOpacity(0.2)),
                ),
                child: meal.photoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(meal.photoPath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : const Center(
                        child: Text(
                          'Photo',
                          style: TextStyle(
                            color: AppTheme.charcoal,
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                meal.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${meal.calories} cal',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.charcoal.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.charcoal.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(0, Icons.settings, 'Settings'),
          _buildBottomNavItem(1, Icons.person, 'Your Profile'),
          _buildBottomNavItem(2, Icons.settings, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primaryGreen : AppTheme.charcoal.withOpacity(0.6),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryGreen : AppTheme.charcoal.withOpacity(0.6),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class AddMealScreen extends StatefulWidget {
  final Function(Meal) onMealAdded;
  final DateTime selectedDate;

  const AddMealScreen({super.key, required this.onMealAdded, required this.selectedDate});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _carbsController = TextEditingController();
  String? _photoPath;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _fatsController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  void _addPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo picker functionality would be implemented here'))
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final meal = Meal(
        name: _nameController.text,
        calories: int.parse(_caloriesController.text),
        proteins: double.parse(_proteinsController.text),
        fats: double.parse(_fatsController.text),
        carbs: double.parse(_carbsController.text),
        photoPath: _photoPath,
        date: widget.selectedDate,
      );
      
      widget.onMealAdded(meal);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        title: Text('Add Meal - ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Meal Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a meal name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter calories';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _proteinsController,
                decoration: const InputDecoration(
                  labelText: 'Proteins (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter proteins';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fatsController,
                decoration: const InputDecoration(
                  labelText: 'Fats (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter fats';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _carbsController,
                decoration: const InputDecoration(
                  labelText: 'Carbs (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter carbs';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _addPhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Add Photo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  final List<Meal> meals;

  const CalendarScreen({super.key, required this.meals});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Meal>> _getMealsForDay() {
    Map<DateTime, List<Meal>> mealsByDay = {};
    for (Meal meal in widget.meals) {
      DateTime day = DateTime(meal.date.year, meal.date.month, meal.date.day);
      if (mealsByDay[day] == null) {
        mealsByDay[day] = [];
      }
      mealsByDay[day]!.add(meal);
    }
    return mealsByDay;
  }

  int _getCaloriesForDay(DateTime day) {
    Map<DateTime, List<Meal>> mealsByDay = _getMealsForDay();
    DateTime dayKey = DateTime(day.year, day.month, day.day);
    List<Meal>? mealsForDay = mealsByDay[dayKey];
    if (mealsForDay == null) return 0;
    return mealsForDay.fold(0, (sum, meal) => sum + meal.calories);
  }

  List<FlSpot> _getChartData() {
    DateTime oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
    List<FlSpot> spots = [];
    
    for (int i = 0; i <= 30; i++) {
      DateTime day = oneMonthAgo.add(Duration(days: i));
      int calories = _getCaloriesForDay(day);
      spots.add(FlSpot(i.toDouble(), calories.toDouble()));
    }
    
    return spots;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    
    Map<DateTime, List<Meal>> mealsByDay = _getMealsForDay();
    DateTime dayKey = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    List<Meal>? mealsForDay = mealsByDay[dayKey];
    
    if (mealsForDay != null && mealsForDay.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DayMealsScreen(
            date: selectedDay,
            meals: mealsForDay,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<DateTime, List<Meal>> mealsByDay = _getMealsForDay();
    
    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Exit to Main Menu',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TableCalendar<Meal>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: (day) {
                    DateTime dayKey = DateTime(day.year, day.month, day.day);
                    return mealsByDay[dayKey] ?? [];
                  },
                  onDaySelected: _onDaySelected,
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isNotEmpty) {
                        int calories = _getCaloriesForDay(day);
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${calories}kcal',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calories Chart (Last 30 Days)',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: _getChartData(),
                                isCurved: true,
                                color: AppTheme.primaryGreen,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppTheme.primaryGreen.withOpacity(0.3),
                                ),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}',
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 20,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() % 5 == 0) {
                                      DateTime date = DateTime.now().subtract(Duration(days: 30 - value.toInt()));
                                      return Text(
                                        '${date.day}/${date.month}',
                                        style: const TextStyle(fontSize: 8),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 200,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.withOpacity(0.3),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DayMealsScreen extends StatelessWidget {
  final DateTime date;
  final List<Meal> meals;

  const DayMealsScreen({super.key, required this.date, required this.meals});

  @override
  Widget build(BuildContext context) {
    int totalCalories = meals.fold(0, (sum, meal) => sum + meal.calories);
    double totalProteins = meals.fold(0, (sum, meal) => sum + meal.proteins);
    double totalCarbs = meals.fold(0, (sum, meal) => sum + meal.carbs);
    double totalFats = meals.fold(0, (sum, meal) => sum + meal.fats);

    return Scaffold(
      backgroundColor: AppTheme.creamWhite,
      appBar: AppBar(
        title: Text('${date.day}/${date.month}/${date.year}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Summary',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildNutritionBar(context, '$totalCalories kcal', 1.0),
                    const SizedBox(height: 16),
                    _buildNutritionBar(context, '${totalProteins.toStringAsFixed(1)}g Proteins', 0.8),
                    const SizedBox(height: 16),
                    _buildNutritionBar(context, '${totalCarbs.toStringAsFixed(1)}g Carbs', 0.6),
                    const SizedBox(height: 16),
                    _buildNutritionBar(context, '${totalFats.toStringAsFixed(1)}g Fats', 0.4),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Meals',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.softGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: meal.photoPath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(meal.photoPath!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.fastfood, color: AppTheme.charcoal),
                      ),
                      title: Text(meal.name),
                      subtitle: Text('${meal.calories} kcal'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('P: ${meal.proteins.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 10)),
                          Text('C: ${meal.carbs.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 10)),
                          Text('F: ${meal.fats.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionBar(BuildContext context, String label, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.softGray,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          minHeight: 8,
        ),
      ],
    );
  }
}