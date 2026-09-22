// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xl;
import '/importacao/import_texto_utils.dart';
import '/importacao/import_diagnostico_model.dart';
import '/importacao/import_arquivo_probe.dart';
import '/importacao/import_erro_amigavel.dart';

/// Le a planilha de Rebanho reportando tudo o que observou.
///
/// Diferente de [parseCsvToJsonRebanho2], nao engole problema: cada arquivo
/// rejeitado e cada linha reprovada viram uma ImportOcorrencia em vez de um
/// print() no console. As linhas reprovadas continuam em `registros`, marcadas
/// pelo numero de linha, para que o relatorio feche com a planilha aberta na
/// tela do usuario.
Future<ImportParseResult> parseCsvToJsonRebanho2Detalhado(
  FFUploadedFile? csvFile,
) async {
  final ocorrencias = <ImportOcorrencia>[];
  final linhasInvalidas = <int>{};

  final nomeArquivo = csvFile == null
      ? null
      : (csvFile.originalFilename.isNotEmpty
          ? csvFile.originalFilename
          : csvFile.name);

  ImportParseResult abortar(
    String codigo,
    String mensagem, {
    String? sugestao,
    ImportArquivoInfo? arquivo,
  }) {
    ocorrencias.add(ImportOcorrencia(
      codigo: codigo,
      severidade: ImportSeveridade.bloqueante,
      escopo: ImportEscopo.arquivo,
      mensagem: mensagem,
      sugestao: sugestao,
    ));
    return ImportParseResult(
      registros: const [],
      arquivo: arquivo ??
          ImportArquivoInfo(
            nomeArquivo: nomeArquivo,
            tamanhoBytes: csvFile?.bytes?.length,
          ),
      ocorrencias: ocorrencias,
      linhasInvalidas: linhasInvalidas,
    );
  }

  if (csvFile == null || csvFile.bytes == null || csvFile.bytes!.isEmpty) {
    return abortar(
      ImportCodigo.arqVazio,
      'O arquivo está vazio ou não foi selecionado.',
      sugestao: 'Selecione a planilha preenchida e tente de novo.',
    );
  }

  final List<int> bytes = csvFile.bytes!;
  final fileName = (csvFile.originalFilename.isNotEmpty
          ? csvFile.originalFilename
          : (csvFile.name ?? ''))
      .toLowerCase();

  if (_isLegacyXlsBinary(bytes, fileName)) {
    return abortar(
      ImportCodigo.arqXlsBinario,
      'Arquivo .xls antigo não é suportado.',
      sugestao: 'No Excel, use Arquivo → Salvar como → Pasta de Trabalho do '
          'Excel (.xlsx), ou CSV UTF-8.',
      arquivo: ImportArquivoInfo(
        nomeArquivo: nomeArquivo,
        tamanhoBytes: bytes.length,
        formato: 'xls',
      ),
    );
  }

  final isXlsx = _isXlsxFile(bytes, fileName);
  final formato = isXlsx ? 'xlsx' : 'csv';

  if (!isXlsx && _looksLikeBinaryContent(bytes)) {
    return abortar(
      ImportCodigo.arqBinarioNaoTexto,
      'O arquivo não parece ser uma planilha de texto (pode ser PDF, imagem '
      'ou estar corrompido).',
      sugestao: 'Exporte a planilha como CSV UTF-8 ou .xlsx.',
      arquivo: ImportArquivoInfo(
        nomeArquivo: nomeArquivo,
        tamanhoBytes: bytes.length,
        formato: formato,
      ),
    );
  }

  try {
    final leitura = isXlsx ? _lerXlsx(bytes) : _lerCsv(bytes);
    final List<List<dynamic>> rows = leitura.rows;

    final infoBase = ImportArquivoInfo(
      nomeArquivo: nomeArquivo,
      tamanhoBytes: bytes.length,
      formato: formato,
      delimitador: leitura.delimitador,
      encodingUsado: leitura.encoding,
      abaUsada: leitura.abaUsada,
      totalAbas: leitura.totalAbas,
    );

    if (rows.isEmpty) {
      return abortar(
        ImportCodigo.arqSemLinhasDados,
        'Não foi possível ler nenhuma linha da planilha.',
        sugestao: 'Confira se o arquivo não está vazio ou protegido por senha.',
        arquivo: infoBase,
      );
    }

    // 6. Colunas do banco (para fallback por posição quando CSV já vem exportado)
    const dbColumnsInOrder = [
      'id',
      'created_at',
      'idPropriedade',
      'numeroAnimal',
      'chip',
      'codRegistro',
      'nome',
      'sexo',
      'categoria',
      'dataNascimento',
      'pesoNascimento',
      'porte',
      'raca',
      'loteID',
      'dataEntradaLote',
      'rebanhoIdMatriz',
      'rebanhoIdReprodutor',
      'dataDesmama',
      'pesoDesmama',
      'pesoAtual',
      'status',
      'origem',
      'anotacoes',
      'idRebanho',
      'deletado',
      'updated_at',
      'loteNome',
      'tipo',
      'dataAcao',
      'valorCompra',
      'dataUltimaPesagem',
      'nomeConcat',
      'dataVenda',
      'valorVenda',
      'movimentacao_entrada',
      'numeroMatriz',
      'nomeMatriz',
      'dataNascMatriz',
      'racaMatriz',
      'numeroReprodutor',
      'nomeReprodutor',
      'dataNascReprodutor',
      'racaReprodutor',
      'movimentacao_saida',
      'data_morte',
      'motivo_morte',
      'categoria_matriz',
    ];

    const dbColumnSet = {
      'id',
      'created_at',
      'idPropriedade',
      'numeroAnimal',
      'chip',
      'codRegistro',
      'nome',
      'sexo',
      'categoria',
      'dataNascimento',
      'pesoNascimento',
      'porte',
      'raca',
      'loteID',
      'dataEntradaLote',
      'rebanhoIdMatriz',
      'rebanhoIdReprodutor',
      'dataDesmama',
      'pesoDesmama',
      'pesoAtual',
      'status',
      'origem',
      'anotacoes',
      'idRebanho',
      'deletado',
      'updated_at',
      'loteNome',
      'tipo',
      'dataAcao',
      'valorCompra',
      'dataUltimaPesagem',
      'nomeConcat',
      'dataVenda',
      'valorVenda',
      'movimentacao_entrada',
      'numeroMatriz',
      'nomeMatriz',
      'dataNascMatriz',
      'racaMatriz',
      'numeroReprodutor',
      'nomeReprodutor',
      'dataNascReprodutor',
      'racaReprodutor',
      'movimentacao_saida',
      'data_morte',
      'motivo_morte',
      'categoria_matriz',
    };

    const dateColumns = [
      'created_at',
      'dataNascimento',
      'dataEntradaLote',
      'dataDesmama',
      'updated_at',
      'dataAcao',
      'dataUltimaPesagem',
      'dataVenda',
      'movimentacao_entrada',
      'dataNascMatriz',
      'dataNascReprodutor',
      'movimentacao_saida',
      'data_morte',
    ];

    const numericColumns = [
      'pesoNascimento',
      'pesoDesmama',
      'pesoAtual',
      'valorCompra',
      'valorVenda',
    ];

    // --- detectar layout ---------------------------------------------------
    // Se a primeira linha tem cabecalho conhecido, mapeia por nome. Caso
    // contrario o parser historicamente cai num mapeamento por POSICAO cuja
    // ordem comeca em id, created_at, idPropriedade -- e a planilha do produtor,
    // que comeca em "Numero", entra inteira deslocada. Agora isso e reportado.
    final headerRow = rows.first;
    final headerStrings = headerRow
        .map((e) => e == null ? '' : e.toString())
        .map(_cleanText)
        .toList();
    final normalizedHeaders = headerStrings.map(_normalizeHeader).toList();

    final bool looksLikeUserTemplate = normalizedHeaders.contains('numero') ||
        normalizedHeaders.contains('numero_animal') ||
        normalizedHeaders.contains('data_compra') ||
        normalizedHeaders.contains('valor_compra');

    final bool looksLikeDbExport = headerStrings.any(dbColumnSet.contains);

    final bool useHeaderMapping =
        (looksLikeUserTemplate || looksLikeDbExport) &&
            normalizedHeaders.any((h) => h.isNotEmpty);

    final mapping = useHeaderMapping
        ? _buildHeaderToDbMapping(headerStrings, dbColumnSet)
        : <String, int>{
            for (var i = 0; i < dbColumnsInOrder.length; i++)
              dbColumnsInOrder[i]: i
          };

    final exame = examinarCabecalho(
      entidade: ImportEntidade.rebanho,
      headers: headerStrings,
      mapeamento: mapping,
    );

    final arquivo = infoBase.copyWith(
      usouFallbackPosicional: !useHeaderMapping,
      headersOriginais: headerStrings.where((h) => h.isNotEmpty).toList(),
      headersReconhecidos: exame.reconhecidos,
      headersDesconhecidos: useHeaderMapping ? exame.desconhecidos : const [],
      colunasObrigatoriasFaltando:
          useHeaderMapping ? exame.obrigatoriasFaltando : const [],
      colunasDuplicadas: exame.duplicados,
      entidadeDetectada: detectarEntidadePorHeaders(headerStrings),
    );

    // --- ler as linhas de dados -------------------------------------------
    final out = <dynamic>[];
    var totalLinhas = 0;
    var linhasEmBranco = 0;

    // A linha 1 e o cabecalho, entao a primeira linha de dados e a 2.
    var numeroLinha = 1;
    for (final row in rows.skip(1)) {
      numeroLinha++;
      if (_isCsvRowEmpty(row)) {
        linhasEmBranco++;
        continue;
      }
      totalLinhas++;

      final map = <String, dynamic>{};

      mapping.forEach((dbColumn, index) {
        final raw = (index < row.length && row[index] != null)
            ? row[index].toString()
            : '';
        final value = _cleanText(raw);
        final cleaned = _cleanCellToNull(value, dbColumn, numericColumns);

        // O zero convertido em vazio e um comportamento antigo e surpreendente:
        // o animal cujo numero e literalmente "0" perde o numero.
        if (cleaned == null) {
          if (value == '0' && !numericColumns.contains(dbColumn)) {
            ocorrencias.add(ImportOcorrencia(
              codigo: ImportCodigo.rebZeroViraVazio,
              severidade: ImportSeveridade.aviso,
              escopo: ImportEscopo.dado,
              linha: numeroLinha,
              coluna: dbColumn,
              valor: value,
              mensagem: 'Linha $numeroLinha: o valor "0" em '
                  '${labelColunaImportacao(dbColumn.toLowerCase())} será '
                  'tratado como vazio.',
              sugestao: 'Se o valor é realmente 0, escreva "000".',
            ));
          }
          map[dbColumn] = null;
          return;
        }

        if (dateColumns.contains(dbColumn)) {
          map[dbColumn] = cleaned;
        } else if (numericColumns.contains(dbColumn)) {
          // O bruto e perdido na conversao, entao o problema numerico so pode
          // ser detectado aqui, onde o texto original ainda existe.
          final numero = _parseNumberPtBr(cleaned);
          if (numero == null) {
            ocorrencias.add(ImportOcorrencia(
              codigo: ImportCodigo.rebNumeroInvalido,
              severidade: ImportSeveridade.bloqueante,
              escopo: ImportEscopo.dado,
              linha: numeroLinha,
              coluna: dbColumn,
              valor: cleaned,
              mensagem: 'Linha $numeroLinha: '
                  '${labelColunaImportacao(dbColumn.toLowerCase())} "$cleaned" '
                  'não é um número.',
              sugestao: 'Escreva apenas o número, sem unidade '
                  '(ex.: 480 em vez de "480 kg").',
            ));
            linhasInvalidas.add(numeroLinha);
          } else if (_pontoDeMilharAmbiguo(cleaned)) {
            ocorrencias.add(ImportOcorrencia(
              codigo: ImportCodigo.rebNumeroPtbrAmbiguo,
              severidade: ImportSeveridade.aviso,
              escopo: ImportEscopo.dado,
              linha: numeroLinha,
              coluna: dbColumn,
              valor: cleaned,
              mensagem: 'Linha $numeroLinha: '
                  '${labelColunaImportacao(dbColumn.toLowerCase())} "$cleaned" '
                  'foi lido como $numero, e não como '
                  '${cleaned.replaceAll('.', '')}.',
              sugestao: 'Escreva sem separador de milhar '
                  '(${cleaned.replaceAll('.', '')}) ou use vírgula para '
                  'decimal.',
            ));
          }
          map[dbColumn] = numero;
        } else {
          map[dbColumn] = cleaned;
        }
      });

      // Campos que o usuário normalmente não tem: deixam null para o
      // batch_insert gerar/limpar.
      map.putIfAbsent('idRebanho', () => null);
      map.putIfAbsent('idPropriedade', () => null);

      if (_isAllValuesMissing(map.values)) {
        linhasEmBranco++;
        totalLinhas--;
        continue;
      }

      // O que antes saia por print() e virava linha desaparecida agora e
      // relatado, e a linha segue na lista marcada como invalida.
      final validationError = _validateParsedRecord(map);
      if (validationError != null) {
        ocorrencias.add(ImportOcorrencia(
          codigo: _codigoDoErroDeValidacao(validationError),
          severidade: ImportSeveridade.bloqueante,
          escopo: ImportEscopo.dado,
          linha: numeroLinha,
          mensagem: 'Linha $numeroLinha: $validationError',
          sugestao: 'Corrija a linha na planilha ou remova-a.',
        ));
        linhasInvalidas.add(numeroLinha);
      }

      map[kCampoLinhaArquivo] = numeroLinha;
      out.add(map);
    }

    if (linhasEmBranco > 0) {
      ocorrencias.add(ImportOcorrencia(
        codigo: ImportCodigo.arqLinhasEmBranco,
        severidade: ImportSeveridade.informativo,
        escopo: ImportEscopo.arquivo,
        mensagem: '$linhasEmBranco linha(s) em branco foram ignoradas.',
      ));
    }

    if (linhasInvalidas.isNotEmpty) {
      ocorrencias.add(ImportOcorrencia(
        codigo: ImportCodigo.arqLinhasDescartadas,
        severidade: ImportSeveridade.aviso,
        escopo: ImportEscopo.arquivo,
        mensagem: '${linhasInvalidas.length} de $totalLinhas linha(s) não '
            'podem ser importadas por problema no conteúdo.',
        sugestao: 'Veja o detalhe de cada uma na lista abaixo.',
      ));
    }

    ocorrencias.addAll(diagnosticarEstrutura(
      entidade: ImportEntidade.rebanho,
      arquivo: arquivo,
      totalLinhasDados: totalLinhas,
    ));

    return ImportParseResult(
      registros: out,
      arquivo: arquivo,
      ocorrencias: ocorrencias,
      linhasInvalidas: linhasInvalidas,
      totalLinhas: totalLinhas,
    );
  } catch (e, stack) {
    print('Erro no processamento da planilha de rebanho: $e');
    print(stack);
    return abortar(
      ImportCodigo.arqBinarioNaoTexto,
      'Não foi possível ler a planilha: $e',
      sugestao: 'Confira se o arquivo é um CSV ou .xlsx válido.',
    );
  }
}

