import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/custom_code/actions/batch_insert_supabase_reproducao.dart';
import 'package:in_lida_web/custom_code/actions/export_reproducao_excel.dart';

void main() {
  group('campos de sêmen em Monta Natural', () {
    test('normaliza campos incompatíveis antes da importação', () {
      final normalized = normalizarCamposSemenMontaNatural({
        'tipo_reproducao': '  MONTA NATURAL ',
        'data_inseminacao': '2026-08-01',
        'data_partida_semen': '2026-07-20',
        'partida_semen': 12,
      });

      expect(normalized['data_inseminacao'], isNull);
      expect(normalized['data_partida_semen'], isNull);
      expect(normalized['partida_semen'], isNull);
    });

    test('mantém campos de sêmen para Inseminação', () {
      final normalized = normalizarCamposSemenMontaNatural({
        'tipo_reproducao': 'Inseminação',
        'data_inseminacao': '2026-08-01',
        'data_partida_semen': '2026-07-20',
        'partida_semen': 12,
      });

      expect(normalized['data_inseminacao'], '2026-08-01');
      expect(normalized['data_partida_semen'], '2026-07-20');
      expect(normalized['partida_semen'], 12);
    });

    test('deixa campos de sêmen vazios na exportação', () {
      final row = {
        'tipo_reproducao': 'Monta Natural',
        'data_inseminacao': '2026-08-01',
        'data_partida_semen': '2026-07-20',
        'partida_semen': 12,
        'data_inicial': '2026-08-10',
      };

      expect(valorReproducaoParaExportacao(row, 'data_inseminacao'), isNull);
      expect(
        valorReproducaoParaExportacao(row, 'data_partida_semen'),
        isNull,
      );
      expect(valorReproducaoParaExportacao(row, 'partida_semen'), isNull);
      expect(
        valorReproducaoParaExportacao(row, 'data_inicial'),
        '2026-08-10',
      );
    });

    test('mantém campos de sêmen na exportação de Inseminação', () {
      final row = {
        'tipo_reproducao': 'Inseminação',
        'data_inseminacao': '2026-08-01',
        'data_partida_semen': '2026-07-20',
        'partida_semen': 12,
      };

      expect(
        valorReproducaoParaExportacao(row, 'data_inseminacao'),
        '2026-08-01',
      );
      expect(
        valorReproducaoParaExportacao(row, 'data_partida_semen'),
        '2026-07-20',
      );
      expect(valorReproducaoParaExportacao(row, 'partida_semen'), 12);
    });
  });
}
