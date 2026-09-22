import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/sanidade/sanidade_protocolo_options.dart';

/// BUG-WEB-P.ALTA: "Não dá pra editar todos os campos da sanidade quando
/// lançada". Os campos D0 e Retirada não existiam na tela de edição. Ao
/// colocá-los, o que já está gravado precisa aparecer — inclusive o que foi
/// lançado pelo app, que grava a mesma opção com espaçamento diferente.
void main() {
  group('valor que aparece no campo', () {
    test('casa a grafia do app com a opção da web', () {
      expect(
        sanidadeProtocoloValorSalvo(
            'BE  + Implante novo', kSanidadeProtocoloD0Options),
        'BE + Implante novo',
      );
    });

    test('a string "null" conta como vazio', () {
      expect(
        sanidadeProtocoloValorSalvo('null', kSanidadeProtocoloD0Options),
        isNull,
      );
      expect(
        sanidadeProtocoloValorSalvo('  ', kSanidadeProtocoloD0Options),
        isNull,
      );
      expect(
        sanidadeProtocoloValorSalvo(null, kSanidadeProtocoloD0Options),
        isNull,
      );
    });

    test('valor fora da lista é preservado, não descartado', () {
      expect(
        sanidadeProtocoloValorSalvo(
            'CE + eCG', kSanidadeProtocoloRetiradaOptions),
        'CE + eCG',
      );
    });
  });

  group('opções do dropdown', () {
    test('valor fora da lista entra como opção', () {
      final opcoes = sanidadeProtocoloOpcoes(
          'CE + eCG', kSanidadeProtocoloRetiradaOptions);

      expect(opcoes, contains('CE + eCG'));
      expect(opcoes.length, kSanidadeProtocoloRetiradaOptions.length + 1);
    });

    test('grafia do app não duplica a opção', () {
      final opcoes = sanidadeProtocoloOpcoes(
          'BE  + Implante novo', kSanidadeProtocoloD0Options);

      expect(opcoes.length, kSanidadeProtocoloD0Options.length);
    });

    test('sem valor gravado, a lista é a padrão', () {
      expect(sanidadeProtocoloOpcoes(null, kSanidadeProtocoloD0Options),
          kSanidadeProtocoloD0Options);
      expect(sanidadeProtocoloOpcoes('null', kSanidadeProtocoloD0Options),
          kSanidadeProtocoloD0Options);
    });
  });
}
