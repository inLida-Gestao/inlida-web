import 'dart:typed_data';

/// Stub para a VM (usado por `flutter test`). O app so roda no navegador;
/// estas funcoes existem apenas para que o codigo compile fora dele.
///
/// Elas lancam em vez de virar no-op: um download que falha em silencio e
/// justamente o defeito que a migracao para `package:web` veio corrigir.
Future<void> download(Stream<int> stream, String filename) async =>
    throw UnsupportedError(
      'Download de arquivo so esta disponivel no navegador.',
    );

String criarUrlDoArquivo(Uint8List data) => throw UnsupportedError(
      'Download de arquivo so esta disponivel no navegador.',
    );

Future<void> downloadData(Uint8List data, String filename) async =>
    throw UnsupportedError(
      'Download de arquivo so esta disponivel no navegador.',
    );
