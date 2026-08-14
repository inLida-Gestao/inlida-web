import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/backend/schema/structs/index.dart';
import 'package:in_lida_web/pg_lotes/lote_ordenacao.dart';

void main() {
  RebanhoDTStruct animal(String numero, {String dataNascimento = ''}) =>
      RebanhoDTStruct(
        numeroAnimal: numero,
        dataNascimento: dataNascimento,
      );

  test('campo vazio retorna a lista original sem reordenar', () {
    final original = [
      animal('270'),
      animal('254'),
      animal('265'),
    ];

    final resultado = ordenarAnimaisLote(original, '', true);

    expect(resultado, same(original));
    expect(resultado.map((e) => e.numeroAnimal).toList(), [
      '270',
      '254',
      '265',
    ]);
  });

  test('ordena por número crescente', () {
    final original = [
      animal('270'),
      animal('254'),
      animal('265'),
    ];

    final resultado = ordenarAnimaisLote(original, kOrdenarNumero, true);

    expect(resultado.map((e) => e.numeroAnimal).toList(), [
      '254',
      '265',
      '270',
    ]);
  });

  test('ordena por número decrescente', () {
    final original = [
      animal('254'),
      animal('270'),
      animal('265'),
    ];

    final resultado = ordenarAnimaisLote(original, kOrdenarNumero, false);

    expect(resultado.map((e) => e.numeroAnimal).toList(), [
      '270',
      '265',
      '254',
    ]);
  });

  test('ordena por data de nascimento crescente', () {
    final original = [
      animal('1', dataNascimento: '2024-01-01'),
      animal('2', dataNascimento: '2020-01-01'),
      animal('3', dataNascimento: '2022-01-01'),
    ];

    final resultado = ordenarAnimaisLote(original, kOrdenarNascimento, true);

    expect(resultado.map((e) => e.numeroAnimal).toList(), ['2', '3', '1']);
  });

  test('ordena por data de nascimento decrescente', () {
    final original = [
      animal('1', dataNascimento: '2020-01-01'),
      animal('2', dataNascimento: '2024-01-01'),
      animal('3', dataNascimento: '2022-01-01'),
    ];

    final resultado = ordenarAnimaisLote(original, kOrdenarNascimento, false);

    expect(resultado.map((e) => e.numeroAnimal).toList(), ['2', '3', '1']);
  });

  test('não modifica a lista original ao ordenar', () {
    final original = [
      animal('270'),
      animal('254'),
      animal('265'),
    ];
    final originalCopia = List<RebanhoDTStruct>.of(original);

    ordenarAnimaisLote(original, kOrdenarNumero, true);

    expect(
      original.map((e) => e.numeroAnimal).toList(),
      originalCopia.map((e) => e.numeroAnimal).toList(),
    );
  });
}
