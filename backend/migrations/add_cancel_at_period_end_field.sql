-- Migration: Add cancel_at_period_end field to track pending cancellations
-- Run this in Supabase SQL Editor

-- Add cancel_at_period_end column to track if subscription will auto-cancel
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS cancel_at_period_end BOOLEAN DEFAULT FALSE;

-- Add comment for documentation
COMMENT ON COLUMN user_profiles.cancel_at_period_end IS
'True if subscription is set to cancel at the end of current billing period. User retains access until subscription_end_date.';
