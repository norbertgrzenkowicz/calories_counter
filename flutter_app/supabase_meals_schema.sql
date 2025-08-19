-- Meals table schema for Supabase
-- This table stores meal information for users with nutrition tracking

CREATE TABLE IF NOT EXISTS public.meals (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    uid UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    calories INTEGER NOT NULL CHECK (calories >= 0),
    carbs DECIMAL(8,2) NOT NULL CHECK (carbs >= 0),
    proteins DECIMAL(8,2) NOT NULL CHECK (proteins >= 0),
    fats DECIMAL(8,2) NOT NULL CHECK (fats >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    photo_url TEXT,
    date TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_meals_uid ON public.meals(uid);
CREATE INDEX IF NOT EXISTS idx_meals_date ON public.meals(date);
CREATE INDEX IF NOT EXISTS idx_meals_uid_date ON public.meals(uid, date);

-- Enable Row Level Security (RLS)
ALTER TABLE public.meals ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access their own meals
CREATE POLICY "Users can view their own meals" 
    ON public.meals 
    FOR SELECT 
    USING (auth.uid() = uid);

CREATE POLICY "Users can insert their own meals" 
    ON public.meals 
    FOR INSERT 
    WITH CHECK (auth.uid() = uid);

CREATE POLICY "Users can update their own meals" 
    ON public.meals 
    FOR UPDATE 
    USING (auth.uid() = uid);

CREATE POLICY "Users can delete their own meals" 
    ON public.meals 
    FOR DELETE 
    USING (auth.uid() = uid);

-- Grant necessary permissions
GRANT ALL ON public.meals TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.meals_id_seq TO authenticated;