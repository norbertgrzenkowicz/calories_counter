import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../services/data_export_service.dart';
import '../core/app_logger.dart';

enum ExportFormat { csv, json, xml, pdf }

class ExportDataScreen extends ConsumerStatefulWidget {
  const ExportDataScreen({super.key});

  @override
  ConsumerState<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends ConsumerState<ExportDataScreen> {
  bool _includeWeightHistory = true;
  bool _includeMealHistory = false; // Disabled for now
  bool _selectAllData = true;
  DateTime? _fromDate;
  DateTime? _toDate;
  ExportFormat _selectedFormat = ExportFormat.csv;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _toDate = now;
    // Default to 1 year ago
    _fromDate = DateTime(now.year - 1, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppTheme.creamWhite,
      body: _isExporting ? _buildExportingView() : _buildExportForm(),
    );
  }

  Widget _buildExportingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          ),
          SizedBox(height: 16),
          Text(
            'Exporting your data...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This may take a few moments',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Data to Export',
            child: _buildDataSelectionSection(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Date Range',
            child: _buildDateRangeSection(),
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Export Format',
            child: _buildFormatSelectionSection(),
          ),
          const SizedBox(height: 32),
          _buildExportButton(),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildDataSelectionSection() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Weight History'),
          subtitle: const Text('All your weight tracking data'),
          value: _includeWeightHistory,
          onChanged: (bool? value) {
            setState(() {
              _includeWeightHistory = value ?? false;
            });
          },
          activeColor: AppTheme.primaryGreen,
        ),
        CheckboxListTile(
          title: const Text('Meal History'),
          subtitle: const Text('Coming soon - meal tracking data'),
          value: _includeMealHistory,
          onChanged: null, // Disabled for now
          activeColor: AppTheme.primaryGreen,
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Select All Data'),
          subtitle: const Text('Export all available data from your account'),
          value: _selectAllData,
          onChanged: (bool? value) {
            setState(() {
              _selectAllData = value ?? false;
            });
          },
          activeColor: AppTheme.primaryGreen,
        ),
        if (!_selectAllData) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'From',
                  date: _fromDate,
                  onTap: () => _selectDate(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  label: 'To',
                  date: _toDate,
                  onTap: () => _selectDate(false),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select date',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelectionSection() {
    return Column(
      children: [
        _buildFormatOption(
          ExportFormat.csv,
          'CSV',
          'Comma-separated values, ideal for spreadsheets',
          Icons.table_chart,
        ),
        _buildFormatOption(
          ExportFormat.json,
          'JSON',
          'Structured data format, ideal for developers',
          Icons.code,
        ),
        _buildFormatOption(
          ExportFormat.xml,
          'XML',
          'Enterprise-friendly structured data format',
          Icons.description,
        ),
        _buildFormatOption(
          ExportFormat.pdf,
          'PDF',
          'Human-readable report with charts and graphs',
          Icons.picture_as_pdf,
        ),
      ],
    );
  }

  Widget _buildFormatOption(
    ExportFormat format,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _selectedFormat == format;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFormat = format;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.1) : null,
          ),
          child: Row(
            children: [
              Radio<ExportFormat>(
                value: format,
                groupValue: _selectedFormat,
                onChanged: (ExportFormat? value) {
                  if (value != null) {
                    setState(() {
                      _selectedFormat = value;
                    });
                  }
                },
                activeColor: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 12),
              Icon(icon, color: AppTheme.primaryGreen),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppTheme.primaryGreen : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    final canExport = _includeWeightHistory && 
                     (!_selectAllData ? (_fromDate != null && _toDate != null) : true);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canExport ? _exportData : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Export Data',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate ?? DateTime.now() : _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          // Ensure from date is not after to date
          if (_toDate != null && _fromDate!.isAfter(_toDate!)) {
            _toDate = _fromDate;
          }
        } else {
          _toDate = picked;
          // Ensure to date is not before from date
          if (_fromDate != null && _toDate!.isBefore(_fromDate!)) {
            _fromDate = _toDate;
          }
        }
      });
    }
  }

  Future<void> _exportData() async {
    if (!_includeWeightHistory) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one data type to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final exportService = DataExportService();
      
      final success = await exportService.exportWeightHistory(
        format: _selectedFormat,
        fromDate: _selectAllData ? null : _fromDate,
        toDate: _selectAllData ? null : _toDate,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      } else if (mounted) {
        throw Exception('Export failed');
      }
    } catch (e) {
      AppLogger.error('Export failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}