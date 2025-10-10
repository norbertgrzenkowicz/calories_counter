import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../core/app_logger.dart';
import '../theme/app_theme.dart';
import '../models/meal.dart';
import '../services/supabase_service.dart';
import '../services/openfoodfacts_service.dart';
import '../utils/file_upload_validator.dart';
import '../utils/input_sanitizer.dart';
import 'barcode_scanner_screen.dart';

class AddMealScreen extends StatefulWidget {
  final Function() onMealAdded;
  final DateTime selectedDate;

  const AddMealScreen(
      {super.key, required this.onMealAdded, required this.selectedDate});

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
  bool _isAnalyzing = false;
  bool _hasAnalyzedPhoto = false;
  Map<String, dynamic>? _analysisResult;
  String? _scannedBarcode;
  bool _isScanningBarcode = false;
  ProductNutrition? _scannedProduct;
  bool _isSubmitting = false;

  // API endpoint using cloud function
  static const String _apiBaseUrl =
      'https://us-central1-white-faculty-417521.cloudfunctions.net/yapper-api';

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _fatsController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final source = await _showPhotoSourceDialog();
    if (source != null) {
      await _pickImageFromSource(source);
    }
  }

  Future<ImageSource?> _showPhotoSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Photo Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      AppLogger.debug('Photo selected for upload: ${pickedFile.path}');

      // Validate the uploaded file
      final validationResult =
          await FileUploadValidator.validateImageFile(pickedFile);

      if (validationResult != FileValidationResult.valid) {
        final errorMessage =
            FileUploadValidator.getErrorMessage(validationResult);
        AppLogger.warning('File validation failed: $errorMessage');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      AppLogger.debug('File validation successful');
      setState(() {
        _photoPath = pickedFile.path;
        _hasAnalyzedPhoto = false;
        _analysisResult = null;
      });
      await _analyzePhoto();
    }
  }

  Future<void> _analyzePhoto() async {
    if (_photoPath == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Read image file and convert to base64
      final bytes = await File(_photoPath!).readAsBytes();
      final base64Image = base64Encode(bytes);

      // Call the API
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/analyze_food'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': base64Image,
          'filename': _photoPath!.split('/').last,
        }),
      );

      if (response.statusCode == 200) {
        final analysisData = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _analysisResult = analysisData;
          _hasAnalyzedPhoto = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo analyzed! Review the suggested values.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to analyze photo: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to analyze photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _acceptAnalysis() {
    if (_analysisResult != null) {
      setState(() {
        _caloriesController.text = _analysisResult!['calories'].toString();
        _proteinsController.text = _analysisResult!['protein'].toString();
        _fatsController.text = _analysisResult!['fats'].toString();
        _carbsController.text = _analysisResult!['carbs'].toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analysis accepted! Values filled in.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _scanBarcode() async {
    setState(() {
      _isScanningBarcode = true;
    });

    try {
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Looking up product...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );

        // Look up product with cache-first strategy
        final supabaseService = SupabaseService();
        final product = await supabaseService.getProductWithCache(result);

        if (product != null && mounted) {
          setState(() {
            _scannedProduct = product;
            _nameController.text = product.displayName;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product found: ${product.name}'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          // Product not found - show placeholder
          // Sanitize the barcode result before displaying
          final sanitizedBarcode = InputSanitizer.sanitizeBarcode(result);
          final displayBarcode = sanitizedBarcode ?? 'Invalid';

          setState(() {
            _scannedProduct = null;
            _nameController.text = 'Unknown Product ($displayBarcode)';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Product not found in database. You can enter nutrition manually.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan barcode: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isScanningBarcode = false;
      });
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product nutrition accepted! Values filled in.'),
            backgroundColor: Colors.green,
          ),
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
        if (!supabaseService.isInitialized) {
          throw Exception('Supabase not initialized');
        }

        AppLogger.info('Adding meal to database');

        String? photoUrl;

        // Upload photo if one was taken
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
        // Note: Meal data not logged for privacy

        await supabaseService.addMeal(meal.toSupabase());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meal added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        widget.onMealAdded();
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add meal: $e'),
              backgroundColor: Colors.red,
            ),
          );
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
                if (_photoPath != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_photoPath!),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                OutlinedButton.icon(
                  onPressed: _isAnalyzing ? null : _addPhoto,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt),
                  label: Text(_isAnalyzing ? 'Analyzing...' : 'Add Photo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 12),
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
                if (_hasAnalyzedPhoto && _analysisResult != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Analysis Results:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Calories: ${_analysisResult!['calories']}'),
                        Text('Protein: ${_analysisResult!['protein']}g'),
                        Text('Fats: ${_analysisResult!['fats']}g'),
                        Text('Carbs: ${_analysisResult!['carbs']}g'),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _acceptAnalysis,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Accept & Fill Values'),
                          ),
                        ),
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
