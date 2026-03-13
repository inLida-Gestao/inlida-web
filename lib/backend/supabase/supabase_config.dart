/// Supabase configuration loaded from environment variables.
///
/// Pass values at build time with:
///   flutter run --dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_ANON_KEY=eyJ...
///
/// Defaults are provided for development convenience.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://eqrtgsqnxxnfjjzlxpuj.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
  );

  static String get baseRpcUrl => '$url/rest/v1/rpc';
}
