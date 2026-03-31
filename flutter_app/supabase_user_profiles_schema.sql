-- User Profiles table — canonical schema
-- Includes all subscription fields (previously in backend/migrations/).
-- BMR/TDEE dropped: computed in-app from height/weight/age/gender/activity_level.
-- target_calories/protein/carbs/fats kept: store user-adjusted targets.

CREATE TABLE IF NOT EXISTS public.user_profiles (
    id BIGSERIAL PRIMARY KEY,
    uid UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Basic Profile Information
    full_name TEXT,
    email TEXT,
    date_of_birth DATE,

    -- Physical Characteristics (required for BMR calculations)
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('male', 'female')),
    height_cm DECIMAL(5,2) NOT NULL CHECK (height_cm > 0 AND height_cm <= 300),
    current_weight_kg DECIMAL(5,2) NOT NULL CHECK (current_weight_kg > 0 AND current_weight_kg <= 500),
    target_weight_kg DECIMAL(5,2) CHECK (target_weight_kg > 0 AND target_weight_kg <= 500),

    -- Goals and Activity
    goal VARCHAR(20) NOT NULL DEFAULT 'maintaining' CHECK (goal IN ('weight_loss', 'weight_gain', 'maintaining', 'hypertrophy')),
    activity_level DECIMAL(3,2) NOT NULL DEFAULT 1.2 CHECK (activity_level >= 1.2 AND activity_level <= 2.4),

    -- User-adjusted calorie/macro targets (persisted from calorie adjustment popup)
    -- Falls back to formula values when NULL. Computed in-app, not stored for BMR/TDEE.
    target_calories INTEGER,
    target_protein_g DECIMAL(6,2),
    target_carbs_g DECIMAL(6,2),
    target_fats_g DECIMAL(6,2),

    -- Weight Loss Tracking
    weight_loss_start_date DATE,
    initial_weight_kg DECIMAL(5,2),
    weekly_weight_loss_target DECIMAL(4,2) DEFAULT 0.5 CHECK (weekly_weight_loss_target >= 0 AND weekly_weight_loss_target <= 2.0),

    -- Subscription fields
    subscription_status VARCHAR(50) DEFAULT 'free'
        CONSTRAINT subscription_status_check CHECK (subscription_status IN ('free', 'trialing', 'active', 'past_due', 'canceled')),
    subscription_tier VARCHAR(50)
        CONSTRAINT subscription_tier_check CHECK (subscription_tier IS NULL OR subscription_tier IN ('monthly', 'yearly')),
    stripe_customer_id VARCHAR(255),
    stripe_subscription_id VARCHAR(255),
    subscription_start_date TIMESTAMPTZ,
    subscription_end_date TIMESTAMPTZ,
    trial_ends_at TIMESTAMPTZ,
    cancel_at_period_end BOOLEAN DEFAULT FALSE,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(uid)
);

COMMENT ON COLUMN public.user_profiles.subscription_status IS 'Subscription status: free, trialing, active, past_due, canceled';
COMMENT ON COLUMN public.user_profiles.subscription_tier IS 'Subscription tier: monthly, yearly';
COMMENT ON COLUMN public.user_profiles.stripe_customer_id IS 'Stripe customer ID for this user';
COMMENT ON COLUMN public.user_profiles.stripe_subscription_id IS 'Active Stripe subscription ID';
COMMENT ON COLUMN public.user_profiles.trial_ends_at IS 'When the free trial ends (if applicable)';
COMMENT ON COLUMN public.user_profiles.cancel_at_period_end IS 'True if subscription cancels at end of current billing period. User retains access until subscription_end_date.';

-- Indexes — only what queries actually use
CREATE INDEX IF NOT EXISTS idx_user_profiles_uid ON public.user_profiles(uid);
CREATE INDEX IF NOT EXISTS idx_user_profiles_subscription_status ON public.user_profiles(subscription_status);

-- Enable Row Level Security
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can delete their own profile" ON public.user_profiles;

CREATE POLICY "Users can view their own profile"
    ON public.user_profiles FOR SELECT USING (auth.uid() = uid);
CREATE POLICY "Users can insert their own profile"
    ON public.user_profiles FOR INSERT WITH CHECK (auth.uid() = uid);
CREATE POLICY "Users can update their own profile"
    ON public.user_profiles FOR UPDATE USING (auth.uid() = uid);
CREATE POLICY "Users can delete their own profile"
    ON public.user_profiles FOR DELETE USING (auth.uid() = uid);

GRANT ALL ON public.user_profiles TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.user_profiles_id_seq TO authenticated;

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON public.user_profiles;
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
