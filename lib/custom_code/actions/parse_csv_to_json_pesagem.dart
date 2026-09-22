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

/// Le a planilha de Pesagem reportando tudo o que observou.
///
/// Alem do diagnostico, corrige duas cegueiras do caminho antigo:
///  - `.xls` binario era aceito por _isXlsxFile, estourava no decode e o catch
///    devolvia lista vazia, de modo que o usuario via apenas "Nenhum registro
///    valido" sem saber por que;
///  - conteudo binario (PDF, imagem) era lido como CSV e virava lixo.
Future<ImportParseResult> parseCsvToJsonPesagemDetalhado(
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

  if (_isLegacyXlsBinaryPesagem(bytes, fileName)) {
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

  if (!isXlsx && _looksLikeBinaryContentPesagem(bytes)) {
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
    final leitura = isXlsx ? _lerXlsxPesagem(bytes) : _lerCsvPesagem(bytes);
    final rows = leitura.rows;

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

    const dbColumnsInOrder = [
      'numeroAnimal',
      'chip',
      'nome',
      'sexo',
      'dataNascimento',
      'raca',
      'dataPesagem',
      'peso',
      'tipo',
    ];

    const dateColumns = ['dataNascimento', 'dataPesagem'];
    const numericColumns = ['peso'];

    final headerRow = rows.first;
    final headerStrings = headerRow
        .map((e) => e == null ? '' : e.toString())
        .map(_cleanText)
        .toList();
    final normalizedHeaders = headerStrings.map(_normalizeHeader).toList();

    final bool looksLikeHeader = normalizedHeaders.any((h) =>
        h == 'numero' ||
        h == 'numero_animal' ||
        h == 'nome' ||
        h == 'chip' ||
        h == 'data_nascimento' ||
        h == 'raca' ||
        h == 'sexo' ||
        h == 'data_pesagem' ||
        h == 'tipo' ||
        h == 'peso');

    final bool looksLikeDbExport = headerStrings.any((h) => const {
          'numeroAnimal',
          'chip',
          'dataPesagem',
          'dataNascimento',
          'peso'
        }.contains(h));

    final bool useHeaderMapping = (looksLikeHeader || looksLikeDbExport) &&
        normalizedHeaders.any((h) => h.isNotEmpty);

    final mapping = useHeaderMapping
        ? _buildPesagemHeaderMapping(headerStrings)
        : <String, int>{
            for (var i = 0; i < dbColumnsInOrder.length; i++)
              dbColumnsInOrder[i]: i
          };

    final exame = examinarCabecalho(
      entidade: ImportEntidade.pesagem,
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

    final out = <dynamic>[];
    var totalLinhas = 0;
    var linhasEmBranco = 0;
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
        if (cleaned == null) {
          map[dbColumn] = null;
          return;
        }

        if (dateColumns.contains(dbColumn)) {
          map[dbColumn] = cleaned;
        } else if (numericColumns.contains(dbColumn)) {
          // O texto bruto do peso so existe aqui; depois da conversao um
          // "480 kg" seria indistinguivel de celula vazia.
          final numero = _parseNumberPtBr(cleaned);
          if (numero == null) {
            ocorrencias.add(ImportOcorrencia(
              codigo: ImportCodigo.pesPesoZeroOuNegativo,
              severidade: ImportSeveridade.bloqueante,
              escopo: ImportEscopo.dado,
              linha: numeroLinha,
              coluna: dbColumn,
              valor: cleaned,
              mensagem: 'Linha $numeroLinha: Peso "$cleaned" não é um número.',
              sugestao: 'Escreva apenas o número, sem unidade (ex.: 480).',
            ));
            linhasInvalidas.add(numeroLinha);
          } else if (_pontoDeMilharAmbiguoPesagem(cleaned)) {
            ocorrencias.add(ImportOcorrencia(
              codigo: ImportCodigo.pesPesoPtbrAmbiguo,
              severidade: ImportSeveridade.aviso,
              escopo: ImportEscopo.dado,
              linha: numeroLinha,
              coluna: dbColumn,
              valor: cleaned,
              mensagem: 'Linha $numeroLinha: Peso "$cleaned" foi lido como '
                  '$numero kg, e não como ${cleaned.replaceAll('.', '')} kg.',
              sugestao: 'Escreva sem separador de milhar '
                  '(${cleaned.replaceAll('.', '')}).',
            ));
          }
          map[dbColumn] = numero;
        } else {
          map[dbColumn] = cleaned;
        }
      });

      if (_isAllValuesMissing(map.values)) {
        linhasEmBranco++;
        totalLinhas--;
        continue;
      }

      // _hasMinimumPesagemData exige identificacao E (peso OU data). O "ou"
      // deixava passar linha sem peso, que era inserida com peso null e
      // escapava tambem do unique parcial de historico_pesagens. Agora a linha
      // permanece no relatorio e o diagnostico de pesagem a bloqueia.
      if (!_hasMinimumPesagemData(map)) {
        ocorrencias.add(ImportOcorrencia(
          codigo: ImportCodigo.pesSemIdentificacao,
          severidade: ImportSeveridade.bloqueante,
          escopo: ImportEscopo.dado,
          linha: numeroLinha,
          mensagem: 'Linha $numeroLinha: a linha não tem dados suficientes '
              'para uma pesagem (falta identificação do animal, ou peso e data).',
          sugestao: 'Informe o número do animal, o peso e a data.',
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
      entidade: ImportEntidade.pesagem,
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
    print('Erro no processamento da planilha de pesagem: $e');
    print(stack);
    return abortar(
      ImportCodigo.arqBinarioNaoTexto,
      'Não foi possível ler a planilha: $e',
      sugestao: 'Confira se o arquivo é um CSV ou .xlsx válido.',
    );
  }
}

/// Ver _pontoDeMilharAmbiguo em parse_csv_to_json_rebanho2.dart.
bool _pontoDeMilharAmbiguoPesagem(String texto) {
  if (texto.contains(',')) return false;
  return RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(texto.trim());
}

/// Assinatura OLE do .xls binario antigo. Portado de
/// parse_csv_to_json_rebanho2.dart, onde ja existia: aqui a checagem faltava e
/// o arquivo estourava no decode, devolvendo lista vazia sem explicacao.
bool _isLegacyXlsBinaryPesagem(List<int> bytes, String fileName) {
  const assinatura = [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1];
  if (bytes.length >= assinatura.length) {
    var confere = true;
    for (var i = 0; i < assinatura.length; i++) {
      if (bytes[i] != assinatura[i]) {
        confere = false;
        break;
      }
    }
    if (confere) return true;
  }
  // .xls sem assinatura ZIP tambem nao e um xlsx valido.
  return fileName.endsWith('.xls') && !_hasZipSignaturePesagem(bytes);
}

bool _hasZipSignaturePesagem(List<int> bytes) =>
    bytes.length >= 4 &&
    bytes[0] == 0x50 &&
    bytes[1] == 0x4B &&
    bytes[2] == 0x03 &&
    bytes[3] == 0x04;

/// Heuristica de conteudo binario, portada de
/// parse_csv_to_json_rebanho2.dart: NUL em qualquer posicao, ou mais de 4% de
/// bytes de controle na amostra.
bool _looksLikeBinaryContentPesagem(List<int> bytes) {
  if (bytes.isEmpty) return false;
  final limite = bytes.length < 4096 ? bytes.length : 4096;
  var controle = 0;
  for (var i = 0; i < limite; i++) {
    final b = bytes[i];
    if (b == 0) return true;
    final ehControleAceitavel = b == 0x09 || b == 0x0A || b == 0x0D;
    if (b < 0x20 && !ehControleAceitavel) controle++;
  }
  return controle / limite > 0.04;
}

/// Ver _LeituraPlanilha em parse_csv_to_json_rebanho2.dart.
class _LeituraPesagem {
  final List<List<dynamic>> rows;
  final String? delimitador;
  final String? encoding;
  final String? abaUsada;
  final int? totalAbas;

  const _LeituraPesagem({
    required this.rows,
    this.delimitador,
    this.encoding,
    this.abaUsada,
    this.totalAbas,
  });
}

_LeituraPesagem _lerXlsxPesagem(List<int> bytes) {
  final excel = xl.Excel.decodeBytes(bytes);
  if (excel.tables.isEmpty) {
    return const _LeituraPesagem(rows: [], totalAbas: 0);
  }
  return _LeituraPesagem(
    rows: _parseXlsx(bytes),
    abaUsada: excel.tables.keys.first,
    totalAbas: excel.tables.length,
  );
}

_LeituraPesagem _lerCsvPesagem(List<int> bytes) {
  var encoding = 'utf-8';
  List<int> cleanBytes = bytes;
  if (cleanBytes.length >= 3 &&
      cleanBytes[0] == 0xEF &&
      cleanBytes[1] == 0xBB &&
      cleanBytes[2] == 0xBF) {
    cleanBytes = cleanBytes.sublist(3);
    encoding = 'utf-8-bom';
  }

  var csvString = _decodeWithBestEncoding(cleanBytes);
  csvString = csvString.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final delimiter = _detectDelimiter(csvString.split('\n').first);

  final converter = CsvToListConverter(
    fieldDelimiter: delimiter,
    eol: '\n',
    shouldParseNumbers: false,
    allowInvalid: true,
  );
  return _LeituraPesagem(
    rows: converter.convert(csvString),
    delimitador: delimiter,
    encoding: encoding,
  );
}

/// Mantida para os call-sites que ainda nao usam o diagnostico.
Future<List<dynamic>> parseCsvToJsonPesagem(FFUploadedFile? csvFile) async {
  final resultado = await parseCsvToJsonPesagemDetalhado(csvFile);
  return resultado.registrosCompativeis
      .map((r) => r is Map
          ? (Map<String, dynamic>.from(r)..remove(kCampoLinhaArquivo))
          : r)
      .toList();
}

bool _isXlsxFile(List<int> bytes, String fileName) {
  if (fileName.endsWith('.xlsx') || fileName.endsWith('.xls')) return true;
  // ZIP magic number (XLSX is a ZIP file)
  if (bytes.length >= 4 &&
      bytes[0] == 0x50 &&
      bytes[1] == 0x4B &&
      bytes[2] == 0x03 &&
      bytes[3] == 0x04) {
    return true;
  }
  return false;
}

List<List<dynamic>> _parseXlsx(List<int> bytes) {
  final excel = xl.Excel.decodeBytes(bytes);
  final sheetName = excel.tables.keys.first;
  final sheet = excel.tables[sheetName];
  if (sheet == null || sheet.rows.isEmpty) return [];

  final rows = <List<dynamic>>[];
  for (final row in sheet.rows) {
    final cells = <dynamic>[];
    for (final cell in row) {
      if (cell == null || cell.value == null) {
        cells.add('');
      } else {
        final val = cell.value;
        if (val is xl.DateCellValue) {
          final dt = val.asDateTimeLocal();
          cells.add(
              '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}');
        } else if (val is xl.DoubleCellValue) {
          cells.add(val.value.toString());
        } else if (val is xl.IntCellValue) {
          cells.add(val.value.toString());
        } else {
          cells.add(val.toString());
        }
      }
    }
    rows.add(cells);
  }
  return rows;
}

Map<String, int> _buildPesagemHeaderMapping(List<String> headerStrings) {
  const templateMap = <String, String>{
    'numero': 'numeroAnimal',
    'numero_animal': 'numeroAnimal',
    'num': 'numeroAnimal',
    'chip': 'chip',
    'brinco': 'chip',
    'nome': 'nome',
    'nome_animal': 'nome',
    'data_nascimento': 'dataNascimento',
    'data_nasc': 'dataNascimento',
    'nascimento': 'dataNascimento',
    'raca': 'raca',
    'sexo': 'sexo',
    'data_pesagem': 'dataPesagem',
    'data_da_pesagem': 'dataPesagem',
    'dt_pesagem': 'dataPesagem',
    'tipo': 'tipo',
    'tipo_pesagem': 'tipo',
    'peso': 'peso',
    'peso_kg': 'peso',
  };

  const dbColumnSet = {
    'numeroAnimal',
    'chip',
    'nome',
    'dataNascimento',
    'raca',
    'sexo',
    'dataPesagem',
    'tipo',
    'peso',
  };

  final out = <String, int>{};

  for (var i = 0; i < headerStrings.length; i++) {
    final rawHeader = headerStrings[i];
    if (rawHeader.trim().isEmpty) continue;

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

bool _hasMinimumPesagemData(Map<String, dynamic> map) {
  final hasIdentification = _hasValue(map['numeroAnimal']) ||
      _hasValue(map['chip']) ||
      _hasValue(map['nome']);
  final hasPesagem = _hasValue(map['peso']) || _hasValue(map['dataPesagem']);
  return hasIdentification && hasPesagem;
}

bool _hasValue(dynamic value) {
  if (value == null) return false;
  final s = value.toString().trim().toLowerCase();
  return s.isNotEmpty && s != 'null' && s != 'undefined';
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

String _decodeWithBestEncoding(List<int> bytes) {
  String? utf8Text;
  try {
    utf8Text = utf8.decode(bytes);
  } catch (_) {}

  if (utf8Text != null) {
    if (!_looksMojibake(utf8Text)) {
      return utf8Text;
    }
    try {
      final latin1Text = latin1.decode(bytes);
      if (_mojibakeScore(latin1Text) < _mojibakeScore(utf8Text)) {
        return latin1Text;
      }
    } catch (_) {}
    return utf8Text;
  }

  try {
    return latin1.decode(bytes);
  } catch (_) {}

  String result = '';
  for (int i = 0; i < bytes.length; i++) {
    final byte = bytes[i];
    switch (byte) {
      case 0x90:
        result += 'ê';
        break;
      case 0x8D:
        result += 'ç';
        break;
      case 0xCC:
        result += 'Ã';
        break;
      default:
        result += String.fromCharCode(byte);
        break;
    }
  }
  return result;
}

bool _looksMojibake(String value) => looksMojibakeImport(value);

int _mojibakeScore(String value) => mojibakeScoreImport(value);

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

String _cleanText(String text) => cleanTextImport(text);

String? _cleanCellToNull(
        String value, String column, List<String> numericColumns) =>
    cleanCellToNullImport(value, column, numericColumns);

double? _parseNumberPtBr(String value) => parseNumberPtBrImport(value);

String _normalizeHeader(String header) => normalizeHeaderImport(header);
