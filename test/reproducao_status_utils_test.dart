import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/reproducao/reproducao_status_utils.dart';

void main() {
  group('statusReproducaoPermitePrevisaoParto', () {
    test('permite apenas não diagnosticado e prenhez', () {
      expect(statusReproducaoPermitePrevisaoParto('Não diagnosticado'), isTrue);
      expect(statusReproducaoPermitePrevisaoParto('Prenhez'), isTrue);
      expect(statusReproducaoPermitePrevisaoParto('  PRENHEZ  '), isTrue);
      expect(
        statusReproducaoPermitePrevisaoParto(' não diagnosticado '),
        isTrue,
      );
    });

    test('rejeita diagnósticos sem previsão de parto', () {
      for (final status in <String?>[
        'Absorção',
        'Aborto',
        'Natimorto',
        'Vazio',
        'Parida',
        '',
        null,
      ]) {
        expect(
          statusReproducaoPermitePrevisaoParto(status),
          isFalse,
          reason: 'Status inesperadamente permitido: $status',
        );
      }
    });
  });

  test('statusReproducaoEfetivo usa não diagnosticado como padrão', () {
    expect(statusReproducaoEfetivo(null), statusReproducaoNaoDiagnosticado);
    expect(statusReproducaoEfetivo('  '), statusReproducaoNaoDiagnosticado);
    expect(statusReproducaoEfetivo(' Prenhez '), 'Prenhez');
  });

  test('previsaoPartoPermitida remove a data de estados incompatíveis', () {
    final previsao = DateTime(2027, 3, 10);

    expect(previsaoPartoPermitida('Prenhez', previsao), previsao);
    expect(previsaoPartoPermitida('Não diagnosticado', previsao), previsao);
    expect(previsaoPartoPermitida('Vazio', previsao), isNull);
    expect(previsaoPartoPermitida('Absorção', previsao), isNull);
    expect(previsaoPartoPermitida('Aborto', previsao), isNull);
  });
}
