-- Enhanced User Profiles table schema for comprehensive calorie tracking
-- This table stores detailed user profile information needed for accurate BMR/TDEE calculations

-- Drop existing table if needed for clean migration
-- DROP TABLE IF EXISTS public.user_profiles CASCADE;

CREATE TABLE IF NOT EXISTS public.user_profiles (
    id BIGSERIAL PRIMARY KEY,
    uid UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Basic Profile Information
    full_name TEXT,
    email TEXT,
    date_of_birth DATE, -- More precise than just age for calculations
    
    -- Physical Characteristics (required for BMR calculations)
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('male', 'female')), -- Critical for BMR formula
    height_cm DECIMAL(5,2) NOT NULL CHECK (height_cm > 0 AND height_cm <= 300), -- Height in centimeters
    current_weight_kg DECIMAL(5,2) NOT NULL CHECK (current_weight_kg > 0 AND current_weight_kg <= 500), -- Current weight
    target_weight_kg DECIMAL(5,2) CHECK (target_weight_kg > 0 AND target_weight_kg <= 500), -- Goal weight
    
    -- Goals and Activity
    goal VARCHAR(20) NOT NULL DEFAULT 'maintaining' CHECK (goal IN ('weight_loss', 'weight_gain', 'maintaining', 'hypertrophy')),
    activity_level DECIMAL(3,2) NOT NULL DEFAULT 1.2 CHECK (activity_level >= 1.2 AND activity_level <= 2.4), -- PAL value
    
    -- Calculated Values (stored for performance)
    bmr_calories INTEGER, -- Basal Metabolic Rate
    tdee_calories INTEGER, -- Total Daily Energy Expenditure
    target_calories INTEGER, -- Daily calorie target based on goals
    target_protein_g DECIMAL(6,2), -- Daily protein target in grams
    target_carbs_g DECIMAL(6,2), -- Daily carbs target in grams
    target_fats_g DECIMAL(6,2), -- Daily fats target in grams
    
    -- Weight Loss Tracking
    weight_loss_start_date DATE, -- When weight loss journey started
    initial_weight_kg DECIMAL(5,2), -- Starting weight for current goal
    weekly_weight_loss_target DECIMAL(4,2) DEFAULT 0.5 CHECK (weekly_weight_loss_target >= 0 AND weekly_weight_loss_target <= 2.0), -- kg per week
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Ensure one profile per user
    UNIQUE(uid)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_uid ON public.user_profiles(uid);
CREATE INDEX IF NOT EXISTS idx_user_profiles_goal ON public.user_profiles(goal);
CREATE INDEX IF NOT EXISTS idx_user_profiles_updated_at ON public.user_profiles(updated_at);

-- Enable Row Level Security (RLS)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can delete their own profile" ON public.user_profiles;

-- RLS Policies: Users can only access their own profile
CREATE POLICY "Users can view their own profile" 
    ON public.user_profiles 
    FOR SELECT 
    USING (auth.uid() = uid);

CREATE POLICY "Users can insert their own profile" 
    ON public.user_profiles 
    FOR INSERT 
    WITH CHECK (auth.uid() = uid);

CREATE POLICY "Users can update their own profile" 
    ON public.user_profiles 
    FOR UPDATE 
    USING (auth.uid() = uid);

CREATE POLICY "Users can delete their own profile" 
    ON public.user_profiles 
    FOR DELETE 
    USING (auth.uid() = uid);

-- Grant necessary permissions
GRANT ALL ON public.user_profiles TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.user_profiles_id_seq TO authenticated;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop existing trigger if it exists, then create it
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON public.user_profiles;
CREATE TRIGGER update_user_profiles_updated_at 
    BEFORE UPDATE ON public.user_profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();