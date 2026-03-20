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

  Map<String, String> _getHeaders() {
    final userId = _supabaseService.getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return {'Content-Type': 'application/json', 'X-User-ID': userId};
  }

  Future<Map<String, dynamic>> analyzeFoodFromText(String text) async {
    try {
      AppLogger.debug('Analyzing food from text: $text');

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/analyze_food/text'),
        headers: _getHeaders(),
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to analyze text: ${response.statusCode} - ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final analysis = FoodAnalysisResult.fromJson(data);
      AppLogger.debug('Text analysis successful: $data');

      return {
        'meal_name': analysis.mealName,
        'calories': analysis.calories,
        'protein': analysis.protein,
        'carbs': analysis.carbs,
        'fats': analysis.fats,
      };
    } catch (e) {
      AppLogger.error('Text analysis error', e);
      rethrow;
    }
  }

  Future<FoodAnalysisResult> analyzeFoodFromImage({
    File? imageFile,
    String? contextText,
    String? imageUrl,
  }) async {
    try {
      if (imageFile == null && (imageUrl == null || imageUrl.trim().isEmpty)) {
        throw Exception('Either imageFile or imageUrl must be provided');
      }

      AppLogger.debug(
        'Analyzing food from image: ${imageFile?.path ?? imageUrl}',
      );

      final body = <String, dynamic>{};
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        body['image'] = base64Encode(bytes);
      }
      if (imageUrl != null && imageUrl.trim().isNotEmpty) {
        body['image_url'] = imageUrl.trim();
      }
      if (contextText != null && contextText.trim().isNotEmpty) {
        body['context_text'] = contextText.trim();
      }

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/analyze_food/image'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to analyze image: ${response.statusCode} - ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      AppLogger.debug('Image analysis successful: $data');
      return FoodAnalysisResult.fromJson(data);
    } catch (e) {
      AppLogger.error('Image analysis error', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> analyzeFoodFromAudio(
    File audioFile,
    String format,
  ) async {
    try {
      AppLogger.debug(
        'Analyzing food from audio: ${audioFile.path} (format: $format)',
      );

      final bytes = await audioFile.readAsBytes();
      final base64Audio = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/analyze_food/audio'),
        headers: _getHeaders(),
        body: jsonEncode({'audio': base64Audio, 'format': format}),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to analyze audio: ${response.statusCode} - ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final analysis = FoodAnalysisResult.fromJson(data);
      AppLogger.debug('Audio analysis successful: $data');

      return {
        'meal_name': analysis.mealName,
        'calories': analysis.calories,
        'protein': analysis.protein,
        'carbs': analysis.carbs,
        'fats': analysis.fats,
      };
    } catch (e) {
      AppLogger.error('Audio analysis error', e);
      rethrow;
    }
  }
}
