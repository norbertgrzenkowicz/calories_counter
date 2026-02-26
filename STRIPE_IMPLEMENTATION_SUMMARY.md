# Stripe Payment Implementation Summary

## ✅ What's Been Accomplished

### Backend Implementation (FastAPI)

1. **Dependencies Added** (`backend/requirements.txt`)
   - `stripe==7.6.0`
   - `pydantic-settings==2.1.0`
   - `supabase==2.3.0`

2. **Database Migration** (`backend/migrations/add_subscription_fields.sql`)
   - Adds subscription fields to `user_profiles` table
   - Includes indexes for performance
   - **ACTION REQUIRED**: Run this SQL in your Supabase SQL Editor

3. **Core Services Created**
   - `backend/stripe_service.py` - Stripe API wrapper with all subscription logic
   - `backend/subscription_routes.py` - FastAPI endpoints for checkout, portal, and status
   - `backend/middleware/subscription_check.py` - Access control middleware
   - `backend/app.py` - Updated to integrate subscription routes

4. **Environment Template** (`backend/.env.example`)
   - Created template showing required environment variables

5. **Premium Features Protected**
   - All `/analyze_food/*` endpoints now require active subscription
   - Middleware checks subscription status before allowing access

### Flutter Implementation

1. **Dependencies Added** (`pubspec.yaml`)
   - `webview_flutter: ^4.4.2`

2. **Models Created**
   - `lib/models/subscription.dart` - Subscription enums and model
   - `lib/models/user_profile.dart` - Updated with subscription fields

3. **Services & Providers**
   - `lib/services/subscription_service.dart` - API calls to backend
   - `lib/providers/subscription_provider.dart` - Riverpod state management

4. **UI Screens & Widgets**
   - `lib/screens/subscription_screen.dart` - Beautiful subscription purchase UI
   - `lib/screens/paywall_screen.dart` - Shown when trial expires
   - `lib/widgets/subscription_banner.dart` - Trial countdown banner
   - `lib/screens/settings_screen.dart` - Updated with subscription management
   - `lib/screens/dashboard_screen.dart` - Updated to show banner

---

## 📋 What YOU Need to Do

### 1. Stripe Dashboard Setup (15 minutes)

#### Get API Keys
1. Sign up at https://dashboard.stripe.com
2. Ensure you're in **Test Mode** (toggle in top-right)
3. Go to **Developers → API Keys**
4. Copy **Publishable key** (`pk_test_...`)
5. Copy **Secret key** (`sk_test_...`)

#### Create Products with Free Trial
**Monthly Product:**
1. Products → Add Product
2. Name: "Japer Premium Monthly"
3. Add pricing model → Standard pricing
4. Price: $5.00 USD, Billing: Monthly
5. **Trial period** → Toggle ON → Enter **7 days**
6. Save and copy **Price ID** (`price_...`)

**Yearly Product:**
1. Add Product → "Japer Premium Yearly"
2. Price: $30.00 USD, Billing: Yearly
3. **Trial period** → Toggle ON → Enter **7 days**
4. Save and copy **Price ID** (`price_...`)

#### Configure Trial Settings
Go to **Settings → Billing → Trials**:
- ✅ Automatically charge after trial ends
- ✅ Require payment method during trial signup
- ✅ Allow customers to cancel during trial
- ✅ Enable trial ending email notifications

### 2. Database Migration (5 minutes)

1. Go to Supabase Dashboard → SQL Editor
2. Open `backend/migrations/add_subscription_fields.sql`
3. Copy entire file contents
4. Paste into SQL Editor and run
5. Verify table updated: `SELECT * FROM user_profiles LIMIT 1;`

### 3. Backend Environment Setup (10 minutes)

Create `backend/.env` file:

```bash
# OpenAI (existing)
OPENAI_API_KEY=your_existing_key

# Supabase (existing)
SUPABASE_URL=your_existing_url
SUPABASE_ANON_KEY=your_existing_key

# Stripe - ADD THESE NEW ONES
STRIPE_SECRET_KEY=sk_test_XXXXX  # From Step 1
STRIPE_PUBLISHABLE_KEY=pk_test_XXXXX  # From Step 1
STRIPE_WEBHOOK_SECRET=whsec_XXXXX  # From Step 4 below
STRIPE_MONTHLY_PRICE_ID=price_XXXXX  # Monthly price ID from Step 1
STRIPE_YEARLY_PRICE_ID=price_XXXXX  # Yearly price ID from Step 1
```

### 4. Local Development with Stripe CLI (10 minutes)

#### Install Stripe CLI
```bash
brew install stripe/stripe-tap/stripe
stripe login  # Follow browser authentication
```

#### Run Backend and Webhook Listener

**Terminal 1 - Backend:**
```bash
cd /Users/norbert/projects/japer/backend
uvicorn app:app --reload --port 5001
```

**Terminal 2 - Stripe Webhooks:**
```bash
stripe listen --forward-to localhost:5001/stripe/webhook
```

**IMPORTANT**: Copy the webhook signing secret (`whsec_...`) from Terminal 2 output and add it to your `.env` file as `STRIPE_WEBHOOK_SECRET`.

