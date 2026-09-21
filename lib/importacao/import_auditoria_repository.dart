// Persistencia da trilha de auditoria de importacao.
//
// Regra nao-negociavel deste arquivo: a auditoria NUNCA pode quebrar a
// importacao. Toda operacao e envolvida em try/catch que apenas registra no
// console; se a tabela nao existir, a RLS recusar ou a rede cair, `abrir`
// devolve null e o handle vira um no-op silencioso. Registrar o que aconteceu
// e util, mas nao mais importante do que a planilha do produtor entrar.
//
// Volume: o resumo por codigo vai completo (no maximo ~60 linhas por
// importacao), e os itens sao truncados -- 50 por codigo e 1000 por auditoria.
// Sem isso uma planilha de 175 mil linhas com um erro sistematico geraria 175
// mil linhas de detalhe que ninguem leria.

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '/backend/supabase/supabase.dart';

import 'import_diagnostico_model.dart';

/// Ate quantos itens detalhados guardar por codigo de problema.
const kMaxItensPorCodigo = 50;

/// Teto de itens detalhados por importacao.
const kMaxItensPorAuditoria = 1000;

String _severidadeSql(ImportSeveridade s) => s.name;
String _escopoSql(ImportEscopo e) => e.name;
String _acaoSql(ImportAcaoLinha a) => a.name;

String _decisaoSql(ImportDecisaoAuditoria d) => switch (d) {
      ImportDecisaoAuditoria.cancelou => 'cancelou',
      ImportDecisaoAuditoria.importouValidos => 'importou_validos',
      ImportDecisaoAuditoria.forcou => 'forcou',
      ImportDecisaoAuditoria.naoConfirmou => 'nao_confirmou',
    };

/// Espelha a coluna `decisao`. Enum proprio para nao acoplar a persistencia ao
/// enum do widget.
enum ImportDecisaoAuditoria { cancelou, importouValidos, forcou, naoConfirmou }

/// Calcula o sha1 do arquivo, usado para identificar o reenvio do mesmo
/// arquivo sem correcao -- sinal de que o usuario nao entendeu a mensagem.
String? sha1DoArquivo(List<int>? bytes) {
  if (bytes == null || bytes.isEmpty) return null;
  try {
    return sha1.convert(bytes).toString();
  } catch (e) {
    debugPrint('Auditoria: falha ao calcular sha1 do arquivo: $e');
    return null;
  }
}

/// Nome e e-mail de quem esta importando, para o snapshot da auditoria.
///
/// A policy `users_select_own` deixa o usuario ler apenas o proprio registro
/// em `public.users`, entao guardar so o UUID tornaria impossivel responder
/// "quem da equipe fez esta importacao". A fonte aqui e
/// `users_propriedades`, legivel por quem tem acesso a propriedade.
///
/// Nunca lanca: sem nome, a auditoria ainda vale pelo usuario_id.
Future<({String? nome, String? email})> _autorDaImportacao(
  String idPropriedade,
) async {
  final usuario = SupaFlow.client.auth.currentUser;
  final emailDaSessao = usuario?.email;
  if (usuario == null) return (nome: null, email: emailDaSessao);

  try {
    final res = await SupaFlow.client
        .from('users_propriedades')
        .select('nome,email')
        .eq('user_id', usuario.id)
        .eq('idPropriedade', idPropriedade)
        .limit(1)
        .maybeSingle();

    if (res != null) {
      final nome = res['nome']?.toString().trim();
      final email = res['email']?.toString().trim();
      return (
        nome: (nome == null || nome.isEmpty) ? null : nome,
        email: (email == null || email.isEmpty) ? emailDaSessao : email,
      );
    }
  } catch (e) {
    debugPrint('Auditoria: nao foi possivel resolver o autor: $e');
  }
  return (nome: null, email: emailDaSessao);
}

