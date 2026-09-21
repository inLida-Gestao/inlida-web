import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/importacao/import_diagnostico_model.dart';

ImportOcorrencia _oc(
  String codigo,
  ImportSeveridade sev, {
  int? linha,
  ImportEscopo escopo = ImportEscopo.dado,
}) =>
    ImportOcorrencia(
      codigo: codigo,
      severidade: sev,
      escopo: escopo,
      linha: linha,
      mensagem: 'msg',
    );

void main() {
  group('acaoPorLinha', () {
    test('bloqueante vence criar e atualizar, em qualquer ordem', () {
      final b = ImportDiagnosticoBuilder(entidade: ImportEntidade.rebanho);
      b.marcarCriar(2);
      b.add(_oc(ImportCodigo.rebSemIdentidade, ImportSeveridade.bloqueante,
          linha: 2));
      b.marcarAtualizar(2);

      b.add(_oc(ImportCodigo.rebSemIdentidade, ImportSeveridade.bloqueante,
          linha: 3));
      b.marcarCriar(3);

      final d = b.build(arquivo: const ImportArquivoInfo(), totalLinhas: 2);
      expect(d.acaoPorLinha[2], ImportAcaoLinha.bloquear);
      expect(d.acaoPorLinha[3], ImportAcaoLinha.bloquear);
      expect(d.totalBloquear, 2);
      expect(d.totalImportavel, 0);
    });

    test('atualizar sobrepoe criar e alimenta a lista de sobrescrita', () {
      final b = ImportDiagnosticoBuilder(entidade: ImportEntidade.rebanho);
      b.marcarCriar(2);
      b.marcarAtualizar(2, resumo: {'linha': 2, 'numeroAnimal': '1204'});
      b.marcarCriar(3);

      final d = b.build(arquivo: const ImportArquivoInfo(), totalLinhas: 2);
      expect(d.totalAtualizar, 1);
      expect(d.totalCriar, 1);
      expect(d.registrosAtualizados.single['numeroAnimal'], '1204');
    });

    test('aviso nao bloqueia a linha', () {
      final b = ImportDiagnosticoBuilder(entidade: ImportEntidade.rebanho);
      b.marcarCriar(2);
      b.add(_oc(ImportCodigo.rebAnoImplausivel, ImportSeveridade.aviso,
          linha: 2));
      final d = b.build(arquivo: const ImportArquivoInfo(), totalLinhas: 1);
      expect(d.acaoPorLinha[2], ImportAcaoLinha.criar);
      expect(d.temBloqueio, isFalse);
      expect(d.temAviso, isTrue);
    });
  });

  group('registrosValidos', () {
    test('remove apenas as linhas bloqueadas, preservando as demais', () {
      final b = ImportDiagnosticoBuilder(entidade: ImportEntidade.rebanho);
      b.add(_oc(ImportCodigo.rebSemIdentidade, ImportSeveridade.bloqueante,
          linha: 3));
      final d = b.build(arquivo: const ImportArquivoInfo(), totalLinhas: 3);

      final registros = [
        {kCampoLinhaArquivo: 2, 'numeroAnimal': 'A'},
        {kCampoLinhaArquivo: 3, 'numeroAnimal': 'B'},
        {kCampoLinhaArquivo: 4, 'numeroAnimal': 'C'},
      ];
      final validos = d.registrosValidos(registros);
      expect(validos.map((r) => r['numeroAnimal']), ['A', 'C']);
    });

    test('sem bloqueio devolve tudo', () {
      final d = ImportDiagnosticoBuilder(entidade: ImportEntidade.rebanho)
          .build(arquivo: const ImportArquivoInfo(), totalLinhas: 2);
      final registros = [
        {kCampoLinhaArquivo: 2},
        {kCampoLinhaArquivo: 3},
      ];
      expect(d.registrosValidos(registros).length, 2);
    });
  });

  group('volume', () {
    test('trunca a amostra mas mantem o agregado exato', () {
      final b = ImportDiagnosticoBuilder(
        entidade: ImportEntidade.rebanho,
        limitePorCodigo: 5000,
      );
      // Erro sistematico numa planilha grande: 200 mil linhas com o mesmo codigo.
      for (var linha = 2; linha < 200002; linha++) {
        b.add(_oc(ImportCodigo.rebDataFormatoNaoReconhecido,
            ImportSeveridade.bloqueante,
            linha: linha));
      }
      final d = b.build(arquivo: const ImportArquivoInfo(), totalLinhas: 200000);

      final p = d.problemasAgregados.single;
      expect(p.quantidade, 200000, reason: 'a contagem real nao pode truncar');
      expect(p.ocorrencias.length, 5000, reason: 'a amostra e limitada');
      expect(p.truncado, isTrue);
      expect(p.linhasAmostra.length, 50, reason: 'exibicao usa ate 50 linhas');
      expect(d.amostraTruncada, isTrue);
      // Bloqueio continua valendo para TODAS as linhas, nao so para a amostra.
      expect(d.totalBloquear, 200000);
      expect(d.totalBloqueantes, 200000);
    });
  });

  group('problemasAgregados', () {
    test('ordena bloqueantes primeiro e, dentro disso, os mais frequentes', () {
      final b = ImportDiagnosticoBuilder(entidade: ImportEntidade.rebanho);
      b.add(_oc(ImportCodigo.rebAnoImplausivel, ImportSeveridade.aviso,
          linha: 2));
      for (var i = 0; i < 3; i++) {
        b.add(_oc(ImportCodigo.rebSexoForaDoDominio,
            ImportSeveridade.bloqueante,
            linha: 10 + i));
      }
      for (var i = 0; i < 7; i++) {
        b.add(_oc(ImportCodigo.rebNumeroInvalido, ImportSeveridade.bloqueante,
            linha: 20 + i));
      }
      b.add(_oc(ImportCodigo.arqMultiplasAbas, ImportSeveridade.informativo,
          escopo: ImportEscopo.arquivo));

      final codigos = b
          .build(arquivo: const ImportArquivoInfo(), totalLinhas: 30)
          .problemasAgregados
          .map((p) => p.codigo)
          .toList();

      expect(codigos, [
        ImportCodigo.rebNumeroInvalido, // bloqueante, 7
        ImportCodigo.rebSexoForaDoDominio, // bloqueante, 3
        ImportCodigo.rebAnoImplausivel, // aviso
        ImportCodigo.arqMultiplasAbas, // informativo
      ]);
    });

    test('todo codigo do catalogo tem titulo em portugues', () {
      // Protege contra exibir o codigo cru (ex. "REB_SEM_IDENTIDADE") na tela.
      final semTitulo = <String>[];
      for (final entry in tituloDoCodigo.entries) {
        if (entry.value.trim().isEmpty) semTitulo.add(entry.key);
      }
      expect(semTitulo, isEmpty);
      expect(tituloDoCodigo.length, greaterThan(50));
    });
  });

  test('valor da ocorrencia e truncado para nao inflar a auditoria', () {
    final o = ImportOcorrencia(
      codigo: ImportCodigo.rebTextoCorrompido,
      severidade: ImportSeveridade.bloqueante,
      escopo: ImportEscopo.dado,
      mensagem: 'msg',
      valor: 'x' * 500,
    );
    expect(o.valor!.length, lessThanOrEqualTo(121));
  });
}
