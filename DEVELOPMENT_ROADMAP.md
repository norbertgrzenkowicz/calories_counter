# Development Roadmap — Ship Fast, Ship What Matters

Last updated: 2026-02-27

## Current State: Honest Assessment

The app has solid bones — auth, meal tracking via chat/text/audio/barcode, weight tracking, calendar, Stripe subscription backend, Riverpod architecture partially rolled out. It works on a phone today.

**But it can't make money yet.** The paywall doesn't enforce anything. Free users get every feature forever. That's the single biggest gap.

### What's Actually Working
- Auth (login/register/JWT)
- Meal CRUD via chat text + audio analysis
- Barcode scanning with product cache
- Manual meal entry with sanitization
- Weight tracking with charts
- Calendar view of meal history
- Stripe subscription backend (checkout, portal, webhooks)
- Export to PDF/CSV
- Profile with personalized nutrition targets

### What's Broken or Missing
| Issue | Impact | Effort |
|---|---|---|
| **No paywall enforcement** | Zero revenue. Free = premium forever | Small (1 day) |
| **Old dashboard is the live one** | Riverpod dashboard exists but is dead code. Live dashboard uses raw SupabaseService | Medium (2 days) |
| **No crash reporting** | Blind to production issues | Small (half day) |
| **Camera/photo analysis not wired** | Core feature advertised but missing from UI | Medium (1-2 days) |
| **No onboarding flow** | New users dropped into complex UI cold | Medium (1-2 days) |
| **Account deletion stub** | GDPR/App Store compliance blocker | Small (half day) |
| **100% online dependent** | App is useless without network | Large (3-5 days) |
| **Settings "Coming Soon" placeholders** | Looks unfinished | Small |

---

## Priority Order: Maximum Revenue Impact Per Hour Spent

### Sprint 1: Make Money Work (1-2 days)

**The paywall is the only thing between $0 MRR and $5/mo per user.**

`PaywallScreen` already exists but is never imported. `Subscription.hasAccess` exists but is never checked. Wire it up:

1. **Gate premium features behind `hasAccess`**
   - Add meal (allow N free meals/day, then paywall)
   - Export data
   - Weight tracking charts
   - Audio input
   - Files: `add_meal_screen.dart`, `export_data_screen.dart`, `weight_tracking_screen.dart`, `dashboard_screen.dart`

2. **Show `PaywallScreen` when blocked**
   - Already built, just needs to be imported and navigated to
   - File: `paywall_screen.dart` (unused), every gated screen

3. **Show subscription status in settings**
   - Already partially there in `settings_screen.dart`

**Why first:** Without this, nothing else matters. You can polish forever but $0 is $0.

### Sprint 2: Switch to Riverpod Dashboard (1-2 days)

The old `DashboardScreen` (1500 lines, raw SupabaseService) is what users actually see. `DashboardScreenRiverpod` (480 lines, clean) exists and works but is dead code.

1. **Wire `DashboardScreenRiverpod` as the live dashboard**
   - `splash_screen.dart` line 35: change `DashboardScreen` → `DashboardScreenRiverpod`
   - `login_screen.dart` line 50: same change
   - Port the chat UI from old dashboard to Riverpod one (or decide to drop it from main dashboard)

2. **Delete `dashboard_screen.dart`** once migration is verified

**Why second:** Eliminates the biggest source of state management chaos. Every future feature builds on this.

### Sprint 3: Crash Reporting + Analytics (half day)

1. **Add Sentry** (`sentry_flutter` package)
   - Wrap `runApp` with `SentryFlutter.init()`
   - `main.dart` already has a TODO for this
   - Catches unhandled exceptions, gives stack traces from real users

2. **Firebase Analytics** (optional, for funnel tracking)
   - Registration → Profile setup → First meal → Subscription conversion

**Why third:** You need visibility before public launch. Can't fix what you can't see.

### Sprint 4: Onboarding (1-2 days)

New users currently land on the dashboard with a dismissable "Complete Your Profile" dialog. That's not onboarding.

Build 3-4 screen flow:
1. Welcome — what the app does (15-second food tracking)
2. Dietary goal selection (lose weight / maintain / gain)
3. Basic profile (height, weight, activity level)
4. Camera + notification permissions

**Why here:** Directly impacts trial-to-paid conversion. Users who set up a profile understand the value.

### Sprint 5: Wire Up Photo Analysis (1-2 days)

The backend API exists. `ChatService.analyzePhoto()` exists. The UI just never calls it.

1. Add `image_picker` to pubspec.yaml
2. Add camera button to `add_meal_screen.dart`
3. Capture photo → call analysis API → fill nutrition fields
4. Upload photo to Supabase Storage

**Why here:** This is the headline feature ("snap a photo, get nutrition"). Without it, the app is just a manual food logger competing with MyFitnessPal.

### Sprint 6: Account Deletion (half day)

Required for App Store and GDPR. Currently stubs out with an error.

1. Implement actual account deletion in `auth_repository_impl.dart`
2. Delete user data from Supabase (meals, profile, chat messages)
3. Sign out and navigate to login

### Sprint 7: Offline Support (3-5 days — do this last)

Nice to have, not a launch blocker. Most target users (gym-goers) have internet.

1. Add local DB (Drift or Isar)
2. Cache meals/profile locally
3. Queue offline changes for sync
4. Show cached data when offline

---

## What NOT To Do

- Don't refactor code that works. The old dashboard is ugly but if Sprint 2 replaces it, refactoring is wasted work.
- Don't add features nobody asked for. No social features, no meal planning, no recipe suggestions. Ship the core loop first.
- Don't write tests for UI. Manual testing on device is faster for an MVP. Write tests for payment logic only.
- Don't optimize performance until you have users complaining about it.
- Don't build offline support before launch. Ship online-only, add offline if retention data shows it matters.

---

## Definition of "Launchable"

All of these must be true:
- [ ] Paywall enforced — free users hit a gate after trial
- [ ] Crash reporting live — Sentry catching unhandled exceptions
- [ ] Account deletion works — App Store requirement
- [ ] Riverpod dashboard is the live one — no state management split
- [ ] One full flow works end-to-end: register → profile → add meal → see it in calendar → subscription prompt

That's Sprints 1-3 + account deletion. ~4 days of focused work.
