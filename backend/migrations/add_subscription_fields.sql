-- Migration: Add subscription fields to user_profiles table
-- Run this in Supabase SQL Editor

-- Add subscription-related columns
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS subscription_status VARCHAR(50) DEFAULT 'free',
ADD COLUMN IF NOT EXISTS subscription_tier VARCHAR(50),
ADD COLUMN IF NOT EXISTS stripe_customer_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS stripe_subscription_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS subscription_start_date TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS trial_ends_at TIMESTAMP WITH TIME ZONE;

-- Add index for faster subscription status queries
CREATE INDEX IF NOT EXISTS idx_user_profiles_subscription_status
ON user_profiles(subscription_status);

-- Add index for Stripe customer lookups
CREATE INDEX IF NOT EXISTS idx_user_profiles_stripe_customer_id
ON user_profiles(stripe_customer_id);

-- Add index for Stripe subscription lookups
CREATE INDEX IF NOT EXISTS idx_user_profiles_stripe_subscription_id
ON user_profiles(stripe_subscription_id);

-- Add comment for documentation
COMMENT ON COLUMN user_profiles.subscription_status IS
'Subscription status: free, trialing, active, past_due, canceled';

COMMENT ON COLUMN user_profiles.subscription_tier IS
'Subscription tier: monthly, yearly';

COMMENT ON COLUMN user_profiles.stripe_customer_id IS
'Stripe customer ID for this user';

COMMENT ON COLUMN user_profiles.stripe_subscription_id IS
'Active Stripe subscription ID';

COMMENT ON COLUMN user_profiles.trial_ends_at IS
'When the free trial ends (if applicable)';
