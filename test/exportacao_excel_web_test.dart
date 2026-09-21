@TestOn('browser')
library;

import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/utils/download_arquivo.dart';

/// Regressao da exportacao no navegador.
///
/// O `excel` monta o .xlsx com o pacote `archive`, que escolhe a implementacao
/// de inflate por condicao de biblioteca:
///
///     import '_inflate_buffer_stub.dart'
///         if (dart.library.io) '_inflate_buffer_io.dart'
///         if (dart.library.js) '_inflate_buffer_html.dart';
///
/// No build WebAssembly nenhuma das duas condicoes vale, entao ele cai no stub
/// e lanca "inflateBuffer requires html or io": nenhuma exportacao conclui.
/// Este teste roda em Chrome (dart2js), o mesmo caminho do build da Vercel, e
/// falha se voltarmos a um build onde gerar planilha nao funciona.
void main() {
  test('gera um xlsx no navegador', () {
    final excel = Excel.createExcel();
    final sheet = excel['Teste'];
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = TextCellValue('inLida');

    final bytes = excel.encode();

    expect(bytes, isNotNull);
    expect(bytes!.length, greaterThan(0));
  });

  test('entrega o arquivo pelo navegador', () {
    // O pacote `download` escolhia a implementacao pela mesma condicao e no
    // build WebAssembly caia no dart:io, tentando gravar em disco de dentro do
    // navegador. Aqui a URL do Blob prova que o caminho de entrega funciona.
    final url = criarUrlDoArquivo(Uint8List.fromList([1, 2, 3, 4]));

    expect(url, startsWith('blob:'));
  });
}
