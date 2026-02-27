import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_theme.dart';
import '../models/meal.dart';
import '../utils/app_page_route.dart';
import 'day_meals_screen.dart';

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
    DateTime dayKey =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    List<Meal>? mealsForDay = mealsByDay[dayKey];

    if (mealsForDay != null && mealsForDay.isNotEmpty) {
      Navigator.of(context).push(
        AppPageRoute(
          builder: (context) => DayMealsScreen(
            date: selectedDay,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<DateTime, List<Meal>> mealsByDay = _getMealsForDay();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.neonGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${calories}kcal',
                              style: const TextStyle(
                                color: AppTheme.darkBackground,
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
                                color: AppTheme.neonGreen,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppTheme.neonGreen.withOpacity(0.3),
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
                                      DateTime date = DateTime.now().subtract(
                                          Duration(days: 30 - value.toInt()));
                                      return Text(
                                        '${date.day}/${date.month}',
                                        style: const TextStyle(fontSize: 8),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
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
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.3)),
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