/// True quando o texto tem ponto seguido de exatamente 3 digitos e nenhuma
/// virgula -- assinatura de separador de milhar que parseNumberPtBrImport
/// interpreta como decimal ("1.234" vira 1,234 kg).
bool _pontoDeMilharAmbiguo(String texto) {
  if (texto.contains(',')) return false;
  return RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(texto.trim());
}

/// Traduz a mensagem de _validateParsedRecord no codigo de catalogo
/// correspondente, para que o relatorio agrupe por causa.
String _codigoDoErroDeValidacao(String erro) {
  final lower = erro.toLowerCase();
  if (lower.contains('identificador')) {
    return ImportCodigo.rebIdentificadorImplausivel;
  }
  if (lower.contains('corrompid') || lower.contains('incompat')) {
    return ImportCodigo.rebTextoCorrompido;
  }
  return ImportCodigo.rebSemIdentidade;
}

/// Mantida para os call-sites que ainda nao usam o diagnostico. Preserva o
/// comportamento antigo: descarta as linhas reprovadas e nao expoe os campos
/// auxiliares do relatorio.
Future<List<dynamic>> parseCsvToJsonRebanho2(FFUploadedFile? csvFile) async {
  final resultado = await parseCsvToJsonRebanho2Detalhado(csvFile);
  return resultado.registrosCompativeis
      .map((r) => r is Map
          ? (Map<String, dynamic>.from(r)..remove(kCampoLinhaArquivo))
          : r)
      .toList();
}

