import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('trigger evita busca de pais externos quando a progenie nao mudou', () {
    final migration = File(
      'supabase/migrations/'
      '20260914170000_optimize_parent_link_save.sql',
    ).readAsStringSync();

    expect(migration, contains('v_processar_matriz boolean := true'));
    expect(migration, contains('v_processar_reprodutor boolean := true'));
    expect(
      migration,
      contains(
        'if not v_processar_matriz and not v_processar_reprodutor then',
      ),
    );
    expect(migration, contains('idx_rebanho_parent_match_female'));
    expect(migration, contains('idx_rebanho_parent_match_male'));
    expect(RegExp(r'limit 2').allMatches(migration), hasLength(4));
  });
}
