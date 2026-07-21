import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/reproducao/reproducao_form_validation.dart';

void main() {
  group('validarCamposMontaNatural', () {
    test('bloqueia monta natural sem data inicial', () {
      expect(
        validarCamposMontaNatural(
          tipoReproducao: 'Monta Natural',
          dataInicial: null,
          idReprodutor: 'reprodutor-1',
        ),
        'Selecione a data inicial da monta natural.',
      );
    });

    test('bloqueia monta natural sem reprodutor', () {
      expect(
        validarCamposMontaNatural(
          tipoReproducao: 'Monta Natural',
          dataInicial: DateTime(2026, 7, 21),
          idReprodutor: '  ',
        ),
        'Selecione o reprodutor da monta natural.',
      );
    });

    test('permite monta natural com os campos obrigatorios', () {
      expect(
        validarCamposMontaNatural(
          tipoReproducao: 'Monta Natural',
          dataInicial: DateTime(2026, 7, 21),
          idReprodutor: 'reprodutor-1',
        ),
        isNull,
      );
    });

    test('nao exige data inicial para inseminacao', () {
      expect(
        validarCamposMontaNatural(
          tipoReproducao: 'Inseminação',
          dataInicial: null,
          idReprodutor: null,
        ),
        isNull,
      );
    });
  });
}
