import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/weight_history.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../services/nutrition_calculator_service.dart';
import '../utils/app_snackbar.dart';

class WeightTrackingScreen extends StatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  List<WeightHistory> _weightHistory = [];
  UserProfile? _userProfile;
  String _selectedMeasurementTime = 'morning';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isLoadingHistory = true;

  final List<String> _measurementTimes = ['morning', 'afternoon', 'evening'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Helper function to parse weight with both comma and dot decimal separators
  double? _parseWeight(String text) {
    if (text.isEmpty) return null;

    // Replace comma with dot for parsing
    String normalizedText = text.replaceAll(',', '.');

    // Handle multiple dots (invalid input)
    if (normalizedText.split('.').length > 2) return null;

    return double.tryParse(normalizedText);
  }

  void _loadData() async {
    setState(() => _isLoadingHistory = true);

    try {
      final profileService = ProfileService();
      final profile = await profileService.getUserProfile();
      final history =
          await profileService.getWeightHistory(limit: 30); // Last 30 entries

      setState(() {
        _userProfile = profile;
        _weightHistory = history;
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() => _isLoadingHistory = false);
      if (mounted) {
        AppSnackbar.error(context, 'Error loading data: $e');
      }
    }
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _addWeightEntry() async {
    if (_weightController.text.isEmpty) {
      AppSnackbar.warning(context, 'Please enter your weight');
      return;
    }

    final weight = _parseWeight(_weightController.text);
    if (weight == null || weight <= 0 || weight > 300) {
      AppSnackbar.warning(context, 'Please enter a valid weight (1-300 kg)');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final profileService = ProfileService();

      final weightEntry = WeightHistory(
        weightKg: weight,
        recordedDate: _selectedDate,
        measurementTime: _selectedMeasurementTime,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      // Add weight entry to history
      await profileService.addWeightEntry(weightEntry);

      // Update current weight in profile and recalculate calories
      if (_userProfile != null) {
        final updatedProfile = _userProfile!.copyWith(
          currentWeightKg: weight,
        );
        await profileService.saveUserProfile(updatedProfile);
      }

      // Clear form
      _weightController.clear();
      _notesController.clear();
      _selectedDate = DateTime.now();
      _selectedMeasurementTime = 'morning';

      // Reload data
      _loadData();

      if (mounted) {
        AppSnackbar.success(context, 'Weight entry added successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Error adding weight entry: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showProgressAnalysis() {
    if (_weightHistory.length < 2 || _userProfile == null) {
      AppSnackbar.warning(context, 'Need at least 2 weight entries and a complete profile for analysis');
      return;
    }

    final targetCalories = _userProfile!.calculateTargetCalories();
    final tdee = _userProfile!.calculateTDEE();
    final dailyDeficit = tdee - targetCalories;

    final analysis = NutritionCalculatorService.analyzeWeightProgress(
      weightHistory: _weightHistory,
      dailyCalorieDeficit: dailyDeficit,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Progress Analysis', style: TextStyle(color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (analysis['hasProgress'] == true) ...[
                _buildAnalysisRow('Actual Weight Change',
                    '${analysis['actualWeightChange'].toStringAsFixed(1)} kg'),
                _buildAnalysisRow('Expected Weight Change',
                    '${analysis['expectedWeightChange'].toStringAsFixed(1)} kg'),
                _buildAnalysisRow('Progress',
                    '${analysis['progressPercentage'].toStringAsFixed(0)}%'),
                _buildAnalysisRow('Weekly Actual',
                    '${analysis['weeklyActualChange'].toStringAsFixed(2)} kg/week'),
                _buildAnalysisRow('Weekly Expected',
                    '${analysis['weeklyExpectedChange'].toStringAsFixed(2)} kg/week'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(analysis['progressStatus'] as String)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _getStatusColor(analysis['progressStatus'] as String)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${_getStatusTitle(analysis['progressStatus'] as String)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(analysis['progressStatus'] as String),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        analysis['recommendation'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text((analysis['error'] as String?) ?? 'Unable to analyze progress'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: AppTheme.neonGreen)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(WeightHistory entry) {
    final dateString =
        '${entry.recordedDate.day}/${entry.recordedDate.month}/${entry.recordedDate.year}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Weight Entry', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
            'Are you sure you want to delete the weight entry from $dateString?',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteWeightEntry(entry);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.neonRed),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _deleteWeightEntry(WeightHistory entry) async {
    if (entry.id == null) {
      AppSnackbar.error(context, 'Cannot delete entry: Invalid ID');
      return;
    }

    try {
      final profileService = ProfileService();

      // Delete the weight entry
      await profileService.deleteWeightEntry(entry.id!);

      // Get the updated weight history (after deletion)
      final updatedHistory = await profileService.getWeightHistory(limit: 1);

      // Update profile with the most recent weight (if any)
      if (_userProfile != null && updatedHistory.isNotEmpty) {
        final mostRecentWeight = updatedHistory.first.weightKg;
        final updatedProfile = _userProfile!.copyWith(
          currentWeightKg: mostRecentWeight,
        );
        await profileService.saveUserProfile(updatedProfile);
      }

      _loadData();

      if (mounted) {
        AppSnackbar.success(context, 'Weight entry deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Error deleting weight entry: $e');
      }
    }
  }

  Widget _buildAnalysisRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'exceeding':
        return Colors.orange;
      case 'on_track':
        return Colors.green;
      case 'slow_progress':
        return Colors.blue;
      case 'minimal_progress':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'exceeding':
        return 'Exceeding Target';
      case 'on_track':
        return 'On Track';
      case 'slow_progress':
        return 'Slow Progress';
      case 'minimal_progress':
        return 'Minimal Progress';
      default:
        return 'Unknown';
    }
  }

  Widget _buildWeightChart() {
    if (_weightHistory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                Icons.show_chart,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'Weight Chart',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add weight entries to see your progress chart',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Sort weight history by date (oldest first) for the chart
    final sortedHistory = List<WeightHistory>.from(_weightHistory)
      ..sort((a, b) => a.recordedDate.compareTo(b.recordedDate));

    // Create spots for the line chart
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedHistory[i].weightKg));
    }

    // Calculate min and max weight for Y axis
    final weights = sortedHistory.map((e) => e.weightKg).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final weightRange = maxWeight - minWeight;
    final yMin = minWeight - (weightRange * 0.1).clamp(0.5, 5.0);
    final yMax = maxWeight + (weightRange * 0.1).clamp(0.5, 5.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.show_chart,
                  color: AppTheme.neonGreen,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weight Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (yMax - yMin) / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: (sortedHistory.length / 5).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < sortedHistory.length) {
                            final date = sortedHistory[index].recordedDate;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (yMax - yMin) / 5,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  minX: 0,
                  maxX: (sortedHistory.length - 1).toDouble(),
                  minY: yMin,
                  maxY: yMax,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppTheme.neonGreen,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.neonGreen,
                            strokeWidth: 2,
                            strokeColor: AppTheme.darkBackground,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.neonGreen.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) =>
                          AppTheme.darkBackground.withOpacity(0.8),
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < sortedHistory.length) {
                            final entry = sortedHistory[index];
                            final date = entry.recordedDate;
                            return LineTooltipItem(
                              '${entry.weightKg.toStringAsFixed(1)} kg\n${date.day}/${date.month}/${date.year}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressAnalysisCard() {
    if (_weightHistory.length < 2 || _userProfile == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'Progress Analysis',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add at least 2 weight entries to see your progress analysis',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final targetCalories = _userProfile!.calculateTargetCalories();
    final tdee = _userProfile!.calculateTDEE();
    final dailyDeficit = tdee - targetCalories;

    final analysis = NutritionCalculatorService.analyzeWeightProgress(
      weightHistory: _weightHistory,
      dailyCalorieDeficit: dailyDeficit,
    );

    if (analysis['hasProgress'] != true) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to analyze progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                (analysis['error'] as String?) ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: AppTheme.neonGreen,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Progress Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildAnalysisRow('Actual Weight Change',
                '${analysis['actualWeightChange'].toStringAsFixed(1)} kg'),
            _buildAnalysisRow('Expected Weight Change',
                '${analysis['expectedWeightChange'].toStringAsFixed(1)} kg'),
            _buildAnalysisRow('Progress',
                '${analysis['progressPercentage'].toStringAsFixed(0)}%'),
            _buildAnalysisRow('Weekly Actual',
                '${analysis['weeklyActualChange'].toStringAsFixed(2)} kg/week'),
            _buildAnalysisRow('Weekly Expected',
                '${analysis['weeklyExpectedChange'].toStringAsFixed(2)} kg/week'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(analysis['progressStatus'] as String)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _getStatusColor(analysis['progressStatus'] as String)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ${_getStatusTitle(analysis['progressStatus'] as String)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(analysis['progressStatus'] as String),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    analysis['recommendation'] as String,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Weight Tracking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoadingHistory
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Add Weight Entry Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Weight Entry',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 20),

                            // Weight Input
                            TextFormField(
                              controller: _weightController,
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                hintText: 'e.g., 70.5 or 70,5',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.monitor_weight),
                                suffixText: 'kg',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                            const SizedBox(height: 16),

                            // Date Selection
                            InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Measurement Time
                            DropdownButtonFormField<String>(
                              value: _selectedMeasurementTime,
                              decoration: const InputDecoration(
                                labelText: 'Measurement Time',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              items: _measurementTimes.map((time) {
                                return DropdownMenuItem(
                                  value: time,
                                  child: Text(time.replaceFirst(
                                      time[0], time[0].toUpperCase())),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(
                                    () => _selectedMeasurementTime = value!);
                              },
                            ),
                            const SizedBox(height: 16),

                            // Notes
                            TextFormField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'Notes (optional)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.note),
                                hintText:
                                    'e.g., after workout, before breakfast',
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 20),

                            // Add Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _addWeightEntry,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.neonGreen,
                                foregroundColor: AppTheme.darkBackground,
                                padding: const EdgeInsets.all(16),
                                disabledBackgroundColor: Colors.grey.shade400,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Add Weight Entry'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Weight Chart
                    _buildWeightChart(),

                    const SizedBox(height: 20),

                    // Progress Analysis Card
                    _buildProgressAnalysisCard(),

                    const SizedBox(height: 20),

                    // Weight History
                    Text(
                      'Weight History',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    _weightHistory.isEmpty
                        ? Card(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.monitor_weight_outlined,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No weight entries yet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add your first weight entry above to start tracking your progress',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.grey.shade500,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: _weightHistory.map((entry) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppTheme.neonGreen.withOpacity(0.1),
                                    child: Icon(
                                      Icons.monitor_weight,
                                      color: AppTheme.neonGreen,
                                      size: 20,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${entry.weightKg.toStringAsFixed(1)} kg',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _showDeleteConfirmation(entry),
                                        icon: const Icon(Icons.close, size: 20),
                                        color: Colors.red.shade600,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 24,
                                          minHeight: 24,
                                        ),
                                        tooltip: 'Delete entry',
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${entry.recordedDate.day}/${entry.recordedDate.month}/${entry.recordedDate.year} - ${entry.measurementTimeDisplayName}',
                                      ),
                                      if (entry.notes != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          entry.notes!,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (entry.weightChangeKg != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: entry.weightChangeColor ==
                                                    'positive'
                                                ? Colors.green.shade50
                                                : entry.weightChangeColor ==
                                                        'negative'
                                                    ? Colors.red.shade50
                                                    : Colors.grey.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            entry.weightChangeDescription,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: entry.weightChangeColor ==
                                                      'positive'
                                                  ? Colors.green.shade700
                                                  : entry.weightChangeColor ==
                                                          'negative'
                                                      ? Colors.red.shade700
                                                      : Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (entry.isInitialPhase) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Initial Phase',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 80), // Space for bottom padding
                  ],
                ),
              ),
            ),
    );
  }
}
