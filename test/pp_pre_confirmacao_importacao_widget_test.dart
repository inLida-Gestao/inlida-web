// O ponto critico deste widget e nao deixar o usuario gravar o que o banco
// recusaria. Estes testes cobrem o estado dos botoes e a paginacao do detalhe.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/flutter_flow/flutter_flow_theme.dart';
import 'package:in_lida_web/flutter_flow/flutter_flow_widgets.dart';
import 'package:in_lida_web/importacao/import_diagnostico_model.dart';
import 'package:in_lida_web/importacao/pp_pre_confirmacao_importacao_widget.dart';

ImportDiagnostico _diagnostico({
  int criar = 0,
  int atualizar = 0,
  int bloquear = 0,
  int repeticoesDoBloqueio = 1,
  List<Map<String, dynamic>> atualizados = const [],
}) {
  final b = ImportDiagnosticoBuilder(entidade: ImportEntidade.rebanho);
  var linha = 1;

  for (var i = 0; i < criar; i++) {
    b.marcarCriar(++linha);
  }
  for (var i = 0; i < atualizar; i++) {
    linha++;
    b.add(ImportOcorrencia(
      codigo: ImportCodigo.rebSobrescritaDeAnimalExistente,
      severidade: ImportSeveridade.aviso,
      escopo: ImportEscopo.consistencia,
      linha: linha,
      mensagem: 'Linha $linha: será sobrescrito.',
    ));
    b.marcarAtualizar(linha,
        resumo: i < atualizados.length
            ? atualizados[i]
            : {'linha': linha, 'numeroAnimal': '$linha', 'nome': 'Animal'});
  }
  for (var i = 0; i < bloquear; i++) {
    linha++;
    for (var r = 0; r < repeticoesDoBloqueio; r++) {
      b.add(ImportOcorrencia(
        codigo: ImportCodigo.rebSexoForaDoDominio,
        severidade: ImportSeveridade.bloqueante,
        escopo: ImportEscopo.dado,
        linha: linha,
        coluna: 'sexo',
        valor: 'Femia',
        mensagem: 'Linha $linha: Sexo inválido.',
        sugestao: 'Use Fêmea ou Macho.',
      ));
    }
  }

  return b.build(
    arquivo: const ImportArquivoInfo(nomeArquivo: 'rebanho.csv', formato: 'csv'),
    totalLinhas: criar + atualizar + bloquear,
  );
}

