-- Usage type ENUM
CREATE TYPE public.usage_type AS ENUM ('ai_input', 'ocr_scan');

-- Usage events table for tracking AI/OCR usage
CREATE TABLE public.usage_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  usage_type public.usage_type NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX idx_usage_events_user_id ON public.usage_events(user_id);
CREATE INDEX idx_usage_events_created_at ON public.usage_events(created_at);
CREATE INDEX idx_usage_events_user_type_date ON public.usage_events(user_id, usage_type, created_at);

-- RLS
ALTER TABLE public.usage_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own usage events"
  ON public.usage_events FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own usage events"
  ON public.usage_events FOR INSERT
  WITH CHECK (auth.uid() = user_id);
