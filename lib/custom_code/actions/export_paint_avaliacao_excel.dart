// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
import 'paint_excel_helpers.dart';
// Begin custom action code

import 'package:download/download.dart';
import 'package:excel/excel.dart';

/// Resultado da exportação de planilha PAINT, permitindo à UI exibir mensagens
/// específicas em vez de um genérico "nenhum animal".
enum PaintExportStatus {
  ok,
  configIncompleta,
  semElegiveis,
  semNascimento,
  semAvaliacao,
  vazio,
}

/// Exporta template Excel PAINT de avaliações, lista de touros ou coberturas.
/// [tipo]: matrizes | desmama | sobreano | lista_touros | cobertura
/// [modo]: vazio | preenchido (ignorado para lista_touros e cobertura)
///
/// Filtros opcionais (reunião 01/06 — evitar baixar grandes volumes, ex.:
/// Cachoeira ~1.400 registros): intervalo de data de nascimento e, no modo
/// preenchido, intervalo de data de avaliação.
Future<PaintExportStatus> exportPaintAvaliacaoExcel(
  String idPropriedade,
  String tipo,
  String modo, {
  DateTime? dataNascimentoDe,
  DateTime? dataNascimentoAte,
  DateTime? dataAvaliacaoDe,
  DateTime? dataAvaliacaoAte,
  String? status,
  String? tipoReproducao,
}) async {
  if (idPropriedade.isEmpty) return PaintExportStatus.configIncompleta;
  final t = tipo.toLowerCase().trim();
  final m = modo.toLowerCase().trim();
  final preenchido = m == 'preenchido';

  if (t == 'lista_touros') {
    return _exportListaTouros(idPropriedade, preenchido);
  }

  // A planilha de cobertura sai de `reproducao`, não do rebanho, então não passa
  // pelo pipeline de elegibilidade/nascimento/avaliação abaixo. Mesmo desvio que
  // a lista de touros faz. Reusa o intervalo de data de avaliação como data da
  // cobertura, e não tem modo "vazio": sem a lista não há o que preencher.
  if (t == 'cobertura') {
    return _exportCoberturaPeriodo(
      idPropriedade,
      dataAvaliacaoDe,
      dataAvaliacaoAte,
      tipoReproducao,
    );
  }

  final cfg = await loadPaintConfig(idPropriedade);
  if (cfg == null) return PaintExportStatus.configIncompleta;

  List<String> headers;
  String nomeArquivo;
  bool Function(Map<String, dynamic>) filtro;

  switch (t) {
    case 'matrizes':
      headers = matrizesHeaders;
      nomeArquivo =
          preenchido ? 'PAINT_Av_Matrizes_preenchido' : 'PAINT_Av_Matrizes';
      filtro = (r) => filtroMatrizes(r, status: status);
      break;
    case 'desmama':
      headers = desmamaHeaders;
      nomeArquivo =
          preenchido ? 'PAINT_Av_Desmama_preenchido' : 'PAINT_Av_Desmama';
      filtro = (r) => filtroDesmama(r, status: status);
      break;
    case 'sobreano':
      headers = sobreanoHeaders;
      nomeArquivo =
          preenchido ? 'PAINT_Av_Sobreano_preenchido' : 'PAINT_Av_Sobreano';
      filtro = (r) => filtroSobreano(r, status: status);
      break;
    default:
      return PaintExportStatus.configIncompleta;
  }

  final rebanho = await fetchRebanhoPaint(idPropriedade);
  // A12 oficial do PAINT: o modelo entregue à cliente deve trazer a MESMA chave
  // que o ANIMAL.TXT emite, senão a planilha volta com A12 divergente.
  final a12Oficiais = await fetchA12OficialPorRebanho(idPropriedade);
  String a12Do(Map<String, dynamic> r) =>
      a12Oficiais[(r['idRebanho'] ?? '').toString().trim()] ??
      a12FromRebanho(r, cfg);

  // Animais elegíveis por status/categoria (independente de datas).
  final elegiveis = rebanho.where(filtro).toList();
  if (elegiveis.isEmpty) return PaintExportStatus.semElegiveis;

  // Filtro por data de nascimento.
  final comNascimento = elegiveis.where((r) {
    return dentroIntervaloData(
      parseDateIso(r['dataNascimento']),
      dataNascimentoDe,
      dataNascimentoAte,
    );
  }).toList();
  if (comNascimento.isEmpty) return PaintExportStatus.semNascimento;

  // Avaliações já salvas, agrupadas por A12 (pode haver mais de uma por animal).
  // Sobreano não usa: o template sai só com a identidade do animal.
  final existentesPorA12 = <String, List<Map<String, dynamic>>>{};
  if (preenchido && t != 'sobreano') {
    final table = t == 'matrizes'
        ? 'paint_avaliacao_rah'
        : 'paint_avaliacao_desmama';
    final rows = await SupaFlow.client
        .from(table)
        .select()
        .eq('id_propriedade', idPropriedade);
    for (final e in rows) {
      final a = (e['animal_a12'] ?? '').toString().trim();
      if (a.isEmpty) continue;
      (existentesPorA12[a] ??= []).add(Map<String, dynamic>.from(e));
    }
  }

  final temFiltroAvaliacao =
      preenchido && (dataAvaliacaoDe != null || dataAvaliacaoAte != null);

  // Linhas de dados já computadas (valores por célula).
  final linhas = <List<dynamic>>[];

  if (t == 'sobreano') {
    // Sobreano traz APENAS a identidade do animal (Numero, Nascimento, Sexo,
    // A12); Data_Avaliacao, notas e Peso_kg são preenchidos pelo avaliador no
    // Excel e voltam via importação — que também registra a pesagem no rebanho
    // (tipo "Atual"). Por não haver datas pré-preenchidas, o filtro de data de
    // avaliação não se aplica a este template.
    for (final r in comNascimento) {
      final a12 = a12Do(r);
      if (a12.isEmpty) continue;
      linhas.add([
        (r['numeroAnimal'] ?? '').toString(),
        parseDateIso(r['dataNascimento']) ?? '',
        sexoMF(r['sexo']),
        a12.trim(),
        '', '', '', '', '', '', '', '', '',
      ]);
    }

    if (linhas.isEmpty) return PaintExportStatus.vazio;
  } else {
    // matrizes / desmama: 1 linha por animal (comportamento inalterado).
    final selecionados = <_AnimalExport>[];
    for (final r in comNascimento) {
      final a12 = a12Do(r);
      if (a12.isEmpty) continue;
      final lista = preenchido
          ? (existentesPorA12[a12.trim()] ?? const <Map<String, dynamic>>[])
          : const <Map<String, dynamic>>[];

      Map<String, dynamic>? exist;
      if (temFiltroAvaliacao) {
        // Prioriza uma avaliação salva dentro do intervalo selecionado.
        for (final e in lista) {
          if (dentroIntervaloData(
              parseDateIso(e['data']), dataAvaliacaoDe, dataAvaliacaoAte)) {
            exist = e;
            break;
          }
        }
        if (exist == null) {
          // Sem avaliação salva no intervalo: exige que a data de fallback do
          // rebanho (desmama/última pesagem) esteja dentro do intervalo.
          final efetiva = dataEfetivaAvaliacao(t, r, null);
          if (!dentroIntervaloData(efetiva, dataAvaliacaoDe, dataAvaliacaoAte)) {
            continue;
          }
        }
      } else {
        exist = lista.isNotEmpty ? lista.first : null;
      }
      selecionados.add(_AnimalExport(r, exist));
    }

    if (temFiltroAvaliacao && selecionados.isEmpty) {
      return PaintExportStatus.semAvaliacao;
    }
    if (selecionados.isEmpty) return PaintExportStatus.vazio;

    for (final sel in selecionados) {
      final r = sel.rebanho;
      final exist = sel.avaliacao;
      final numAnimal = (r['numeroAnimal'] ?? '').toString();
      final nasc = parseDateIso(r['dataNascimento']) ?? '';
      final sexo = sexoMF(r['sexo']);
      final a12 = a12Do(r).trim();
      final dataAv = dataEfetivaAvaliacao(t, r, exist) ?? '';

      if (t == 'matrizes') {
        linhas.add([
          numAnimal,
          nasc,
          sexo,
          a12,
          dataAv,
          exist?['racial'] ?? '',
          exist?['frame'] ?? '',
          exist?['aprumos'] ?? '',
          exist?['pigmentacao'] ?? '',
        ]);
      } else {
        linhas.add([
          numAnimal,
          nasc,
          sexo,
          a12,
          dataAv,
          exist?['nota_c'] ?? '',
          exist?['nota_p'] ?? '',
          exist?['nota_m'] ?? '',
          exist?['nota_u'] ?? '',
          exist?['obs'] ?? '',
          exist?['peso'] ?? r['pesoDesmama'] ?? '',
        ]);
      }
    }
  }

  final excel = Excel.createExcel();
  final sheet = excel.tables[excel.tables.keys.first]!;
  for (var c = 0; c < headers.length; c++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).value =
        TextCellValue(headers[c]);
  }

  var rowIdx = 1;
  for (final vals in linhas) {
    for (var c = 0; c < vals.length; c++) {
      final v = vals[c];
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: c, rowIndex: rowIdx),
      );
      if (v is num) {
        cell.value = DoubleCellValue(v.toDouble());
      } else if (headers[c].contains('Data') && v.toString().isNotEmpty) {
        final d = DateTime.tryParse(v.toString());
        if (d != null) {
          cell.value = DateCellValue.fromDateTime(d);
        } else {
          cell.value = TextCellValue(v.toString());
        }
      } else {
        cell.value = TextCellValue(v?.toString() ?? '');
      }
    }
    rowIdx++;
  }

  // Nenhuma linha de dados escrita (apenas cabeçalho): não baixa planilha vazia.
  if (rowIdx <= 1) return PaintExportStatus.vazio;

  final bytes = excel.encode();
  if (bytes == null || bytes.isEmpty) return PaintExportStatus.vazio;
  await download(Stream.fromIterable(bytes), '$nomeArquivo.xlsx');
  return PaintExportStatus.ok;
}

