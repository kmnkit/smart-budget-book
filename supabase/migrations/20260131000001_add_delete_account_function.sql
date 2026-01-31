-- RPC function for authenticated users to delete their own account.
-- SECURITY DEFINER runs with the function owner's privileges,
-- allowing access to auth.users which is not normally accessible.
-- CASCADE constraints on profiles/accounts/transactions handle cleanup.

CREATE OR REPLACE FUNCTION public.delete_own_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;

GRANT EXECUTE ON FUNCTION public.delete_own_account() TO authenticated;
