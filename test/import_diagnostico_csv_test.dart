import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/importacao/import_diagnostico_csv.dart';
import 'package:in_lida_web/importacao/import_diagnostico_model.dart';

void main() {
  test('cabecalho e uma linha por ocorrencia', () {
    final b = ImportDiagnosticoBuilder(entidade: ImportEntidade.rebanho);
    b.marcarCriar(2);
    b.add(ImportOcorrencia(
      codigo: ImportCodigo.rebSexoForaDoDominio,
      severidade: ImportSeveridade.bloqueante,
      escopo: ImportEscopo.dado,
      linha: 3,
      coluna: 'sexo',
      valor: 'Femia',
      mensagem: 'Linha 3: Sexo "Femia" não é válido.',
      sugestao: 'Use Fêmea ou Macho.',
    ));

    final csv = montarDiagnosticoCsv(
        b.build(arquivo: const ImportArquivoInfo(), totalLinhas: 2));
    final linhas = csv.trim().split('\n');
    expect(linhas.first,
        'Linha;Severidade;Codigo;Escopo;Coluna;Valor;Mensagem;Sugestao;Acao');
    expect(linhas[1], contains('REB_SEXO_FORA_DO_DOMINIO'));
    expect(linhas[1], contains('Bloqueante'));
    expect(linhas[1], contains('Bloqueado'),
        reason: 'a coluna Acao mostra o destino da linha');
  });

  test('escapa ponto e virgula, aspas e quebra de linha', () {
    final b = ImportDiagnosticoBuilder(entidade: ImportEntidade.rebanho);
    b.add(ImportOcorrencia(
      codigo: ImportCodigo.rebTextoCorrompido,
      severidade: ImportSeveridade.bloqueante,
      escopo: ImportEscopo.dado,
      linha: 2,
      valor: 'a;b"c',
      mensagem: 'tem ; e "aspas"',
    ));
    final csv = montarDiagnosticoCsv(
        b.build(arquivo: const ImportArquivoInfo(), totalLinhas: 1));
    expect(csv, contains('"a;b""c"'));
    expect(csv, contains('"tem ; e ""aspas"""'));
  });

  test('avisa quando a amostra foi truncada', () {
    final b = ImportDiagnosticoBuilder(
      entidade: ImportEntidade.rebanho,
      limitePorCodigo: 3,
    );
    for (var i = 0; i < 10; i++) {
      b.add(ImportOcorrencia(
        codigo: ImportCodigo.rebNumeroInvalido,
        severidade: ImportSeveridade.bloqueante,
        escopo: ImportEscopo.dado,
        linha: 2 + i,
        mensagem: 'erro',
      ));
    }
    final csv = montarDiagnosticoCsv(
        b.build(arquivo: const ImportArquivoInfo(), totalLinhas: 10));
    expect(csv, contains('10 ocorrencias'));
    expect(csv, contains('apenas 3 foram detalhadas'));
  });

  test('nome do arquivo tem entidade e carimbo de tempo', () {
    final nome = nomeArquivoDiagnostico('Rebanho',
        agora: DateTime(2026, 9, 21, 14, 5, 9));
    expect(nome, 'diagnostico_importacao_rebanho_20260921_140509.csv');
  });
}
