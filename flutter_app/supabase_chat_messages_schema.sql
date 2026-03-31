-- Chat Messages table — canonical schema
-- Includes meal_id + is_deleted (previously in flutter_app/migrations/).
-- meal_id has FK constraint → meals.id ON DELETE SET NULL.
-- date column is DATE (user local date), not TIMESTAMPTZ.

CREATE TABLE IF NOT EXISTS public.chat_messages (
    id BIGSERIAL PRIMARY KEY,
    uid UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    message_id TEXT NOT NULL UNIQUE, -- UUID from Flutter ChatMessage.id
    content TEXT NOT NULL,           -- Text content or file storage path
    message_type VARCHAR(10) NOT NULL CHECK (message_type IN ('text', 'image', 'audio')),
    is_user BOOLEAN NOT NULL,
    nutrition_data JSONB,
    is_discarded BOOLEAN NOT NULL DEFAULT FALSE,
    is_added BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT check_not_discarded_and_added CHECK (NOT (is_discarded AND is_added)),
    meal_name TEXT,                  -- Cached meal name (also in nutrition_data JSONB)
    meal_id BIGINT REFERENCES public.meals(id) ON DELETE SET NULL,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE, -- true when the linked meal was deleted
    is_edited BOOLEAN NOT NULL DEFAULT FALSE,
    date DATE NOT NULL,              -- User's local date (which day this chat belongs to)
    timestamp TIMESTAMPTZ NOT NULL,  -- Exact creation time
    created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON COLUMN public.chat_messages.meal_id IS 'FK → meals.id; set to NULL when the meal is deleted';
COMMENT ON COLUMN public.chat_messages.is_deleted IS 'True if the linked meal has been deleted';

-- Indexes
CREATE INDEX IF NOT EXISTS idx_chat_messages_uid ON public.chat_messages(uid);
CREATE INDEX IF NOT EXISTS idx_chat_messages_date ON public.chat_messages(date);
CREATE INDEX IF NOT EXISTS idx_chat_messages_uid_date ON public.chat_messages(uid, date);
CREATE INDEX IF NOT EXISTS idx_chat_messages_meal_id ON public.chat_messages(meal_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_timestamp ON public.chat_messages(timestamp);
-- NOTE: idx_chat_messages_message_id is intentionally omitted — UNIQUE already creates an index.

-- Enable Row Level Security
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can insert their own chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can update their own chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can delete their own chat messages" ON public.chat_messages;

CREATE POLICY "Users can view their own chat messages"
    ON public.chat_messages FOR SELECT USING (auth.uid() = uid);
CREATE POLICY "Users can insert their own chat messages"
    ON public.chat_messages FOR INSERT WITH CHECK (auth.uid() = uid);
CREATE POLICY "Users can update their own chat messages"
    ON public.chat_messages FOR UPDATE USING (auth.uid() = uid);
CREATE POLICY "Users can delete their own chat messages"
    ON public.chat_messages FOR DELETE USING (auth.uid() = uid);

GRANT ALL ON public.chat_messages TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.chat_messages_id_seq TO authenticated;
