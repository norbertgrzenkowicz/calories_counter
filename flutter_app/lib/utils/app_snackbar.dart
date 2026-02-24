import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppSnackbar {
  static void success(BuildContext context, String message) {
    _show(context, message, AppTheme.neonGreen, Icons.check_circle);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, AppTheme.neonRed, Icons.error);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message, AppTheme.neonOrange, Icons.warning);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, AppTheme.neonBlue, Icons.info);
  }

  static void _show(
      BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: color),
              ),
            ),
          ],
        ),
        backgroundColor: color.withOpacity(0.15),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
