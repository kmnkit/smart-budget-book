-- Migration: Fix authorization checks in subscription helper functions
-- Created: 2026-02-01
-- Description: Add auth.uid() verification to SECURITY DEFINER functions to prevent unauthorized access

-- Fix get_monthly_transaction_count
CREATE OR REPLACE FUNCTION public.get_monthly_transaction_count(
  p_user_id UUID,
  p_year INTEGER,
  p_month INTEGER
) RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Verify caller is authorized to access this user's data
  IF p_user_id != auth.uid() THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  RETURN (
    SELECT COUNT(*)::INTEGER
    FROM transactions
    WHERE user_id = p_user_id
      AND deleted_at IS NULL
      AND EXTRACT(YEAR FROM date) = p_year
      AND EXTRACT(MONTH FROM date) = p_month
  );
END;
$$;

-- Fix get_monthly_usage_count
CREATE OR REPLACE FUNCTION public.get_monthly_usage_count(
  p_user_id UUID,
  p_usage_type public.usage_type,
  p_year INTEGER,
  p_month INTEGER
) RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Verify caller is authorized to access this user's data
  IF p_user_id != auth.uid() THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  RETURN (
    SELECT COUNT(*)::INTEGER
    FROM ai_usage_log
    WHERE user_id = p_user_id
      AND usage_type = p_usage_type
      AND EXTRACT(YEAR FROM created_at) = p_year
      AND EXTRACT(MONTH FROM created_at) = p_month
  );
END;
$$;

-- Fix get_account_count
CREATE OR REPLACE FUNCTION public.get_account_count(
  p_user_id UUID
) RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Verify caller is authorized to access this user's data
  IF p_user_id != auth.uid() THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  RETURN (
    SELECT COUNT(*)::INTEGER
    FROM accounts
    WHERE user_id = p_user_id
      AND deleted_at IS NULL
  );
END;
$$;

-- Fix has_premium_access
CREATE OR REPLACE FUNCTION public.has_premium_access(
  p_user_id UUID
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Verify caller is authorized to access this user's data
  IF p_user_id != auth.uid() THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  RETURN (
    SELECT EXISTS (
      SELECT 1
      FROM subscriptions
      WHERE user_id = p_user_id
        AND status IN ('active', 'trialing')
        AND (expires_at IS NULL OR expires_at > NOW())
    )
  );
END;
$$;

-- Add comments
COMMENT ON FUNCTION public.get_monthly_transaction_count(UUID, INTEGER, INTEGER) IS
  'Returns transaction count for a user in a specific month. Requires auth.uid() match.';
COMMENT ON FUNCTION public.get_monthly_usage_count(UUID, public.usage_type, INTEGER, INTEGER) IS
  'Returns AI usage count for a user in a specific month. Requires auth.uid() match.';
COMMENT ON FUNCTION public.get_account_count(UUID) IS
  'Returns active account count for a user. Requires auth.uid() match.';
COMMENT ON FUNCTION public.has_premium_access(UUID) IS
  'Checks if user has active premium subscription. Requires auth.uid() match.';
