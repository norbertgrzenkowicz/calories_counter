class InputSanitizer {
  static String sanitizeText(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String sanitizeName(String input) {
    final sanitized = sanitizeText(input);
    return sanitized.replaceAll(RegExp(r'[^\w\s-.]'), '');
  }

  static String sanitizeNumber(String input) {
    return input.replaceAll(RegExp(r'[^\d.,]'), '');
  }

  static double? parseDouble(String input) {
    final sanitized = sanitizeNumber(input).replaceAll(',', '.');
    return double.tryParse(sanitized);
  }

  static int? parseInt(String input) {
    final sanitized = sanitizeNumber(input).split('.')[0];
    return int.tryParse(sanitized);
  }

  static String sanitizeEmail(String input) {
    return sanitizeText(input).toLowerCase();
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  static String sanitizeUrl(String input) {
    return sanitizeText(input);
  }

  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static String removeSpecialCharacters(String input) {
    return input.replaceAll(RegExp(r'[^\w\s]'), '');
  }

  static String limitLength(String input, int maxLength) {
    return input.length <= maxLength ? input : input.substring(0, maxLength);
  }

  static String sanitizeBarcode(String input) {
    return input.replaceAll(RegExp(r'[^\w]'), '');
  }

  static String sanitizeMealName(String input) {
    return sanitizeText(input);
  }

  static int? sanitizeCalories(String input) {
    return parseInt(input);
  }

  static double? sanitizeMacroNutrient(String input) {
    return parseDouble(input);
  }

  static String sanitizePhotoUrl(String? input) {
    if (input == null) return '';
    return sanitizeUrl(input);
  }
}