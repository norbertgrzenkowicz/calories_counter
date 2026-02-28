# Known Bugs & Issues

## Critical

1. **Paywall not enforced** — `PaywallScreen` exists but is never imported. `Subscription.hasAccess` is never checked. Free users get all features forever. Revenue = $0.

2. **Account deletion not implemented** — `auth_repository_impl.dart` lines 194-213 just signs out and shows an error. Actual data deletion never happens. App Store / GDPR blocker.

3. **Live dashboard uses raw SupabaseService** — `splash_screen.dart` and `login_screen.dart` route to `DashboardScreen` (1500-line StatefulWidget with direct DB calls), not `DashboardScreenRiverpod` (clean, 480 lines, already built).

## High

4. **Camera/photo food analysis not wired to UI** — Backend API + `ChatService.analyzePhoto()` exist, but no `image_picker` in pubspec and no camera button in `add_meal_screen.dart`. The headline feature is missing.

5. **No crash reporting** — `main.dart` line 18 has a TODO. No Sentry, no Firebase Crashlytics. Blind to production crashes.

6. **Double-tap on add meal submits twice** — `_isSubmitting` guard exists but race condition still possible on fast taps.

## Medium

7. **Settings screen has "Coming Soon" placeholders** — Help/FAQ, Privacy/Security, Feedback, Notifications all stub out with a SnackBar. Looks unfinished.

8. **No onboarding flow** — New users see a dismissable dialog. No guided setup, no permission requests, no value explanation.

9. **CalendarScreen uses raw SupabaseService** — Gets static meal list passed in, doesn't react to changes.

## Low

10. **Unused imports accumulating** — `dart:convert`, `dart:io`, `http`, `file_upload_validator` in various files.

11. **SharedPreferences in pubspec but unused** — Added as dependency, never imported anywhere.

12. **App 100% online-dependent** — No local cache. Meals, profile, everything requires network.
