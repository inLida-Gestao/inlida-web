import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/pg_rebanho/categoria_rebanho_utils.dart';

void main() {
  test('categoriaRebanhoCondizComSexo valida categorias por sexo', () {
    expect(
      categoriaRebanhoCondizComSexo(sexo: 'Fêmea', categoria: 'Bezerra'),
      isTrue,
    );
    expect(
      categoriaRebanhoCondizComSexo(sexo: 'Macho', categoria: 'Bezerro'),
      isTrue,
    );
    expect(
      categoriaRebanhoCondizComSexo(sexo: 'Macho', categoria: 'Bezerra'),
      isFalse,
    );
    expect(
      categoriaRebanhoCondizComSexo(sexo: 'Fêmea', categoria: 'Bezerro'),
      isFalse,
    );
  });

  test('categoria inicial é descartada quando o sexo muda', () {
    expect(
      categoriaRebanhoInicialParaSexo(
        sexoSelecionado: 'Macho',
        sexoOriginal: 'Fêmea',
        categoriaOriginal: 'Bezerra',
      ),
      isNull,
    );
  });
}
