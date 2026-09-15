// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart'; // ignore: unused_import
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:download/download.dart';
import 'package:excel/excel.dart';

/// Converte o valor vindo do Supabase/JSON para [DateTime] para células tipo data no Excel.
DateTime? _parseDateForExcelExport(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) {
    final s = value.trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }
  if (value is int) {
    final a = value.abs();
    if (a > 2000000000000000) {
      return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
    }
    if (a > 2000000000000) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    if (a > 2000000000) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
    }
  }
  if (value is double) {
    final asInt = value.round();
    if ((value - asInt).abs() < 1e-9) {
      return _parseDateForExcelExport(asInt);
    }
  }
  return DateTime.tryParse(value.toString());
}

bool _isPesagemAtivaForRebanhoExport(Map<String, dynamic> row) =>
    row['deletado']?.toString().trim().toUpperCase() != 'SIM';

Map<String, dynamic> latestPesagemDatesByRebanhoForExport(
  Iterable<Map<String, dynamic>> pesagens,
) {
  final latestRows = <String, Map<String, dynamic>>{};

  for (final row in pesagens) {
    final idRebanho = row['idRebanho']?.toString().trim() ?? '';
    final date = _parseDateForExcelExport(row['dataPesagem']);
    if (idRebanho.isEmpty ||
        date == null ||
        !_isPesagemAtivaForRebanhoExport(row)) {
      continue;
    }

    final current = latestRows[idRebanho];
    final currentDate = _parseDateForExcelExport(current?['dataPesagem']);
    final rowId = int.tryParse(row['id']?.toString() ?? '') ?? 0;
    final currentId = int.tryParse(current?['id']?.toString() ?? '') ?? 0;
    if (currentDate == null ||
        date.isAfter(currentDate) ||
        (date.isAtSameMomentAs(currentDate) && rowId > currentId)) {
      latestRows[idRebanho] = row;
    }
  }

  return latestRows.map(
    (idRebanho, row) => MapEntry(idRebanho, row['dataPesagem']),
  );
}

Future<Map<String, dynamic>> _fetchLatestPesagemDatesForRebanhoExport(
  Iterable<Map<String, dynamic>> rebanhoRows,
) async {
  final ids = rebanhoRows
      .map((row) => row['idRebanho']?.toString().trim() ?? '')
      .where((id) => id.isNotEmpty)
      .toSet()
      .toList();
  const idChunkSize = 200;
  const pageSize = 1000;
  final latestDates = <String, dynamic>{};

  for (var start = 0; start < ids.length; start += idChunkSize) {
    final end =
        start + idChunkSize > ids.length ? ids.length : start + idChunkSize;
    final chunk = ids.sublist(start, end);
    final pesagens = <Map<String, dynamic>>[];
    var offset = 0;

    while (true) {
      final response = await SupaFlow.client
          .from('historico_pesagens')
          .select('id, idRebanho, dataPesagem, deletado')
          .inFilter('idRebanho', chunk)
          .or('deletado.is.null,deletado.neq.SIM')
          .not('dataPesagem', 'is', null)
          .order('dataPesagem', ascending: false)
          .order('id', ascending: false)
          .range(offset, offset + pageSize - 1);
      pesagens.addAll(response.map(Map<String, dynamic>.from));
      if (response.length < pageSize) break;
      offset += pageSize;
    }

    latestDates.addAll(latestPesagemDatesByRebanhoForExport(pesagens));
  }

  return latestDates;
}

