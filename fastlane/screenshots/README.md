# App Store Screenshots

Screenshots must be captured from a real device or simulator.

## Required iPhone Sizes

| Device | Size | Directory |
|--------|------|-----------|
| iPhone 6.7" (14 Pro Max / 15 Plus) | 1290×2796 | `en-US/` |
| iPhone 6.5" (11 Pro Max / XS Max) | 1242×2688 | `en-US/` |
| iPhone 5.5" (8 Plus / 7 Plus) | 1242×2208 | `en-US/` |

App Store requires at least one set (6.5" is mandatory, 5.5" required for older devices).

## Required Screenshots (5-10 per size)

1. **Home / Dashboard** - Daily calorie ring + macro breakdown
2. **Food Scanner** - Camera view scanning a meal
3. **Analysis Result** - AI nutrition result card (meal name + macros)
4. **Barcode Scanner** - Scanning a packaged product
5. **Calendar View** - Month view with logged meals
6. **Weight Chart** - Weight trend graph
7. **Subscription Screen** - Free trial + pricing

## How to Capture

```bash
# Run on simulator
cd flutter_app
flutter run -d "iPhone 15 Pro Max"

# Or build release for screenshots
flutter build ios --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

Then use Xcode Simulator > File > Save Screenshot (Cmd+S), or:
```bash
xcrun simctl io booted screenshot screenshot_name.png
```

## Naming Convention

```
en-US/iPhone_67_01_home.png
en-US/iPhone_67_02_scanner.png
en-US/iPhone_67_03_analysis.png
...
```
