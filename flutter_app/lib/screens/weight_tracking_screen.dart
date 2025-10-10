import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/weight_history.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../services/nutrition_calculator_service.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your weight')),
      );
      return;
    }

    final weight = _parseWeight(_weightController.text);
    if (weight == null || weight <= 0 || weight > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid weight (1-300 kg)')),
      );
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

      await profileService.addWeightEntry(weightEntry);

      // Clear form
      _weightController.clear();
      _notesController.clear();
      _selectedDate = DateTime.now();
      _selectedMeasurementTime = 'morning';

      // Reload data
      _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weight entry added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding weight entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showProgressAnalysis() {
    if (_weightHistory.length < 2 || _userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Need at least 2 weight entries and a complete profile for analysis')),
      );
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
        title: const Text('Progress Analysis'),
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
                    color: _getStatusColor(analysis['progressStatus'])
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _getStatusColor(analysis['progressStatus'])),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${_getStatusTitle(analysis['progressStatus'])}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(analysis['progressStatus']),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        analysis['recommendation'],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(analysis['error'] ?? 'Unable to analyze progress'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
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
        title: const Text('Delete Weight Entry'),
        content: Text(
            'Are you sure you want to delete the weight entry from $dateString?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteWeightEntry(entry);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _deleteWeightEntry(WeightHistory entry) async {
    if (entry.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete entry: Invalid ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final profileService = ProfileService();
      await profileService.deleteWeightEntry(entry.id!);

      _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weight entry deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting weight entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Weight Tracking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _weightHistory.length >= 2 && _userProfile != null
                ? _showProgressAnalysis
                : null,
            icon: const Icon(Icons.analytics),
            tooltip: 'Progress Analysis',
          ),
        ],
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
