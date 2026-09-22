// A tela de historico reabre o MESMO popup que o usuario viu antes de
// confirmar. Isso so funciona se a remontagem a partir do que foi gravado for
// fiel -- em especial nas contagens, que vem do resumo (completo) e nao dos
// itens (amostra truncada).
import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/importacao/import_auditoria_repository.dart';
import 'package:in_lida_web/importacao/import_diagnostico_model.dart';

Map<String, dynamic> _auditoria({
  int criar = 0,
  int atualizar = 0,
  int bloquear = 0,
  int totalLinhas = 0,
  bool fallback = false,
}) =>
    {
      'id': 'uuid-1',
      'entidade': 'rebanho',
      'nome_arquivo': 'rebanho.csv',
      'formato': 'csv',
      'delimitador': ';',
      'encoding_usado': 'utf-8',
      'usou_fallback_posicional': fallback,
      'total_linhas': totalLinhas,
      'previstos_criar': criar,
      'previstos_atualizar': atualizar,
      'previstos_bloquear': bloquear,
    };

void main() {
  test('as contagens vem do resumo, nao da amostra de itens', () {
    // No banco: 8000 ocorrencias do codigo, mas so 50 itens guardados.
    final d = remontarDiagnosticoDaAuditoria(
      auditoria: _auditoria(totalLinhas: 8000, bloquear: 8000),
      resumos: [
        {
          'codigo': 'REB_DATA_FORMATO_NAO_RECONHECIDO',
          'quantidade': 8000,
        }
      ],
      itens: [
        for (var i = 0; i < 50; i++)
          {
            'codigo': 'REB_DATA_FORMATO_NAO_RECONHECIDO',
            'severidade': 'bloqueante',
            'escopo': 'dado',
            'linha': 2 + i,
            'mensagem': 'Linha ${2 + i}: data inválida.',
          }
      ],
    );

    final p = d.problemasAgregados.single;
    expect(p.quantidade, 8000, reason: 'o numero real veio do resumo');
    expect(p.ocorrencias.length, 50);
    expect(p.truncado, isTrue, reason: 'o popup precisa avisar que e amostra');
    expect(d.totalBloquear, 8000, reason: 'veio dos totais do job');
  });

  test('reconstroi os cartoes de criados, atualizados e bloqueados', () {
    final d = remontarDiagnosticoDaAuditoria(
      auditoria: _auditoria(
          criar: 120, atualizar: 38, bloquear: 5, totalLinhas: 163),
      resumos: const [],
      itens: const [],
    );
    expect(d.totalCriar, 120);
    expect(d.totalAtualizar, 38);
    expect(d.totalBloquear, 5);
    expect(d.totalImportavel, 158);
    expect(d.totalLinhas, 163);
  });

  test('linhas sinteticas nao colidem com as linhas reais do arquivo', () {
    final d = remontarDiagnosticoDaAuditoria(
      auditoria: _auditoria(criar: 3, bloquear: 1),
      resumos: const [],
      itens: const [
        {
          'codigo': 'X',
          'severidade': 'bloqueante',
          'escopo': 'dado',
          'linha': 2,
          'mensagem': 'erro na linha 2',
        }
      ],
    );
    // As acoes usam indices negativos; a ocorrencia real aponta para a linha 2.
    expect(d.acaoPorLinha.keys.every((k) => k < 0), isTrue);
    expect(d.ocorrencias.single.linha, 2);
  });

  test('preserva os metadados do arquivo', () {
    final d = remontarDiagnosticoDaAuditoria(
      auditoria: _auditoria(fallback: true),
      resumos: const [],
      itens: const [],
    );
    expect(d.arquivo.nomeArquivo, 'rebanho.csv');
    expect(d.arquivo.delimitador, ';');
    expect(d.arquivo.usouFallbackPosicional, isTrue);
  });

  test('converte os textos do banco de volta para os enums', () {
    expect(severidadeDoTexto('bloqueante'), ImportSeveridade.bloqueante);
    expect(severidadeDoTexto('informativo'), ImportSeveridade.informativo);
    expect(severidadeDoTexto(null), ImportSeveridade.aviso);
    expect(escopoDoTexto('consistencia'), ImportEscopo.consistencia);
    expect(escopoDoTexto('semantica'), ImportEscopo.semantica);
    expect(escopoDoTexto('qualquer'), ImportEscopo.dado);
    expect(entidadeDoTexto('pesagem'), ImportEntidade.pesagem);
    expect(entidadeDoTexto('rebanho'), ImportEntidade.rebanho);
  });
}
