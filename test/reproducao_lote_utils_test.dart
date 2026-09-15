import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/backend/supabase/supabase.dart';
import 'package:in_lida_web/reproducao/reproducao_lote_utils.dart';

RebanhoRow _animal({
  required String id,
  required String propriedade,
  required String lote,
  String sexo = 'Fêmea',
  String? deletado = 'NAO',
}) {
  return RebanhoRow({
    'idRebanho': id,
    'idPropriedade': propriedade,
    'loteID': lote,
    'sexo': sexo,
    'deletado': deletado,
  });
}

void main() {
  group('filtrarMatrizesDoLoteParaReproducao', () {
    test('mantém somente matrizes ativas do lote e propriedade selecionados',
        () {
      final animais = [
        _animal(id: 'matriz-correta', propriedade: 'prop-1', lote: 'lote-1'),
        _animal(id: 'outro-lote', propriedade: 'prop-1', lote: 'lote-2'),
        _animal(id: 'outra-propriedade', propriedade: 'prop-2', lote: 'lote-1'),
        _animal(
          id: 'macho',
          propriedade: 'prop-1',
          lote: 'lote-1',
          sexo: 'Macho',
        ),
        _animal(
          id: 'excluida',
          propriedade: 'prop-1',
          lote: 'lote-1',
          deletado: 'SIM',
        ),
      ];

      final resultado = filtrarMatrizesDoLoteParaReproducao(
        rebanho: animais,
        idPropriedade: 'prop-1',
        idLote: 'lote-1',
      );

      expect(resultado.map((animal) => animal.idRebanho), ['matriz-correta']);
    });

    test('remove IDs duplicados e aceita registro ativo sem flag deletado', () {
      final animais = [
        _animal(
          id: 'matriz-1',
          propriedade: 'prop-1',
          lote: 'lote-1',
          deletado: null,
        ),
        _animal(id: 'matriz-1', propriedade: 'prop-1', lote: 'lote-1'),
      ];

      final resultado = filtrarMatrizesDoLoteParaReproducao(
        rebanho: animais,
        idPropriedade: ' prop-1 ',
        idLote: ' lote-1 ',
      );

      expect(resultado.map((animal) => animal.idRebanho), ['matriz-1']);
    });

    test('não retorna animais quando lote ou propriedade são inválidos', () {
      final animais = [
        _animal(id: 'matriz-1', propriedade: 'prop-1', lote: 'lote-1'),
      ];

      expect(
        filtrarMatrizesDoLoteParaReproducao(
          rebanho: animais,
          idPropriedade: '',
          idLote: 'lote-1',
        ),
        isEmpty,
      );
      expect(
        filtrarMatrizesDoLoteParaReproducao(
          rebanho: animais,
          idPropriedade: 'prop-1',
          idLote: ' ',
        ),
        isEmpty,
      );
    });
  });
}
