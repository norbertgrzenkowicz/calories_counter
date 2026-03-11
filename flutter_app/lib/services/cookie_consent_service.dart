import 'package:shared_preferences/shared_preferences.dart';

const _kConsentKey = 'cookie_consent_given';

class CookieConsentService {
  static Future<bool> hasAnswered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kConsentKey);
  }

  static Future<bool?> getConsent() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_kConsentKey)) return null;
    return prefs.getBool(_kConsentKey);
  }

  static Future<void> setConsent({required bool accepted}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kConsentKey, accepted);
  }
}
