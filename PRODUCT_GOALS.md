# Product Goals & Context

## Overview

**Your Mission:** Build profitable products that solve real problems and generate sustainable revenue.

**Current Goal:** Launch Yapper (Japer) as a paid SaaS with clean execution, hitting 3-5k MRR within 6-12 months through a combination of:
- Strong product-market fit
- Modern architecture & quality code
- Fast iteration cycle
- Focus on core features first, then expansion

---

## Active Product: Yapper (Japer)

### Overview

**Yapper** is an AI-powered food scanner & nutrition tracking app. Users take photos of food (or describe meals via text/audio), get instant nutrition analysis, and track their dietary intake over time.

### Type & Status

- **Type:** Mobile SaaS (iOS/Android)
- **Status:** MVP with Stripe integration (building toward public launch)
- **Problem Solved:** 
  - Manual food logging is tedious (takes 5-10 minutes per meal)
  - People want to understand nutrition without apps like MyFitnessPal (cluttered, ads)
  - Yapper: snap a photo → instant nutrition → done (15 seconds)

### Tech Stack

**Frontend:**
- Framework: Flutter 3.0+ (iOS + Android)
- Language: Dart
- State Management: Riverpod
- UI: Material Design + custom widgets
- Key Libraries: fl_chart, google_maps_flutter, mobile_scanner, table_calendar

**Backend:**
- Framework: FastAPI (Python 3.8+)
- Database: Supabase (PostgreSQL)
- Auth: Supabase JWT
- AI: OpenAI GPT-4 Vision (food analysis)
- Payments: Stripe (subscriptions)
- Deployment: Google Cloud Functions / Docker

**Infrastructure:**
- Database: Supabase (PostgreSQL, real-time)
- Auth: Supabase (JWT tokens)
- Images: Supabase Storage
- Notifications: Supabase Realtime
- Payments: Stripe (recurring subscriptions)

### Current Features (Implemented)

✅ **User Management**
- Email/password registration & login
- JWT-based authentication
- User profiles (name, goals, dietary preferences)
- Profile customization

✅ **Food Analysis**
- Image recognition (camera photos of meals)
- Text description parsing (describe food in words)
- Audio input (describe meals via voice)
- Returns: meal name, calories, protein, carbs, fats

✅ **Barcode Scanning**
- Quick product lookup via barcode
- Fallback to OpenFoodFacts database
- Instant nutrition data

✅ **Meal Tracking**
- Add meals (analyzed or manual entry)
- View meal history (calendar view)
- Persistent storage (Supabase)
- Daily/weekly summary

✅ **Weight Tracking**
- Log daily weight
- Visual charts (trends over time)
- Weight-to-calorie correlation

✅ **Analytics & Progress**
- Daily calorie breakdown (macros: protein, carbs, fats)
- Calendar view (meals per day)
- Weight charts with trendlines
- Export data to PDF/CSV

✅ **Payments & Subscriptions**
- Stripe integration (checkout flow)
- Subscription plans:
  - **Free tier:** 7-day trial (all features)
  - **Premium Monthly:** $5/month
  - **Premium Yearly:** $30/year
- Subscription portal (manage billing)
- Auto-renewal with trial period

✅ **UI/UX**
- Dark mode friendly
- Responsive design
- Smooth animations
- Intuitive navigation (bottom tab bar)

### Current Focus & Next Priorities (Next 30 Days)

**Priority 1: Stabilize & Polish (Week 1-2)**
- [ ] Fix remaining food photo analysis issues (currently disabled)
- [ ] Clean up chat/description UI (test user feedback)
- [ ] Keyboard handling improvements (numeric inputs, dismissal)
- [ ] Test full subscription flow (trial → paid)

**Priority 2: Quality & Metrics (Week 2-3)**
- [ ] Add crash reporting (Sentry or similar)
- [ ] Add analytics (Mixpanel or Firebase)
- [ ] Performance profiling (app startup, image analysis speed)
- [ ] Battery/data usage optimization

**Priority 3: Public Beta Prep (Week 3-4)**
- [ ] Privacy policy & terms of service
- [ ] Support flow (email/in-app)
- [ ] Beta signup landing page
- [ ] App Store compliance (iOS/Android)

**Priority 4: Launch & Early Monetization**
- [ ] Beta launch (invite 50-100 testers)
- [ ] Gather feedback
- [ ] Iterate on PMF
- [ ] Plan marketing (TikTok, Reddit fitness communities)

### Revenue Model

**Pricing:**
- Free tier: 7-day trial (all features)
- Premium: $5/month or $30/year
- Future: Pro tier ($15/month) with advanced analytics, coaching

