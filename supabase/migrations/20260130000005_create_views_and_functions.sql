-- Account balances VIEW
-- Balance calculation differs by account type:
-- Asset/Expense: initial_balance + SUM(debits) - SUM(credits)
-- Liability/Income/Equity: initial_balance + SUM(credits) - SUM(debits)

CREATE OR REPLACE VIEW public.account_balances AS
SELECT
  a.id,
  a.user_id,
  a.name,
  a.type,
  a.category,
  a.icon,
  a.color,
  a.currency,
  a.initial_balance,
  a.is_archived,
  a.display_order,
  CASE
    WHEN a.type IN ('asset', 'expense') THEN
      a.initial_balance
      + COALESCE((SELECT SUM(t.amount) FROM public.transactions t WHERE t.debit_account_id = a.id AND t.deleted_at IS NULL), 0)
      - COALESCE((SELECT SUM(t.amount) FROM public.transactions t WHERE t.credit_account_id = a.id AND t.deleted_at IS NULL), 0)
    ELSE
      a.initial_balance
      + COALESCE((SELECT SUM(t.amount) FROM public.transactions t WHERE t.credit_account_id = a.id AND t.deleted_at IS NULL), 0)
      - COALESCE((SELECT SUM(t.amount) FROM public.transactions t WHERE t.debit_account_id = a.id AND t.deleted_at IS NULL), 0)
  END AS balance
FROM public.accounts a
WHERE a.is_archived = false;

-- RLS for the view (via underlying table RLS)

-- Function: get_user_balances
CREATE OR REPLACE FUNCTION public.get_user_balances(p_user_id UUID)
RETURNS TABLE (
  id UUID,
  name TEXT,
  type public.account_type,
  category public.account_category,
  icon TEXT,
  color TEXT,
  currency TEXT,
  balance BIGINT,
  display_order INTEGER
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    ab.id,
    ab.name,
    ab.type,
    ab.category,
    ab.icon,
    ab.color,
    ab.currency,
    ab.balance,
    ab.display_order
  FROM public.account_balances ab
  WHERE ab.user_id = p_user_id
  ORDER BY ab.type, ab.display_order, ab.name;
$$;

-- Function: get_monthly_summary
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
    COALESCE(SUM(CASE WHEN da.type = 'expense' THEN t.amount ELSE 0 END), 0)::BIGINT AS total_expense,
    COALESCE(SUM(CASE WHEN ca.type = 'income' THEN 0 WHEN da.type = 'income' THEN t.amount ELSE 0 END), 0)::BIGINT AS total_income,
    (COALESCE(SUM(CASE WHEN ca.type = 'income' THEN 0 WHEN da.type = 'income' THEN t.amount ELSE 0 END), 0)
     - COALESCE(SUM(CASE WHEN da.type = 'expense' THEN t.amount ELSE 0 END), 0))::BIGINT AS net_income,
    COUNT(*)::INTEGER AS transaction_count
  FROM public.transactions t
  JOIN public.accounts da ON t.debit_account_id = da.id
  JOIN public.accounts ca ON t.credit_account_id = da.id
  WHERE t.user_id = p_user_id
    AND t.deleted_at IS NULL
    AND EXTRACT(YEAR FROM t.date) = p_year
    AND EXTRACT(MONTH FROM t.date) = p_month;
$$;