/// Resultado bruto da leitura da planilha, com os metadados que o diagnostico
/// precisa relatar (delimitador detectado, encoding usado, aba lida).
/// Antes esses dados so apareciam em print() e se perdiam.
class _LeituraPlanilha {
  final List<List<dynamic>> rows;
  final String? delimitador;
  final String? encoding;
  final String? abaUsada;
  final int? totalAbas;

  const _LeituraPlanilha({
    required this.rows,
    this.delimitador,
    this.encoding,
    this.abaUsada,
    this.totalAbas,
  });
}

/// Le um .xlsx. Assim como antes, usa apenas a PRIMEIRA aba -- a diferenca e
/// que agora informa quantas existem, para o diagnostico avisar o usuario.
_LeituraPlanilha _lerXlsx(List<int> bytes) {
  final excel = xl.Excel.decodeBytes(bytes);
  if (excel.tables.isEmpty) {
    return const _LeituraPlanilha(rows: [], totalAbas: 0);
  }
  final sheetName = excel.tables.keys.first;
  final totalAbas = excel.tables.length;
  return _LeituraPlanilha(
    rows: _parseXlsx(bytes),
    abaUsada: sheetName,
    totalAbas: totalAbas,
  );
}

/// Le um CSV, devolvendo tambem o delimitador e o encoding escolhidos.
_LeituraPlanilha _lerCsv(List<int> bytes) {
  List<int> cleanBytes = bytes;
  var encoding = 'utf-8';

  String? csvString = _decodeUtf16Bom(cleanBytes);
  if (csvString != null) {
    encoding = 'utf-16';
  } else {
    if (cleanBytes.length >= 3 &&
        cleanBytes[0] == 0xEF &&
        cleanBytes[1] == 0xBB &&
        cleanBytes[2] == 0xBF) {
      cleanBytes = cleanBytes.sublist(3);
      encoding = 'utf-8-bom';
    }
    csvString = _decodeWithBestEncoding(cleanBytes);
  }

  csvString = csvString.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final delimiter = _detectDelimiter(csvString.split('\n').first);

  final converter = CsvToListConverter(
    fieldDelimiter: delimiter,
    eol: '\n',
    shouldParseNumbers: false,
    allowInvalid: true,
  );
  return _LeituraPlanilha(
    rows: converter.convert(csvString),
    delimitador: delimiter,
    encoding: encoding,
  );
}

