-- Waitlist table schema for Supabase
-- Collects emails for pre-launch / feature waitlists

CREATE TABLE IF NOT EXISTS public.waitlist (
    id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    email TEXT NOT NULL,
    CONSTRAINT waitlist_email_key UNIQUE (email)
);

-- Enable Row Level Security
ALTER TABLE public.waitlist ENABLE ROW LEVEL SECURITY;

-- Grant permissions (anon can insert for sign-up forms)
GRANT ALL ON TABLE public.waitlist TO anon;
GRANT ALL ON TABLE public.waitlist TO authenticated;
GRANT ALL ON TABLE public.waitlist TO service_role;
