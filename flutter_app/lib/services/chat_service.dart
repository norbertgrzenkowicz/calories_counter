import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/app_logger.dart';
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

  /// Analyze food from text description
  /// Returns nutrition data: {meal_name, calories, protein, carbs, fats}
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

  /// Analyze food from image file
  /// Returns nutrition data: {meal_name, calories, protein, carbs, fats}
  Future<Map<String, dynamic>> analyzeFoodFromImage(File imageFile) async {
    try {
      AppLogger.debug('Analyzing food from image: ${imageFile.path}');

      // Read image and convert to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/analyze_food/image'),
        headers: _getHeaders(),
        body: jsonEncode({
          'image': base64Image,
          'filename': imageFile.path.split('/').last,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        AppLogger.debug('Image analysis successful: $data');

        return {
          'meal_name': data['meal_name'] as String? ?? 'My Meal',
          'calories': data['calories'] as int,
          'protein': data['protein'] as int,
          'carbs': data['carbs'] as int,
          'fats': data['fats'] as int,
        };
      } else {
        throw Exception(
            'Failed to analyze image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      AppLogger.error('Image analysis error', e);
      rethrow;
    }
  }

  /// Analyze food from audio file
  /// Returns nutrition data: {meal_name, calories, protein, carbs, fats}
  Future<Map<String, dynamic>> analyzeFoodFromAudio(
      File audioFile, String format) async {
    try {
      AppLogger.debug(
          'Analyzing food from audio: ${audioFile.path} (format: $format)');

      // Read audio and convert to base64
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
