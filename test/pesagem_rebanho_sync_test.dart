import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/backend/supabase/supabase.dart';
import 'package:in_lida_web/pg_rebanho/pesagem_rebanho_sync.dart';

void main() {
  test('pesagemRebanhoAtiva considera ativo tudo que nao esta marcado como SIM',
      () {
    expect(
        pesagemRebanhoAtiva(HistoricoPesagensRow({'deletado': null})), isTrue);
    expect(
        pesagemRebanhoAtiva(HistoricoPesagensRow({'deletado': 'NAO'})), isTrue);
    expect(pesagemRebanhoAtiva(HistoricoPesagensRow({'deletado': 'SIM'})),
        isFalse);
  });
}