bool _isXlsxFile(List<int> bytes, String fileName) {
  if (fileName.endsWith('.xlsx')) return true;
  if (fileName.endsWith('.xls') && _hasZipSignature(bytes)) return true;
  // XLSX é um ZIP; a assinatura evita decodificar bytes binários como CSV.
  return _hasZipSignature(bytes);
}

bool _hasZipSignature(List<int> bytes) {
  return bytes.length >= 4 &&
      bytes[0] == 0x50 &&
      bytes[1] == 0x4B &&
      bytes[2] == 0x03 &&
      bytes[3] == 0x04;
}

bool _isLegacyXlsBinary(List<int> bytes, String fileName) {
  final hasOleSignature = bytes.length >= 8 &&
      bytes[0] == 0xD0 &&
      bytes[1] == 0xCF &&
      bytes[2] == 0x11 &&
      bytes[3] == 0xE0 &&
      bytes[4] == 0xA1 &&
      bytes[5] == 0xB1 &&
      bytes[6] == 0x1A &&
      bytes[7] == 0xE1;

  if (hasOleSignature) return true;

  return fileName.endsWith('.xls') && !_hasZipSignature(bytes);
}

bool _hasUtf16Bom(List<int> bytes) {
  return bytes.length >= 2 &&
      ((bytes[0] == 0xFF && bytes[1] == 0xFE) ||
          (bytes[0] == 0xFE && bytes[1] == 0xFF));
}

