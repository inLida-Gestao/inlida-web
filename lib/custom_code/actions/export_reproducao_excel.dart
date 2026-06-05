// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:excel/excel.dart';
import 'package:download/download.dart';

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String? _nonEmptyExportText(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
    return null;
  }
  return text;
}

DateTime? _parseDateForReproducaoExport(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
  if (value is int) {
    final absValue = value.abs();
    if (absValue > 2000000000000000) {
      return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
    }
    if (absValue > 2000000000000) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    if (absValue > 2000000000) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
    }
  }
  if (value is double) {
    final asInt = value.round();
    if ((value - asInt).abs() < 1e-9) {
      return _parseDateForReproducaoExport(asInt);
    }
  }
  return DateTime.tryParse(value.toString());
}

DateTime? _dataReferenciaReproducao(Map<String, dynamic> row) {
  return _parseDateForReproducaoExport(row['data_inseminacao']) ??
      _parseDateForReproducaoExport(row['data_inicial']) ??
      _parseDateForReproducaoExport(row['created_at']);
}

bool _loteAtualCompativelComDataReproducao(
  Map<String, dynamic> row,
  Map<String, dynamic> matriz,
) {
  final dataReferencia = _dataReferenciaReproducao(row);
  final dataEntradaLote =
      _parseDateForReproducaoExport(matriz['dataEntradaLote']);
  if (dataReferencia == null || dataEntradaLote == null) {
    return true;
  }
  return !_dateOnly(dataEntradaLote).isAfter(_dateOnly(dataReferencia));
}

Future<Map<String, String>> _buscarNomesLotesPorIdReproducaoExport(
  String idPropriedade,
) async {
  const batchSize = 1000;
  var offset = 0;
  final nomesPorId = <String, String>{};

  while (true) {
    final rows = await SupaFlow.client
        .from('lotes')
        .select('id_lote,nome')
        .eq('id_propriedade', idPropriedade)
        .range(offset, offset + batchSize - 1);

    for (final item in rows) {
      final row = Map<String, dynamic>.from(item);
      final id = _nonEmptyExportText(row['id_lote']);
      final nome = _nonEmptyExportText(row['nome']);
      if (id != null && nome != null) {
        nomesPorId[id] = nome;
      }
    }

    if (rows.length < batchSize) break;
    offset += batchSize;
  }

  return nomesPorId;
}

Future<Map<String, Map<String, dynamic>>> _buscarMatrizesReproducaoExport(
  String idPropriedade,
  Iterable<String> idsRebanho,
) async {
  const idChunk = 200;
  final ids = idsRebanho.toSet().toList();
  final matrizesPorId = <String, Map<String, dynamic>>{};

  for (var start = 0; start < ids.length; start += idChunk) {
    final end = start + idChunk > ids.length ? ids.length : start + idChunk;
    final chunk = ids.sublist(start, end);
    final rows = await SupaFlow.client
        .from('rebanho')
        .select('idRebanho,loteID,loteNome,dataEntradaLote')
        .eq('idPropriedade', idPropriedade)
        .inFilter('idRebanho', chunk);

    for (final item in rows) {
      final row = Map<String, dynamic>.from(item);
      final id = _nonEmptyExportText(row['idRebanho']);
      if (id != null) {
        matrizesPorId[id] = row;
      }
    }
  }

  return matrizesPorId;
}

