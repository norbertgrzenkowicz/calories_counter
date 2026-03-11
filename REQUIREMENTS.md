# Yapper — Public Beta Requirements

> Last updated: 2026-03-11
> Status: Pre-launch — MVP complete, beta prep in progress

---

## 1. Launch Checklist

Minimum requirements before inviting public beta users.

### Legal & Compliance

- [ ] Privacy Policy (GDPR + CCPA compliant) — hosted URL required by App Store
- [ ] Terms of Service — hosted URL required by App Store
- [ ] Cookie/data consent banner (web landing page)
- [ ] GDPR: right to deletion (account delete must purge all user data from Supabase)
- [ ] Data Processing Agreement with Supabase, OpenAI, Stripe (review ToS)
- [ ] Apple App Store: completed App Privacy labels (Data Types collected, usage)
- [ ] Google Play: Data Safety form completed

### App Store Submission (iOS)

- [ ] App Store Connect account active
- [ ] Bundle ID registered: `com.yapper.app` (or chosen ID)
- [ ] App icons: 1024×1024 + all required sizes
- [ ] Screenshots for all required device sizes (6.7", 6.5", 5.5" iPhone)
- [ ] App description, keywords, category (Health & Fitness)
- [ ] Age rating completed (likely 4+)
- [ ] Privacy policy URL in App Store Connect
- [ ] Support URL (email or web page)
- [ ] In-App Purchase SKUs registered (monthly $4.99, yearly $29.99)
- [ ] StoreKit production receipts tested
- [ ] TestFlight build uploaded and tested on real devices

### App Store Submission (Android) — optional at launch

- [ ] Google Play Console account active
- [ ] Signing keystore stored securely (not in git)
- [ ] Target SDK: API 34+
- [ ] Data Safety form filled
- [ ] Play Billing integration (Stripe on Android requires extra compliance review)

### Authentication

- [ ] Email/password flow working end-to-end (register → confirm → login)
- [ ] Fix misleading "check your email" message (Supabase auto-confirm is on — update copy)
- [ ] Password reset flow tested
- [ ] Apple Sign-In (required by App Store if any social login exists — even optional)
- [ ] Session expiry handled gracefully (no silent failures, prompt re-login)
- [ ] JWT refresh on app resume works

### Payments & Subscriptions

- [ ] Paywall **enforced** — free users must be blocked after trial expiry (currently not enforced)
- [ ] Stripe webhooks deployed and receiving events in production
- [ ] `customer.subscription.deleted` → revoke access, prompt to resubscribe
- [ ] `invoice.payment_failed` → notify user, grace period logic
- [ ] Trial logic: 7-day countdown visible to user in-app
- [ ] Upgrade/downgrade flow tested (monthly → yearly)
- [ ] Stripe Customer Portal working in production
- [ ] Test mode → Live mode switch done before launch (separate Stripe keys)
- [ ] Receipts and billing history accessible in-app or via portal

### Core Feature Stability

- [ ] Food photo analysis working (re-enable with rate limiting / cost cap)
- [ ] Text/audio meal logging: no crashes on edge cases (empty input, timeout)
- [ ] Barcode scanner: fallback to OpenFoodFacts works reliably
- [ ] Meal CRUD: create/edit/delete all work without UI glitches
- [ ] Weight tracking: entry + chart rendering stable
- [ ] Calendar view: correct day highlighting, no off-by-one timezone bugs
- [ ] Data export (PDF/CSV): generates valid files on iOS

### Infrastructure & Reliability

- [ ] Backend deployed (Cloud Run or equivalent) with health check endpoint
- [ ] Supabase project on paid plan (free tier pauses after inactivity)
- [ ] OpenAI API key with spending limit set (prevent runaway costs)
- [ ] Stripe webhook endpoint verified in production dashboard
- [ ] Environment variables managed via secrets manager (not `.env` in repo)
- [ ] HTTPS enforced on all API endpoints

### Crash Reporting & Observability

- [ ] Sentry (or Firebase Crashlytics) integrated in Flutter app
- [ ] Backend error tracking (Sentry Python SDK or Cloud Logging)
- [ ] Alert on >1% crash rate
- [ ] Logging: structured logs on backend (request/response, AI call latency)

### Analytics

- [ ] Mixpanel or PostHog installed
- [ ] Track: app_open, meal_logged, photo_analyzed, subscription_started, subscription_cancelled
- [ ] Identify users post-login
- [ ] Funnel: install → register → first meal → trial start → paid

### Quality Gates

- [ ] No crashes on fresh install (cold start)
- [ ] App launch < 2 seconds on iPhone 12+
- [ ] Food analysis response < 5 seconds (P95)
- [ ] Zero layout overflow warnings in release build
- [ ] All deprecated Flutter APIs resolved
- [ ] `flutter analyze` passing with zero errors

---

## 2. Feature Priorities

### Tier 1 — Conversion (Must-have at launch)

These directly determine whether a trial user converts to paid:

| Feature | Why it drives conversion |
|---|---|
| Food photo analysis | Core value prop — "snap a photo, get nutrition" |
| Accurate macro breakdown | Users verify against known foods; accuracy = trust |
| 7-day trial with visible countdown | Creates urgency, sets expectation |
| Paywall enforcement | No revenue without it |
| Smooth onboarding (first meal in <60s) | High drop-off if first-use is confusing |
| Apple Sign-In | Reduces friction (no email form) |

### Tier 2 — Retention (Must-have within first sprint post-launch)

These determine whether users stay past day 7:

| Feature | Why it drives retention |
|---|---|
| Daily calorie goal + progress bar | Visual feedback loop — habit forming |
| Streak / usage stats | Gamification increases return rate |
| Push notifications (daily reminder) | Re-engage users who forget to log |
| Weight trend visualization | Motivates continued logging |
| Meal history (weekly view) | Users review past patterns |
| Barcode scanning speed | Fast scanning = less friction for packaged foods |

### Tier 3 — Nice-to-have (Post-PMF)

- Google Sign-In
- Wearables integration (Apple Health, Google Fit)
- Meal planning / recommendations
- Restaurant menu scanning
- Social features (friends, leaderboard)
- AI coaching messages
- Macro split custom targets (keto, paleo, etc.)
- Dark mode toggle (currently always dark — add light option)

### Minimum Viable Feature Set

To launch with 50 beta users, the app needs exactly:

1. Email auth (register + login + password reset)
2. Food photo analysis (re-enabled with cost cap)
3. Text meal logging
4. Barcode scanning
5. Daily calorie tracker with macro breakdown
6. Meal history (list + calendar)
7. Subscription paywall (enforced, Stripe live mode)
8. Profile (name, calorie goal, dietary preference)

Everything else is a bonus for beta.

---

## 3. Technical Gaps

### Critical (Blocking Launch)

#### 3.1 Paywall Not Enforced

**File:** `backend/middleware/subscription_check.py`, `flutter_app/lib/screens/paywall_screen.dart`

The paywall screen exists but the middleware isn't applied to protected API routes. Free users after trial expiry have full access. Fix: apply `subscription_check` middleware to `/analyze_food/*` endpoints and enforce in Flutter before routing to meal logging screens.

#### 3.2 Account Deletion Incomplete

**File:** `flutter_app/lib/screens/profile_screen.dart`

Account deletion UI exists but does not delete user data from Supabase tables (`meals`, `weight_history`, `chat_messages`, `user_profiles`). GDPR requires full deletion. Fix: cascade delete in Supabase RLS policies or a backend `/account/delete` endpoint.

#### 3.3 Food Photo Analysis Disabled

**File:** `flutter_app/lib/screens/add_meal_screen.dart`

The UI re-enables calling OpenAI Vision (commit `2780a6c`) but cost controls are absent. Fix: add per-user rate limiting (e.g., 10 photo analyses/day on free tier, unlimited on paid) in `backend/app.py`. Add spending alert in OpenAI dashboard.

#### 3.4 Misleading Auth Copy

**File:** `flutter_app/lib/screens/register_screen.dart`

After registration, the app says "check your email to confirm" but Supabase auto-confirm is enabled — users can log in immediately. This causes confusion. Fix: update the success message copy, or disable auto-confirm and implement real email verification.

#### 3.5 Duplicate Dashboard Code

**Files:** `flutter_app/lib/screens/dashboard_screen.dart`, `dashboard_screen_riverpod.dart`

Two dashboard implementations exist. The Riverpod version is unused dead code. Fix: delete `dashboard_screen.dart` (old version), rename `dashboard_screen_riverpod.dart` to `dashboard_screen.dart`.

### High Priority (Fix Before Beta)

#### 3.6 No Crash Reporting

**File:** `flutter_app/lib/main.dart` (TODO comment present)

No Sentry or Firebase Crashlytics configured. Flying blind in production. Required for any serious beta.

#### 3.7 No Analytics

No Mixpanel/PostHog/Amplitude integration. Can't measure conversion funnel, retention, or feature usage. Required to make data-driven decisions post-launch.

#### 3.8 No CI/CD Pipeline

`.github/` directory exists but no workflow files. Manual deployments only. Minimum: GitHub Actions running `flutter analyze && flutter test` on PRs against `main`.

#### 3.9 Stripe in Test Mode

`stripe_service.py` uses keys from `.env`. Must confirm production Stripe keys are configured in Cloud deployment before launch. Live mode webhooks must be registered separately.

#### 3.10 Offline Behavior Undefined

App crashes or shows blank on network loss. Add graceful degradation: show cached data, display "offline" banner, queue writes for retry.

### Medium Priority (Post-Launch Iteration)

- `google_maps_flutter` dependency — maps library included but not used in any feature. Remove to reduce APK size and avoid requiring Google Maps API key on Android.
- `shared_preferences` vs Supabase persistence inconsistency — some state is local-only, some remote, no clear boundary documented.
- Freezed code generation — `.freezed.dart` and `.g.dart` files should be in `.gitignore` but are committed. Standard practice is to generate on CI.
- `supabase_test.dart` in `lib/services/` — test file in production code directory. Move to `test/`.

---

## 4. Timeline Estimate

Based on current state and one developer working full-time (~8h/day):

### Week 1-2: Foundation (Blockers)

| Task | Days |
|---|---|
| Enforce paywall across all protected routes | 2 |
| Fix account deletion (GDPR) | 1 |
| Re-enable photo analysis with rate limiting | 2 |
| Fix misleading auth copy | 0.5 |
| Sentry crash reporting (Flutter + backend) | 1 |
| Analytics integration (PostHog recommended — free tier) | 1 |
| Stripe: switch to live mode, verify webhooks | 1 |
| **Total** | **~8.5 days** |

### Week 3: App Store Prep

| Task | Days |
|---|---|
| Apple Sign-In integration | 2 |
| App icons + screenshots | 1 |
| Privacy policy + ToS (use a generator, customize) | 1 |
| App Store Connect setup + TestFlight build | 1 |
| App Store review submission | 1 (+ 1-3 days review time) |
| **Total** | **~6 days** |

### Week 4: Beta Launch

| Task | Days |
|---|---|
| Beta landing page (simple, email capture) | 2 |
| Beta invite emails to first 50 users | 0.5 |
| Monitor crash reports + analytics | ongoing |
| Fix top 3 bugs from beta feedback | 2 |
| **Total** | **~4.5 days** |

**Realistic launch date: ~4 weeks from today (2026-04-08)**

This assumes no major blockers. App Store review alone can take 1-5 days.

---

## 5. Risks

### Risk Matrix

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| App Store rejection (first submission) | High | High | Read App Store Review Guidelines thoroughly before submitting; common rejections: missing privacy policy, incomplete metadata, broken demo account |
| OpenAI Vision costs spike | Medium | High | Per-user daily limit (10 free, unlimited paid), spending cap in OpenAI dashboard, alert at $50/month |
| Stripe webhook failures in production | Medium | High | Implement idempotency, test webhooks with Stripe CLI before launch, monitor Stripe Dashboard webhook logs |
| Low beta engagement (<10 users active) | Medium | Medium | Personal outreach > passive signup; target Reddit r/fitness, r/loseit, Discord communities |
| Supabase free tier pause | Low | High | Upgrade to Pro ($25/month) before launch — free tier pauses after 1 week inactivity |
| GDPR complaint from EU user | Low | High | Implement account deletion, publish privacy policy, avoid storing unnecessary PII |
| Competitor feature copy | Low | Low | Speed and UX are the moat — not features; ship fast |
| App crashes on older iOS versions | Medium | Medium | Test on iOS 15+ (minimum supported); note any version-specific workarounds |
| Dart/Flutter package breaking changes | Low | Medium | Pin versions in pubspec.yaml, don't upgrade packages during beta |

### Specific Technical Risks

**Payment Revenue Leak**
Without paywall enforcement, users don't need to subscribe. This is the most critical revenue risk. The fix is a single middleware change + Flutter route guard, but it must be tested thoroughly to not lock out valid subscribers.

**OpenAI Cost Runaway**
GPT-4 Vision at ~$0.01-0.03 per image with 1000 beta users doing 3 meals/day = $30-90/day without limits. A $100/day spend cap + per-user limits makes this manageable.

**App Store Review Delay**
Initial reviews take 1-3 days, but rejections can stall a launch by 1-2 weeks. Submit for review early (week 3), plan for one round of fixes.

**Subscription Sync Bugs**
Stripe subscription state and Supabase subscription state can drift if webhooks fail. Implement a fallback: on app launch, verify subscription status directly via Stripe API if local state is stale.

---

## 6. Competition Analysis

### What Competitors Do Well

**MyFitnessPal**
- Massive food database (11M+ items)
- Barcode scanning is fast and accurate
- Social features (friends, challenges)
- Integration with Apple Health, Garmin, Fitbit

**Cronometer**
- Micronutrient tracking (vitamins, minerals) — more complete than just macros
- Trusted by dietitians and serious athletes
- Data export (accessible raw data)

**Lose It!**
- Clean, modern UI (compared to MyFitnessPal)
- Meal planning and recipes
- Subscription model similar to Yapper ($39.99/year)

### What's Missing in the Market

- **Speed**: All competitors require searching a database and selecting portions. A photo → instant macros flow (15 seconds) doesn't exist at quality in any mainstream app.
- **No ads on reasonable tier**: MyFitnessPal free tier is heavily advertised. Users are willing to pay to escape ads.
- **AI accuracy transparency**: Users don't trust AI nutrition estimates because they don't know how confident the estimate is. Showing confidence or allowing quick corrections builds trust.
- **Simplicity**: MyFitnessPal is overwhelmingly complex. Many users want only calories + protein, not 50 micronutrients.

### Yapper's Unfair Advantages

1. **Photo-first UX**: No competitor has a polished "snap → done" flow. This is a genuine differentiator if the OpenAI Vision accuracy holds up.
2. **Modern stack (Flutter + FastAPI)**: Allows fast cross-platform iteration with a solo developer.
3. **No legacy debt**: Competitors have 10+ year old codebases. Yapper can implement modern UX patterns without rewrites.
4. **Price**: $30/year is at the low end of the market. Cronometer is $44.99/year, Lose It! is $39.99/year.

### Strategic Recommendation

Do not compete with MyFitnessPal on database size. Win on:
- **Speed** (15-second meal logging via photo)
- **Simplicity** (calories + protein + carbs + fat — that's it)
- **Honesty** (show AI confidence, let users correct estimates)
- **Price** (keep $30/year, don't race to premium)

---

## Appendix: File Quick Reference

| What | Where |
|---|---|
| Flutter app entry | `flutter_app/lib/main.dart` |
| Backend API routes | `backend/app.py` |
| Stripe service | `backend/stripe_service.py` |
| Subscription middleware | `backend/middleware/subscription_check.py` |
| Auth middleware | `backend/middleware/auth.py` |
| Paywall screen | `flutter_app/lib/screens/paywall_screen.dart` |
| Subscription screen | `flutter_app/lib/screens/subscription_screen.dart` |
| Profile screen | `flutter_app/lib/screens/profile_screen.dart` |
| Add meal screen | `flutter_app/lib/screens/add_meal_screen.dart` |
| Supabase service | `flutter_app/lib/services/supabase_service.dart` |
| Subscription provider | `flutter_app/lib/providers/subscription_provider.dart` |
| DB schemas | `flutter_app/*.sql` |
