class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const googleWebClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const googleIosClientId =
      String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
  static const appEnv =
      String.fromEnvironment('APP_ENV', defaultValue: 'development');
  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';
}
