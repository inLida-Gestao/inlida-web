import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/pg_rebanho/origem_compra_utils.dart';

void main() {
  test('mantem dados de compra somente para origem Compra', () {
    final dataCompra = DateTime(2026, 8, 19);

    expect(normalizarValorCompra('Compra', 3800), 3800);
    expect(normalizarDataCompra(' compra ', dataCompra), dataCompra);
    expect(normalizarValorCompra('Nascimento', 3800), isNull);
    expect(normalizarDataCompra('Nascimento', dataCompra), isNull);
    expect(normalizarValorCompra(null, 3800), isNull);
  });
}