Future<void> _preencherLotesAusentesReproducaoExport(
  List<Map<String, dynamic>> rows,
  String idPropriedade,
) async {
  final nomesLotesPorId =
      await _buscarNomesLotesPorIdReproducaoExport(idPropriedade);

  for (final row in rows) {
    if (_nonEmptyExportText(row['loteNome']) != null) {
      continue;
    }

    final idLote = _nonEmptyExportText(row['id_lote']);
    final nomeLote = idLote == null ? null : nomesLotesPorId[idLote];
    if (nomeLote != null) {
      row['loteNome'] = nomeLote;
    }
  }

  final idsMatrizes = rows
      .where((row) => _nonEmptyExportText(row['loteNome']) == null)
      .map((row) => _nonEmptyExportText(row['id_rebanho_matriz']))
      .whereType<String>();
  final matrizes =
      await _buscarMatrizesReproducaoExport(idPropriedade, idsMatrizes);

  for (final row in rows) {
    if (_nonEmptyExportText(row['loteNome']) != null) {
      continue;
    }

    final idMatriz = _nonEmptyExportText(row['id_rebanho_matriz']);
    final matriz = idMatriz == null ? null : matrizes[idMatriz];
    if (matriz == null || !_loteAtualCompativelComDataReproducao(row, matriz)) {
      continue;
    }

    final idLoteMatriz = _nonEmptyExportText(matriz['loteID']);
    final nomeLoteMatriz = _nonEmptyExportText(matriz['loteNome']) ??
        (idLoteMatriz == null ? null : nomesLotesPorId[idLoteMatriz]);
    if (nomeLoteMatriz != null) {
      row['loteNome'] = nomeLoteMatriz;
    }
    if (_nonEmptyExportText(row['id_lote']) == null && idLoteMatriz != null) {
      row['id_lote'] = idLoteMatriz;
    }
  }
}

