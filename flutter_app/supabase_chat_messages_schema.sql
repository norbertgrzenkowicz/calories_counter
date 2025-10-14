-- Chat Messages table schema for Supabase
-- This table stores daily chat messages with AI nutrition analysis
-- Supports text, image, and audio message types

CREATE TABLE IF NOT EXISTS public.chat_messages (
    id BIGSERIAL PRIMARY KEY,
    uid UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    message_id TEXT NOT NULL UNIQUE, -- UUID from Flutter ChatMessage.id
    content TEXT NOT NULL, -- Text content or file storage path
    message_type VARCHAR(10) NOT NULL CHECK (message_type IN ('text', 'image', 'audio')),
    is_user BOOLEAN NOT NULL, -- true for user messages, false for AI responses
    nutrition_data JSONB, -- Nutrition data from AI (meal_name, calories, protein, carbs, fats)
    is_discarded BOOLEAN NOT NULL DEFAULT FALSE, -- true if message has been discarded
    is_added BOOLEAN NOT NULL DEFAULT FALSE, -- true if meal has been added to meals
    meal_name TEXT, -- Name of the meal (set when discarded)
    date DATE NOT NULL, -- Which day this chat belongs to (user's local date)
    timestamp TIMESTAMPTZ NOT NULL, -- Exact time message was created
    created_at TIMESTAMPTZ DEFAULT NOW() -- When row was inserted to DB
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_chat_messages_uid ON public.chat_messages(uid);
CREATE INDEX IF NOT EXISTS idx_chat_messages_date ON public.chat_messages(date);
CREATE INDEX IF NOT EXISTS idx_chat_messages_uid_date ON public.chat_messages(uid, date);
CREATE INDEX IF NOT EXISTS idx_chat_messages_message_id ON public.chat_messages(message_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_timestamp ON public.chat_messages(timestamp);

-- Enable Row Level Security (RLS)
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (for clean migration)
DROP POLICY IF EXISTS "Users can view their own chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can insert their own chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can update their own chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can delete their own chat messages" ON public.chat_messages;

-- RLS Policy: Users can only access their own chat messages
CREATE POLICY "Users can view their own chat messages"
    ON public.chat_messages
    FOR SELECT
    USING (auth.uid() = uid);

CREATE POLICY "Users can insert their own chat messages"
    ON public.chat_messages
    FOR INSERT
    WITH CHECK (auth.uid() = uid);

CREATE POLICY "Users can update their own chat messages"
    ON public.chat_messages
    FOR UPDATE
    USING (auth.uid() = uid);

CREATE POLICY "Users can delete their own chat messages"
    ON public.chat_messages
    FOR DELETE
    USING (auth.uid() = uid);

-- Grant necessary permissions
GRANT ALL ON public.chat_messages TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.chat_messages_id_seq TO authenticated;

-- Optional: Function to clean up old chat messages (if you ever want to add retention)
-- Commented out by default since user wants to keep everything forever
/*
CREATE OR REPLACE FUNCTION cleanup_old_chat_messages()
RETURNS void AS $$
BEGIN
    DELETE FROM public.chat_messages
    WHERE created_at < NOW() - INTERVAL '90 days';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
*/

-- ========== STORAGE BUCKET SETUP ==========
-- NOTE: Reusing existing 'meal-photos' bucket for chat media
--
-- Storage policies CANNOT be created via SQL Editor due to permissions.
-- You must add them manually via Supabase Dashboard:
--
-- 1. Go to: Storage → meal-photos → Policies
-- 2. Click "New Policy" for each operation (SELECT, INSERT, UPDATE, DELETE)
-- 3. Use these policy definitions:
--
-- Policy Name: "Users can view their own media"
-- Allowed Operation: SELECT
-- Target roles: authenticated
-- Policy definition:
-- bucket_id = 'meal-photos' AND (storage.foldername(name))[1] = auth.uid()::text
--
-- Policy Name: "Users can upload their own media"
-- Allowed Operation: INSERT
-- Target roles: authenticated
-- WITH CHECK expression:
-- bucket_id = 'meal-photos' AND (storage.foldername(name))[1] = auth.uid()::text
--
-- Policy Name: "Users can update their own media"
-- Allowed Operation: UPDATE
-- Target roles: authenticated
-- USING expression:
-- bucket_id = 'meal-photos' AND (storage.foldername(name))[1] = auth.uid()::text
--
-- Policy Name: "Users can delete their own media"
-- Allowed Operation: DELETE
-- Target roles: authenticated
-- USING expression:
-- bucket_id = 'meal-photos' AND (storage.foldername(name))[1] = auth.uid()::text
