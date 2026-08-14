import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/backend/schema/structs/index.dart';
import 'package:in_lida_web/flutter_flow/custom_functions.dart';

void main() {
  RebanhoDTStruct animal(String numero, {String dataNascimento = ''}) =>
      RebanhoDTStruct(
        numeroAnimal: numero,
        dataNascimento: dataNascimento,
      );

  test('detecta conflito usando somente o ID canônico do lote', () {
    final animalComNomeDesatualizado = RebanhoDTStruct(
      loteID: 'lote-a',
      loteNome: 'Nome antigo',
    );

    expect(
      animalEstaEmOutroLote(
        animalComNomeDesatualizado,
        idLoteDestino: 'lote-a',
      ),
      isFalse,
    );
    expect(
      animalEstaEmOutroLote(
        animalComNomeDesatualizado,
        idLoteDestino: 'lote-b',
      ),
      isTrue,
    );
  });

  test('ordena número do animal pelo valor numérico extraído do texto', () {
    final sorted = rebanhoSortingFunction(
      [
        animal('270', dataNascimento: '2024-01-01'),
        animal('267', dataNascimento: '2020-01-01'),
        animal('(277)', dataNascimento: '2020-01-01'),
        animal('L 255', dataNascimento: '2025-01-01'),
        animal('265', dataNascimento: '2022-01-01'),
        animal('254', dataNascimento: '2021-01-01'),
        animal('- 258', dataNascimento: '2023-01-01'),
        animal('(R 261)', dataNascimento: '2021-01-01'),
        animal('(276)', dataNascimento: '2020-01-01'),
      ],
      0,
      true,
    )!
        .map((item) => item.numeroAnimal)
        .toList();

    expect(sorted, [
      '254',
      'L 255',
      '- 258',
      '(R 261)',
      '265',
      '267',
      '270',
      '(276)',
      '(277)',
    ]);
  });

  test('ordena nascimento pela data quando a coluna selecionada é nascimento',
      () {
    final sorted = rebanhoSortingFunction(
      [
        animal('3', dataNascimento: '2024-01-01'),
        animal('2', dataNascimento: '2022-01-01'),
        animal('1', dataNascimento: '2023-01-01'),
      ],
      3,
      true,
    )!
        .map((item) => item.numeroAnimal)
        .toList();

    expect(sorted, ['2', '1', '3']);
  });
}
