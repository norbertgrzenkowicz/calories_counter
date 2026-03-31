-- =============================================================================
-- Yapper DB Schema Fixes
-- Run this in Supabase SQL Editor (Dashboard → SQL Editor)
-- Execute all sections in order.
-- =============================================================================


-- =============================================================================
-- C1/C2: Revoke clean_old_cached_products from anon + authenticated
-- Any user could call this and wipe the shared product cache.
-- Only service_role (backend/cron) should be able to call it.
-- =============================================================================

REVOKE EXECUTE ON FUNCTION public.clean_old_cached_products() FROM anon;
REVOKE EXECUTE ON FUNCTION public.clean_old_cached_products() FROM authenticated;


-- =============================================================================
-- C4: Drop broken handle_updated_at() function
-- Has RETURN NOW; instead of RETURN NEW; — would corrupt rows if used in a trigger.
-- Not referenced by any trigger, safe to drop.
-- =============================================================================

DROP FUNCTION IF EXISTS public.handle_updated_at();


-- NOTE: handle_user_update() is kept — it is called by the trigger
-- on_auth_user_updated on auth.users (auth schema, not visible in public dump).
-- It syncs email/name/avatar changes from auth.users → public.users.


-- =============================================================================
-- H5: Revoke trigger functions from anon
-- Triggers run under the postgres owner; anon access is not needed.
-- =============================================================================

REVOKE EXECUTE ON FUNCTION public.calculate_weight_metrics() FROM anon;
REVOKE EXECUTE ON FUNCTION public.update_updated_at_column() FROM anon;
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM anon;


-- =============================================================================
-- C6: Add FK — chat_messages.meal_id → meals.id ON DELETE SET NULL
-- Step 1: nullify any dangling meal_ids (meals that no longer exist).
-- Step 2: enforce referential integrity going forward.
-- =============================================================================

UPDATE public.chat_messages
SET meal_id = NULL
WHERE meal_id IS NOT NULL
  AND meal_id NOT IN (SELECT id FROM public.meals);

ALTER TABLE public.chat_messages
  ADD CONSTRAINT chat_messages_meal_id_fkey
  FOREIGN KEY (meal_id) REFERENCES public.meals(id) ON DELETE SET NULL;


-- =============================================================================
-- C5: Change meals.date from TIMESTAMPTZ to DATE
-- The app sends local date; TIMESTAMPTZ caused UTC-midnight shift bugs.
-- Existing values are truncated to UTC date (acceptable at current scale).
-- Flutter app already updated to send date-only strings.
-- =============================================================================

ALTER TABLE public.meals
  ALTER COLUMN date TYPE DATE USING (date AT TIME ZONE 'UTC')::date;


-- =============================================================================
-- C3: Drop weight_history trigger + computed columns
-- The trigger had a correctness bug: only recalculated the inserted row,
-- leaving subsequent rows stale when backfilling older dates.
-- These metrics are now computed client-side in profile_service.dart.
-- =============================================================================

DROP TRIGGER IF EXISTS calculate_weight_metrics_trigger ON public.weight_history;
DROP FUNCTION IF EXISTS public.calculate_weight_metrics();

ALTER TABLE public.weight_history
  DROP COLUMN IF EXISTS weight_change_kg,
  DROP COLUMN IF EXISTS weekly_average_kg,
  DROP COLUMN IF EXISTS monthly_average_kg,
  DROP COLUMN IF EXISTS days_since_goal_start;


-- =============================================================================
-- M4: Drop is_initial_phase column from weight_history
-- Redundant with the phase column ('initial' / 'steady_state').
-- Flutter app updated to use entry.phase == 'initial' everywhere.
-- =============================================================================

ALTER TABLE public.weight_history
  DROP COLUMN IF EXISTS is_initial_phase;


-- =============================================================================
-- H1: Drop bmr_calories + tdee_calories from user_profiles
-- These are always derivable from height/weight/age/gender/activity_level.
-- They were written on every profile save, causing silent drift.
-- Flutter app now calls profile.calculateBMR()/calculateTDEE() directly.
-- NOTE: target_calories, target_protein_g, target_carbs_g, target_fats_g
--       are KEPT — they store user-adjusted targets from the calorie popup.
-- =============================================================================

ALTER TABLE public.user_profiles
  DROP COLUMN IF EXISTS bmr_calories,
  DROP COLUMN IF EXISTS tdee_calories;


-- =============================================================================
-- M5: Add CHECK constraints on subscription fields
-- DB now enforces the values documented in column comments.
-- =============================================================================

ALTER TABLE public.user_profiles
  ADD CONSTRAINT subscription_status_check
  CHECK (subscription_status IN ('free', 'trialing', 'active', 'past_due', 'canceled'));

ALTER TABLE public.user_profiles
  ADD CONSTRAINT subscription_tier_check
  CHECK (subscription_tier IS NULL OR subscription_tier IN ('monthly', 'yearly'));


-- =============================================================================
-- Redundant index cleanup (Low priority but free wins)
-- idx_cached_products_barcode  → duplicate of PK index on barcode
-- idx_chat_messages_message_id → duplicate of UNIQUE constraint index
-- idx_user_profiles_goal       → no query filters by goal
-- idx_user_profiles_updated_at → no query orders by updated_at
-- =============================================================================

DROP INDEX IF EXISTS public.idx_cached_products_barcode;
DROP INDEX IF EXISTS public.idx_chat_messages_message_id;
DROP INDEX IF EXISTS public.idx_user_profiles_goal;
DROP INDEX IF EXISTS public.idx_user_profiles_updated_at;
