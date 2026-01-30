-- Fix get_monthly_summary function: 3 bugs
-- Bug 1: JOIN condition - ca was joining on da.id instead of ca.id
-- Bug 2: SELECT column order mismatch with RETURNS TABLE (income/expense swapped)
-- Bug 3: Income calculation logic reversed (should be credit account based)

CREATE OR REPLACE FUNCTION public.get_monthly_summary(
  p_user_id UUID,
  p_year INTEGER,
  p_month INTEGER
)
RETURNS TABLE (
  total_income BIGINT,
  total_expense BIGINT,
  net_income BIGINT,
  transaction_count INTEGER
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    COALESCE(SUM(CASE WHEN ca.type = 'income' THEN t.amount ELSE 0 END), 0)::BIGINT AS total_income,
    COALESCE(SUM(CASE WHEN da.type = 'expense' THEN t.amount ELSE 0 END), 0)::BIGINT AS total_expense,
    (COALESCE(SUM(CASE WHEN ca.type = 'income' THEN t.amount ELSE 0 END), 0)
     - COALESCE(SUM(CASE WHEN da.type = 'expense' THEN t.amount ELSE 0 END), 0))::BIGINT AS net_income,
    COUNT(*)::INTEGER AS transaction_count
  FROM public.transactions t
  JOIN public.accounts da ON t.debit_account_id = da.id
  JOIN public.accounts ca ON t.credit_account_id = ca.id
  WHERE t.user_id = p_user_id
    AND t.deleted_at IS NULL
    AND EXTRACT(YEAR FROM t.date) = p_year
    AND EXTRACT(MONTH FROM t.date) = p_month;
$$;