Future<bool> exportRebanhoExcel(String nameExcel, String idPropriedade) async {
  try {
    print('=== INÍCIO DA EXPORTAÇÃO ===');
    print('Nome arquivo: $nameExcel');
    print('ID Propriedade: $idPropriedade');

    // Lista para armazenar todos os dados
    List<Map<String, dynamic>> allData = [];
    final exportedIds = <String>{};
    int fetchedRows = 0;
    int skippedDuplicates = 0;

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
            .from('rebanho')
            .select()
            .eq('idPropriedade', idPropriedade)
            .eq('deletado', 'NAO')
            .order('id', ascending: true)
            .range(offset, offset + batchSize - 1);

        print('Registros retornados: ${response.length}');
        fetchedRows += response.length;

        // Adicionar os dados à lista principal
        for (var item in response) {
          final row = Map<String, dynamic>.from(item);
          final rowId = row['id']?.toString();
          if (rowId != null && rowId.isNotEmpty && !exportedIds.add(rowId)) {
            skippedDuplicates++;
            print('Registro duplicado ignorado na exportação: id=$rowId');
            continue;
          }
          allData.add(row);
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

    print('Total de registros buscados: $fetchedRows');
    print('Total de duplicados ignorados: $skippedDuplicates');
    print('Total de registros carregados para exportar: ${allData.length}');

    if (allData.isEmpty) {
      print('AVISO: Nenhum registro encontrado para exportar');
      return false;
    }

    final latestPesagemDates =
        await _fetchLatestPesagemDatesForRebanhoExport(allData);
    var correctedLatestDates = 0;
    for (final row in allData) {
      final idRebanho = row['idRebanho']?.toString().trim() ?? '';
      if (!latestPesagemDates.containsKey(idRebanho)) continue;
      final latestDate = latestPesagemDates[idRebanho];
      if (row['dataUltimaPesagem'] != latestDate) {
        row['dataUltimaPesagem'] = latestDate;
        correctedLatestDates++;
      }
    }
    print('Datas de última pesagem corrigidas pelo histórico: '
        '$correctedLatestDates');

    print('Criando Excel...');
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Exportar no formato do MODELO de importação (não exportar todas as colunas da tabela).
    // Headers aqui são os nomes do Excel; os valores são obtidos do map retornado pelo Supabase.
    const template = <String, String>{
      'Numero': 'numeroAnimal',
      'Chip': 'chip',
      'Codigo_registro': 'codRegistro',
      'Nome': 'nome',
      'Sexo': 'sexo',
      'Data_nascimento': 'dataNascimento',
      'Peso_nascimento': 'pesoNascimento',
      'Porte': 'porte',
      'Categoria': 'categoria',
      'Raca': 'raca',
      'Lote': 'loteNome',
      'Data_desmama': 'dataDesmama',
      'Peso_desmama': 'pesoDesmama',
      'Data_ultima_pesagem': 'dataUltimaPesagem',
      'Peso_atual': 'pesoAtual',
      'Status': 'status',
      'Data_venda': 'dataVenda',
      'Valor_venda': 'valorVenda',
      'Data_morte': 'data_morte',
      'Motivo_morte': 'motivo_morte',
      'Movimentacao_saida': 'movimentacao_saida',
      'Origem': 'origem',
      'Data_compra': 'dataAcao',
      'Valor_compra': 'valorCompra',
      'Movimentacao_entrada': 'movimentacao_entrada',
      'Anotacoes': 'anotacoes',
      'Numero_matriz': 'numeroMatriz',
      'Nome_matriz': 'nomeMatriz',
      'Data_nascimento_matriz': 'dataNascMatriz',
      'Categoria_matriz': 'categoria_matriz',
      'Raca_matriz': 'racaMatriz',
      'Numero_reprodutor': 'numeroReprodutor',
      'Nome_reprodutor': 'nomeReprodutor',
      'Data_nascimento_reprodutor': 'dataNascReprodutor',
      'Raca_reprodutor': 'racaReprodutor',
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

    // Colunas numéricas e de data (do TEMPLATE)
    Set<String> numericColumns = {
      'Peso_nascimento',
      'Peso_desmama',
      'Peso_atual',
      'Valor_compra',
      'Valor_venda',
    };

    Set<String> dateColumns = {
      'Data_nascimento',
      'Data_desmama',
      'Data_ultima_pesagem',
      'Data_venda',
      'Data_morte',
      'Movimentacao_entrada',
      'Movimentacao_saida',
      'Data_compra',
      'Data_nascimento_matriz',
      'Data_nascimento_reprodutor',
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
            }
          } else if (dateColumns.contains(columnName)) {
            // Célula tipo data nativa do Excel (não número genérico nem texto “dd/MM/yyyy”).
            final parsed = _parseDateForExcelExport(value);
            final cell = sheet.cell(CellIndex.indexByColumnRow(
                columnIndex: colIndex, rowIndex: rowIndex + 1));
            if (parsed != null) {
              cell.value = DateCellValue.fromDateTime(parsed);
            } else {
              final isEmpty =
                  value == null || (value is String && value.trim().isEmpty);
              cell.value = TextCellValue(isEmpty ? '' : value.toString());
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