bool _looksLikeBinaryContent(List<int> bytes) {
  if (bytes.isEmpty || _hasUtf16Bom(bytes) || _hasZipSignature(bytes)) {
    return false;
  }

  final sampleLength = bytes.length < 4096 ? bytes.length : 4096;
  var binaryControlBytes = 0;
  var nullBytes = 0;

  for (var i = 0; i < sampleLength; i++) {
    final byte = bytes[i];
    if (byte == 0) {
      nullBytes++;
      continue;
    }

    final isAllowedTextControl = byte == 0x09 || byte == 0x0A || byte == 0x0D;
    if (byte < 0x20 && !isAllowedTextControl) {
      binaryControlBytes++;
    }
  }

  final binaryRatio = (binaryControlBytes + nullBytes) / sampleLength;
  return nullBytes > 0 || binaryRatio > 0.04;
}

List<List<dynamic>> _parseXlsx(List<int> bytes) {
  final excel = xl.Excel.decodeBytes(bytes);
  if (excel.tables.isEmpty) return [];

  final sheetName = excel.tables.keys.first;
  final sheet = excel.tables[sheetName];
  if (sheet == null || sheet.rows.isEmpty) return [];

  final rows = <List<dynamic>>[];
  for (final row in sheet.rows) {
    final cells = <dynamic>[];
    for (final cell in row) {
      final value = cell?.value;
      if (value == null) {
        cells.add('');
      } else if (value is xl.DateCellValue) {
        final dt = value.asDateTimeLocal();
        cells.add(
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}',
        );
      } else if (value is xl.DoubleCellValue) {
        cells.add(value.value.toString());
      } else if (value is xl.IntCellValue) {
        cells.add(value.value.toString());
      } else if (value is xl.TextCellValue) {
        cells.add(value.value.text ?? '');
      } else {
        cells.add(value.toString());
      }
    }
    rows.add(cells);
  }
  return rows;
}

