// Popup de pre-confirmacao da importacao.
//
// Substitui os quatro AlertDialog "Linhas com erro na importacao" que estavam
// duplicados em sub_menu_painel_importar_widget.dart e
// pp_importar_pesagem_widget.dart, cada um com um take(100) e um exportador de
// CSV proprio.
//
// Diferencas de comportamento que importam:
//  - aparece ANTES de gravar, nao depois;
//  - agrupa os problemas por causa, com a contagem real, e pagina o detalhe em
//    vez de cortar em 100 linhas;
//  - diz quantos registros serao criados e quantos serao SOBRESCRITOS, com a
//    lista de quem -- a sobrescrita hoje e silenciosa e apaga campos em branco;
//  - quando ha problema bloqueante, "Importar mesmo assim" fica desabilitado.
//
// O mesmo widget serve a tela de historico de auditoria, em somenteLeitura.

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

import 'import_diagnostico_csv.dart';
import 'import_diagnostico_model.dart';
import 'import_erro_amigavel.dart';

/// O que o usuario decidiu no popup.
enum ImportDecisao {
  /// Fechar sem importar. E o caminho recomendado quando ha erro.
  cancelar,

  /// Importar apenas as linhas sem problema bloqueante.
  importarValidos,

  /// Importar tudo. So alcancavel quando nao ha bloqueante.
  importarMesmoAssim,
}

class PpPreConfirmacaoImportacaoWidget extends StatefulWidget {
  const PpPreConfirmacaoImportacaoWidget({
    super.key,
    required this.diagnostico,
    required this.nomeEntidade,
    this.permitirForcar = true,
    this.somenteLeitura = false,
  });

  final ImportDiagnostico diagnostico;

  /// "Rebanho", "Pesagem"... usado nos textos.
  final String nomeEntidade;

  /// Em pesagem e false: o unique parcial de historico_pesagens recusaria as
  /// linhas de qualquer forma, entao oferecer "importar mesmo assim" seria
  /// prometer algo que o banco nao cumpre.
  final bool permitirForcar;

  /// Modo consulta, usado pela tela de auditoria: esconde os botoes de acao.
  final bool somenteLeitura;

  /// Abre o popup e devolve a decisao. Fechar pelo X ou pelo fundo equivale a
  /// cancelar -- nunca a importar.
  static Future<ImportDecisao> mostrar(
    BuildContext context, {
    required ImportDiagnostico diagnostico,
    required String nomeEntidade,
    bool permitirForcar = true,
    bool somenteLeitura = false,
  }) async =>
      await showDialog<ImportDecisao>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PpPreConfirmacaoImportacaoWidget(
          diagnostico: diagnostico,
          nomeEntidade: nomeEntidade,
          permitirForcar: permitirForcar,
          somenteLeitura: somenteLeitura,
        ),
      ) ??
      ImportDecisao.cancelar;

  @override
  State<PpPreConfirmacaoImportacaoWidget> createState() =>
      _PpPreConfirmacaoImportacaoWidgetState();
}