class ImportAuditoriaRepository {
  /// Abre a auditoria e grava o diagnostico. Devolve null quando a gravacao
  /// falha -- e o chamador segue a importacao normalmente.
  Future<ImportAuditoriaHandle?> abrir({
    required ImportDiagnostico diagnostico,
    required String idPropriedade,
    List<int>? bytesDoArquivo,
    int? duracaoParseMs,
    int? duracaoDiagnosticoMs,
  }) async {
    try {
      final arquivo = diagnostico.arquivo;
      final autor = await _autorDaImportacao(idPropriedade);
      final payload = <String, dynamic>{
        'id_propriedade': idPropriedade,
        'usuario_id': SupaFlow.client.auth.currentUser?.id,
        'usuario_nome': autor.nome,
        'usuario_email': autor.email,
        'entidade': diagnostico.entidade.name,
        'entidade_detectada': arquivo.entidadeDetectada?.name,
        'nome_arquivo': arquivo.nomeArquivo,
        'arquivo_tamanho_bytes': arquivo.tamanhoBytes,
        'arquivo_sha1': arquivo.sha1 ?? sha1DoArquivo(bytesDoArquivo),
        'formato': arquivo.formato,
        'delimitador': arquivo.delimitador,
        'encoding_usado': arquivo.encodingUsado,
        'aba_usada': arquivo.abaUsada,
        'usou_fallback_posicional': arquivo.usouFallbackPosicional,
        'total_linhas': diagnostico.totalLinhas,
        'total_bloqueantes': diagnostico.totalBloqueantes,
        'total_avisos': diagnostico.totalAvisos,
        'previstos_criar': diagnostico.totalCriar,
        'previstos_atualizar': diagnostico.totalAtualizar,
        'previstos_bloquear': diagnostico.totalBloquear,
        'status': 'aguardando_confirmacao',
        'itens_truncados': diagnostico.amostraTruncada,
        'duracao_parse_ms': duracaoParseMs,
        'duracao_diagnostico_ms': duracaoDiagnosticoMs,
        'app_version': kAppVersionImportacao,
      };

      final res = await SupaFlow.client
          .from('import_auditoria')
          .insert(payload)
          .select('id')
          .single();

      final id = res['id']?.toString();
      if (id == null) return null;

      final handle = ImportAuditoriaHandle._(id);
      await handle._gravarDiagnostico(diagnostico);
      return handle;
    } catch (e) {
      debugPrint('Auditoria de importacao indisponivel (seguindo sem ela): $e');
      return null;
    }
  }
}

/// Referencia a uma auditoria aberta. Todos os metodos sao tolerantes a falha.
class ImportAuditoriaHandle {
  ImportAuditoriaHandle._(this.id);

  final String id;

  Future<void> _gravarDiagnostico(ImportDiagnostico d) async {
    final resumos = <Map<String, dynamic>>[];
    final itens = <Map<String, dynamic>>[];
    var totalItens = 0;

    for (final p in d.problemasAgregados) {
      resumos.add({
        'auditoria_id': id,
        'codigo': p.codigo,
        'severidade': _severidadeSql(p.severidade),
        'escopo': _escopoSql(p.escopo),
        'coluna': p.coluna,
        'quantidade': p.quantidade,
        'linhas_amostra': p.linhasAmostra,
        'mensagem': p.titulo,
      });

      var doCodigo = 0;
      for (final o in p.ocorrencias) {
        if (doCodigo >= kMaxItensPorCodigo) break;
        if (totalItens >= kMaxItensPorAuditoria) break;
        itens.add({
          'auditoria_id': id,
          'linha': o.linha,
          'severidade': _severidadeSql(o.severidade),
          'escopo': _escopoSql(o.escopo),
          'codigo': o.codigo,
          'coluna': o.coluna,
          'valor': o.valor,
          'mensagem': o.mensagem,
          'acao_resultante': o.linha == null
              ? null
              : (d.acaoPorLinha[o.linha] == null
                  ? null
                  : _acaoSql(d.acaoPorLinha[o.linha]!)),
        });
        doCodigo++;
        totalItens++;
      }
    }

    await _inserirEmLote('import_auditoria_resumo', resumos);
    await _inserirEmLote('import_auditoria_item', itens);
  }

  Future<void> _inserirEmLote(
    String tabela,
    List<Map<String, dynamic>> linhas,
  ) async {
    if (linhas.isEmpty) return;
    const chunk = 500;
    for (var i = 0; i < linhas.length; i += chunk) {
      final fatia = linhas.sublist(
          i, i + chunk > linhas.length ? linhas.length : i + chunk);
      try {
        await SupaFlow.client.from(tabela).insert(fatia);
      } catch (e) {
        debugPrint('Auditoria: falha ao gravar em $tabela: $e');
        return;
      }
    }
  }

  Future<void> _atualizar(Map<String, dynamic> campos) async {
    try {
      await SupaFlow.client
          .from('import_auditoria')
          .update(campos)
          .eq('id', id);
    } catch (e) {
      debugPrint('Auditoria: falha ao atualizar $id: $e');
    }
  }

  /// O usuario viu o relatorio e desistiu. E o registro mais valioso para
  /// entender o que trava a importacao na pratica.
  Future<void> finalizarCancelada() => _atualizar({
        'status': 'cancelada',
        'decisao': _decisaoSql(ImportDecisaoAuditoria.cancelou),
        'finished_at': DateTime.now().toIso8601String(),
      });

  /// A importacao terminou.
  Future<void> finalizar({
    required Map<String, dynamic> resultado,
    required ImportDecisaoAuditoria decisao,
    int? duracaoEscritaMs,
  }) {
    final sucesso = resultado['success'] == true;
    final falhados = (resultado['failed'] as num?)?.toInt() ?? 0;
    return _atualizar({
      'status': !sucesso || falhados > 0 ? 'parcial' : 'sucesso',
      'decisao': _decisaoSql(decisao),
      'criados': (resultado['created'] as num?)?.toInt() ?? 0,
      'atualizados': (resultado['updated'] as num?)?.toInt() ?? 0,
      'falhados': falhados,
      'duracao_escrita_ms': duracaoEscritaMs,
      'finished_at': DateTime.now().toIso8601String(),
    });
  }

