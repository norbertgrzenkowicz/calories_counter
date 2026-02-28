-- Migration: Add meal tracking fields to chat_messages table
-- This migration adds meal_id and is_deleted fields to support reactive meal deletion tracking

-- Add meal_id column to track which meal was added from a chat message
ALTER TABLE public.chat_messages
ADD COLUMN IF NOT EXISTS meal_id BIGINT;

-- Add is_deleted column to track if the associated meal has been deleted
ALTER TABLE public.chat_messages
ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN NOT NULL DEFAULT FALSE;

-- Add index on meal_id for faster lookups when syncing deletion states
CREATE INDEX IF NOT EXISTS idx_chat_messages_meal_id ON public.chat_messages(meal_id);

-- Optional: Add comment to explain the relationship
COMMENT ON COLUMN public.chat_messages.meal_id IS 'Foreign key reference to meals.id for tracking meal deletions';
COMMENT ON COLUMN public.chat_messages.is_deleted IS 'True if the associated meal has been deleted from meals table';