class _PpPreConfirmacaoImportacaoWidgetState
    extends State<PpPreConfirmacaoImportacaoWidget> {
  ImportDiagnostico get d => widget.diagnostico;

  Color _corDaSeveridade(ImportSeveridade s) {
    final tema = FlutterFlowTheme.of(context);
    return switch (s) {
      ImportSeveridade.bloqueante => tema.error,
      ImportSeveridade.aviso => tema.warning,
      ImportSeveridade.informativo => tema.secondaryText,
    };
  }

  IconData _iconeDaSeveridade(ImportSeveridade s) => switch (s) {
        ImportSeveridade.bloqueante => Icons.block,
        ImportSeveridade.aviso => Icons.warning_amber_rounded,
        ImportSeveridade.informativo => Icons.info_outline,
      };

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final altura = MediaQuery.of(context).size.height;
    final largura = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: tema.secondaryBackground,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: largura < 940 ? largura : 900,
          maxHeight: altura * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _cabecalho(tema),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _faixaDoArquivo(tema),
                    const SizedBox(height: 16),
                    _cartoesDeResumo(tema),
                    if (d.totalAtualizar > 0) ...[
                      const SizedBox(height: 8),
                      _avisoDeSobrescrita(tema),
                    ],
                    const SizedBox(height: 20),
                    _listaDeProblemas(tema),
                  ],
                ),
              ),
            ),
            if (!widget.somenteLeitura) ...[
              const Divider(height: 1),
              _acoes(tema),
            ],
          ],
        ),
      ),
    );
  }

  Widget _cabecalho(FlutterFlowTheme tema) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.somenteLeitura
                        ? 'Importação de ${widget.nomeEntidade}'
                        : 'Revisar importação de ${widget.nomeEntidade}',
                    style: tema.headlineSmall,
                  ),
                  if (d.arquivo.nomeArquivo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        d.arquivo.nomeArquivo!,
                        style:
                            tema.bodySmall.copyWith(color: tema.secondaryText),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Fechar sem importar',
              onPressed: () =>
                  Navigator.of(context).pop(ImportDecisao.cancelar),
            ),
          ],
        ),
      );

  Widget _faixaDoArquivo(FlutterFlowTheme tema) {
    final partes = <String>[
      d.arquivo.formato.toUpperCase(),
      if (d.arquivo.delimitador != null) 'separador "${d.arquivo.delimitador}"',
      if (d.arquivo.encodingUsado != null) d.arquivo.encodingUsado!,
      if (d.arquivo.abaUsada != null) 'aba "${d.arquivo.abaUsada}"',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(partes.join(' · '),
            style: tema.bodySmall.copyWith(color: tema.secondaryText)),
        if (d.arquivo.usouFallbackPosicional)
          _chip(tema, 'Cabeçalho não reconhecido', tema.error),
        if (d.arquivo.entidadeDetectada != null)
          _chip(tema, 'Planilha de outro tipo', tema.error),
      ],
    );
  }

  Widget _chip(FlutterFlowTheme tema, String texto, Color cor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: cor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cor.withValues(alpha: 0.4)),
        ),
        child: Text(texto,
            style: tema.bodySmall
                .copyWith(color: cor, fontWeight: FontWeight.w600)),
      );

  Widget _cartoesDeResumo(FlutterFlowTheme tema) {
    final cartoes = <Widget>[
      _cartao(tema, 'Linhas na planilha', d.totalLinhas, tema.primaryText),
      _cartao(tema, 'Serão criados', d.totalCriar, tema.success),
      _cartao(tema, 'Serão atualizados', d.totalAtualizar, tema.warning),
      _cartao(tema, 'Bloqueados', d.totalBloquear, tema.error),
    ];
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth < 560
          ? Column(
              children: [
                for (final cartao in cartoes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(width: double.infinity, child: cartao),
                  ),
              ],
            )
          : Row(
              children: [
                for (var i = 0; i < cartoes.length; i++) ...[
                  Expanded(child: cartoes[i]),
                  if (i < cartoes.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
    );
  }

  Widget _cartao(FlutterFlowTheme tema, String rotulo, int valor, Color cor) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cor.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$valor', style: tema.headlineMedium.copyWith(color: cor)),
            const SizedBox(height: 2),
            Text(rotulo,
                style: tema.bodySmall.copyWith(color: tema.secondaryText)),
          ],
        ),
      );

  Widget _avisoDeSobrescrita(FlutterFlowTheme tema) {
    final linhas = d.registrosAtualizados;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tema.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atualizar sobrescreve os dados atuais. Colunas em branco na '
            'planilha apagam o que está gravado hoje.',
            style: tema.bodySmall.copyWith(color: tema.primaryText),
          ),
          if (linhas.isNotEmpty)
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text(
                  'Ver os ${linhas.length} registro(s) que serão atualizados',
                  style: tema.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                children: [
                  _TabelaPaginada(
                    colunas: const [
                      'Linha',
                      'Número',
                      'Nome',
                      'Situação atual'
                    ],
                    linhas: [
                      for (final r in linhas)
                        [
                          '${r['linha'] ?? ''}',
                          '${r['numeroAnimal'] ?? ''}',
                          '${r['nome'] ?? ''}',
                          '${r['detalhe'] ?? ''}',
                        ],
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _listaDeProblemas(FlutterFlowTheme tema) {
    final problemas = d.problemasAgregados;
    if (problemas.isEmpty) {
      return Row(
        children: [
          Icon(Icons.check_circle_outline, color: tema.success, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Nenhum problema encontrado na planilha.',
                style: tema.bodyMedium),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Problemas encontrados', style: tema.titleSmall),
        const SizedBox(height: 8),
        for (final p in problemas) _grupoDeProblema(tema, p),
      ],
    );
  }

  Widget _grupoDeProblema(FlutterFlowTheme tema, ImportProblemaAgregado p) {
    final cor = _corDaSeveridade(p.severidade);
    final comLinha = p.ocorrencias.where((o) => o.linha != null).toList();
    final sugestao = p.ocorrencias
        .map((o) => o.sugestao)
        .firstWhere((s) => s != null && s.isNotEmpty, orElse: () => null);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tema.alternate),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(_iconeDaSeveridade(p.severidade), color: cor),
          title: Text(p.titulo,
              style: tema.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(
            p.quantidade == 1 ? '1 ocorrência' : '${p.quantidade} ocorrências',
            style: tema.bodySmall.copyWith(color: cor),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sugestao != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline,
                              size: 16, color: tema.secondaryText),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(sugestao,
                                style: tema.bodySmall
                                    .copyWith(color: tema.secondaryText)),
                          ),
                        ],
                      ),
                    ),
                  if (comLinha.isEmpty)
                    Text(p.ocorrencias.first.mensagem, style: tema.bodySmall)
                  else
                    _TabelaPaginada(
                      colunas: const ['Linha', 'Coluna', 'Valor', 'Detalhe'],
                      linhas: [
                        for (final o in comLinha)
                          [
                            '${o.linha}',
                            o.coluna == null
                                ? ''
                                : labelColunaImportacao(
                                    o.coluna!.toLowerCase()),
                            o.valor ?? '',
                            o.mensagem,
                          ],
                      ],
                      rodape: p.truncado
                          ? 'Mostrando ${p.ocorrencias.length} de '
                              '${p.quantidade} ocorrências deste tipo.'
                          : null,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _acoes(FlutterFlowTheme tema) {
    final bloqueado = d.temBloqueio;
    final podeForcar = !bloqueado && widget.permitirForcar;
    final temAlgoParaImportar = d.totalImportavel > 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('Exportar CSV do diagnóstico'),
            onPressed: d.temProblema
                ? () => baixarDiagnosticoCsv(d, widget.nomeEntidade)
                : null,
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(ImportDecisao.cancelar),
            child: Text(
              d.temProblema ? 'Corrigir e reenviar' : 'Cancelar',
              style: tema.bodyMedium,
            ),
          ),
          if (bloqueado || !temAlgoParaImportar)
            Tooltip(
              message: temAlgoParaImportar
                  ? 'Há ${d.totalBloquear} linha(s) que o sistema não aceita. '
                      'Elas ficam de fora.'
                  : 'Nenhuma linha da planilha pode ser importada.',
              child: FFButtonWidget(
                text: temAlgoParaImportar
                    ? 'Importar apenas as ${d.totalImportavel} linhas válidas'
                    : 'Nada a importar',
                onPressed: temAlgoParaImportar
                    ? () =>
                        Navigator.of(context).pop(ImportDecisao.importarValidos)
                    : null,
                options: _opcoesBotao(tema, tema.primary),
              ),
            )
          else
            FFButtonWidget(
              text: 'Importar ${d.totalImportavel} registro(s)',
              onPressed: podeForcar
                  ? () => Navigator.of(context)
                      .pop(ImportDecisao.importarMesmoAssim)
                  : () =>
                      Navigator.of(context).pop(ImportDecisao.importarValidos),
              options: _opcoesBotao(tema, tema.primary),
            ),
        ],
      ),
    );
  }

  FFButtonOptions _opcoesBotao(FlutterFlowTheme tema, Color cor) =>
      FFButtonOptions(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: cor,
        textStyle: tema.titleSmall.copyWith(color: Colors.white),
        disabledColor: tema.alternate,
        disabledTextColor: tema.secondaryText,
        borderRadius: BorderRadius.circular(8),
        elevation: 0,
      );
}

