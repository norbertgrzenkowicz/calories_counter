import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/recipe_import_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_snackbar.dart';
import '../utils/app_page_route.dart';

/// Allows the user to paste or scan a recipe URL and returns extracted
/// [RecipeNutrition] to the caller via [Navigator.pop].
class RecipeImportScreen extends StatefulWidget {
  const RecipeImportScreen({super.key});

  @override
  State<RecipeImportScreen> createState() => _RecipeImportScreenState();
}

class _RecipeImportScreenState extends State<RecipeImportScreen> {
  final _urlController = TextEditingController();
  final _service = RecipeImportService();

  bool _isLoading = false;
  RecipeNutrition? _result;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _scanQR() async {
    final url = await Navigator.push<String>(
      context,
      AppPageRoute(builder: (context) => const _QRScannerScreen()),
    );
    if (url != null && mounted) {
      _urlController.text = url;
      // Auto-fetch if the scanned value looks like a URL
      if (url.startsWith('http')) {
        await _fetchRecipe();
      }
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isNotEmpty) {
      _urlController.text = text;
    }
  }

  Future<void> _fetchRecipe() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      AppSnackbar.warning(context, 'Enter a recipe URL first');
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final nutrition = await _service.importFromUrl(url);
      if (mounted) {
        setState(() => _result = nutrition);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _acceptResult() {
    if (_result != null) Navigator.pop(context, _result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Import Recipe URL'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // URL input row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Recipe URL',
                      hintText: 'https://...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    onSubmitted: (_) => _fetchRecipe(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  icon: const Icon(Icons.content_paste),
                  tooltip: 'Paste from clipboard',
                  onPressed: _pasteFromClipboard,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _scanQR,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan QR Code'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _fetchRecipe,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: Text(_isLoading ? 'Fetching...' : 'Fetch Recipe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonGreen,
                      foregroundColor: AppTheme.darkBackground,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Help text
            if (_result == null && !_isLoading) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to import a recipe',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Copy the URL of any recipe page\n'
                      '2. Paste it above or scan its QR code\n'
                      '3. Tap "Fetch Recipe" to extract nutrition\n\n'
                      'Works best on sites like AllRecipes, BBC Food,\n'
                      'Epicurious, and most major recipe websites.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Result card
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.neonGreen.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.neonGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _result!.name,
                            style: const TextStyle(
                              color: AppTheme.neonGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _NutritionRow(
                      calories: _result!.calories,
                      protein: _result!.protein,
                      carbs: _result!.carbs,
                      fat: _result!.fat,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _acceptResult,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonGreen,
                          foregroundColor: AppTheme.darkBackground,
                          padding: const EdgeInsets.all(14),
                        ),
                        child: const Text(
                          'Use This Recipe',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  const _NutritionRow({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Macro(label: 'Calories', value: '$calories kcal', highlight: true),
        _Macro(label: 'Protein', value: '${protein.toStringAsFixed(1)}g'),
        _Macro(label: 'Carbs', value: '${carbs.toStringAsFixed(1)}g'),
        _Macro(label: 'Fat', value: '${fat.toStringAsFixed(1)}g'),
      ],
    );
  }
}

class _Macro extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _Macro({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: highlight ? AppTheme.neonGreen : AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}

/// Minimal QR-code scanner screen — returns the raw URL string.
class _QRScannerScreen extends StatefulWidget {
  const _QRScannerScreen();

  @override
  State<_QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<_QRScannerScreen> {
  late final MobileScannerController _controller;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
      detectionTimeoutMs: 300,
      returnImage: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value != null) {
      _done = true;
      Navigator.pop(context, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Recipe QR Code'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.neonGreen, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 32,
            right: 32,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Point camera at the QR code on the recipe page',
                style: TextStyle(color: Colors.white, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