Future<bool> exportReproducaoExcel(
    String nameExcel, String idPropriedade) async {
  try {
    print('=== INÍCIO DA EXPORTAÇÃO - REPRODUÇÃO ===');
    print('Nome arquivo: $nameExcel');
    print('ID Propriedade: $idPropriedade');

    // Lista para armazenar todos os dados
    List<Map<String, dynamic>> allData = [];

    // Configuração da paginação
    int batchSize = 1000;
    int offset = 0;
    bool hasMoreData = true;

    print('Iniciando busca no Supabase...');

    // Loop para buscar todos os dados em batches
    while (hasMoreData) {
      print('Buscando registros $offset a ${offset + batchSize}...');

      try {
        final response = await SupaFlow.client
            .from('reproducao')
            .select()
            .eq('id_propriedade', idPropriedade)
            .eq('deletado', 'NAO')
            .order('id', ascending: true)
            .range(offset, offset + batchSize - 1);

        print('Registros retornados: ${response.length}');

        // Adicionar os dados à lista principal
        for (var item in response) {
          allData.add(Map<String, dynamic>.from(item));
        }

        // Verificar se há mais dados
        if (response.length < batchSize) {
          hasMoreData = false;
          print('Última página alcançada');
        } else {
          offset += batchSize;
        }
      } catch (e) {
        print('Erro ao buscar batch: $e');
        hasMoreData = false;
      }
    }

    print('Total de registros carregados: ${allData.length}');

    if (allData.isEmpty) {
      print('AVISO: Nenhum registro encontrado para exportar');
      return false;
    }

    await _preencherLotesAusentesReproducaoExport(allData, idPropriedade);

    print('Criando Excel...');
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Exportar no formato do MODELO de importação (não exportar todas as colunas da tabela).
    // IMPORTANTE: headers e ordem devem ser IGUAIS ao modelo usado na importação.
    const template = <String, String>{
      'Tipo_reproducao': 'tipo_reproducao',
      'Data_inseminacao': 'data_inseminacao',
      'Data_inicial_monta': 'data_inicial',
      'Data_final_monta': 'data_final',
      'Número_matriz': 'numMatriz',
      'Nome_matriz': 'nomeMatriz',
      'Data_nascimento_matriz': 'nascimentoMatriz',
      'Categoria_matriz': 'categoria',
      'Raça_matriz': 'racaMatriz',
      'Lote': 'loteNome',
      'Score_corporal': 'score_corporal',
      'Número_reprodutor': 'numReprodutor',
      'Nome_reprodutor': 'nomeReprodutor',
      'Data_nascimento_reprodutor': 'nascimentoReprodutor',
      'Raça_reprodutor': 'racaReprodutor',
      'Data_partida_sêmen': 'data_partida_semen',
      'Partida_sêmen': 'partida_semen',
      'Inseminador': 'inseminador',
      'Previsão_parto': 'previsao_parto',
      'Status_reprodução': 'status_reproducao',
      'Data_status': 'data_status',
      'Ressinc': 'ressinc',
      'Parida': 'parida',
      'Data_parto': 'data_parto',
      'GnRH': 'gnrh',
      'Cio': 'cio',
      'Anotações': 'anotacoes',
    };

    final headers = template.keys.toList(growable: false);

    print('Colunas a exportar (${headers.length}): $headers');

    // Adicionar headers
    for (var i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
    }
    print('Headers adicionados!');

    // Colunas numéricas do TEMPLATE
    Set<String> numericColumns = {'Score_corporal', 'Partida_sêmen'};

    // Colunas de data do TEMPLATE
    Set<String> dateColumns = {
      'Data_inseminacao',
      'Data_inicial_monta',
      'Data_final_monta',
      'Data_nascimento_matriz',
      'Data_nascimento_reprodutor',
      'Data_partida_sêmen',
      'Previsão_parto',
      'Data_status',
      'Data_parto',
    };

    // Preencher dados
    print('Preenchendo dados...');
    for (var rowIndex = 0; rowIndex < allData.length; rowIndex++) {
      if (rowIndex % 1000 == 0) {
        print('Processando linha $rowIndex de ${allData.length}');
      }

      for (var colIndex = 0; colIndex < headers.length; colIndex++) {
        final header = headers[colIndex];
        final sourceKey = template[header]!;
        var value = allData[rowIndex][sourceKey];
        String columnName = header;

        try {
          if (numericColumns.contains(columnName)) {
            // Tratamento numérico
            if (value == null) {
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: colIndex, rowIndex: rowIndex + 1))
                  .value = TextCellValue('');
            } else if (value is num) {
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: colIndex, rowIndex: rowIndex + 1))
                  .value = DoubleCellValue(value.toDouble());
            } else if (value is String && value.isNotEmpty) {
              var numVal = double.tryParse(value.replaceAll(',', '.'));
              if (numVal != null) {
                sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: colIndex, rowIndex: rowIndex + 1))
                    .value = DoubleCellValue(numVal);
              } else {
                sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: colIndex, rowIndex: rowIndex + 1))
                    .value = TextCellValue(value);
              }
            } else {
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: colIndex, rowIndex: rowIndex + 1))
                  .value = TextCellValue(value.toString());
            }
          } else if (dateColumns.contains(columnName)) {
            // Tratamento de data — usa DateCellValue para Excel reconhecer como data
            final cell = sheet.cell(CellIndex.indexByColumnRow(
                columnIndex: colIndex, rowIndex: rowIndex + 1));
            if (value == null) {
              cell.value = TextCellValue('');
            } else {
              try {
                DateTime date;
                if (value is DateTime) {
                  date = value;
                } else {
                  date = DateTime.parse(value.toString());
                }
                cell.value = DateCellValue(
                  year: date.year,
                  month: date.month,
                  day: date.day,
                );
                cell.cellStyle = CellStyle(numberFormat: NumFormat.defaultDate);
              } catch (e) {
                cell.value = TextCellValue(value.toString());
              }
            }
          } else {
            // Tratamento padrão
            sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: colIndex, rowIndex: rowIndex + 1))
                .value = TextCellValue(value?.toString() ?? '');
          }
        } catch (e) {
          print('ERRO na célula [$rowIndex, $colIndex]: $e');
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: colIndex, rowIndex: rowIndex + 1))
              .value = TextCellValue('ERRO');
        }
      }
    }

    print('Dados preenchidos com sucesso!');

    // Ajustar largura das colunas
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 25);
    }

    print('Codificando Excel...');
    var bytes = excel.encode();

    if (bytes == null || bytes.isEmpty) {
      print('ERRO: Não foi possível codificar o Excel');
      return false;
    }

    print('Excel codificado! Tamanho: ${bytes.length} bytes');
    print('Iniciando download...');

    await download(Stream.fromIterable(bytes), '$nameExcel.xlsx');

    print('=== DOWNLOAD CONCLUÍDO COM SUCESSO! ===');
    print('Total de registros exportados: ${allData.length}');
    return true;
  } catch (e, stackTrace) {
    print('=== ERRO CRÍTICO ===');
    print('Erro: $e');
    print('StackTrace: $stackTrace');
    return false;
  }
}
