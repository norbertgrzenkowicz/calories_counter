import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Max longest-side dimension for images stored in Supabase.
/// Chosen to cover full-screen display on the largest current iPhones (~1290px)
/// while cutting iPhone 4K photo file sizes by ~85%.
const int _kStorageMaxPx = 1920;
const int _kStorageQuality = 85;

/// Resizes [file] so its longest side ≤ [_kStorageMaxPx] px at JPEG [_kStorageQuality]%.
/// Returns the original file unchanged if it is already within bounds or is not an image.
/// The returned file is a temp file — the caller owns its lifecycle.
Future<File> resizeForStorage(File file) async {
  final ext = file.path.split('.').last.toLowerCase();
  const imageExts = {'jpg', 'jpeg', 'png', 'heic', 'heif', 'webp'};
  if (!imageExts.contains(ext)) return file;

  final bytes = await file.readAsBytes();

  final compressed = await FlutterImageCompress.compressWithList(
    bytes,
    minWidth: _kStorageMaxPx,
    minHeight: _kStorageMaxPx,
    quality: _kStorageQuality,
    format: CompressFormat.jpeg,
    keepExif: false,
  );

  // Skip if compress made it larger (rare, but possible for tiny images)
  if (compressed.length >= bytes.length) return file;

  final tmp = await getTemporaryDirectory();
  final outPath = '${tmp.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg';
  return File(outPath).writeAsBytes(compressed);
}
