import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_logger.dart';
import '../models/food_analysis_result.dart';
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
  final _clarificationController = TextEditingController();
  String? _photoPath;
  bool _isAnalyzing = false;
  bool _hasAnalyzedPhoto = false;
  FoodAnalysisResult? _analysisResult;
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
    _clarificationController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    setState(() {
      _isScanningBarcode = true;
    });

    try {
      final result = await Navigator.push<String>(
        context,
        AppPageRoute(builder: (context) => const BarcodeScannerScreen()),
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

          AppSnackbar.warning(
            context,
            'Product not found in database. You can enter nutrition manually.',
          );
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
        title: const Text(
          'Add Photo',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.neonGreen),
              title: const Text(
                'Camera',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppTheme.neonGreen,
              ),
              title: const Text(
                'Gallery',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
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
      final xFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (xFile == null) return;

      final validationResult = await FileUploadValidator.validateImageFile(
        xFile,
      );
      if (validationResult != FileValidationResult.valid) {
        if (mounted) {
          AppSnackbar.error(
            context,
            FileUploadValidator.getErrorMessage(validationResult),
          );
        }
        return;
      }

      setState(() {
        _photoPath = xFile.path;
        _hasAnalyzedPhoto = false;
        _analysisResult = null;
        _clarificationController.clear();
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
      final result = await _chatService.analyzeFoodFromImage(
        imageFile: File(_photoPath!),
      );
      setState(() {
        _analysisResult = result;
        _hasAnalyzedPhoto = true;
        if (result.isComplete) {
          _clarificationController.clear();
        }
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
      _nameController.text = _analysisResult!.mealName;
      _caloriesController.text = _analysisResult!.calories.toString();
      _proteinsController.text = _analysisResult!.protein.toString();
      _fatsController.text = _analysisResult!.fats.toString();
      _carbsController.text = _analysisResult!.carbs.toString();
    });

    AppSnackbar.success(
      context,
      'Nutrition values filled from photo analysis!',
    );
  }

  Future<void> _refineAnalysis() async {
    if (_photoPath == null || _analysisResult == null) return;

    final clarificationText = _clarificationController.text.trim();
    if (clarificationText.isEmpty) {
      AppSnackbar.warning(context, 'Answer the clarification question first');
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await _chatService.analyzeFoodFromImage(
        imageFile: File(_photoPath!),
        contextText: clarificationText,
      );

      setState(() {
        _analysisResult = result;
        _hasAnalyzedPhoto = true;
        _clarificationController.clear();
      });
    } catch (e) {
      AppLogger.error('Photo refinement failed', e);
      if (mounted) {
        AppSnackbar.error(context, 'Refinement failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
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
        AppSnackbar.success(
          context,
          'Product nutrition accepted! Values filled in.',
        );
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
          photoUrl = await supabaseService.uploadMealPhoto(
            _photoPath!,
            fileName,
          );
          AppLogger.debug('Photo uploaded successfully');
        }

        // Sanitize input data
        final sanitizedName = InputSanitizer.sanitizeMealName(
          _nameController.text,
        );
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
        if (sanitizedCalories < 0) {
          throw Exception('Calories cannot be negative');
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

  Widget _buildAnalysisCard() {
    final analysis = _analysisResult!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: analysis.needsClarification
              ? AppTheme.neonYellow.withOpacity(0.45)
              : AppTheme.neonGreen.withOpacity(0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppTheme.neonGreen,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  analysis.mealName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              _buildConfidenceChip(analysis),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${analysis.calories} kcal  '
            'P: ${analysis.protein}g  '
            'C: ${analysis.carbs}g  '
            'F: ${analysis.fats}g',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            analysis.needsClarification
                ? 'Provisional estimate'
                : 'Ready to use',
            style: TextStyle(
              color: analysis.needsClarification
                  ? AppTheme.neonYellow
                  : AppTheme.neonGreen,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          if (analysis.assumptions.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildStringSection('Assumptions', analysis.assumptions),
          ],
          if (analysis.flags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: analysis.flags
                  .map(
                    (flag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.borderColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        flag.replaceAll('_', ' '),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (analysis.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Item breakdown',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ...analysis.items.map(_buildAnalysisItemTile),
          ],
          if (analysis.needsClarification &&
              analysis.clarifyingQuestion != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neonYellow.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.neonYellow.withOpacity(0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clarification',
                    style: TextStyle(
                      color: AppTheme.neonYellow,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    analysis.clarifyingQuestion!,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _clarificationController,
                    enabled: !_isAnalyzing,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Add the missing detail',
                      hintStyle: const TextStyle(color: AppTheme.textTertiary),
                      filled: true,
                      fillColor: AppTheme.darkBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.borderColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.neonYellow,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isAnalyzing ? null : _refineAnalysis,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.neonYellow,
                            foregroundColor: AppTheme.darkBackground,
                          ),
                          child: const Text('Refine estimate'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isAnalyzing ? null : _acceptAnalysis,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textPrimary,
                            side: BorderSide(
                              color: AppTheme.textSecondary.withOpacity(0.35),
                            ),
                          ),
                          child: const Text('Use current estimate'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _acceptAnalysis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen,
                  foregroundColor: AppTheme.darkBackground,
                ),
                child: const Text('Accept analysis'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceChip(FoodAnalysisResult analysis) {
    final color = switch (analysis.confidenceLabel) {
      'high' => AppTheme.neonGreen,
      'medium' => AppTheme.neonYellow,
      _ => AppTheme.neonRed,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.32)),
      ),
      child: Text(
        '${analysis.confidenceLabel} ${(analysis.confidence * 100).round()}%',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStringSection(String title, List<String> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        ...values.map(
          (value) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $value',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisItemTile(FoodAnalysisItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          if (item.portionText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.portionText,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            '${item.calories} kcal  '
            'P: ${item.protein}g  '
            'C: ${item.carbs}g  '
            'F: ${item.fats}g',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(
          '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 0.08,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // --- Meal name: prominent, silent style ---
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.44,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Meal name',
                    hintStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textTertiary,
                      letterSpacing: -0.44,
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.borderColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.borderColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.neonGreen,
                        width: 1.5,
                      ),
                    ),
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a meal name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // --- Action chips row: photo / barcode / AI ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ActionChip(
                        icon: _isAnalyzing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.textPrimary,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: AppTheme.textPrimary,
                              ),
                        label: _isAnalyzing
                            ? 'Analyzing...'
                            : (_photoPath != null ? 'Change Photo' : 'Add Photo'),
                        onTap: _isAnalyzing ? null : _addPhoto,
                      ),
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: _isScanningBarcode
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.textPrimary,
                                ),
                              )
                            : const Icon(
                                Icons.qr_code_scanner,
                                size: 14,
                                color: AppTheme.textPrimary,
                              ),
                        label: _isScanningBarcode ? 'Scanning...' : 'Scan Barcode',
                        onTap: _isScanningBarcode ? null : _scanBarcode,
                      ),
                      if (_photoPath != null && !_hasAnalyzedPhoto) ...[
                        const SizedBox(width: 8),
                        _ActionChip(
                          icon: const Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: AppTheme.neonGreen,
                          ),
                          label: 'Analyze with AI',
                          onTap: _isAnalyzing ? null : _analyzePhoto,
                          accentColor: AppTheme.neonGreen,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- Photo preview ---
                if (_photoPath != null) ...[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.neonGreen.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.file(
                        File(_photoPath!),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // --- AI analysis results ---
                if (_hasAnalyzedPhoto && _analysisResult != null) ...[
                  _buildAnalysisCard(),
                  const SizedBox(height: 20),
                ],

                // --- Barcode result card ---
                if (_scannedBarcode != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code,
                              color: _scannedProduct != null
                                  ? AppTheme.neonGreen
                                  : AppTheme.neonOrange,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _scannedProduct != null
                                    ? 'Product Found'
                                    : 'Barcode Scanned',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _scannedProduct != null
                              ? _scannedProduct!.displayName
                              : 'Barcode: $_scannedBarcode',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (_scannedProduct != null &&
                            _scannedProduct!.hasBasicNutrition) ...[
                          const SizedBox(height: 10),
                          Text(
                            'PER 100G',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textTertiary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            [
                              if (_scannedProduct!.caloriesPer100g != null)
                                '${_scannedProduct!.caloriesPer100g!.round()} kcal',
                              if (_scannedProduct!.proteinPer100g != null)
                                'P ${_scannedProduct!.proteinPer100g!.toStringAsFixed(1)}g',
                              if (_scannedProduct!.carbsPer100g != null)
                                'C ${_scannedProduct!.carbsPer100g!.toStringAsFixed(1)}g',
                              if (_scannedProduct!.fatPer100g != null)
                                'F ${_scannedProduct!.fatPer100g!.toStringAsFixed(1)}g',
                            ].join('  ·  '),
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: AppTheme.neonGlowShadow(),
                              ),
                              child: ElevatedButton(
                                onPressed: _acceptBarcodeNutrition,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.neonGreen,
                                  foregroundColor: const Color(0xFF003919),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Accept & Fill Nutrition Values',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ] else if (_scannedProduct == null) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Product not found in OpenFoodFacts database.\nEnter nutrition manually below.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // --- Nutrition fields grouped in a surface card ---
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NUTRITION',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textTertiary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Calories - full width
                      TextFormField(
                        controller: _caloriesController,
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Calories (kcal)',
                          labelStyle: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.borderColor.withOpacity(0.15),
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.borderColor.withOpacity(0.15),
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.neonGreen,
                              width: 1.5,
                            ),
                          ),
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                          if (parsed < 0) {
                            return 'Calories cannot be negative';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Protein + Carbs row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _proteinsController,
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Protein (g)',
                                labelStyle: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.borderColor.withOpacity(0.15),
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.borderColor.withOpacity(0.15),
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.neonGreen,
                                    width: 1.5,
                                  ),
                                ),
                                filled: false,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final parsed = double.tryParse(value);
                                if (parsed == null) return 'Invalid';
                                if (parsed < 0) return 'Cannot be negative';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: TextFormField(
                              controller: _carbsController,
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Carbs (g)',
                                labelStyle: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.borderColor.withOpacity(0.15),
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.borderColor.withOpacity(0.15),
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.neonGreen,
                                    width: 1.5,
                                  ),
                                ),
                                filled: false,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final parsed = double.tryParse(value);
                                if (parsed == null) return 'Invalid';
                                if (parsed < 0) return 'Cannot be negative';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Fats - single row (could expand later)
                      TextFormField(
                        controller: _fatsController,
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Fats (g)',
                          labelStyle: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.borderColor.withOpacity(0.15),
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.borderColor.withOpacity(0.15),
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.neonGreen,
                              width: 1.5,
                            ),
                          ),
                          filled: false,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
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
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // --- Submit button: neon green with glow ---
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _isSubmitting ? [] : AppTheme.neonGlowShadow(),
                  ),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isSubmitting ? AppTheme.surfaceContainerHigh : AppTheme.neonGreen,
                      foregroundColor: _isSubmitting
                          ? AppTheme.textSecondary
                          : const Color(0xFF003919),
                      padding: const EdgeInsets.all(18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.2,
                      ),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Adding...'),
                            ],
                          )
                        : const Text('Add Meal'),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact icon+label chip for the action row in AddMealScreen.
class _ActionChip extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onTap;
  final Color? accentColor;

  const _ActionChip({
    required this.icon,
    required this.label,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppTheme.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
