import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../core/app_logger.dart';
import '../models/weight_history.dart';
import '../screens/export_data_screen.dart';
import '../services/profile_service.dart';

class DataExportService {
  final ProfileService _profileService = ProfileService();

  Future<bool> exportWeightHistory({
    required ExportFormat format,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      // Check and request permissions
      if (!await _requestStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      // Fetch weight history data
      final weightHistory = await _profileService.getWeightHistory(
        startDate: fromDate,
        endDate: toDate,
      );

      if (weightHistory.isEmpty) {
        throw Exception('No weight history data found for the selected period');
      }

      AppLogger.info('Fetched ${weightHistory.length} weight entries for export');

      // Generate file based on format
      File? exportFile;
      switch (format) {
        case ExportFormat.csv:
          exportFile = await _generateCsvFile(weightHistory, fromDate, toDate);
        case ExportFormat.json:
          exportFile = await _generateJsonFile(weightHistory, fromDate, toDate);
        case ExportFormat.xml:
          exportFile = await _generateXmlFile(weightHistory, fromDate, toDate);
        case ExportFormat.pdf:
          exportFile = await _generatePdfFile(weightHistory, fromDate, toDate);
      }

      if (exportFile != null) {
        // Share the file with the user
        await Share.shareXFiles([XFile(exportFile.path)]);
        
        AppLogger.info('Export completed successfully: ${exportFile.path}');
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.error('Export failed', e);
      rethrow;
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final permission = await Permission.storage.status;
      if (permission != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        return result == PermissionStatus.granted;
      }
      return true;
    }
    // iOS doesn't require explicit storage permission for app documents
    return true;
  }

  Future<File> _generateCsvFile(
    List<WeightHistory> data,
    DateTime? fromDate,
    DateTime? toDate,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _generateFileName('csv', fromDate, toDate);
    final file = File('${directory.path}/$fileName');

    final csvContent = StringBuffer();
    
    // CSV Header
    csvContent.writeln(
      'Date,Weight (kg),Measurement Time,Notes,Goal,Days Since Goal Start,Weight Change (kg),Weekly Average (kg),Monthly Average (kg),Phase'
    );

    // CSV Data
    for (final entry in data) {
      csvContent.writeln([
        entry.recordedDate.toIso8601String().split('T')[0],
        entry.weightKg.toStringAsFixed(2),
        entry.measurementTime,
        '"${entry.notes?.replaceAll('"', '""') ?? ''}"',
        entry.goalDisplayName,
        entry.daysSinceGoalStart,
        entry.weightChangeKg?.toStringAsFixed(2) ?? '',
        entry.weeklyAverageKg?.toStringAsFixed(2) ?? '',
        entry.monthlyAverageKg?.toStringAsFixed(2) ?? '',
        entry.phaseDisplayName,
      ].join(','));
    }

    await file.writeAsString(csvContent.toString());
    return file;
  }

  Future<File> _generateJsonFile(
    List<WeightHistory> data,
    DateTime? fromDate,
    DateTime? toDate,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _generateFileName('json', fromDate, toDate);
    final file = File('${directory.path}/$fileName');

    final exportData = {
      'export_info': {
        'app': 'Japer',
        'data_type': 'weight_history',
        'export_date': DateTime.now().toIso8601String(),
        'date_range': {
          'from': fromDate?.toIso8601String().split('T')[0],
          'to': toDate?.toIso8601String().split('T')[0],
        },
        'total_entries': data.length,
      },
      'weight_history': data.map((entry) => {
        'id': entry.id,
        'date': entry.recordedDate.toIso8601String().split('T')[0],
        'weight_kg': entry.weightKg,
        'measurement_time': entry.measurementTime,
        'notes': entry.notes,
        'goal_at_time': entry.goalAtTime,
        'goal_display_name': entry.goalDisplayName,
        'days_since_goal_start': entry.daysSinceGoalStart,
        'weight_change_kg': entry.weightChangeKg,
        'weekly_average_kg': entry.weeklyAverageKg,
        'monthly_average_kg': entry.monthlyAverageKg,
        'phase': entry.phase,
        'phase_display_name': entry.phaseDisplayName,
        'is_initial_phase': entry.isInitialPhase,
        'created_at': entry.createdAt?.toIso8601String(),
        'updated_at': entry.updatedAt?.toIso8601String(),
      }).toList(),
    };

    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(exportData));
    return file;
  }

  Future<File> _generateXmlFile(
    List<WeightHistory> data,
    DateTime? fromDate,
    DateTime? toDate,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _generateFileName('xml', fromDate, toDate);
    final file = File('${directory.path}/$fileName');

    final xmlContent = StringBuffer();
    xmlContent.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    xmlContent.writeln('<weight_history_export>');
    xmlContent.writeln('  <export_info>');
    xmlContent.writeln('    <app>Japer</app>');
    xmlContent.writeln('    <data_type>weight_history</data_type>');
    xmlContent.writeln('    <export_date>${DateTime.now().toIso8601String()}</export_date>');
    xmlContent.writeln('    <date_range>');
    xmlContent.writeln('      <from>${fromDate?.toIso8601String().split('T')[0] ?? ''}</from>');
    xmlContent.writeln('      <to>${toDate?.toIso8601String().split('T')[0] ?? ''}</to>');
    xmlContent.writeln('    </date_range>');
    xmlContent.writeln('    <total_entries>${data.length}</total_entries>');
    xmlContent.writeln('  </export_info>');
    xmlContent.writeln('  <entries>');

    for (final entry in data) {
      xmlContent.writeln('    <entry>');
      xmlContent.writeln('      <id>${entry.id ?? ''}</id>');
      xmlContent.writeln('      <date>${entry.recordedDate.toIso8601String().split('T')[0]}</date>');
      xmlContent.writeln('      <weight_kg>${entry.weightKg}</weight_kg>');
      xmlContent.writeln('      <measurement_time>${entry.measurementTime}</measurement_time>');
      xmlContent.writeln('      <notes><![CDATA[${entry.notes ?? ''}]]></notes>');
      xmlContent.writeln('      <goal_at_time>${entry.goalAtTime ?? ''}</goal_at_time>');
      xmlContent.writeln('      <goal_display_name>${entry.goalDisplayName}</goal_display_name>');
      xmlContent.writeln('      <days_since_goal_start>${entry.daysSinceGoalStart}</days_since_goal_start>');
      xmlContent.writeln('      <weight_change_kg>${entry.weightChangeKg ?? ''}</weight_change_kg>');
      xmlContent.writeln('      <weekly_average_kg>${entry.weeklyAverageKg ?? ''}</weekly_average_kg>');
      xmlContent.writeln('      <monthly_average_kg>${entry.monthlyAverageKg ?? ''}</monthly_average_kg>');
      xmlContent.writeln('      <phase>${entry.phase}</phase>');
      xmlContent.writeln('      <phase_display_name>${entry.phaseDisplayName}</phase_display_name>');
      xmlContent.writeln('      <is_initial_phase>${entry.isInitialPhase}</is_initial_phase>');
      xmlContent.writeln('      <created_at>${entry.createdAt?.toIso8601String() ?? ''}</created_at>');
      xmlContent.writeln('      <updated_at>${entry.updatedAt?.toIso8601String() ?? ''}</updated_at>');
      xmlContent.writeln('    </entry>');
    }

    xmlContent.writeln('  </entries>');
    xmlContent.writeln('</weight_history_export>');

    await file.writeAsString(xmlContent.toString());
    return file;
  }

  Future<File> _generatePdfFile(
    List<WeightHistory> data,
    DateTime? fromDate,
    DateTime? toDate,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _generateFileName('pdf', fromDate, toDate);
    final file = File('${directory.path}/$fileName');

    final pdf = pw.Document();

    // Calculate statistics
    final totalEntries = data.length;
    final startWeight = data.isNotEmpty ? data.last.weightKg : 0.0;
    final currentWeight = data.isNotEmpty ? data.first.weightKg : 0.0;
    final totalWeightChange = currentWeight - startWeight;
    final averageWeight = data.isNotEmpty 
        ? data.map((e) => e.weightKg).reduce((a, b) => a + b) / data.length
        : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'Japer Weight History Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Export Info
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Export Information',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('Export Date: ${DateTime.now().toIso8601String().split('T')[0]}'),
                  pw.Text('Date Range: ${fromDate?.toIso8601String().split('T')[0] ?? 'All data'} to ${toDate?.toIso8601String().split('T')[0] ?? 'Present'}'),
                  pw.Text('Total Entries: $totalEntries'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Statistics Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Weight Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text('Starting Weight: ${startWeight.toStringAsFixed(2)} kg'),
                  pw.Text('Current Weight: ${currentWeight.toStringAsFixed(2)} kg'),
                  pw.Text('Total Weight Change: ${totalWeightChange >= 0 ? '+' : ''}${totalWeightChange.toStringAsFixed(2)} kg'),
                  pw.Text('Average Weight: ${averageWeight.toStringAsFixed(2)} kg'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Weight History Table
            pw.Text(
              'Weight History Details',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),

            pw.Table.fromTextArray(
              headers: ['Date', 'Weight (kg)', 'Change', 'Time', 'Notes'],
              data: data.map((entry) => [
                entry.recordedDate.toIso8601String().split('T')[0],
                entry.weightKg.toStringAsFixed(2),
                entry.weightChangeDescription,
                entry.measurementTimeDisplayName,
                entry.notes?.substring(0, entry.notes!.length > 30 ? 30 : entry.notes!.length) ?? '',
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.centerLeft,
              },
            ),
          ];
        },
      ),
    );

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  String _generateFileName(String format, DateTime? fromDate, DateTime? toDate) {
    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    final rangeStr = fromDate != null && toDate != null
        ? '_${fromDate.toIso8601String().split('T')[0]}_to_${toDate.toIso8601String().split('T')[0]}'
        : '_all_data';
    
    return 'japer_weight_history$rangeStr$dateStr.$format';
  }
}