-- Transactions table for double-entry bookkeeping

CREATE TABLE public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  amount BIGINT NOT NULL CHECK (amount > 0),
  debit_account_id UUID NOT NULL REFERENCES public.accounts(id),
  credit_account_id UUID NOT NULL REFERENCES public.accounts(id),
  description TEXT,
  note TEXT,
  source_type public.source_type NOT NULL DEFAULT 'manual',
  tags TEXT[] DEFAULT '{}',
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT different_accounts CHECK (debit_account_id != credit_account_id)
);

-- RLS
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own transactions"
  ON public.transactions FOR SELECT
  USING (auth.uid() = user_id AND deleted_at IS NULL);

CREATE POLICY "Users can view own deleted transactions"
  ON public.transactions FOR SELECT
  USING (auth.uid() = user_id AND deleted_at IS NOT NULL);

CREATE POLICY "Users can insert own transactions"
  ON public.transactions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own transactions"
  ON public.transactions FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own transactions"
  ON public.transactions FOR DELETE
  USING (auth.uid() = user_id);

-- Indexes
CREATE INDEX idx_transactions_user_date ON public.transactions(user_id, date DESC);
CREATE INDEX idx_transactions_debit ON public.transactions(debit_account_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_transactions_credit ON public.transactions(credit_account_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_transactions_not_deleted ON public.transactions(user_id) WHERE deleted_at IS NULL;

-- Updated_at trigger
CREATE TRIGGER update_transactions_updated_at
  BEFORE UPDATE ON public.transactions
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
