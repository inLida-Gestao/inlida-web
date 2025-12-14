import 'package:supabase_flutter/supabase_flutter.dart';

export 'database/database.dart';
export 'storage/storage.dart';

String _kSupabaseUrl = 'https://eqrtgsqnxxnfjjzlxpuj.supabase.co';
String _kSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM';

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() => Supabase.initialize(
        url: _kSupabaseUrl,
        headers: {
          'X-Client-Info': 'flutterflow',
        },
        anonKey: _kSupabaseAnonKey,
        debug: false,
        authOptions:
            const FlutterAuthClientOptions(authFlowType: AuthFlowType.implicit),
      );
}
