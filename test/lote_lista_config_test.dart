import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/pg_lotes/lote_lista_config.dart';

void main() {
  test('usa 50 como quantidade padrão', () {
    expect(normalizarLoteAnimaisPageSize(null), 50);
    expect(normalizarLoteAnimaisPageSize(25), 50);
  });

  test('aceita as quantidades configuradas', () {
    expect(
      loteAnimaisPageSizeOptions.map(normalizarLoteAnimaisPageSize),
      [20, 50, 100, 200, 300, 400, 500],
    );
  });

  test('calcula páginas e ajusta página fora do intervalo', () {
    expect(calcularTotalPaginasLote(totalItems: 137, pageSize: 50), 3);
    expect(
      ajustarPaginaLote(page: 8, totalItems: 137, pageSize: 50),
      3,
    );
  });

  test('recorta itens nas quantidades configuradas', () {
    final items = List<int>.generate(650, (index) => index + 1);

    expect(
      paginarItensLote(items, page: 2, pageSize: 20),
      List<int>.generate(20, (index) => index + 21),
    );
    expect(paginarItensLote(items, page: 3, pageSize: 50), hasLength(50));
    expect(paginarItensLote(items, page: 2, pageSize: 100), hasLength(100));
    expect(paginarItensLote(items, page: 2, pageSize: 200), hasLength(200));
    expect(paginarItensLote(items, page: 2, pageSize: 300), hasLength(300));
    expect(paginarItensLote(items, page: 2, pageSize: 400), hasLength(250));
    expect(paginarItensLote(items, page: 2, pageSize: 500), hasLength(150));
  });

  test('informa a faixa visível da página', () {
    expect(
      faixaPaginaLote(page: 3, totalItems: 137, pageSize: 50),
      (start: 101, end: 137),
    );
    expect(
      faixaPaginaLote(page: 1, totalItems: 0, pageSize: 50),
      (start: 0, end: 0),
    );
  });

  test('divide seleção global respeitando o limite de mil da API', () {
    expect(
      loteSelecaoGlobalOffsets(11213),
      [0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 11000],
    );
    expect(loteSelecaoGlobalLimit(11213, 0), 1000);
    expect(loteSelecaoGlobalLimit(11213, 11000), 213);
  });

  test('não cria páginas globais para totais inválidos', () {
    expect(loteSelecaoGlobalOffsets(0), isEmpty);
    expect(loteSelecaoGlobalOffsets(-1), isEmpty);
    expect(loteSelecaoGlobalLimit(100, 100), 0);
  });
}
