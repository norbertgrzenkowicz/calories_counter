-- Custom foods table: user-defined food items with per-100g nutrition data
CREATE TABLE public.custom_foods (
  id BIGSERIAL PRIMARY KEY,
  uid UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  brand TEXT,
  calories_per_100g DECIMAL(8,2) NOT NULL CHECK (calories_per_100g >= 0),
  proteins_per_100g DECIMAL(8,2) NOT NULL DEFAULT 0 CHECK (proteins_per_100g >= 0),
  fats_per_100g DECIMAL(8,2) NOT NULL DEFAULT 0 CHECK (fats_per_100g >= 0),
  carbs_per_100g DECIMAL(8,2) NOT NULL DEFAULT 0 CHECK (carbs_per_100g >= 0),
  serving_unit TEXT NOT NULL DEFAULT 'g',
  serving_size_g DECIMAL(8,2),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast user food lookups
CREATE INDEX idx_custom_foods_uid ON public.custom_foods (uid);
CREATE INDEX idx_custom_foods_uid_name ON public.custom_foods (uid, name);

-- Row Level Security: users can only access their own foods
ALTER TABLE public.custom_foods ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own custom foods"
  ON public.custom_foods FOR SELECT
  USING (auth.uid() = uid);

CREATE POLICY "Users can insert own custom foods"
  ON public.custom_foods FOR INSERT
  WITH CHECK (auth.uid() = uid);

CREATE POLICY "Users can update own custom foods"
  ON public.custom_foods FOR UPDATE
  USING (auth.uid() = uid);

CREATE POLICY "Users can delete own custom foods"
  ON public.custom_foods FOR DELETE
  USING (auth.uid() = uid);
