import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_logger.dart';
import '../theme/app_theme.dart';
import '../models/meal.dart';
import '../providers/meals_provider.dart';
import '../services/chat_service.dart';
import '../services/supabase_service.dart';
import '../services/openfoodfacts_service.dart';
import '../utils/app_page_route.dart';
import '../utils/app_snackbar.dart';
import '../utils/file_upload_validator.dart';
import '../utils/input_sanitizer.dart';
import 'barcode_scanner_screen.dart';

class AddMealScreen extends ConsumerStatefulWidget {
  final VoidCallback onMealAdded;
  final DateTime selectedDate;
  final int? initialCalories;
  final int? initialProtein;
  final int? initialCarbs;
  final int? initialFats;

  const AddMealScreen({
    super.key,
    this.onMealAdded = _defaultCallback,
    required this.selectedDate,
    this.initialCalories,
    this.initialProtein,
    this.initialCarbs,
    this.initialFats,
  });

  static void _defaultCallback() {}

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _carbsController = TextEditingController();
  String? _photoPath;
  bool _isAnalyzing = false;
  bool _hasAnalyzedPhoto = false;
  Map<String, dynamic>? _analysisResult;
  String? _scannedBarcode;
  bool _isScanningBarcode = false;
  ProductNutrition? _scannedProduct;
  bool _isSubmitting = false;

