import 'dart:io';
import 'package:image_picker/image_picker.dart';

enum FileValidationResult {
  valid,
  tooLarge,
  invalidFormat,
  corrupted,
  accessDenied,
}

class FileUploadValidator {
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
  static const List<String> allowedMimeTypes = [
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'image/gif'
  ];

  static Future<FileValidationResult> validateFile(File file) async {
    try {
      // Check if file exists and is accessible
      if (!await file.exists()) {
        return FileValidationResult.accessDenied;
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize > maxFileSizeBytes) {
        return FileValidationResult.tooLarge;
      }

      // Check file extension
      final fileName = file.path.toLowerCase();
      final hasValidExtension = allowedExtensions.any((ext) => fileName.endsWith(ext));
      
      if (!hasValidExtension) {
        return FileValidationResult.invalidFormat;
      }

      // Basic file integrity check - try to read first few bytes
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        return FileValidationResult.corrupted;
      }

      return FileValidationResult.valid;
    } catch (e) {
      return FileValidationResult.accessDenied;
    }
  }

  static Future<FileValidationResult> validateImageFile(XFile file) async {
    final ioFile = File(file.path);
    return await validateFile(ioFile);
  }

  static String getErrorMessage(FileValidationResult result) {
    return getValidationErrorMessage(result);
  }

  static String getValidationErrorMessage(FileValidationResult result) {
    switch (result) {
      case FileValidationResult.valid:
        return '';
      case FileValidationResult.tooLarge:
        return 'File is too large. Maximum size is ${maxFileSizeBytes ~/ (1024 * 1024)}MB.';
      case FileValidationResult.invalidFormat:
        return 'Invalid file format. Only JPG, PNG, and GIF are allowed.';
      case FileValidationResult.corrupted:
        return 'File appears to be corrupted or empty.';
      case FileValidationResult.accessDenied:
        return 'Cannot access the file. Please check permissions.';
    }
  }
}