### 5. Flutter Setup (5 minutes)

#### Run code generation for Riverpod:
```bash
cd /Users/norbert/projects/japer/flutter_app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Update API URL (if needed)
The service currently points to:
```dart
// lib/services/subscription_service.dart:7
static const String _apiBaseUrl =
  'https://us-central1-white-faculty-417521.cloudfunctions.net/japer-api';
```

If your backend is elsewhere, update this URL.

---

## 🧪 Testing Guide

### Test Cards (Stripe Test Mode)
- **Success**: `4242 4242 4242 4242`
- **Decline**: `4000 0000 0000 0002`
- Any future expiry date, any CVC

### Test Flow
1. **Start trial:**
   - Open app → Settings → "Upgrade to Premium"
   - Select Monthly or Yearly
   - Click "Start Free Trial"
   - Enter test card `4242 4242 4242 4242`
   - Complete checkout

2. **Verify trial active:**
   - Dashboard should show "X days left in trial" banner
   - Settings should show "Manage Subscription"
   - Check Supabase: `subscription_status` should be `trialing`

3. **Test food analysis:**
   - Try scanning food (should work during trial)

4. **Simulate trial expiration:**
   - In Supabase SQL Editor:
   ```sql
   UPDATE user_profiles
   SET trial_ends_at = NOW() - INTERVAL '1 day',
       subscription_status = 'free'
   WHERE uid = 'your_user_id';
   ```
   - Restart app
   - Try scanning food → Should show paywall

5. **Test webhooks:**
   ```bash
   stripe trigger customer.subscription.created
   stripe trigger customer.subscription.updated
   ```
   - Check backend logs for webhook processing

### Debugging

**Backend not receiving webhooks?**
- Ensure `stripe listen` is running in Terminal 2
- Check webhook signing secret in `.env` matches Terminal 2 output

**App shows "Failed to create checkout"?**
- Verify Stripe keys in `.env`
- Check backend is running (`localhost:5001`)
- Check price IDs are correct

**Subscription not syncing?**
- Check Supabase table for subscription fields
- Verify webhook events in Stripe Dashboard → Developers → Events

---

## 🚀 Production Deployment (When Ready)

### 1. Deploy Backend
Deploy your FastAPI backend to a cloud service:
- **Render.com**: Auto-deploy from GitHub
- **Railway.app**: Easy deployment
- **Fly.io**: Free tier available

### 2. Update Stripe Webhook
1. Go to Stripe Dashboard → Developers → Webhooks
2. Add endpoint: `https://your-production-domain.com/stripe/webhook`
3. Select events:
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
4. Copy production webhook signing secret
5. Update production environment variables

### 3. Switch to Live Mode
1. Stripe Dashboard → Toggle "Test Mode" OFF
2. Create products again in Live Mode
3. Get Live API keys (start with `pk_live_` and `sk_live_`)
4. Update production environment variables

### 4. Update Flutter
Update API URL in `lib/services/subscription_service.dart` to production backend URL.

---

## 📝 Checklist

### Setup Phase
- [ ] Stripe account created
- [ ] Test mode products created (Monthly + Yearly)
- [ ] 7-day trial enabled on both products
- [ ] API keys copied
- [ ] Database migration run in Supabase
- [ ] `backend/.env` file created with all keys
- [ ] Stripe CLI installed and authenticated

### Development Phase
- [ ] Backend running (`uvicorn app:app --reload --port 5001`)
- [ ] Stripe webhook listener running (`stripe listen --forward-to localhost:5001/stripe/webhook`)
- [ ] Riverpod code generated (`flutter pub run build_runner build`)
- [ ] App successfully starts

### Testing Phase
- [ ] Trial signup works with test card
- [ ] Subscription status shows correctly in Settings
- [ ] Banner displays trial countdown
- [ ] Food analysis works during trial
- [ ] Webhooks successfully sync to database
- [ ] Trial expiration blocks premium features
- [ ] Customer Portal opens successfully

### Production Phase (Later)
- [ ] Backend deployed to production
- [ ] Production webhook endpoint configured
- [ ] Live mode products created
- [ ] Live API keys updated
- [ ] Flutter app updated with production URL

---

## 🔍 Key Files to Review

**Backend:**
- `backend/stripe_service.py` - Main subscription logic
- `backend/subscription_routes.py` - API endpoints
- `backend/app.py` - Check integration

**Flutter:**
- `lib/providers/subscription_provider.dart` - State management
- `lib/screens/subscription_screen.dart` - Purchase UI
- `lib/widgets/subscription_banner.dart` - Trial banner

**Database:**
- `backend/migrations/add_subscription_fields.sql` - Schema changes

---

## 🆘 Support

**Stripe Documentation:**
- https://stripe.com/docs/billing/subscriptions/trials
- https://stripe.com/docs/webhooks

**Testing:**
- Test cards: https://stripe.com/docs/testing
- Stripe CLI: https://stripe.com/docs/stripe-cli

**Issues?**
- Check backend logs for errors
- Review Stripe Dashboard → Events for webhook delivery
- Verify environment variables are set correctly
