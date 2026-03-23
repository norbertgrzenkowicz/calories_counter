import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_scanner/providers/locale_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('locale provider defaults to system when unset', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(container.dispose);

    expect(
        container.read(localePreferenceProvider), AppLanguagePreference.system);
    expect(container.read(appLocaleProvider), isNull);
  });

  test('locale provider persists manual language selection', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(localePreferenceProvider.notifier)
        .update(AppLanguagePreference.english);

    expect(container.read(localePreferenceProvider),
        AppLanguagePreference.english);
    expect(container.read(appLocaleProvider), const Locale('en'));
    expect(
      preferences.getString('locale_preference'),
      AppLanguagePreference.english.name,
    );
  });
}
