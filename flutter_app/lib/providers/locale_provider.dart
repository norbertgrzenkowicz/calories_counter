import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguagePreference {
  system,
  english,
  polish,
}

const _localePreferenceKey = 'locale_preference';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at app start');
});

final localePreferenceProvider =
    StateNotifierProvider<LocalePreferenceNotifier, AppLanguagePreference>(
  (ref) => LocalePreferenceNotifier(ref.read(sharedPreferencesProvider)),
);

final appLocaleProvider = Provider<Locale?>((ref) {
  final preference = ref.watch(localePreferenceProvider);
  switch (preference) {
    case AppLanguagePreference.system:
      return null;
    case AppLanguagePreference.english:
      return const Locale('en');
    case AppLanguagePreference.polish:
      return const Locale('pl');
  }
});

class LocalePreferenceNotifier extends StateNotifier<AppLanguagePreference> {
  LocalePreferenceNotifier(this._preferences)
      : super(_readPreference(_preferences));

  final SharedPreferences _preferences;

  Future<void> update(AppLanguagePreference preference) async {
    state = preference;
    await _preferences.setString(_localePreferenceKey, preference.name);
  }

  static AppLanguagePreference _readPreference(SharedPreferences preferences) {
    final storedValue = preferences.getString(_localePreferenceKey);
    return AppLanguagePreference.values.firstWhere(
      (value) => value.name == storedValue,
      orElse: () => AppLanguagePreference.system,
    );
  }
}
