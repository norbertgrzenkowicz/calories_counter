-- Cached Products table schema for Supabase
-- This table caches product information from OpenFoodFacts for better performance

CREATE TABLE IF NOT EXISTS public.cached_products (
    barcode TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    brand TEXT,
    calories_per_100g INTEGER,
    protein_per_100g DECIMAL(8,2),
    carbs_per_100g DECIMAL(8,2),
    fat_per_100g DECIMAL(8,2),
    fiber_per_100g DECIMAL(8,2),
    sugar_per_100g DECIMAL(8,2),
    sodium_per_100g DECIMAL(8,2),
    serving_size TEXT,
    serving_quantity DECIMAL(8,2),
    cached_at TIMESTAMPTZ DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_cached_products_barcode ON public.cached_products(barcode);
CREATE INDEX IF NOT EXISTS idx_cached_products_user_id ON public.cached_products(user_id);
CREATE INDEX IF NOT EXISTS idx_cached_products_cached_at ON public.cached_products(cached_at);

-- Enable Row Level Security (RLS)
ALTER TABLE public.cached_products ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can access products they've cached and public cache entries
CREATE POLICY "Users can view their own cached products" 
    ON public.cached_products 
    FOR SELECT 
    USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can insert their own cached products" 
    ON public.cached_products 
    FOR INSERT 
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can update their own cached products" 
    ON public.cached_products 
    FOR UPDATE 
    USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can delete their own cached products" 
    ON public.cached_products 
    FOR DELETE 
    USING (auth.uid() = user_id OR user_id IS NULL);

-- Grant necessary permissions
GRANT ALL ON public.cached_products TO authenticated;

-- Function to clean up old cached products (7 days old)
CREATE OR REPLACE FUNCTION clean_old_cached_products()
RETURNS void AS $$
BEGIN
    DELETE FROM public.cached_products 
    WHERE cached_at < NOW() - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission on the cleanup function
GRANT EXECUTE ON FUNCTION clean_old_cached_products() TO authenticated;