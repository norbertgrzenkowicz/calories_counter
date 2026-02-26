# Subscription Cancellation Implementation

## Overview
This implementation properly handles Stripe subscription cancellations when users cancel but retain access until the end of their billing period.

## Problem Solved
**Before:** When a user cancelled their subscription (e.g., today, Nov 9), but it remained active until the end of the billing period (e.g., Nov 19), the system showed "Active" with no indication of pending cancellation.

**After:** The system now tracks `cancel_at_period_end` and displays "Cancels in X days" while maintaining user access until the period ends.

---

## Changes Made

### 1. Database Migration
**File:** `backend/migrations/add_cancel_at_period_end_field.sql`

Added `cancel_at_period_end` boolean field to `user_profiles` table:
```sql
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS cancel_at_period_end BOOLEAN DEFAULT FALSE;
```

### 2. Backend: Webhook Handlers (`backend/stripe_service.py`)

**Updated methods:**
- `_handle_checkout_completed` (line 231): Tracks `cancel_at_period_end` for new subscriptions
- `_handle_subscription_created` (line 287): Captures cancellation status when subscription is created
- `_handle_subscription_updated` (line 334): **CRITICAL** - Detects when user cancels subscription
- `_handle_subscription_deleted` (line 375): Clears flag when subscription fully ends
- `get_subscription_status` (line 472): Returns cancellation info to API

### 3. Backend: API Response (`backend/subscription_routes.py`)

**Updated:**
- `SubscriptionStatusResponse` model (line 32): Added `cancel_at_period_end` field
- `/subscription/status` endpoint (line 110): Returns cancellation status

### 4. Flutter: Data Model (`flutter_app/lib/models/subscription.dart`)

**Added fields:**
- `cancelAtPeriodEnd` boolean property
- `willCancelSoon` getter - returns true if subscription is active but will cancel

**Updated methods:**
- `fromJson` (line 129): Parses `cancel_at_period_end` from API
- `toJson` (line 141): Serializes cancellation status
- `copyWith` (line 187): Includes cancellation flag

### 5. Flutter: UI Display (`flutter_app/lib/screens/settings_screen.dart`)

**Updated `_getSubscriptionSubtitle` method (line 163):**
Shows clear cancellation messaging:
- "Cancels in X days - Monthly"
- "Cancels tomorrow - Yearly"
- "Cancels today - Monthly"

---

## How It Works

### User Cancels Subscription

**1. User cancels in Stripe Customer Portal:**
```
User clicks "Cancel subscription" → Selects "Cancel at period end"
```

**2. Stripe fires `customer.subscription.updated` webhook:**
```json
{
  "type": "customer.subscription.updated",
  "data": {
    "object": {
      "id": "sub_xxx",
      "status": "active",  // Still active!
      "cancel_at_period_end": true,  // But will cancel
      "current_period_end": 1700352000  // Nov 19
    }
  }
}
```

**3. Backend updates database:**
```python
# stripe_service.py:334
cancel_at_period_end = subscription.get('cancel_at_period_end', False)
# → True

update_data = {
    'subscription_status': 'active',  # Still active
    'cancel_at_period_end': True,     # But cancelling
    'subscription_end_date': '2025-11-19'
}
```

**4. App displays cancellation notice:**
```dart
// settings_screen.dart:163
if (subscription.willCancelSoon) {
  return 'Cancels in 10 days - Monthly';
}
```

**5. User retains access:**
```python
# stripe_service.py:475
has_access = status in ('active', 'trialing')
# → True (still active until Nov 19)
```

### Period Ends (Nov 19)

**6. Stripe fires `customer.subscription.deleted` webhook:**
```json
{
  "type": "customer.subscription.deleted",
  "data": {
    "object": {
      "id": "sub_xxx",
      "status": "canceled"
    }
  }
}
```

**7. Backend deactivates subscription:**
```python
# stripe_service.py:375
{
    'subscription_status': 'canceled',
    'cancel_at_period_end': False,
    'stripe_subscription_id': None
}
```

**8. App blocks premium features:**
```dart
has_access = false  // No longer has access
```

---

## Testing Guide

### 1. Database Migration
```bash
# Run this in Supabase SQL Editor
cat backend/migrations/add_cancel_at_period_end_field.sql
```

### 2. Backend Testing

**Ensure webhook is configured:**
```bash
# Terminal 1: Start backend
cd backend
uvicorn app:app --reload --port 5001

# Terminal 2: Start Stripe webhook listener
stripe listen --forward-to localhost:5001/stripe/webhook
```

