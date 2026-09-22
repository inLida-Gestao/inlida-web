// A conversao ImportDiagnostico -> payloads da auditoria e pura, entao da para
// testar o truncamento sem tocar o Supabase. O ponto e garantir que o resumo
// nunca perde contagem e que os itens respeitam os tetos.
import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/importacao/import_auditoria_repository.dart';
import 'package:in_lida_web/importacao/import_diagnostico_model.dart';

ImportDiagnostico _comOcorrencias({
  required int porCodigo,
  required int codigos,
  int limitePorCodigo = kLimiteOcorrenciasPorCodigo,
}) {
  final b = ImportDiagnosticoBuilder(
    entidade: ImportEntidade.rebanho,
    limitePorCodigo: limitePorCodigo,
  );
  var linha = 1;
  for (var c = 0; c < codigos; c++) {
    for (var i = 0; i < porCodigo; i++) {
      b.add(ImportOcorrencia(
        codigo: 'CODIGO_$c',
        severidade: ImportSeveridade.bloqueante,
        escopo: ImportEscopo.dado,
        linha: ++linha,
        mensagem: 'erro',
      ));
    }
  }
  return b.build(
      arquivo: const ImportArquivoInfo(formato: 'csv'),
      totalLinhas: porCodigo * codigos);
}

void main() {
  test('tetos declarados sao os do plano de retencao', () {
    expect(kMaxItensPorCodigo, 50);
    expect(kMaxItensPorAuditoria, 1000);
  });

  test('o resumo cobre todos os codigos com a contagem real', () {
    final d = _comOcorrencias(porCodigo: 8000, codigos: 3);
    final resumo = d.problemasAgregados;

    expect(resumo, hasLength(3));
    for (final p in resumo) {
      expect(p.quantidade, 8000,
          reason: 'a contagem nao pode ser afetada pelo truncamento');
      expect(p.linhasAmostra.length, lessThanOrEqualTo(50));
    }
    expect(d.amostraTruncada, isTrue);
  });

  test('sha1 identifica o mesmo arquivo e distingue arquivos diferentes', () {
    final a = sha1DoArquivo([1, 2, 3, 4]);
    final b = sha1DoArquivo([1, 2, 3, 4]);
    final c = sha1DoArquivo([1, 2, 3, 5]);

    expect(a, isNotNull);
    expect(a, b, reason: 'reenvio do mesmo arquivo precisa dar o mesmo hash');
    expect(a, isNot(c));
    expect(sha1DoArquivo(null), isNull);
    expect(sha1DoArquivo(const []), isNull);
  });

  test('o valor da ocorrencia cabe no limite da coluna', () {
    // A coluna valor tem check de 400 chars; o modelo trunca em 120.
    final o = ImportOcorrencia(
      codigo: 'X',
      severidade: ImportSeveridade.aviso,
      escopo: ImportEscopo.dado,
      mensagem: 'm',
      valor: 'z' * 5000,
    );
    expect(o.valor!.length, lessThan(400));
  });

  test('nomes dos enums batem com os CHECK da migration', () {
    // Se um enum for renomeado sem atualizar a migration, o insert quebra em
    // producao. Este teste trava os nomes.
    expect(ImportSeveridade.values.map((e) => e.name).toSet(),
        {'bloqueante', 'aviso', 'informativo'});
    expect(ImportEscopo.values.map((e) => e.name).toSet(),
        {'arquivo', 'dado', 'consistencia', 'semantica'});
    expect(ImportAcaoLinha.values.map((e) => e.name).toSet(),
        {'criar', 'atualizar', 'bloquear'});
    expect(ImportEntidade.values.map((e) => e.name).toSet(),
        {'rebanho', 'pesagem'});
  });
}
