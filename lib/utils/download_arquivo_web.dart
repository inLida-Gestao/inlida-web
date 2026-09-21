import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Download de arquivo no navegador, compatível com os dois builds web.
///
/// O pacote `download` escolhe a implementação por `dart.library.html`. No
/// build WebAssembly essa condição é falsa, então ele caía na implementação de
/// `dart:io` e tentava gravar o arquivo em disco de dentro do navegador: toda
/// exportação parava de funcionar. Aqui usamos `package:web`, que vale para o
/// build JavaScript e para o WebAssembly.
///
/// O conteúdo vai por Blob e não por data URL em base64, porque as planilhas
/// de fazendas grandes passam de alguns MB e o navegador recusa data URL desse
/// tamanho.
Future<void> download(Stream<int> stream, String filename) async {
  final bytes = await stream.toList();
  await downloadData(Uint8List.fromList(bytes), filename);
}

/// Publica o conteúdo como um Blob e devolve a URL temporária.
///
/// Separado do resto para dar para testar no navegador sem disparar download.
String criarUrlDoArquivo(Uint8List data) {
  final blob = web.Blob(
    <JSAny>[data.toJS].toJS,
    web.BlobPropertyBag(type: 'application/octet-stream'),
  );
  return web.URL.createObjectURL(blob);
}

Future<void> downloadData(Uint8List data, String filename) async {
  final nome = filename.replaceAll('/', '_').replaceAll('\\', '_');

  final url = criarUrlDoArquivo(data);

  final ancora = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = nome
    ..style.display = 'none';

  web.document.body?.appendChild(ancora);
  ancora.click();
  ancora.remove();

  // O clique dispara o download de forma assíncrona: revogar na hora cancela
  // o arquivo em navegadores mais lentos.
  Future.delayed(
      const Duration(minutes: 1), () => web.URL.revokeObjectURL(url));
}
