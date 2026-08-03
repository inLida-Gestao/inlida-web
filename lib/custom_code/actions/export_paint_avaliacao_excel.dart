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

/// Exporta template Excel PAINT de avaliações ou lista de touros.
/// [tipo]: matrizes | desmama | sobreano | lista_touros
/// [modo]: vazio | preenchido (ignorado para lista_touros)
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
}) async {
  if (idPropriedade.isEmpty) return PaintExportStatus.configIncompleta;
  final t = tipo.toLowerCase().trim();
  final m = modo.toLowerCase().trim();
  final preenchido = m == 'preenchido';

  if (t == 'lista_touros') {
    return _exportListaTouros(idPropriedade, preenchido);
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