**Simulate cancellation:**
```bash
# Option 1: Via Stripe Dashboard
# 1. Go to Stripe Dashboard → Customers
# 2. Find test customer → Subscriptions
# 3. Click "Cancel subscription" → "Cancel at period end"

# Option 2: Via Stripe CLI
stripe subscriptions update sub_xxx --cancel-at-period-end=true
```

**Check database:**
```sql
SELECT
  uid,
  subscription_status,
  cancel_at_period_end,
  subscription_end_date
FROM user_profiles
WHERE stripe_subscription_id = 'sub_xxx';

-- Expected:
-- subscription_status: 'active'
-- cancel_at_period_end: true
-- subscription_end_date: future date
```

### 3. Flutter App Testing

**Test the UI:**
1. Open app → Settings
2. Should see: "Cancels in X days - Monthly"
3. User still has access to premium features
4. Check subscription banner shows cancellation

**Test API response:**
```bash
curl -s http://0.0.0.0:8080/subscription/status \
  -H "Authorization: Bearer YOUR_TOKEN" | jq

# Expected response:
{
  "status": "active",
  "tier": "monthly",
  "cancel_at_period_end": true,
  "subscription_end_date": "2025-11-19T00:00:00",
  "has_access": true
}
```

### 4. Test User Reactivation

**If user re-enables subscription before period ends:**
```bash
# In Stripe Dashboard or Customer Portal
# Click "Renew subscription"
```

Stripe fires `customer.subscription.updated` with:
```json
{
  "cancel_at_period_end": false
}
```

Backend updates:
```python
cancel_at_period_end = False  # No longer cancelling
```

App shows:
```
"Active - Monthly"  // Back to normal
```

---

## Webhook Events Required

**Ensure these events are enabled in Stripe Dashboard:**
- ✅ `customer.subscription.created`
- ✅ `customer.subscription.updated` ← **CRITICAL for cancellation**
- ✅ `customer.subscription.deleted`
- ✅ `invoice.payment_succeeded`
- ✅ `invoice.payment_failed`
- ✅ `checkout.session.completed`

---

## API Changes

### `/subscription/status` Response

**Before:**
```json
{
  "status": "active",
  "tier": "monthly",
  "trial_ends_at": null,
  "subscription_end_date": "2025-11-19T00:00:00",
  "has_access": true
}
```

**After:**
```json
{
  "status": "active",
  "tier": "monthly",
  "trial_ends_at": null,
  "subscription_end_date": "2025-11-19T00:00:00",
  "cancel_at_period_end": true,  ← NEW FIELD
  "has_access": true
}
```

---

## Production Deployment Checklist

- [ ] Run database migration in production Supabase
- [ ] Ensure `customer.subscription.updated` webhook is enabled in Stripe Live Mode
- [ ] Test cancellation flow with live Stripe account
- [ ] Verify webhook signing secret is correct in production environment
- [ ] Test re-activation flow (cancel, then renew before period ends)
- [ ] Monitor logs for webhook processing errors
- [ ] Test subscription ending at period end (status changes to canceled)

---

## Files Modified

### Backend
1. `backend/migrations/add_cancel_at_period_end_field.sql` - NEW
2. `backend/stripe_service.py` - Updated webhook handlers and status method
3. `backend/subscription_routes.py` - Updated response model

### Flutter
4. `flutter_app/lib/models/subscription.dart` - Added cancellation tracking
5. `flutter_app/lib/screens/settings_screen.dart` - Updated UI display

---

## Troubleshooting

**Issue: Cancellation not showing in app**
- Check if `customer.subscription.updated` webhook is enabled in Stripe
- Verify webhook is reaching backend (check logs)
- Confirm database field exists: `SELECT cancel_at_period_end FROM user_profiles LIMIT 1;`

**Issue: Access revoked immediately after cancellation**
- Check subscription status is still "active" in database
- Verify `has_access` logic in `stripe_service.py:475`
- Ensure `cancel_at_period_end` doesn't affect access logic

**Issue: Subscription not ending at period end**
- Check Stripe sends `customer.subscription.deleted` webhook at period end
- Verify webhook handler at `stripe_service.py:366` is working
- Check Stripe Dashboard → Events for webhook delivery

---

## Summary

This implementation ensures users who cancel subscriptions:
1. ✅ See clear "Cancels in X days" messaging
2. ✅ Retain access until period ends
3. ✅ Can reactivate before period ends
4. ✅ Automatically lose access when period expires
5. ✅ See consistent status across app and Stripe Dashboard
