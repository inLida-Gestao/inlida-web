import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

export 'database/database.dart';
export 'storage/storage.dart';

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() => Supabase.initialize(
        url: SupabaseConfig.url,
        headers: {
          'X-Client-Info': 'flutterflow',
        },
        anonKey: SupabaseConfig.anonKey,
        debug: false,
        authOptions:
            const FlutterAuthClientOptions(authFlowType: AuthFlowType.implicit),
      );
}
