import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/custom_code/actions/export_rebanho_excel.dart';

void main() {
  test('seleciona a data da ultima pesagem ativa por animal', () {
    final latestDates = latestPesagemDatesByRebanhoForExport([
      {
        'id': 10,
        'idRebanho': 'animal-1',
        'dataPesagem': '2026-05-11',
        'deletado': 'NAO',
      },
      {
        'id': 20,
        'idRebanho': 'animal-1',
        'dataPesagem': '2026-07-22',
        'deletado': 'NAO',
      },
      {
        'id': 30,
        'idRebanho': 'animal-1',
        'dataPesagem': '2026-07-23',
        'deletado': 'SIM',
      },
      {
        'id': 40,
        'idRebanho': 'animal-2',
        'dataPesagem': '2026-06-01',
        'deletado': null,
      },
      {
        'id': 41,
        'idRebanho': 'animal-2',
        'dataPesagem': '2026-06-01',
        'deletado': 'NAO',
      },
      {
        'id': 50,
        'idRebanho': 'animal-3',
        'dataPesagem': null,
        'deletado': 'NAO',
      },
    ]);

    expect(latestDates, {
      'animal-1': '2026-07-22',
      'animal-2': '2026-06-01',
    });
  });
}
