-- Update handle_new_user to also create a 7-day trial subscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  -- Create profile
  INSERT INTO public.profiles (id, display_name)
  VALUES (NEW.id, NEW.raw_user_meta_data ->> 'display_name');

  -- Create 7-day trial subscription
  INSERT INTO public.subscriptions (
    user_id,
    tier,
    status,
    trial_start_at,
    trial_end_at,
    current_period_start_at,
    current_period_end_at
  ) VALUES (
    NEW.id,
    'premium',
    'trialing',
    now(),
    now() + INTERVAL '7 days',
    now(),
    now() + INTERVAL '7 days'
  );

  -- Set profile subscription_tier to premium during trial
  UPDATE public.profiles
    SET subscription_tier = 'premium'
    WHERE id = NEW.id;

  RETURN NEW;
END;
$$;
