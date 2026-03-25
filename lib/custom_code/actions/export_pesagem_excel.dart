// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:excel/excel.dart';
import 'package:download/download.dart';

/// Pesagens dos animais cuja ficha está nesta propriedade (via [idRebanho]).
/// Não depende só de [historico_pesagens.id_propriedade], que muitas telas não preenchem
/// ao inserir pesagem pela ficha do animal — só importação em lote costumava gravar.
Future<List<Map<String, dynamic>>> _fetchPesagensForProperty(
    String idPropriedade) async {
  final idProp = idPropriedade.trim();
  if (idProp.isEmpty) return [];

  final rebanhoRows = await SupaFlow.client
      .from('rebanho')
      .select('idRebanho')
      .eq('idPropriedade', idProp);

  final ids = <String>[];
  for (final r in rebanhoRows) {
    final k = r['idRebanho']?.toString().trim();
    if (k != null && k.isNotEmpty) ids.add(k);
  }
  if (ids.isEmpty) return [];

  const pageSize = 1000;
  const idChunk = 200;
  final all = <Map<String, dynamic>>[];

  for (var start = 0; start < ids.length; start += idChunk) {
    final end = start + idChunk > ids.length ? ids.length : start + idChunk;
    final chunk = ids.sublist(start, end);
    var offset = 0;
    while (true) {
      final res = await SupaFlow.client
          .from('historico_pesagens')
          .select('*')
          .inFilter('idRebanho', chunk)
          .or('deletado.is.null,deletado.neq.SIM')
          .order('id', ascending: true)
          .range(offset, offset + pageSize - 1);
      for (final item in res) {
        all.add(Map<String, dynamic>.from(item));
      }
      if (res.length < pageSize) break;
      offset += pageSize;
    }
  }

  all.sort((a, b) {
    final ia = (a['id'] is int)
        ? a['id'] as int
        : int.tryParse('${a['id']}') ?? 0;
    final ib = (b['id'] is int)
        ? b['id'] as int
        : int.tryParse('${b['id']}') ?? 0;
    return ia.compareTo(ib);
  });
  return all;
}

Future<bool> exportPesagemExcel(String nameExcel, String idPropriedade) async {
  try {
    print('=== INÍCIO DA EXPORTAÇÃO - PESAGEM ===');
    print('ID Propriedade: $idPropriedade');

    // 1) Buscar pesagens pelos animais da propriedade (idRebanho)
    final allData = await _fetchPesagensForProperty(idPropriedade);
    print('Pesagens carregadas: ${allData.length}');

    if (allData.isEmpty) {
      print('AVISO: Nenhum registro encontrado para exportar');
      return false;
    }

    // 2) Buscar dados do rebanho da mesma propriedade e indexar por idRebanho
    final rebanhoList = await SupaFlow.client
        .from('rebanho')
        .select('idRebanho, numeroAnimal, chip, nome, sexo, dataNascimento, raca')
        .eq('idPropriedade', idPropriedade);
    final rebanhoMap = <String, Map<String, dynamic>>{};
    for (var r in rebanhoList) {
      final key = r['idRebanho'];
      if (key != null) rebanhoMap[key.toString()] = Map<String, dynamic>.from(r);
    }
    print('Animais indexados: ${rebanhoMap.length}');

    print('Criando Excel...');
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    const headers = [
      'Numero_animal', 'Chip', 'Nome', 'Sexo',
      'Data_nascimento', 'Raca', 'Data_pesagem', 'Peso', 'Tipo',
    ];

    // Mapeamento: header -> chave no rebanho (ou null se vier da pesagem)
    const rebanhoKeyMap = <String, String>{
      'Numero_animal': 'numeroAnimal',
      'Chip': 'chip',
      'Nome': 'nome',
      'Sexo': 'sexo',
      'Data_nascimento': 'dataNascimento',
      'Raca': 'raca',
    };
    const pesagemKeyMap = <String, String>{
      'Data_pesagem': 'dataPesagem',
      'Peso': 'peso',
      'Tipo': 'tipo',
    };

    // Adicionar headers
    for (var i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
    }

    const numericColumns = {'Peso'};
    const dateColumns = {'Data_nascimento', 'Data_pesagem'};

    // Preencher dados
    print('Preenchendo dados...');
    for (var rowIndex = 0; rowIndex < allData.length; rowIndex++) {
      if (rowIndex % 1000 == 0) {
        print('Processando linha $rowIndex de ${allData.length}');
      }

      final row = allData[rowIndex];
      final idReb = row['idRebanho']?.toString() ?? '';
      final rebanhoData = rebanhoMap[idReb];

      for (var colIndex = 0; colIndex < headers.length; colIndex++) {
        final header = headers[colIndex];

        // Buscar valor: do rebanho ou direto da pesagem
        dynamic value;
        if (rebanhoKeyMap.containsKey(header)) {
          value = rebanhoData?[rebanhoKeyMap[header]!];
        } else {
          value = row[pesagemKeyMap[header]!];
        }

        final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex + 1));

        try {
          if (numericColumns.contains(header)) {
            if (value == null) {
              cell.value = TextCellValue('');
            } else if (value is num) {
              cell.value = DoubleCellValue(value.toDouble());
            } else if (value is String && value.isNotEmpty) {
              var numVal = double.tryParse(value.replaceAll(',', '.'));
              cell.value = numVal != null
                  ? DoubleCellValue(numVal)
                  : TextCellValue(value);
            } else {
              cell.value = TextCellValue(value.toString());
            }
          } else if (dateColumns.contains(header)) {
            if (value == null) {
              cell.value = TextCellValue('');
            } else {
              String dateStr;
              try {
                DateTime date = value is DateTime
                    ? value
                    : DateTime.parse(value.toString());
                dateStr = DateFormat('dd/MM/yyyy').format(date);
              } catch (_) {
                dateStr = value.toString();
              }
              cell.value = TextCellValue(dateStr);
            }
          } else {
            cell.value = TextCellValue(value?.toString() ?? '');
          }
        } catch (e) {
          print('ERRO na célula [$rowIndex, $colIndex]: $e');
          cell.value = TextCellValue('ERRO');
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
