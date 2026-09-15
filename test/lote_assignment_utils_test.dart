import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/backend/schema/structs/rebanho_d_t_struct.dart';
import 'package:in_lida_web/pg_lotes/lote_assignment_utils.dart';

void main() {
  test('oculta animais fora da propriedade sem filtro explícito', () {
    final animais = filtrarAnimaisSelecionaveisParaLote([
      RebanhoDTStruct(idRebanho: 'na-propriedade', status: 'Na propriedade'),
      RebanhoDTStruct(idRebanho: 'fora', status: 'Fora da propriedade'),
      RebanhoDTStruct(idRebanho: 'semen', status: 'Sêmen'),
    ]);

    expect(animais.map((animal) => animal.idRebanho), ['na-propriedade']);
  });

  test('permite animais fora da propriedade quando filtrados por status', () {
    final animais = filtrarAnimaisSelecionaveisParaLote(
      [
        RebanhoDTStruct(idRebanho: 'fora', status: 'Fora da propriedade'),
        RebanhoDTStruct(idRebanho: 'semen', status: 'Sêmen'),
      ],
      statusFiltro: 'Fora da propriedade',
    );

    expect(animais.map((animal) => animal.idRebanho), ['fora']);
  });

  test('normaliza IDs recebidos da RPC e descarta null textual', () {
    final ids = normalizeLoteAnimalIds([
      ' animal-2 ',
      null,
      'animal-1',
      'null',
      '',
      'animal-2',
    ]);

    expect(ids, ['animal-1', 'animal-2']);
  });

  test('normaliza os IDs do lote sem perder animais transferidos', () {
    final ids = loteAnimalIds([
      RebanhoDTStruct(idRebanho: ' animal-1 '),
      RebanhoDTStruct(idRebanho: 'animal-2'),
      RebanhoDTStruct(idRebanho: 'animal-1'),
      RebanhoDTStruct(idRebanho: ''),
      RebanhoDTStruct(idRebanho: 'null'),
    ]);

    expect(ids, ['animal-1', 'animal-2']);
  });

  test('snapshot da composição é determinístico para concorrência', () {
    final primeiraLeitura = loteAnimalIds([
      RebanhoDTStruct(idRebanho: 'animal-3'),
      RebanhoDTStruct(idRebanho: 'animal-1'),
    ]);
    final segundaLeitura = loteAnimalIds([
      RebanhoDTStruct(idRebanho: ' animal-1 '),
      RebanhoDTStruct(idRebanho: 'animal-3'),
    ]);

    expect(primeiraLeitura, segundaLeitura);
  });
}