/// Par animal do rebanho + avaliação salva selecionada para exportação.
class _AnimalExport {
  final Map<String, dynamic> rebanho;
  final Map<String, dynamic>? avaliacao;
  _AnimalExport(this.rebanho, this.avaliacao);
}

Future<PaintExportStatus> _exportListaTouros(
    String idPropriedade, bool preenchido) async {
  final excel = Excel.createExcel();
  final sheet = excel.tables[excel.tables.keys.first]!;
  for (var c = 0; c < listaTourosHeaders.length; c++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).value =
        TextCellValue(listaTourosHeaders[c]);
  }

  if (preenchido) {
    var row = 1;
    final rows = await SupaFlow.client
        .from('paint_biblioteca_touros')
        .select()
        .order('nome', ascending: true)
        .limit(5000);
    for (final t in rows) {
      final vals = [
        t['a12'],
        t['nome'],
        t['rgd'] ?? t['rgn'],
        t['raca'],
        t['tipo_registro'],
        t['pai_a12'],
        t['mae_a12'],
        t['rgd'],
        t['rgn'],
      ];
      for (var c = 0; c < vals.length; c++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row))
            .value = TextCellValue(vals[c]?.toString() ?? '');
      }
      row++;
    }
  }

  final bytes = excel.encode();
  if (bytes == null) return PaintExportStatus.vazio;
  final nome =
      preenchido ? 'LISTA_TOUROS_PAINT_preenchido' : 'LISTA_TOUROS_PAINT';
  await download(Stream.fromIterable(bytes), '$nome.xlsx');
  return PaintExportStatus.ok;
}