  /// A importacao estourou.
  Future<void> falhar(Object erro) => _atualizar({
        'status': 'erro',
        'erro': erro.toString(),
        'finished_at': DateTime.now().toIso8601String(),
      });
}

// ---------------------------------------------------------------------------
// Leitura de volta
// ---------------------------------------------------------------------------

ImportSeveridade severidadeDoTexto(String? v) => switch (v) {
      'bloqueante' => ImportSeveridade.bloqueante,
      'informativo' => ImportSeveridade.informativo,
      _ => ImportSeveridade.aviso,
    };

ImportEscopo escopoDoTexto(String? v) => switch (v) {
      'arquivo' => ImportEscopo.arquivo,
      'consistencia' => ImportEscopo.consistencia,
      'semantica' => ImportEscopo.semantica,
      _ => ImportEscopo.dado,
    };

ImportEntidade entidadeDoTexto(String? v) =>
    v == 'pesagem' ? ImportEntidade.pesagem : ImportEntidade.rebanho;

/// Remonta o diagnostico a partir do que foi gravado, para a tela de historico
/// reabrir o MESMO popup que o usuario viu antes de confirmar.
///
/// Duas coisas precisam de cuidado aqui:
///  - as contagens vem do RESUMO, nunca dos itens: os itens sao amostra
///    truncada, e usa-los daria numeros menores que a realidade;
///  - o detalhe gravado nao inclui uma linha por registro criado, entao as
///    acoes por linha sao reconstruidas a partir dos totais do job. Isso
///    sustenta os cartoes de resumo, que e o que a tela mostra, e nao pretende
///    reproduzir qual linha especifica virou o que.
ImportDiagnostico remontarDiagnosticoDaAuditoria({
  required Map<String, dynamic> auditoria,
  required List<Map<String, dynamic>> resumos,
  required List<Map<String, dynamic>> itens,
}) {
  final entidade = entidadeDoTexto(auditoria['entidade']?.toString());
  final builder = ImportDiagnosticoBuilder(entidade: entidade);

  for (final item in itens) {
    builder.add(ImportOcorrencia(
      codigo: item['codigo']?.toString() ?? '',
      severidade: severidadeDoTexto(item['severidade']?.toString()),
      escopo: escopoDoTexto(item['escopo']?.toString()),
      linha: item['linha'] is int
          ? item['linha'] as int
          : int.tryParse(item['linha']?.toString() ?? ''),
      coluna: item['coluna']?.toString(),
      valor: item['valor']?.toString(),
      mensagem: item['mensagem']?.toString() ?? '',
    ));
  }

  final base = builder.build(
    arquivo: ImportArquivoInfo(
      nomeArquivo: auditoria['nome_arquivo']?.toString(),
      tamanhoBytes: (auditoria['arquivo_tamanho_bytes'] as num?)?.toInt(),
      sha1: auditoria['arquivo_sha1']?.toString(),
      formato: auditoria['formato']?.toString() ?? 'desconhecido',
      delimitador: auditoria['delimitador']?.toString(),
      encodingUsado: auditoria['encoding_usado']?.toString(),
      abaUsada: auditoria['aba_usada']?.toString(),
      usouFallbackPosicional: auditoria['usou_fallback_posicional'] == true,
    ),
    totalLinhas: (auditoria['total_linhas'] as num?)?.toInt() ?? 0,
  );

  // Linhas negativas e sinteticas: servem so para os contadores, e nao colidem
  // com as linhas reais do arquivo, que sao positivas.
  final acoes = <int, ImportAcaoLinha>{};
  var sintetica = 0;
  void preencher(Object? quantidade, ImportAcaoLinha acao) {
    final n = (quantidade as num?)?.toInt() ?? 0;
    for (var i = 0; i < n; i++) {
      acoes[--sintetica] = acao;
    }
  }

  preencher(auditoria['previstos_criar'], ImportAcaoLinha.criar);
  preencher(auditoria['previstos_atualizar'], ImportAcaoLinha.atualizar);
  preencher(auditoria['previstos_bloquear'], ImportAcaoLinha.bloquear);

  return ImportDiagnostico(
    entidade: base.entidade,
    arquivo: base.arquivo,
    totalLinhas: base.totalLinhas,
    ocorrencias: base.ocorrencias,
    contagemPorCodigo: {
      for (final r in resumos)
        (r['codigo']?.toString() ?? ''):
            (r['quantidade'] as num?)?.toInt() ?? 0,
    },
    acaoPorLinha: acoes,
  );
}
