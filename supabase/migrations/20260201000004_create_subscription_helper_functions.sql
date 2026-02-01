-- Helper: Get monthly transaction count for a user
CREATE OR REPLACE FUNCTION public.get_monthly_transaction_count(
  p_user_id UUID,
  p_year INTEGER,
  p_month INTEGER
)
RETURNS INTEGER
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT COUNT(*)::INTEGER
  FROM public.transactions
  WHERE user_id = p_user_id
    AND deleted_at IS NULL
    AND EXTRACT(YEAR FROM date) = p_year
    AND EXTRACT(MONTH FROM date) = p_month;
$$;

-- Helper: Get monthly usage count (AI/OCR)
CREATE OR REPLACE FUNCTION public.get_monthly_usage_count(
  p_user_id UUID,
  p_usage_type public.usage_type,
  p_year INTEGER,
  p_month INTEGER
)
RETURNS INTEGER
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT COUNT(*)::INTEGER
  FROM public.usage_events
  WHERE user_id = p_user_id
    AND usage_type = p_usage_type
    AND EXTRACT(YEAR FROM created_at) = p_year
    AND EXTRACT(MONTH FROM created_at) = p_month;
$$;

-- Helper: Get active account count
CREATE OR REPLACE FUNCTION public.get_account_count(p_user_id UUID)
RETURNS INTEGER
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT COUNT(*)::INTEGER
  FROM public.accounts
  WHERE user_id = p_user_id
    AND is_archived = false;
$$;

-- Helper: Check premium access
CREATE OR REPLACE FUNCTION public.has_premium_access(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.subscriptions
    WHERE user_id = p_user_id
      AND status IN ('trialing', 'active')
  );
$$;
