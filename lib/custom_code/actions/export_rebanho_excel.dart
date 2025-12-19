// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:excel/excel.dart';
import 'package:download/download.dart';

Future exportRebanhoExcel(String nameExcel, String idPropriedade) async {
  try {
    print('=== INÍCIO DA EXPORTAÇÃO ===');
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
            .from('rebanho')
            .select()
            .eq('idPropriedade', idPropriedade)
            .eq('deletado', 'NAO')
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
      return;
    }

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
            // Tratamento de data
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
      return;
    }

    print('Excel codificado! Tamanho: ${bytes.length} bytes');
    print('Iniciando download...');

    await download(Stream.fromIterable(bytes), '$nameExcel.xlsx');

    print('=== DOWNLOAD CONCLUÍDO COM SUCESSO! ===');
    print('Total de registros exportados: ${allData.length}');
  } catch (e, stackTrace) {
    print('=== ERRO CRÍTICO ===');
    print('Erro: $e');
    print('StackTrace: $stackTrace');
  }
}
