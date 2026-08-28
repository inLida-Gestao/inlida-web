import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/backend/schema/structs/index.dart';
import 'package:in_lida_web/sanidade/sanidade_ordenacao.dart';

SanidadeStruct _sanidade({
  required int id,
  String? dataSanidade,
  String? createdAt,
}) {
  return SanidadeStruct(
    id: id,
    dataSanidade: dataSanidade,
    createdAt: createdAt,
  );
}

void main() {
  group('ordenarSanidadesPorData', () {
    test('ordena pela data de sanidade nas duas direções', () {
      final registros = [
        _sanidade(id: 3, dataSanidade: '2024-03-01'),
        _sanidade(id: 1, dataSanidade: '2024-01-01'),
        _sanidade(id: 2, dataSanidade: '2024-02-01'),
      ];

      final asc = ordenarSanidadesPorData(registros, true);
      final desc = ordenarSanidadesPorData(registros, false);

      expect(asc.map((e) => e.id), [1, 2, 3]);
      expect(desc.map((e) => e.id), [3, 2, 1]);
    });

    test('usa createdAt quando dataSanidade está vazia ou inválida', () {
      final registros = [
        _sanidade(
          id: 2,
          dataSanidade: 'data-invalida',
          createdAt: '2024-02-01T10:00:00Z',
        ),
        _sanidade(
          id: 1,
          dataSanidade: '',
          createdAt: '2024-01-01T10:00:00Z',
        ),
      ];

      final ordenados = ordenarSanidadesPorData(registros, true);

      expect(ordenados.map((e) => e.id), [1, 2]);
    });

    test('mantém registros sem data no fim nas duas direções', () {
      final semData = _sanidade(id: 1);
      final comData = _sanidade(id: 2, dataSanidade: '2024-01-01');

      expect(
        ordenarSanidadesPorData([semData, comData], true).map((e) => e.id),
        [2, 1],
      );
      expect(
        ordenarSanidadesPorData([semData, comData], false).map((e) => e.id),
        [2, 1],
      );
    });

    test('desempata pela identificação na mesma direção da data', () {
      final registros = [
        _sanidade(id: 2, dataSanidade: '2024-01-01'),
        _sanidade(id: 1, dataSanidade: '2024-01-01'),
      ];

      expect(
        ordenarSanidadesPorData(registros, true).map((e) => e.id),
        [1, 2],
      );
      expect(
        ordenarSanidadesPorData(registros, false).map((e) => e.id),
        [2, 1],
      );
    });

    test('não altera a lista recebida', () {
      final registros = [
        _sanidade(id: 2, dataSanidade: '2024-02-01'),
        _sanidade(id: 1, dataSanidade: '2024-01-01'),
      ];
      final original = List<SanidadeStruct>.of(registros);

      final ordenados = ordenarSanidadesPorData(registros, true);

      expect(registros, original);
      expect(ordenados, isNot(same(registros)));
    });
  });
}
