-- Custom ENUM types for Zan double-entry bookkeeping

CREATE TYPE public.account_type AS ENUM (
  'asset',
  'liability',
  'expense',
  'income',
  'equity'
);

CREATE TYPE public.account_category AS ENUM (
  -- Asset categories
  'cash',
  'bank_account',
  'e_money',
  'credit_card_prepaid',
  'investment',
  'receivable',
  'other_asset',
  -- Liability categories
  'credit_card',
  'loan',
  'other_liability',
  -- Expense categories
  'food',
  'transport',
  'housing',
  'utilities',
  'entertainment',
  'shopping',
  'health',
  'education',
  'communication',
  'insurance',
  'tax',
  'other_expense',
  -- Income categories
  'salary',
  'freelance',
  'investment_income',
  'other_income',
  -- Equity categories
  'opening_balance',
  'retained_earnings'
);

CREATE TYPE public.source_type AS ENUM (
  'manual',
  'text_ai',
  'voice_ai',
  'ocr',
  'import'
);
