// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:excel/excel.dart';
import 'package:download/download.dart';

/// Normaliza sexo para exportação (Macho / Fêmea), como no cadastro do rebanho.
String _sexoParaExportacao(dynamic raw) {
  final s = raw?.toString().trim() ?? '';
  if (s.isEmpty) return '';
  final lower = s.toLowerCase();
  if (lower == 'm' || lower == 'macho') return 'Macho';
  if (lower == 'f' || lower == 'femea' || lower == 'fêmea') {
    return 'Fêmea';
  }
  return s;
}

bool _temValorSanidadeExport(dynamic value) =>
    value != null && value.toString().trim().isNotEmpty;

Future<void> _preencherDadosAnimaisSanidade(
  List<Map<String, dynamic>> rows,
) async {
  const camposAnimal = [
    'numeroAnimal',
    'nome',
    'dataNascimento',
    'raca',
    'sexo',
  ];
  final idsComDadosIncompletos = rows
      .where((row) =>
          camposAnimal.any((campo) => !_temValorSanidadeExport(row[campo])))
      .map((row) => row['id_rebanho']?.toString().trim() ?? '')
      .where((id) => id.isNotEmpty)
      .toSet()
      .toList(growable: false);

  if (idsComDadosIncompletos.isEmpty) return;

  const chunkSize = 200;
  final animaisPorId = <String, Map<String, dynamic>>{};

  try {
    for (var start = 0;
        start < idsComDadosIncompletos.length;
        start += chunkSize) {
      final end = start + chunkSize > idsComDadosIncompletos.length
          ? idsComDadosIncompletos.length
          : start + chunkSize;
      final response = await SupaFlow.client
          .from('rebanho')
          .select('idRebanho, numeroAnimal, nome, dataNascimento, raca, sexo')
          .inFilter('idRebanho', idsComDadosIncompletos.sublist(start, end));

      for (final item in response) {
        final animal = Map<String, dynamic>.from(item);
        final idRebanho = animal['idRebanho']?.toString().trim() ?? '';
        if (idRebanho.isNotEmpty) {
          animaisPorId[idRebanho] = animal;
        }
      }
    }
  } catch (e) {
    print('AVISO: não foi possível complementar dados do rebanho: $e');
    return;
  }

  for (final row in rows) {
    final idRebanho = row['id_rebanho']?.toString().trim() ?? '';
    final animal = animaisPorId[idRebanho];
    if (animal == null) continue;

    for (final campo in camposAnimal) {
      if (!_temValorSanidadeExport(row[campo])) {
        row[campo] = animal[campo];
      }
    }
  }
}

Future<bool> exportSanidadeExcel(String nameExcel, String idPropriedade) async {
  try {
    print('=== INÍCIO DA EXPORTAÇÃO - SANIDADE ===');
    print('Nome arquivo: $nameExcel');
    print('ID Propriedade: $idPropriedade');

    List<Map<String, dynamic>> allData = [];

    int batchSize = 1000;
    int offset = 0;
    bool hasMoreData = true;

    print('Iniciando busca no Supabase...');

    while (hasMoreData) {
      print('Buscando registros $offset a ${offset + batchSize}...');

      try {
        // view_rebanho_sanidade: sanidade + dados do animal (rebanho), igual à listagem no app.
        final response = await SupaFlow.client
            .from('view_rebanho_sanidade')
            .select()
            .eq('id_propriedade', idPropriedade)
            .eq('deletado', 'NAO')
            .order('id', ascending: true)
            .range(offset, offset + batchSize - 1);

        print('Registros retornados: ${response.length}');

        for (var item in response) {
          allData.add(Map<String, dynamic>.from(item));
        }

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

    await _preencherDadosAnimaisSanidade(allData);

    print('Criando Excel...');
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    const template = <String, String>{
      'Animal': 'id_rebanho',
      'Numero': 'numeroAnimal',
      'Nome': 'nome',
      'Data_nascimento': 'dataNascimento',
      'Raca': 'raca',
      'Sexo': 'sexo',
      'Data_sanidade': 'data_sanidade',
      'Porcentagem_lote': 'porcentagem_lote',
      'Vacinacao': 'vacinacao',
      'Vacinacao_outros': 'vacinacao_outros',
      'Vacinacao_obs': 'vacinacao_obs',
      'Antiparasitario': 'antiparasitario',
      'Antiparasitario_outros': 'antiparasitario_outros',
      'Antiparasitario_obs': 'antiparasitario_obs',
      'Tratamento': 'tratamento',
      'Tratamento_outros': 'tratamento_outros',
      'Tratamento_obs': 'tratamento_obs',
      'Protocolo_reprodutivo': 'protocolo_reprodutivo',
      'Protocolo_reprodutivo_outros': 'protocolo_reprodutivo_outros',
      'Protocolo_reprodutivo_obs': 'protocolo_reprodutivo_obs',
      'Protocolo_D0': 'protocolo_d0',
      'Protocolo_retirada': 'protocolo_retirada',
      'Protocolo_IATF': 'protocolo_iatf',
    };

    final headers = template.keys.toList(growable: false);

    print('Colunas a exportar (${headers.length}): $headers');

    for (var i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
    }
    print('Headers adicionados!');

    Set<String> numericColumns = {'Porcentagem_lote'};

    Set<String> dateColumns = {
      'Data_sanidade',
      'Data_nascimento',
    };

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

        if (columnName == 'Sexo') {
          value = _sexoParaExportacao(value);
        }

        try {
          if (numericColumns.contains(columnName)) {
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
            if (value == null) {
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: colIndex, rowIndex: rowIndex + 1))
                  .value = TextCellValue('');
            } else {
              String dateStr;
              if (value is DateTime) {
                dateStr = DateFormat('dd/MM/yyyy').format(value);
              } else {
                try {
                  DateTime date = DateTime.parse(value.toString());
                  dateStr = DateFormat('dd/MM/yyyy').format(date);
                } catch (e) {
                  dateStr = value.toString();
                }
              }
              sheet
                  .cell(CellIndex.indexByColumnRow(
                      columnIndex: colIndex, rowIndex: rowIndex + 1))
                  .value = TextCellValue(dateStr);
            }
          } else {
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