**Target Customer:**
- Primary: Fitness enthusiasts (gym-goers, athletes)
- Secondary: People tracking calories for weight loss
- TAM: ~50M people use fitness apps monthly

**MRR Target:**
- Month 1-2 (launch): $100-500 (friends, family)
- Month 3-6 (beta): $1-2k (early adopters)
- Month 6-12: $3-5k (organic growth, word-of-mouth)

### Tech Preferences & Standards

**Code Quality:**
- Write for maintainability (future-you in 3 months should understand it)
- Type-safe (Dart, Python type hints)
- No tech debt (refactor as you go)
- Comments only for complex logic

**Performance:**
- App launch: < 2 seconds
- Food analysis: < 5 seconds (API call + response)
- Image processing: optimize for mobile (compress, resize)
- Database queries: indexed for speed

**Security:**
- JWT tokens with expiry
- HTTPS only (Stripe, APIs)
- No plaintext secrets (use environment variables)
- Validate all inputs (frontend + backend)

**Testing:**
- Unit tests for critical logic (auth, payments)
- Manual testing on real devices (iOS/Android)
- No automated UI tests (manual is faster for now)

**UI/UX Standards:**
- Material Design 3 principles
- Dark mode support
- Accessibility (readable fonts, contrast, tap targets)
- Smooth animations (not jarring)

### Known Issues & Tech Debt

- **Food photo analysis disabled** — GPT-4 Vision costs too much, may re-enable with better cost controls
- **Chat UI** — Needs refinement for longer meal descriptions
- **Offline support** — Partial (cached meals only, no sync)
- **Testing coverage** — Minimal (mostly manual)

### Git Repository

**Path:** `~/projects/yapper`

**Recent Commits:**
- Stripe subscription management (auto-renewal, portal)
- UI polish (keyboard handling, chat bubbles)
- Weight tracking charts
- Subscription paywall

**Key Branches:**
- `main` — production-ready code
- `dev` — active development
- Feature branches for new features (e.g., `feat/food-photo-analysis`)

---

## How Marvin Uses This Context

When you tell Marvin a task like:

> "Build the onboarding flow for new users"

Marvin reads this file and enriches the agent prompt:

```
Task: Build the onboarding flow for new users

Context:
- Project: Yapper (japer) - Food scanner app
- Tech: Flutter, Dart, Riverpod state management
- Status: MVP, targeting public beta soon
- Quality Standards: 
  - Maintainable code (type-safe, self-documenting)
  - Smooth animations (not jarring)
  - Dark mode support
  - <2 second startup time

- Recent focus: Subscription onboarding (free trial → paid)
- Style: Follow Material Design 3, use existing widgets
- Next priority: Public beta, so onboarding must explain features & trial

Implementation Checklist:
1. Show app features (food scanning, tracking, charts)
2. Explain free 7-day trial
3. Collect dietary preferences (for personalization)
4. Request camera & health permissions
5. Test on iOS & Android

See ~/projects/yapper/flutter_app/lib/screens/ for existing patterns.
```

This gives agents everything they need to build *exactly* what Yapper needs.

---

## Success Metrics

**Launch Success:**
- [ ] Private beta with 50+ users
- [ ] First paying subscribers ($100+ MRR)
- [ ] < 4% crash rate on production
- [ ] > 80% 7-day retention (users who come back)

**Growth Targets:**
- Month 1-3: 200 signups, $500 MRR
- Month 3-6: 1000 signups, $2k MRR
- Month 6-12: 3000 signups, $3-5k MRR

**Quality Metrics:**
- < 2 second app startup
- < 5 second food analysis response
- 95%+ uptime on backend
- 0% payment failures (Stripe reliability)

---

## Resources

**Code Documentation:**
- `~/projects/yapper/README.md` — Project overview
- `~/projects/yapper/STRIPE_IMPLEMENTATION_SUMMARY.md` — Payment integration details
- `~/projects/yapper/SUBSCRIPTION_AUTH_FIX.md` — Auth with subscriptions
- `~/projects/yapper/backend/` — Python API source
- `~/projects/yapper/flutter_app/lib/` — Flutter app source

**Key Contact Points:**
- Stripe Dashboard: https://dashboard.stripe.com (test mode)
- Supabase: https://supabase.com (database & auth)
- OpenAI: https://platform.openai.com (GPT-4 Vision API)

---

## Marvin's Job

With this context, Marvin can:

1. **Understand** what Yapper is and why it matters
2. **Suggest** features aligned with PMF & revenue goals
3. **Build** features with proper context (tech stack, code style, quality standards)
4. **Iterate** fast (spawn agents, monitor, notify on Telegram)
5. **Track** progress toward 3-5k MRR

---

**Ready to build Yapper into a profitable business.** 🚀