/// Planilha de período da cobertura: traz as coberturas da propriedade para a
/// cliente marcar Manhã ou Tarde e reimportar. Alimenta `cob_periodo` (C(1),
/// posição 65) no COBERTURA.TXT, que até 09/2026 saía "M" fixo para todas.
///
/// A coluna `id_reproducao` é a chave da volta. Não usamos (A12, data) como as
/// outras planilhas porque a mesma vaca pode ter duas coberturas na mesma data,
/// e dois animais diferentes podem compartilhar o mesmo A12.
Future<PaintExportStatus> _exportCoberturaPeriodo(
  String idPropriedade,
  DateTime? dataDe,
  DateTime? dataAte,
  String? tipoReproducao,
) async {
  // Coberturas com a matriz vinculada. Só Nelore/Nelore PO: são as que entram no
  // COBERTURA.TXT, então marcar período de outra raça não teria efeito.
  final linhas = <Map<String, dynamic>>[];
  const pagina = 1000;
  var offset = 0;
  while (true) {
    final lote = await SupaFlow.client
        .from('reproducao')
        .select(
          'id_reproducao,tipo_reproducao,data_inseminacao,data_inicial,'
          'inseminador,id_rebanho_matriz,id_rebanho_reprodutor',
        )
        .eq('id_propriedade', idPropriedade)
        .neq('deletado', 'SIM')
        .order('id')
        .range(offset, offset + pagina - 1);
    linhas.addAll(lote.cast<Map<String, dynamic>>());
    if (lote.length < pagina) break;
    offset += pagina;
  }
  if (linhas.isEmpty) return PaintExportStatus.semElegiveis;

  // Rebanho indexado por idRebanho, para nome/número da matriz e do touro.
  final rebanho = await fetchRebanhoPaint(idPropriedade);
  final porId = <String, Map<String, dynamic>>{};
  for (final r in rebanho) {
    final id = (r['idRebanho'] ?? '').toString().trim();
    if (id.isNotEmpty) porId[id] = r;
  }

  // Períodos já gravados, para a planilha voltar preenchida com o que existe.
  final jaSalvos = <String, String>{};
  final salvos = await SupaFlow.client
      .from('paint_cobertura_periodo')
      .select('id_reproducao,periodo')
      .eq('id_propriedade', idPropriedade);
  for (final r in salvos) {
    jaSalvos[(r['id_reproducao'] ?? '').toString().trim()] =
        (r['periodo'] ?? '').toString();
  }

  final tipoFiltro = normalizePaintText(tipoReproducao ?? '');
  final dados = <List<String>>[];
  for (final rp in linhas) {
    final matriz = porId[(rp['id_rebanho_matriz'] ?? '').toString().trim()];
    if (matriz == null) continue;
    if (!paintRacaNeloreOuPo(matriz['raca'])) continue;

    final dataIso =
        parseDateIso(rp['data_inseminacao']) ?? parseDateIso(rp['data_inicial']);
    if (dataIso == null) continue;
    if (!dentroIntervaloData(dataIso, dataDe, dataAte)) continue;

    // Filtro de tipo: vazio traz tudo. "INSEMINACAO" casa com Inseminação e
    // IATF; a comparação é normalizada porque o cadastro tem grafias diferentes
    // ("Monta Natural" e "Monta natural" convivem no banco).
    final tipoLinha = normalizePaintText(rp['tipo_reproducao']);
    if (tipoFiltro.isNotEmpty && !tipoLinha.contains(tipoFiltro)) continue;

    final touro = porId[(rp['id_rebanho_reprodutor'] ?? '').toString().trim()];
    dados.add([
      (rp['id_reproducao'] ?? '').toString(),
      (matriz['numeroAnimal'] ?? '').toString(),
      (matriz['nome'] ?? '').toString(),
      dataIso,
      (rp['tipo_reproducao'] ?? '').toString(),
      (touro?['numeroAnimal'] ?? '').toString(),
      (touro?['nome'] ?? '').toString(),
      (rp['inseminador'] ?? '').toString(),
      _periodoRotulo(jaSalvos[(rp['id_reproducao'] ?? '').toString().trim()]),
    ]);
  }
  if (dados.isEmpty) return PaintExportStatus.semAvaliacao;

  dados.sort((a, b) {
    final porData = b[3].compareTo(a[3]);
    return porData != 0 ? porData : a[1].compareTo(b[1]);
  });

  final excel = Excel.createExcel();
  final sheet = excel.tables[excel.tables.keys.first]!;
  for (var c = 0; c < coberturaHeaders.length; c++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).value =
        TextCellValue(coberturaHeaders[c]);
  }
  for (var r = 0; r < dados.length; r++) {
    for (var c = 0; c < dados[r].length; c++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
          .value = TextCellValue(dados[r][c]);
    }
  }

  final bytes = excel.encode();
  if (bytes == null) return PaintExportStatus.vazio;
  await download(
      Stream.fromIterable(bytes), 'PAINT_Cobertura_Periodo.xlsx');
  return PaintExportStatus.ok;
}

/// MANHA/TARDE do banco -> rótulo amigável na planilha.
String _periodoRotulo(String? valor) {
  switch (normalizePaintText(valor ?? '')) {
    case 'MANHA':
      return 'Manhã';
    case 'TARDE':
      return 'Tarde';
    default:
      return '';
  }
}
