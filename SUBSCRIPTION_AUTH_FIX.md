# Subscription Authentication Fix Summary

## Issues Fixed

### 1. ❌ RLS Policy Violation (RESOLVED)
**Error:** `new row violates row-level security policy for table "user_profiles"`

**Root Cause:**
- Backend was using `SUPABASE_ANON_KEY` to create user profiles
- RLS policies blocked anonymous users from creating profiles for other users
- Backend attempted to auto-create profiles during checkout, which violated RLS

**Solution:**
- Removed `_create_default_user_profile()` method from backend
- User profiles must be created during signup in the Flutter app
- Backend now throws clear error if profile doesn't exist before subscribing

**Files Modified:**
- `backend/stripe_service.py:132-137` - Raises exception instead of creating profile
- `backend/stripe_service.py:319-329` - Returns free tier instead of creating profile
- `backend/stripe_service.py:365-389` - Removed `_create_default_user_profile()` method

---

### 2. ❌ No Authentication on Subscription Endpoints (RESOLVED)
**Error:** Endpoints accepted `user_id` in request body without verification

**Root Cause:**
- Anyone could call subscription endpoints with any `user_id`
- No token verification meant users could subscribe as other users
- Security vulnerability

**Solution:**
- Added JWT authentication to all subscription endpoints
- User ID now extracted from verified Bearer token
- Removed `user_id` from request bodies

**Files Modified:**
- `backend/subscription_routes.py:1` - Added `Depends` import
- `backend/subscription_routes.py:7` - Added `get_current_user` import
- `backend/subscription_routes.py:14-15` - Removed `user_id` from CreateCheckoutRequest
- `backend/subscription_routes.py:23-24` - Removed CreatePortalRequest class
- `backend/subscription_routes.py:40-44` - Added authentication to create-checkout
- `backend/subscription_routes.py:79-80` - Added authentication to create-portal
- `backend/subscription_routes.py:102-103` - Changed status endpoint to `/status` with auth

---

### 3. ❌ Invalid Stripe Price ID (RESOLVED)
**Error:** `No such price: 'prod_TEalikMWq6V3tP'`

**Root Cause:**
- Environment variables were set with product IDs instead of price IDs
- Product IDs start with `prod_`, price IDs start with `price_`

**Solution:**
- User updated environment variables with correct price IDs
- Added documentation to `.env.example`

**Files Modified:**
- `backend/.env.example:15-18` - Added comments about price vs product IDs

---

## Flutter App Updates

### Updated Subscription Service
- Added `_getAuthHeaders()` method to get Bearer token from Supabase session
- Removed `userId` parameter from all methods
- All requests now include `Authorization: Bearer <token>` header

**Files Modified:**
- `flutter_app/lib/services/subscription_service.dart:3` - Added supabase_flutter import
- `flutter_app/lib/services/subscription_service.dart:15-26` - Added `_getAuthHeaders()` method
- `flutter_app/lib/services/subscription_service.dart:30-42` - Updated createCheckoutSession
- `flutter_app/lib/services/subscription_service.dart:67-75` - Updated createCustomerPortalSession
- `flutter_app/lib/services/subscription_service.dart:100-108` - Updated getSubscriptionStatus
- `flutter_app/lib/services/subscription_service.dart:126-133` - Updated hasAccess

### Updated Subscription Provider
- Removed `userId` parameter from all service calls
- Authentication now handled by service layer

**Files Modified:**
- `flutter_app/lib/providers/subscription_provider.dart:71` - Updated getSubscriptionStatus call
- `flutter_app/lib/providers/subscription_provider.dart:100-102` - Updated createCheckoutSession call
- `flutter_app/lib/providers/subscription_provider.dart:130` - Updated createCustomerPortalSession call

---

## Required Environment Variables

Add to your `.env` file:

```bash
# Supabase JWT Secret (from Supabase Dashboard > Settings > API > JWT Secret)
SUPABASE_JWT_SECRET=your_jwt_secret_here

# Stripe Price IDs (NOT product IDs!)
STRIPE_MONTHLY_PRICE_ID=price_xxxxxxxxxxxxx
STRIPE_YEARLY_PRICE_ID=price_xxxxxxxxxxxxx
```

---

## Testing Checklist

Before testing, ensure:
- [ ] `SUPABASE_JWT_SECRET` is set in backend `.env`
- [ ] `STRIPE_MONTHLY_PRICE_ID` and `STRIPE_YEARLY_PRICE_ID` use `price_` format
- [ ] User profile exists in `user_profiles` table before subscribing
- [ ] User is logged in with valid Supabase session in Flutter app

### Test Subscription Flow:
1. Login to Flutter app
2. Navigate to subscription screen
3. Click "Subscribe" button
4. Should successfully create checkout session and open Stripe Checkout
5. Complete payment in Stripe
6. Webhook should update subscription status in database

### Expected Behavior:
- ✅ Checkout session creates successfully
- ✅ No RLS policy errors
- ✅ No authentication errors
- ✅ Stripe price IDs are valid
- ✅ Subscription status updates after payment

---

## API Changes

### Breaking Changes for Frontend:

#### `/subscription/create-checkout`
**Before:**
```json
POST /subscription/create-checkout
Headers: Content-Type: application/json
Body: {
  "user_id": "uuid",
  "tier": "monthly"
}
```

**After:**
```json
POST /subscription/create-checkout
Headers:
  Content-Type: application/json
  Authorization: Bearer <supabase_token>
Body: {
  "tier": "monthly"
}
```

#### `/subscription/create-portal`
**Before:**
```json
POST /subscription/create-portal
Headers: Content-Type: application/json
Body: {
  "user_id": "uuid"
}
```

**After:**
```json
POST /subscription/create-portal
Headers:
  Content-Type: application/json
  Authorization: Bearer <supabase_token>
Body: {}
```

#### `/subscription/status/{user_id}`
**Before:**
```
GET /subscription/status/{user_id}
Headers: Content-Type: application/json
```

**After:**
```
GET /subscription/status
Headers:
  Content-Type: application/json
  Authorization: Bearer <supabase_token>
```

---

## Security Improvements

✅ **Implemented:**
- JWT token verification on all subscription endpoints
- User ID extracted from verified token (not request body)
- Removed ability to create profiles from backend
- Clear error messages when profile doesn't exist

✅ **Prevents:**
- Users subscribing as other users
- Unauthorized access to subscription endpoints
- RLS policy bypasses
- Profile creation without proper authentication

---

## Notes

- User profiles MUST be created during app signup, not during checkout
- Backend no longer auto-creates profiles to respect RLS policies
- All subscription operations require authenticated Supabase session
- Stripe price IDs must start with `price_`, not `prod_`