  final _chatService = ChatService();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Pre-fill nutrition values if provided from chat
    if (widget.initialCalories != null) {
      _caloriesController.text = widget.initialCalories.toString();
    }
    if (widget.initialProtein != null) {
      _proteinsController.text = widget.initialProtein.toString();
    }
    if (widget.initialCarbs != null) {
      _carbsController.text = widget.initialCarbs.toString();
    }
    if (widget.initialFats != null) {
      _fatsController.text = widget.initialFats.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _fatsController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    setState(() {
      _isScanningBarcode = true;
    });

    try {
      final result = await Navigator.push<String>(
        context,
        AppPageRoute(
          builder: (context) => const BarcodeScannerScreen(),
        ),
      );

      if (result != null && mounted) {
        // Validate barcode format
        if (!OpenFoodFactsService.isValidBarcode(result)) {
          throw Exception('Invalid barcode format');
        }

        setState(() {
          _scannedBarcode = result;
        });

        // Show scanning feedback
        AppSnackbar.info(context, 'Looking up product...');

        // Look up product with cache-first strategy
        final supabaseService = SupabaseService();
        final product = await supabaseService.getProductWithCache(result);

        if (product != null && mounted) {
          setState(() {
            _scannedProduct = product;
            _nameController.text = product.displayName;
          });

          // Show success message
          AppSnackbar.success(context, 'Product found: ${product.name}');
        } else if (mounted) {
          // Product not found - show placeholder
          // Sanitize the barcode result before displaying
          final sanitizedBarcode = InputSanitizer.sanitizeBarcode(result);
          final displayBarcode = sanitizedBarcode ?? 'Invalid';

          setState(() {
            _scannedProduct = null;
            _nameController.text = 'Unknown Product ($displayBarcode)';
          });

          AppSnackbar.warning(context, 'Product not found in database. You can enter nutrition manually.');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Failed to scan barcode: $e');
      }
    } finally {
      setState(() {
        _isScanningBarcode = false;
      });
    }
  }

  Future<void> _addPhoto() async {
    await _showPhotoSourceDialog();
  }

  Future<void> _showPhotoSourceDialog() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Add Photo', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.neonGreen),
              title: const Text('Camera', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.neonGreen),
              title: const Text('Gallery', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      await _pickImageFromSource(source);
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final xFile = await _imagePicker.pickImage(source: source, imageQuality: 85);
      if (xFile == null) return;

      final validationResult = await FileUploadValidator.validateImageFile(xFile);
      if (validationResult != FileValidationResult.valid) {
        if (mounted) {
          AppSnackbar.error(context, FileUploadValidator.getErrorMessage(validationResult));
        }
        return;
      }

      setState(() {
        _photoPath = xFile.path;
        _hasAnalyzedPhoto = false;
        _analysisResult = null;
      });
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Failed to pick image: $e');
      }
    }
  }

  Future<void> _analyzePhoto() async {
    if (_photoPath == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await _chatService.analyzeFoodFromImage(File(_photoPath!));
      setState(() {
        _analysisResult = result;
        _hasAnalyzedPhoto = true;
      });
    } catch (e) {
      AppLogger.error('Photo analysis failed', e);
      if (mounted) {
        AppSnackbar.error(context, 'Analysis failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _acceptAnalysis() {
    if (_analysisResult == null) return;

    setState(() {
      _nameController.text = _analysisResult!['meal_name'] as String? ?? '';
      _caloriesController.text = (_analysisResult!['calories'] as int).toString();
      _proteinsController.text = (_analysisResult!['protein'] as int).toString();
      _fatsController.text = (_analysisResult!['fats'] as int).toString();
      _carbsController.text = (_analysisResult!['carbs'] as int).toString();
    });

    AppSnackbar.success(context, 'Nutrition values filled from photo analysis!');
  }

  void _acceptBarcodeNutrition() {
    if (_scannedProduct != null && _scannedProduct!.hasBasicNutrition) {
      // Calculate nutrition for 100g serving
      final nutrition = _scannedProduct!.calculateNutritionForPortion(100.0);

      setState(() {
        _caloriesController.text = nutrition['calories'].toString();
        _proteinsController.text = nutrition['protein'].toString();
        _fatsController.text = nutrition['fats'].toString();
        _carbsController.text = nutrition['carbs'].toString();
      });

      if (mounted) {
        AppSnackbar.success(context, 'Product nutrition accepted! Values filled in.');
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && !_isSubmitting) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final supabaseService = SupabaseService();

        AppLogger.info('Adding meal to database');

        String? photoUrl;

        // Upload photo if one was taken (keep using SupabaseService directly for storage)
        if (_photoPath != null) {
          final fileName = 'meal_${DateTime.now().millisecondsSinceEpoch}.jpg';
          photoUrl =
              await supabaseService.uploadMealPhoto(_photoPath!, fileName);
          AppLogger.debug('Photo uploaded successfully');
        }

        // Sanitize input data
        final sanitizedName =
            InputSanitizer.sanitizeMealName(_nameController.text);
        final sanitizedCalories =
            InputSanitizer.sanitizeCalories(_caloriesController.text) ?? 0;
        final sanitizedProteins =
            InputSanitizer.sanitizeMacroNutrient(_proteinsController.text) ??
                0.0;
        final sanitizedFats =
            InputSanitizer.sanitizeMacroNutrient(_fatsController.text) ?? 0.0;
        final sanitizedCarbs =
            InputSanitizer.sanitizeMacroNutrient(_carbsController.text) ?? 0.0;
        final sanitizedPhotoUrl = InputSanitizer.sanitizePhotoUrl(photoUrl);

        // Validate sanitized data
        if (sanitizedName.isEmpty) {
          throw Exception('Meal name is required');
        }
        if (sanitizedCalories <= 0) {
          throw Exception('Calories must be greater than 0');
        }

        final meal = Meal(
          name: sanitizedName,
          calories: sanitizedCalories,
          proteins: sanitizedProteins,
          fats: sanitizedFats,
          carbs: sanitizedCarbs,
          photoUrl: sanitizedPhotoUrl,
          date: widget.selectedDate,
        );

        AppLogger.debug('Meal object created with photo');

        await ref
            .read(mealsNotifierProvider(widget.selectedDate).notifier)
            .addMeal(meal);

        if (mounted) {
          AppSnackbar.success(context, 'Meal added successfully!');
        }

        widget.onMealAdded();
        if (mounted) {
          Navigator.of(context).pop();
          // Refresh the list after we've closed this screen
          ref.invalidate(mealsNotifierProvider(widget.selectedDate));
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.error(context, 'Failed to add meal: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(
            'Add Meal - ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                    final parsed = int.tryParse(value);
                    if (parsed == null) {
                      return 'Please enter a valid number';
                    }
                    if (parsed <= 0) {
                      return 'Calories must be greater than 0';
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
                    final parsed = double.tryParse(value);
                    if (parsed == null) {
                      return 'Please enter a valid number';
                    }
                    if (parsed < 0) {
                      return 'Proteins cannot be negative';
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
                    final parsed = double.tryParse(value);
                    if (parsed == null) {
                      return 'Please enter a valid number';
                    }
                    if (parsed < 0) {
                      return 'Fats cannot be negative';
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
                    final parsed = double.tryParse(value);
                    if (parsed == null) {
                      return 'Please enter a valid number';
                    }
                    if (parsed < 0) {
                      return 'Carbs cannot be negative';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Photo preview
                if (_photoPath != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_photoPath!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                // Add Photo button
                OutlinedButton.icon(
                  onPressed: _isAnalyzing ? null : _addPhoto,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt),
                  label: Text(_isAnalyzing ? 'Analyzing...' : (_photoPath != null ? 'Change Photo' : 'Add Photo')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                if (_photoPath != null && !_hasAnalyzedPhoto) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _isAnalyzing ? null : _analyzePhoto,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Analyze with AI'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      foregroundColor: AppTheme.neonGreen,
                      side: const BorderSide(color: AppTheme.neonGreen),
                    ),
                  ),
                ],
                // AI analysis results
                if (_hasAnalyzedPhoto && _analysisResult != null) ...[
                  const SizedBox(height: 16),
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
                            const Icon(Icons.auto_awesome, color: AppTheme.neonGreen, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'AI Analysis: ${_analysisResult!['meal_name']}',
                              style: const TextStyle(
                                color: AppTheme.neonGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_analysisResult!['calories']} kcal  '
                          'P: ${_analysisResult!['protein']}g  '
                          'C: ${_analysisResult!['carbs']}g  '
                          'F: ${_analysisResult!['fats']}g',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _acceptAnalysis,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.neonGreen,
                              foregroundColor: AppTheme.darkBackground,
                            ),
                            child: const Text('Accept & Fill Values'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isScanningBarcode ? null : _scanBarcode,
                  icon: _isScanningBarcode
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.qr_code_scanner),
                  label:
                      Text(_isScanningBarcode ? 'Scanning...' : 'Scan Barcode'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                if (_scannedBarcode != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _scannedProduct != null
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _scannedProduct != null
                              ? Colors.green.shade200
                              : Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.qr_code,
                                color: _scannedProduct != null
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _scannedProduct != null
                                    ? 'Product Found:'
                                    : 'Barcode Scanned:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _scannedProduct != null
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _scannedProduct != null
                              ? _scannedProduct!.displayName
                              : 'Barcode: $_scannedBarcode',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        if (_scannedProduct != null &&
                            _scannedProduct!.hasBasicNutrition) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Nutrition per 100g:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (_scannedProduct!.caloriesPer100g != null)
                                Text(
                                    '${_scannedProduct!.caloriesPer100g!.round()} kcal  ',
                                    style: const TextStyle(fontSize: 12)),
                              if (_scannedProduct!.proteinPer100g != null)
                                Text(
                                    'P: ${_scannedProduct!.proteinPer100g!.toStringAsFixed(1)}g  ',
                                    style: const TextStyle(fontSize: 12)),
                              if (_scannedProduct!.carbsPer100g != null)
                                Text(
                                    'C: ${_scannedProduct!.carbsPer100g!.toStringAsFixed(1)}g  ',
                                    style: const TextStyle(fontSize: 12)),
                              if (_scannedProduct!.fatPer100g != null)
                                Text(
                                    'F: ${_scannedProduct!.fatPer100g!.toStringAsFixed(1)}g',
                                    style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _acceptBarcodeNutrition,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child:
                                  const Text('Accept & Fill Nutrition Values'),
                            ),
                          ),
                        ] else if (_scannedProduct == null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Product not found in OpenFoodFacts database.\nYou can enter nutrition information manually.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isSubmitting ? Colors.grey : AppTheme.neonGreen,
                    foregroundColor: AppTheme.darkBackground,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Adding...'),
                          ],
                        )
                      : const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