bool _isCsvRowEmpty(List<dynamic> row) {
  if (row.isEmpty) return true;
  for (final cell in row) {
    if (cell == null) continue;
    final cleaned = _cleanText(cell.toString());
    if (cleaned.isNotEmpty && cleaned.toLowerCase() != 'null') {
      return false;
    }
  }
  return true;
}

bool _isAllValuesMissing(Iterable<dynamic> values) {
  for (final v in values) {
    if (v == null) continue;
    final s = v.toString().trim();
    if (s.isNotEmpty &&
        s.toLowerCase() != 'null' &&
        s.toLowerCase() != 'undefined') {
      return false;
    }
  }
  return true;
}

String? _validateParsedRecord(Map<String, dynamic> map) {
  const strictIdentifierColumns = [
    'numeroAnimal',
    'chip',
    'codRegistro',
    'numeroMatriz',
    'numeroReprodutor',
  ];

  for (final column in strictIdentifierColumns) {
    final value = _cleanStringOrNull(map[column]);
    if (value == null) continue;
    if (!_isPlausibleImportIdentifier(value)) {
      return 'campo $column contém caracteres incompatíveis com identificador de animal.';
    }
  }

  for (final entry in map.entries) {
    final value = entry.value;
    if (value is String && _looksLikeCorruptedImportText(value)) {
      return 'campo ${entry.key} parece estar com bytes de arquivo/encoding corrompidos.';
    }
  }

  const identityColumns = ['numeroAnimal', 'chip', 'codRegistro', 'nome'];
  final hasIdentity = identityColumns.any((column) {
    final value = _cleanStringOrNull(map[column]);
    return value != null && !_looksLikeCorruptedImportText(value);
  });

  if (!hasIdentity) {
    return 'registro sem identificação válida do animal.';
  }

  return null;
}

String? _cleanStringOrNull(dynamic value) => cleanStringOrNullImport(value);

bool _isPlausibleImportIdentifier(String value) =>
    isPlausibleImportIdentifier(value);

bool _looksLikeCorruptedImportText(String value) =>
    looksLikeCorruptedImportText(value);

// Função auxiliar para decodificação customizada (fallback)
String _decodeWithBestEncoding(List<int> bytes) {
  // 1) Tentar UTF-8 estrito (principal caminho).
  // Importante: NÃO usar allowMalformed aqui, senão perde caracteres (vira "�")
  // e depois não dá pra recuperar.
  String? utf8Text;
  try {
    utf8Text = utf8.decode(bytes);
  } catch (_) {}

  if (utf8Text != null) {
    if (!_looksMojibake(utf8Text)) {
      return utf8Text;
    }

    // Se UTF-8 parece mojibake, tenta Latin-1 e escolhe o melhor.
    try {
      final latin1Text = latin1.decode(bytes);
      if (_mojibakeScore(latin1Text) < _mojibakeScore(utf8Text)) {
        return latin1Text;
      }
    } catch (_) {}

    return utf8Text;
  }

  // 2) Tentar Latin-1 (muito comum em CSVs antigos / Excel).
  try {
    return latin1.decode(bytes);
  } catch (_) {}

  // 3) Fallback customizado (mantido para casos específicos)
  print('Usando decodificação customizada como fallback');

  // Criar string resultado para casos de encoding customizado
  String result = '';

  // Processar byte por byte com mapeamento específico para arquivos antigos
  for (int i = 0; i < bytes.length; i++) {
    final byte = bytes[i];

    // Mapeamento apenas dos bytes problemáticos identificados em arquivos não-UTF8
    switch (byte) {
      case 0x90:
        result += 'ê'; // Fêmea
        break;
      case 0x8D:
        result += 'ç'; // Mestiço
        break;
      case 0xCC:
        result += 'Ã'; // SÃO
        break;
      default:
        result += String.fromCharCode(byte);
        break;
    }
  }

  return result;
}

