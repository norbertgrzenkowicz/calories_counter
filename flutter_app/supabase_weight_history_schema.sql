-- Weight History table schema for tracking weight changes over time
-- This table enables monitoring progress and implementing two-phase weight loss kinetics

CREATE TABLE IF NOT EXISTS public.weight_history (
    id BIGSERIAL PRIMARY KEY,
    uid UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Weight Data
    weight_kg DECIMAL(5,2) NOT NULL CHECK (weight_kg > 0 AND weight_kg <= 500),
    recorded_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Context Information
    measurement_time VARCHAR(20) DEFAULT 'morning' CHECK (measurement_time IN ('morning', 'afternoon', 'evening')),
    notes TEXT, -- Optional notes about circumstances (after meal, workout, etc.)
    
    -- Goal Tracking
    goal_at_time VARCHAR(20) CHECK (goal_at_time IN ('weight_loss', 'weight_gain', 'maintaining', 'hypertrophy')),
    days_since_goal_start INTEGER DEFAULT 0, -- Days since current goal started
    
    -- Calculated Fields (for performance)
    weight_change_kg DECIMAL(5,2), -- Change from previous entry
    weekly_average_kg DECIMAL(5,2), -- 7-day rolling average
    monthly_average_kg DECIMAL(5,2), -- 30-day rolling average
    
    -- Weight Loss Phase Tracking (for two-phase kinetics)
    is_initial_phase BOOLEAN DEFAULT TRUE, -- First 4-6 weeks have different energy content
    phase VARCHAR(20) DEFAULT 'initial' CHECK (phase IN ('initial', 'steady_state')), -- Track which phase user is in
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Ensure no duplicate entries per user per date
    UNIQUE(uid, recorded_date)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_weight_history_uid ON public.weight_history(uid);
CREATE INDEX IF NOT EXISTS idx_weight_history_date ON public.weight_history(recorded_date);
CREATE INDEX IF NOT EXISTS idx_weight_history_uid_date ON public.weight_history(uid, recorded_date);
CREATE INDEX IF NOT EXISTS idx_weight_history_goal ON public.weight_history(uid, goal_at_time);
CREATE INDEX IF NOT EXISTS idx_weight_history_phase ON public.weight_history(uid, phase);

-- Enable Row Level Security (RLS)
ALTER TABLE public.weight_history ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view their own weight history" ON public.weight_history;
DROP POLICY IF EXISTS "Users can insert their own weight history" ON public.weight_history;
DROP POLICY IF EXISTS "Users can update their own weight history" ON public.weight_history;
DROP POLICY IF EXISTS "Users can delete their own weight history" ON public.weight_history;

-- RLS Policies: Users can only access their own weight history
CREATE POLICY "Users can view their own weight history" 
    ON public.weight_history 
    FOR SELECT 
    USING (auth.uid() = uid);

CREATE POLICY "Users can insert their own weight history" 
    ON public.weight_history 
    FOR INSERT 
    WITH CHECK (auth.uid() = uid);

CREATE POLICY "Users can update their own weight history" 
    ON public.weight_history 
    FOR UPDATE 
    USING (auth.uid() = uid);

CREATE POLICY "Users can delete their own weight history" 
    ON public.weight_history 
    FOR DELETE 
    USING (auth.uid() = uid);

-- Grant necessary permissions
GRANT ALL ON public.weight_history TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.weight_history_id_seq TO authenticated;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_weight_history_updated_at 
    BEFORE UPDATE ON public.weight_history 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate weight change and averages when inserting new weight entry
CREATE OR REPLACE FUNCTION calculate_weight_metrics()
RETURNS TRIGGER AS $$
DECLARE
    prev_weight DECIMAL(5,2);
    seven_day_avg DECIMAL(5,2);
    thirty_day_avg DECIMAL(5,2);
    goal_start_date DATE;
    days_since_start INTEGER;
BEGIN
    -- Get previous weight for change calculation
    SELECT weight_kg INTO prev_weight
    FROM public.weight_history 
    WHERE uid = NEW.uid AND recorded_date < NEW.recorded_date
    ORDER BY recorded_date DESC 
    LIMIT 1;
    
    -- Calculate weight change
    IF prev_weight IS NOT NULL THEN
        NEW.weight_change_kg = NEW.weight_kg - prev_weight;
    END IF;
    
    -- Calculate 7-day rolling average
    SELECT AVG(weight_kg) INTO seven_day_avg
    FROM public.weight_history 
    WHERE uid = NEW.uid 
        AND recorded_date >= NEW.recorded_date - INTERVAL '7 days'
        AND recorded_date <= NEW.recorded_date;
    NEW.weekly_average_kg = seven_day_avg;
    
    -- Calculate 30-day rolling average
    SELECT AVG(weight_kg) INTO thirty_day_avg
    FROM public.weight_history 
    WHERE uid = NEW.uid 
        AND recorded_date >= NEW.recorded_date - INTERVAL '30 days'
        AND recorded_date <= NEW.recorded_date;
    NEW.monthly_average_kg = thirty_day_avg;
    
    -- Determine phase based on goal start date
    SELECT 
        COALESCE(weight_loss_start_date, created_at::date),
        (NEW.recorded_date - COALESCE(weight_loss_start_date, created_at::date))::integer
    INTO goal_start_date, days_since_start
    FROM public.user_profiles 
    WHERE uid = NEW.uid;
    
    IF days_since_start IS NOT NULL THEN
        NEW.days_since_goal_start = days_since_start;
        
        -- Two-phase weight loss kinetics: initial phase for first 28-42 days
        IF days_since_start <= 28 THEN
            NEW.is_initial_phase = TRUE;
            NEW.phase = 'initial';
        ELSE
            NEW.is_initial_phase = FALSE;
            NEW.phase = 'steady_state';
        END IF;
    END IF;
    
    -- Set goal at time from user profile
    SELECT goal INTO NEW.goal_at_time
    FROM public.user_profiles 
    WHERE uid = NEW.uid;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to calculate metrics on insert/update
CREATE TRIGGER calculate_weight_metrics_trigger
    BEFORE INSERT OR UPDATE ON public.weight_history
    FOR EACH ROW
    EXECUTE FUNCTION calculate_weight_metrics();