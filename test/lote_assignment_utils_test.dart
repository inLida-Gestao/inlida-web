import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/backend/schema/structs/rebanho_d_t_struct.dart';
import 'package:in_lida_web/pg_lotes/lote_assignment_utils.dart';

void main() {
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
}
