-- Add subscription_tier to profiles for fast lookup (denormalized cache)
ALTER TABLE public.profiles
  ADD COLUMN subscription_tier public.subscription_tier NOT NULL DEFAULT 'free';
