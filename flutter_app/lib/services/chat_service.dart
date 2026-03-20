import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/app_logger.dart';
import '../models/food_analysis_result.dart';
import 'supabase_service.dart';

class ChatService {
  static const String _apiBaseUrl =
      'https://yapper-backend-789863392317.us-central1.run.app';

  final SupabaseService _supabaseService = SupabaseService();

  /// Get headers with authentication
  Map<String, String> _getHeaders() {
    final userId = _supabaseService.getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return {
      'Content-Type': 'application/json',
      'X-User-ID': userId,
    };
  }

  /// Analyze food from text description.
  /// Returns a legacy-compatible map: {meal_name, calories, protein, carbs, fats}
  Future<Map<String, dynamic>> analyzeFoodFromText(String text) async {
    try {
      AppLogger.debug('Analyzing food from text: $text');

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/analyze_food/text'),
        headers: _getHeaders(),
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        AppLogger.debug('Text analysis successful: $data');

        return {
          'meal_name': data['meal_name'] as String? ?? 'My Meal',
          'calories': data['calories'] as int,
          'protein': data['protein'] as int,
          'carbs': data['carbs'] as int,
          'fats': data['fats'] as int,
        };
      } else {
        throw Exception(
            'Failed to analyze text: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      AppLogger.error('Text analysis error', e);
      rethrow;
    }
  }

  /// Analyze food from image file.
  ///
  /// Accepts optional [contextText] (user clarification for refinement).
  /// Accepts optional [imageUrl] to send a stored URL instead of re-uploading.
  /// Returns a [FoodAnalysisResult] with the full v2 response.
  Future<FoodAnalysisResult> analyzeFoodFromImage(
    File imageFile, {
    String? contextText,
    String? imageUrl,
  }) async {
    try {
      AppLogger.debug('Analyzing food from image: ${imageFile.path}');

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final body = <String, dynamic>{'image': base64Image};
      if (contextText != null && contextText.trim().isNotEmpty) {
        body['context_text'] = contextText.trim();
      }

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/analyze_food/image'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        AppLogger.debug('Image analysis successful: $data');
        return FoodAnalysisResult.fromJson(data);
      } else {
        throw Exception(
            'Failed to analyze image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      AppLogger.error('Image analysis error', e);
      rethrow;
    }
  }

  /// Refine a previous image analysis using a stored image URL + user context.
  ///
  /// Used when the original local file is no longer available (e.g. after app reload).
  Future<FoodAnalysisResult> refineFoodFromImageUrl(
    String imageUrl,
    String contextText,
  ) async {
    try {
      AppLogger.debug('Refining food analysis via URL: $imageUrl');

      final body = <String, dynamic>{
        'image_url': imageUrl,
        'context_text': contextText.trim(),
      };

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/analyze_food/image'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        AppLogger.debug('Image refinement via URL successful: $data');
        return FoodAnalysisResult.fromJson(data);
      } else {
        throw Exception(
            'Failed to refine image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      AppLogger.error('Image refinement error', e);
      rethrow;
    }
  }

  /// Analyze food from audio file.
  /// Returns a legacy-compatible map: {meal_name, calories, protein, carbs, fats}
  Future<Map<String, dynamic>> analyzeFoodFromAudio(
      File audioFile, String format) async {
    try {
      AppLogger.debug(
          'Analyzing food from audio: ${audioFile.path} (format: $format)');

      final bytes = await audioFile.readAsBytes();
      final base64Audio = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/analyze_food/audio'),
        headers: _getHeaders(),
        body: jsonEncode({
          'audio': base64Audio,
          'format': format,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        AppLogger.debug('Audio analysis successful: $data');

        return {
          'meal_name': data['meal_name'] as String? ?? 'My Meal',
          'calories': data['calories'] as int,
          'protein': data['protein'] as int,
          'carbs': data['carbs'] as int,
          'fats': data['fats'] as int,
        };
      } else {
        throw Exception(
            'Failed to analyze audio: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      AppLogger.error('Audio analysis error', e);
      rethrow;
    }
  }
}
