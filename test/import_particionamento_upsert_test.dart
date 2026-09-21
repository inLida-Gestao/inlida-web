// O particionamento existe por causa de um detalhe do postgrest-dart 2.4.2:
// em upsert de LISTA, o parametro `columns` e a uniao das chaves de todos os
// registros. Um lote misto gravaria id nulo nas linhas sem PK.
import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/importacao/import_lookups.dart';

void main() {
  test('separa quem tem PK conhecida de quem nao tem', () {
    final p = particionarPorChavePrimaria(
      registros: [
        {'idRebanho': 'a', 'numeroAnimal': '1'},
        {'idRebanho': 'b', 'numeroAnimal': '2'},
        {'idRebanho': 'c', 'numeroAnimal': '3'},
      ],
      pkPorIdRebanho: {'a': 10, 'c': 30},
    );

    expect(p.atualizar.map((r) => r['idRebanho']), ['a', 'c']);
    expect(p.atualizar.map((r) => r['id']), [10, 30]);
    expect(p.criar.map((r) => r['idRebanho']), ['b']);
  });

  test('os lotes sao HOMOGENEOS: ou todos tem id, ou nenhum tem', () {
    // E a invariante que impede o id nulo.
    final p = particionarPorChavePrimaria(
      registros: [
        {'idRebanho': 'a'},
        {'idRebanho': 'b'},
        {'idRebanho': 'c'},
      ],
      pkPorIdRebanho: {'b': 20},
    );
    expect(p.atualizar.every((r) => r.containsKey('id')), isTrue);
    expect(p.criar.any((r) => r.containsKey('id')), isFalse);
  });

  test('nao muta os registros originais', () {
    final original = {'idRebanho': 'a', 'nome': 'Estrela'};
    final p = particionarPorChavePrimaria(
      registros: [original],
      pkPorIdRebanho: {'a': 7},
    );
    expect(p.atualizar.single['id'], 7);
    expect(original.containsKey('id'), isFalse,
        reason: 'o registro de origem nao pode ganhar a PK por efeito colateral');
  });

  test('sem PK conhecida tudo vai para criar, preservando o caminho antigo', () {
    final p = particionarPorChavePrimaria(
      registros: [
        {'idRebanho': 'a'},
        {'idRebanho': 'b'},
      ],
      pkPorIdRebanho: const {},
    );
    expect(p.atualizar, isEmpty);
    expect(p.criar, hasLength(2));
  });

  test('registro sem a chave de negocio vai para criar', () {
    final p = particionarPorChavePrimaria(
      registros: [
        {'numeroAnimal': '1'}
      ],
      pkPorIdRebanho: {'a': 1},
    );
    expect(p.criar, hasLength(1));
    expect(p.atualizar, isEmpty);
  });
}
