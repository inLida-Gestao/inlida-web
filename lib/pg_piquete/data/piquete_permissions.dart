import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import 'package:flutter/foundation.dart';

Future<bool> currentUserCanAccessPiquetes() async {
  final userId = currentUserUid;
  if (userId.isEmpty) {
    return false;
  }

  try {
    final usersRows = await UsersTable().querySingleRow(
      queryFn: (q) => q.eqOrNull(
        'userID',
        userId,
      ),
    );

    return usersRows.isNotEmpty &&
        (usersRows.first.piquete ?? '').trim().toUpperCase() == 'SIM';
  } catch (error) {
    debugPrint('Erro ao verificar permissao de piquetes: $error');
    return false;
  }
}
