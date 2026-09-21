// Orquestrador do diagnostico: junta o que o parser observou, as regras locais
// e o confronto com o banco num unico relatorio.
//
// O ImportContexto existe para que a leitura do banco aconteca UMA vez por
// importacao e seja reaproveitada pela gravacao. Sem isso, diagnosticar e
// depois gravar leria a tabela `rebanho` da propriedade duas vezes.

import 'diagnostico_pesagem.dart';
import 'diagnostico_rebanho.dart';
import 'import_diagnostico_model.dart';
import 'import_erro_amigavel.dart';
import 'import_lookups.dart';

/// Dados do banco carregados para uma importacao.
class ImportContexto {
  final String idPropriedade;
  final RebanhoDbLookup lookup;

  /// Chaves de pesagens ja existentes. Carregado apenas no fluxo de pesagem.
  final Set<String> chavesPesagemExistentes;

  /// Quanto tempo a leitura levou, para a auditoria medir o custo.
  final int duracaoMs;

  const ImportContexto({
    required this.idPropriedade,
    required this.lookup,
    this.chavesPesagemExistentes = const {},
    this.duracaoMs = 0,
  });
}

/// Carrega o contexto para uma importacao de Rebanho.
Future<ImportContexto> carregarContextoRebanho(String idPropriedade) async {
  final inicio = DateTime.now();
  final lookup = await fetchRebanhoDbLookup(idPropriedade);
  return ImportContexto(
    idPropriedade: idPropriedade,
    lookup: lookup,
    duracaoMs: DateTime.now().difference(inicio).inMilliseconds,
  );
}

/// Carrega o contexto para uma importacao de Pesagem.
///
/// Busca as pesagens existentes apenas dos animais que a planilha menciona --
/// em blocos, e nao uma consulta por linha como faz o caminho de gravacao.
Future<ImportContexto> carregarContextoPesagem(
  String idPropriedade,
  List<dynamic> registros,
) async {
  final inicio = DateTime.now();
  final lookup = await fetchRebanhoDbLookup(idPropriedade);

  final ids = <String>{};
  for (final bruto in registros) {
    if (bruto is! Map) continue;
    final res = lookup.resolver(
      numeroAnimal: bruto['numeroAnimal']?.toString(),
      nome: bruto['nome']?.toString(),
      dataNascimento: bruto['dataNascimento']?.toString(),
      sexo: bruto['sexo']?.toString(),
      raca: bruto['raca']?.toString(),
    );
    if (res.idRebanho != null) ids.add(res.idRebanho!);
  }

  final chaves = await fetchChavesPesagemExistentes(
    idPropriedade: idPropriedade,
    idsRebanho: ids,
  );

  return ImportContexto(
    idPropriedade: idPropriedade,
    lookup: lookup,
    chavesPesagemExistentes: chaves,
    duracaoMs: DateTime.now().difference(inicio).inMilliseconds,
  );
}

/// Monta o relatorio completo de uma importacao.
///
/// [contexto] pode ser omitido para obter apenas o diagnostico local (sem
/// confronto com o banco) -- util em teste e no caso de a leitura falhar.
ImportDiagnostico diagnosticarImportacao({
  required ImportEntidade entidade,
  required ImportParseResult parse,
  ImportContexto? contexto,
  DateTime? hoje,
  int limitePorCodigo = kLimiteOcorrenciasPorCodigo,
}) {
  final builder = ImportDiagnosticoBuilder(
    entidade: entidade,
    limitePorCodigo: limitePorCodigo,
  );

  // O que o parser observou vem primeiro: erro de arquivo bloqueia tudo, e
  // linha reprovada na leitura ja entra bloqueada.
  builder.addTodas(parse.ocorrencias);

  switch (entidade) {
    case ImportEntidade.rebanho:
      diagnosticarRebanhoLocal(
        builder: builder,
        registros: parse.registros,
        hoje: hoje,
      );
      if (contexto != null) {
        diagnosticarRebanhoConsistencia(
          builder: builder,
          registros: parse.registros,
          idPropriedade: contexto.idPropriedade,
          lookup: contexto.lookup,
        );
      }
    case ImportEntidade.pesagem:
      diagnosticarPesagemLocal(
        builder: builder,
        registros: parse.registros,
        hoje: hoje,
      );
      if (contexto != null) {
        diagnosticarPesagemConsistencia(
          builder: builder,
          registros: parse.registros,
          lookup: contexto.lookup,
          chavesPesagemExistentes: contexto.chavesPesagemExistentes,
        );
      }
  }

  // Sem contexto nao houve confronto com o banco, entao nenhuma linha foi
  // classificada: tudo o que nao esta bloqueado conta como criacao.
  if (contexto == null) {
    for (final bruto in parse.registros) {
      if (bruto is! Map) continue;
      final linha = bruto[kCampoLinhaArquivo];
      if (linha is int) builder.marcarCriar(linha);
    }
  }

  return builder.build(
    arquivo: parse.arquivo,
    totalLinhas: parse.totalLinhas,
  );
}

/// Monta um diagnostico a partir das linhas que o BANCO recusou durante a
/// gravacao.
///
/// Serve para reaproveitar o popup no relatorio pos-importacao, em modo
/// somente leitura, em vez dos AlertDialog com take(100) que existiam em cada
/// tela. A mensagem tecnica do Postgres passa pelo tradutor para portugues.
ImportDiagnostico diagnosticoDeFalhasDoBanco({
  required ImportEntidade entidade,
  required ImportArquivoInfo arquivo,
  required int totalLinhas,
  required List<dynamic> failedRows,
}) {
  final builder = ImportDiagnosticoBuilder(entidade: entidade);

  for (final bruto in failedRows) {
    final row =
        bruto is Map ? Map<String, dynamic>.from(bruto) : <String, dynamic>{};

    final linha = row['linha'] is int
        ? row['linha'] as int
        : int.tryParse(row['linha']?.toString() ?? '');

    final erroCru = (row['erro'] ?? row['motivo'] ?? '').toString();
    final amigavel = erroCru.isEmpty
        ? 'O sistema recusou a linha.'
        : buildFriendlyImportError(erroCru);

    final identificacao = [
      if ((row['numeroAnimal']?.toString() ?? '').isNotEmpty)
        'nº ${row['numeroAnimal']}',
      if ((row['nome']?.toString() ?? '').isNotEmpty) '"${row['nome']}"',
    ].join(' ');

    builder.add(ImportOcorrencia(
      codigo: ImportCodigo.bancoRejeitou,
      severidade: ImportSeveridade.bloqueante,
      escopo: ImportEscopo.consistencia,
      linha: linha,
      valor: identificacao.isEmpty ? null : identificacao,
      mensagem: linha == null
          ? amigavel
          : 'Linha $linha${identificacao.isEmpty ? '' : ' ($identificacao)'}: $amigavel',
      sugestao: 'Corrija a linha na planilha e importe apenas ela novamente.',
    ));
  }

  return builder.build(arquivo: arquivo, totalLinhas: totalLinhas);
}
