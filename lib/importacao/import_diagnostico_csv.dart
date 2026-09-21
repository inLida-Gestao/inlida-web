// Exportacao do diagnostico em CSV.
//
// Unifica os quatro _exportFailedRowsCsv* que existiam nos widgets de
// importacao, cada um com o seu proprio conjunto de colunas
// (Linha;Numero;Nome;Motivo;Erro em um, Linha;ID_Lote;... em outro). Aqui as
// colunas sao as mesmas para toda entidade, porque o que o suporte precisa e
// sempre o mesmo: onde, o que, e por que.
//
// Mantem as escolhas que faziam o arquivo abrir certo no Excel em pt-BR: BOM
// UTF-8 no inicio e ponto e virgula como separador.
//
// A entrega do arquivo usa lib/utils/download_arquivo.dart, e nao o pacote
// `download`: aquele pacote escolhe a implementacao por dart.library.html, que
// e falso no build WebAssembly, e ali ele tenta gravar em disco de dentro do
// navegador -- nenhum arquivo chega ao usuario. Ver o commit 0a8617b.

import 'dart:convert';

import '/utils/download_arquivo.dart';

import 'import_diagnostico_model.dart';

String _escapar(String valor) {
  final precisaAspas =
      valor.contains(';') || valor.contains('"') || valor.contains('\n');
  final escapado = valor.replaceAll('"', '""');
  return precisaAspas ? '"$escapado"' : escapado;
}

String _severidadeTexto(ImportSeveridade s) => switch (s) {
      ImportSeveridade.bloqueante => 'Bloqueante',
      ImportSeveridade.aviso => 'Aviso',
      ImportSeveridade.informativo => 'Informativo',
    };

String _escopoTexto(ImportEscopo e) => switch (e) {
      ImportEscopo.arquivo => 'Arquivo',
      ImportEscopo.dado => 'Dado',
      ImportEscopo.consistencia => 'Consistencia',
      ImportEscopo.semantica => 'Negocio',
    };

String _acaoTexto(ImportAcaoLinha? a) => switch (a) {
      ImportAcaoLinha.criar => 'Sera criado',
      ImportAcaoLinha.atualizar => 'Sera atualizado',
      ImportAcaoLinha.bloquear => 'Bloqueado',
      null => '',
    };

/// Monta o CSV do diagnostico.
///
/// Uma linha por ocorrencia. Quando a amostra de um codigo foi truncada, o
/// arquivo termina com uma linha dizendo isso -- omitir seria dar a entender
/// que o CSV tem todos os problemas.
String montarDiagnosticoCsv(ImportDiagnostico d) {
  final buffer = StringBuffer();
  buffer.writeln('Linha;Severidade;Codigo;Escopo;Coluna;Valor;Mensagem;'
      'Sugestao;Acao');

  for (final p in d.problemasAgregados) {
    for (final o in p.ocorrencias) {
      buffer.writeln([
        _escapar(o.linha?.toString() ?? ''),
        _escapar(_severidadeTexto(o.severidade)),
        _escapar(o.codigo),
        _escapar(_escopoTexto(o.escopo)),
        _escapar(o.coluna ?? ''),
        _escapar(o.valor ?? ''),
        _escapar(o.mensagem),
        _escapar(o.sugestao ?? ''),
        _escapar(o.linha == null ? '' : _acaoTexto(d.acaoPorLinha[o.linha])),
      ].join(';'));
    }
  }

  final truncados = d.problemasAgregados.where((p) => p.truncado).toList();
  if (truncados.isNotEmpty) {
    buffer.writeln();
    for (final p in truncados) {
      buffer.writeln(_escapar(
        'Atencao: o codigo ${p.codigo} teve ${p.quantidade} ocorrencias e '
        'apenas ${p.ocorrencias.length} foram detalhadas neste arquivo.',
      ));
    }
  }

  return buffer.toString();
}

String _carimbo(DateTime agora) => '${agora.year.toString().padLeft(4, '0')}'
    '${agora.month.toString().padLeft(2, '0')}'
    '${agora.day.toString().padLeft(2, '0')}_'
    '${agora.hour.toString().padLeft(2, '0')}'
    '${agora.minute.toString().padLeft(2, '0')}'
    '${agora.second.toString().padLeft(2, '0')}';

/// Nome do arquivo baixado.
String nomeArquivoDiagnostico(String nomeEntidade, {DateTime? agora}) {
  final entidade = nomeEntidade
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return 'diagnostico_importacao_${entidade}_${_carimbo(agora ?? DateTime.now())}.csv';
}

/// Gera e baixa o CSV do diagnostico.
Future<void> baixarDiagnosticoCsv(
  ImportDiagnostico d,
  String nomeEntidade,
) async {
  final conteudo = '﻿${montarDiagnosticoCsv(d)}';
  final bytes = utf8.encode(conteudo);
  await download(
    Stream.fromIterable(bytes),
    nomeArquivoDiagnostico(nomeEntidade),
  );
}