/// Tabela com paginacao simples.
///
/// Existe porque os dialogs antigos faziam `failedRows.take(100)` e escondiam o
/// resto: numa planilha grande o usuario via 100 erros de 3 mil e nao tinha
/// como chegar aos demais.
class _TabelaPaginada extends StatefulWidget {
  const _TabelaPaginada({
    required this.colunas,
    required this.linhas,
    this.rodape,
  });

  final List<String> colunas;
  final List<List<String>> linhas;
  final String? rodape;

  /// 50 por pagina: o suficiente para varrer com o olho sem travar o browser
  /// numa planilha com milhares de problemas.
  static const porPagina = 50;

  @override
  State<_TabelaPaginada> createState() => _TabelaPaginadaState();
}

class _TabelaPaginadaState extends State<_TabelaPaginada> {
  int _pagina = 0;

  int get _totalPaginas => widget.linhas.isEmpty
      ? 1
      : (widget.linhas.length / _TabelaPaginada.porPagina).ceil();

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final inicio = _pagina * _TabelaPaginada.porPagina;
    final fim = (inicio + _TabelaPaginada.porPagina) > widget.linhas.length
        ? widget.linhas.length
        : inicio + _TabelaPaginada.porPagina;
    final visiveis = widget.linhas.sublist(inicio, fim);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            headingRowHeight: 36,
            dataRowMinHeight: 32,
            dataRowMaxHeight: 60,
            columns: [
              for (final c in widget.colunas)
                DataColumn(
                  label: Text(c,
                      style:
                          tema.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                ),
            ],
            rows: [
              for (final linha in visiveis)
                DataRow(
                  cells: [
                    for (final celula in linha)
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Text(celula,
                              style: tema.bodySmall, softWrap: true),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        if (_totalPaginas > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Página anterior',
                  onPressed:
                      _pagina > 0 ? () => setState(() => _pagina--) : null,
                ),
                Text('${_pagina + 1} / $_totalPaginas', style: tema.bodySmall),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Próxima página',
                  onPressed: _pagina < _totalPaginas - 1
                      ? () => setState(() => _pagina++)
                      : null,
                ),
                const Spacer(),
                Text('${widget.linhas.length} linha(s)',
                    style: tema.bodySmall.copyWith(color: tema.secondaryText)),
              ],
            ),
          ),
        if (widget.rodape != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(widget.rodape!,
                style: tema.bodySmall.copyWith(color: tema.secondaryText)),
          ),
      ],
    );
  }
}