String? _decodeUtf16Bom(List<int> bytes) {
  if (!_hasUtf16Bom(bytes)) return null;

  final littleEndian = bytes[0] == 0xFF && bytes[1] == 0xFE;
  final buffer = StringBuffer();

  for (var i = 2; i + 1 < bytes.length; i += 2) {
    final codeUnit = littleEndian
        ? bytes[i] | (bytes[i + 1] << 8)
        : (bytes[i] << 8) | bytes[i + 1];
    buffer.writeCharCode(codeUnit);
  }

  return buffer.toString();
}

bool _looksMojibake(String value) => looksMojibakeImport(value);

int _mojibakeScore(String value) => mojibakeScoreImport(value);

// Função auxiliar para detectar delimitador
String _detectDelimiter(String firstLine) {
  final delimiters = [';', ',', '\t', '|'];
  String bestDelimiter = ',';
  int maxFields = 0;

  for (final delimiter in delimiters) {
    final fields = firstLine.split(delimiter).length;
    if (fields > maxFields) {
      maxFields = fields;
      bestDelimiter = delimiter;
    }
  }

  return bestDelimiter;
}

// Função auxiliar para limpar texto preservando acentos
String _cleanText(String text) => cleanTextImport(text);

String? _cleanCellToNull(
        String value, String column, List<String> numericColumns) =>
    cleanCellToNullImport(value, column, numericColumns);

double? _parseNumberPtBr(String value) => parseNumberPtBrImport(value);

String _normalizeHeader(String header) => normalizeHeaderImport(header);

Map<String, int> _buildHeaderToDbMapping(
  List<String> headerStrings,
  Set<String> dbColumnSet,
) {
  // Mapeamento do modelo do usuário (Excel) -> coluna do banco
  const templateMap = <String, String>{
    'numero': 'numeroAnimal',
    'numero_animal': 'numeroAnimal',
    'chip': 'chip',
    'codigo_registro': 'codRegistro',
    'codigo_registro_': 'codRegistro',
    'codigo': 'codRegistro',
    'nome': 'nome',
    'sexo': 'sexo',
    'data_nascimento': 'dataNascimento',
    'peso_nascimento': 'pesoNascimento',
    'porte': 'porte',
    'categoria': 'categoria',
    'raca': 'raca',
    'lote': 'loteNome',
    'data_desmama': 'dataDesmama',
    'data_de_desmama': 'dataDesmama',
    'peso_desmama': 'pesoDesmama',
    'peso_de_desmama': 'pesoDesmama',
    'data_ultima_pesagem': 'dataUltimaPesagem',
    'peso_atual': 'pesoAtual',
    'status': 'status',
    'data_venda': 'dataVenda',
    'valor_venda': 'valorVenda',
    'data_morte': 'data_morte',
    'motivo_morte': 'motivo_morte',
    'movimentacao_saida': 'movimentacao_saida',
    'origem': 'origem',
    'data_compra': 'dataAcao',
    'valor_compra': 'valorCompra',
    'movimentacao_entrada': 'movimentacao_entrada',
    'anotacoes': 'anotacoes',
    'numero_matriz': 'numeroMatriz',
    'nome_matriz': 'nomeMatriz',
    'data_nascimento_matriz': 'dataNascMatriz',
    'categoria_matriz': 'categoria_matriz',
    'raca_matriz': 'racaMatriz',
    'numero_reprodutor': 'numeroReprodutor',
    'nome_reprodutor': 'nomeReprodutor',
    'data_nascimento_reprodutor': 'dataNascReprodutor',
    'raca_reprodutor': 'racaReprodutor',
  };

  final out = <String, int>{};

  for (var i = 0; i < headerStrings.length; i++) {
    final rawHeader = headerStrings[i];
    if (rawHeader.trim().isEmpty) continue;

    // Se já vier com nomes do banco, usa direto.
    if (dbColumnSet.contains(rawHeader)) {
      out.putIfAbsent(rawHeader, () => i);
      continue;
    }

    final normalized = _normalizeHeader(rawHeader);
    final mappedDb = templateMap[normalized];
    if (mappedDb != null) {
      out.putIfAbsent(mappedDb, () => i);
      continue;
    }
  }

  return out;
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