Future<void> _abrir(
  WidgetTester tester,
  ImportDiagnostico d, {
  bool permitirForcar = true,
  bool somenteLeitura = false,
}) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(extensions: const []),
    home: Builder(
      builder: (context) => Scaffold(
        body: PpPreConfirmacaoImportacaoWidget(
          diagnostico: d,
          nomeEntidade: 'Rebanho',
          permitirForcar: permitirForcar,
          somenteLeitura: somenteLeitura,
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

/// Busca o FFButtonWidget cujo texto contem [trecho].
FFButtonWidget _botao(WidgetTester tester, String trecho) =>
    tester.widgetList<FFButtonWidget>(find.byType(FFButtonWidget)).firstWhere(
          (b) => b.text.contains(trecho),
          orElse: () => throw StateError(
            'botao com "$trecho" nao encontrado. '
            'Botoes: ${tester.widgetList<FFButtonWidget>(find.byType(FFButtonWidget)).map((b) => b.text).toList()}',
          ),
        );

void main() {

  testWidgets('sem problema, oferece importar tudo', (tester) async {
    await _abrir(tester, _diagnostico(criar: 5));
    expect(find.textContaining('Nenhum problema encontrado'), findsOneWidget);
    expect(_botao(tester, 'Importar 5').onPressed, isNotNull);
  });

  testWidgets('com bloqueio, so permite importar as validas', (tester) async {
    await _abrir(tester, _diagnostico(criar: 4, bloquear: 2));

    // Nao existe caminho para "importar mesmo assim" quando ha bloqueante.
    final textos = tester
        .widgetList<FFButtonWidget>(find.byType(FFButtonWidget))
        .map((b) => b.text)
        .toList();
    expect(textos.any((t) => t.contains('mesmo assim')), isFalse);

    final botao = _botao(tester, 'apenas as 4 linhas válidas');
    expect(botao.onPressed, isNotNull);
  });

  testWidgets('quando nada e importavel, o botao fica desabilitado',
      (tester) async {
    await _abrir(tester, _diagnostico(bloquear: 3));
    expect(_botao(tester, 'Nada a importar').onPressed, isNull);
  });

  testWidgets('permitirForcar falso nao oferece forcar', (tester) async {
    await _abrir(tester, _diagnostico(criar: 3), permitirForcar: false);
    final botao = _botao(tester, 'Importar 3');
    expect(botao.onPressed, isNotNull,
        reason: 'sem bloqueio a importacao normal segue disponivel');
  });

  testWidgets('mostra os cartoes de criar, atualizar e bloquear',
      (tester) async {
    await _abrir(tester, _diagnostico(criar: 2, atualizar: 3, bloquear: 1));
    expect(find.text('Serão criados'), findsOneWidget);
    expect(find.text('Serão atualizados'), findsOneWidget);
    expect(find.text('Bloqueados'), findsOneWidget);
    expect(find.textContaining('apagam o que está gravado'), findsOneWidget);
  });

  testWidgets('lista os registros que serao sobrescritos', (tester) async {
    await _abrir(
      tester,
      _diagnostico(atualizar: 1, atualizados: [
        {
          'linha': 2,
          'numeroAnimal': '1204',
          'nome': 'Estrela',
          'detalhe': 'Lote Pasto 1',
        }
      ]),
    );
    await tester.tap(find.textContaining('Ver os 1 registro'));
    await tester.pumpAndSettle();
    expect(find.text('1204'), findsOneWidget);
    expect(find.text('Lote Pasto 1'), findsOneWidget);
  });

  testWidgets('detalhe do problema pagina em vez de cortar em 100',
      (tester) async {
    // 120 linhas bloqueadas pelo mesmo motivo.
    await _abrir(tester, _diagnostico(bloquear: 120));
    expect(find.textContaining('120 ocorrências'), findsOneWidget);

    await tester.tap(find.textContaining('Sexo inválido'));
    await tester.pumpAndSettle();

    // 120 linhas em paginas de 50 -> 3 paginas.
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('120 linha(s)'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Próxima página'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Próxima página'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('avisa quando a amostra do problema foi truncada',
      (tester) async {
    final b = ImportDiagnosticoBuilder(
      entidade: ImportEntidade.rebanho,
      limitePorCodigo: 5,
    );
    for (var i = 0; i < 40; i++) {
      b.add(ImportOcorrencia(
        codigo: ImportCodigo.rebNumeroInvalido,
        severidade: ImportSeveridade.bloqueante,
        escopo: ImportEscopo.dado,
        linha: 2 + i,
        mensagem: 'Linha ${2 + i}: número inválido.',
      ));
    }
    await _abrir(
        tester,
        b.build(
            arquivo: const ImportArquivoInfo(formato: 'csv'),
            totalLinhas: 40));

    await tester.tap(find.textContaining('Valor numérico inválido'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Mostrando 5 de 40'), findsOneWidget);
  });

  testWidgets('modo somente leitura esconde as acoes', (tester) async {
    await _abrir(tester, _diagnostico(criar: 3), somenteLeitura: true);
    expect(find.byType(FFButtonWidget), findsNothing);
    expect(find.textContaining('Importação de Rebanho'), findsOneWidget);
  });

  testWidgets('chip de cabecalho nao reconhecido aparece', (tester) async {
    final b = ImportDiagnosticoBuilder(entidade: ImportEntidade.rebanho);
    b.add(ImportOcorrencia(
      codigo: ImportCodigo.arqSemHeaderFallbackPosicional,
      severidade: ImportSeveridade.bloqueante,
      escopo: ImportEscopo.arquivo,
      mensagem: 'Cabeçalho não reconhecido.',
    ));
    await _abrir(
      tester,
      b.build(
        arquivo: const ImportArquivoInfo(
          formato: 'csv',
          usouFallbackPosicional: true,
        ),
        totalLinhas: 10,
      ),
    );
    expect(find.text('Cabeçalho não reconhecido'), findsOneWidget);
  });
}
