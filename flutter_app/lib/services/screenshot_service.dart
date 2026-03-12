import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenshotService {
  static const String _lastCheckKey = 'screenshot_last_check_ms';

  /// Returns the most recent screenshot taken after the last app-resume check.
  /// Returns null if no new screenshot exists or permission was denied.
  Future<File?> checkForNewScreenshot() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastCheckMs = prefs.getInt(_lastCheckKey);

    // First launch: record timestamp and skip to avoid false positives.
    if (lastCheckMs == null) {
      await prefs.setInt(_lastCheckKey, now.millisecondsSinceEpoch);
      return null;
    }

    final lastCheck = DateTime.fromMillisecondsSinceEpoch(lastCheckMs);
    await prefs.setInt(_lastCheckKey, now.millisecondsSinceEpoch);

    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth && !permission.hasAccess) return null;

    final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
    AssetPathEntity? screenshotsAlbum;
    for (final album in albums) {
      final name = album.name.toLowerCase();
      if (name == 'screenshots' || name == 'screenshot') {
        screenshotsAlbum = album;
        break;
      }
    }

    if (screenshotsAlbum == null) return null;

    final count = await screenshotsAlbum.assetCountAsync;
    if (count == 0) return null;

    final assets = await screenshotsAlbum.getAssetListRange(
      start: 0,
      end: count < 20 ? count : 20,
    );

    for (final asset in assets) {
      if (asset.createDateTime.isAfter(lastCheck)) {
        return asset.file;
      }
    }

    return null;
  }
}
