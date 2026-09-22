/// Entrega de arquivo ao usuario, com a implementacao escolhida por plataforma.
///
/// Por que existe esta indirecao: a implementacao real usa `package:web`, que
/// depende de `dart:js_interop`. Essa biblioteca nao existe na VM, e
/// `flutter test` roda na VM -- entao qualquer teste que alcancasse este
/// arquivo pela cadeia de imports falhava ao carregar, com
/// "Dart library 'dart:js_interop' is not available on this platform".
/// Como download_arquivo.dart e alcancavel a partir de
/// custom_code/actions/index.dart, isso atingia todo teste que tocasse o
/// pacote, incluindo os que nada tem a ver com download.
///
/// A condicao e `dart.library.io`, e nao `dart.library.html`: html e falso no
/// build WebAssembly, que foi exatamente a armadilha do pacote `download` que
/// este helper substituiu.
export 'download_arquivo_web.dart'
    if (dart.library.io) 'download_arquivo_vm.dart';
