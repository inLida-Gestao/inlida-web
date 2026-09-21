// Golden dos helpers compartilhados de importacao.
//
// Estes valores foram medidos contra as implementacoes ORIGINAIS (privadas, em
// lib/custom_code/actions/) antes da extracao para lib/importacao/. O objetivo
// e duplo:
//   1. travar a paridade: a extracao foi verbatim, e este teste garante que
//      continua equivalente;
//   2. documentar por escrito os defeitos conhecidos do pipeline atual, que o
//      diagnostico de importacao vai passar a detectar e reportar ao usuario.
// Os casos marcados com DEFEITO CONHECIDO preservam de proposito um
// comportamento errado. Mudar qualquer um deles e uma decisao de produto, nao
// uma correcao de teste.

import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/importacao/import_texto_utils.dart';

void main() {
  group('convertDateFormatImport', () {
    test('converte DD/MM/AAAA e aceita ISO', () {
      expect(convertDateFormatImport('31/12/2024'), '2024-12-31');
      expect(convertDateFormatImport('31-12-2024'), '2024-12-31');
      expect(convertDateFormatImport('2024-12-31'), '2024-12-31');
      expect(convertDateFormatImport('2024-12-31 10:00'), '2024-12-31');
    });

    test('recusa vazio e formatos fora do padrao', () {
      expect(convertDateFormatImport(''), isNull);
      // Exige dois digitos: a planilha com 1/5/2024 perde a data em silencio.
      expect(convertDateFormatImport('1/5/2024'), isNull);
      // Serial do Excel exportado em CSV nao e reconhecido.
      expect(convertDateFormatImport('44562'), isNull);
    });

    test('DEFEITO CONHECIDO: aceita datas impossiveis e devolve ISO invalido',
        () {
      // A funcao monta '$ano-$mes-$dia' e valida com DateTime.tryParse, que
      // NAO rejeita mes 13 nem 31 de fevereiro. O resultado e uma string que o
      // Postgres depois recusa, e o usuario recebe um erro tecnico de banco em
      // vez de "data invalida na linha N".
      expect(convertDateFormatImport('05/13/2024'), '2024-13-05');
      expect(convertDateFormatImport('12/31/2024'), '2024-31-12');
      expect(convertDateFormatImport('31/02/2024'), '2024-02-31');
    });
  });

  group('parseNumberPtBrImport', () {
    test('le decimal com virgula e separador de milhar', () {
      expect(parseNumberPtBrImport('1.234,56'), 1234.56);
      expect(parseNumberPtBrImport('1234,56'), 1234.56);
      expect(parseNumberPtBrImport('1,5'), 1.5);
      expect(parseNumberPtBrImport('1234.56'), 1234.56);
    });

    test('recusa vazio e texto com unidade', () {
      expect(parseNumberPtBrImport(''), isNull);
      expect(parseNumberPtBrImport('480 kg'), isNull);
    });

    test('DEFEITO CONHECIDO: ponto de milhar sem virgula vira decimal', () {
      // "1.234" e mil duzentos e trinta e quatro quilos para o produtor, mas a
      // funcao so trata ponto como milhar quando existe virgula na string.
      expect(parseNumberPtBrImport('1.234'), 1.234);
    });
  });

  group('fixEncodingImport', () {
    test('corrige UTF-8 lido como Latin-1', () {
      expect(fixEncodingImport('FÃªmea'), 'Fêmea');
      expect(fixEncodingImport('MestiÃ§o'), 'Mestiço');
    });

    test('nao altera texto ja correto', () {
      expect(fixEncodingImport('Fêmea'), 'Fêmea');
      expect(fixEncodingImport('Nelore'), 'Nelore');
    });

    test('texto irrecuperavel e mantido, mas detectado como corrompido', () {
      const ruim = 'Ã‡Ã©Â¿';
      expect(fixEncodingImport(ruim), ruim);
      expect(looksLikeCorruptedImportText(ruim), isTrue);
    });

    test('mojibake recuperavel nao e classificado como corrompido', () {
      expect(looksLikeCorruptedImportText('FÃªmea'), isFalse);
    });
  });

  group('normalizeHeaderImport', () {
    test('remove acento, baixa caixa e colapsa separadores', () {
      expect(normalizeHeaderImport('Número'), 'numero');
      expect(normalizeHeaderImport('Data de Nascimento'), 'data_de_nascimento');
      expect(normalizeHeaderImport('Peso  Atual'), 'peso_atual');
      expect(normalizeHeaderImport('numero_animal'), 'numero_animal');
      expect(normalizeHeaderImport('A12'), 'a12');
      expect(normalizeHeaderImport(''), '');
    });
  });

  group('normalizeLoteNomeImport', () {
    test('normaliza caixa, acento e espacos repetidos', () {
      expect(normalizeLoteNomeImport('Pasto 1'), 'pasto 1');
      expect(normalizeLoteNomeImport('PASTO  1'), 'pasto 1');
      expect(normalizeLoteNomeImport('Pásto 1'), 'pasto 1');
    });
  });

  group('isValidPesoImport', () {
    test('aceita numero positivo, inclusive com virgula', () {
      expect(isValidPesoImport(480), isTrue);
      expect(isValidPesoImport('480'), isTrue);
      expect(isValidPesoImport('480,5'), isTrue);
    });

    test('recusa zero, negativo, texto e vazio', () {
      expect(isValidPesoImport('0'), isFalse);
      expect(isValidPesoImport(-5), isFalse);
      expect(isValidPesoImport('abc'), isFalse);
      expect(isValidPesoImport(null), isFalse);
      expect(isValidPesoImport(''), isFalse);
    });
  });

  group('isPlausibleImportIdentifier', () {
    test('aceita identificadores usuais de brinco', () {
      expect(isPlausibleImportIdentifier('1204'), isTrue);
      expect(isPlausibleImportIdentifier('ABC-12'), isTrue);
    });

    test('recusa vazio, simbolo estranho e texto longo demais', () {
      expect(isPlausibleImportIdentifier(''), isFalse);
      expect(isPlausibleImportIdentifier('◆12*'), isFalse);
      expect(isPlausibleImportIdentifier('A' * 81), isFalse);
    });
  });

  group('normalizeDateKeyImport', () {
    test('normaliza para ISO e corta horario', () {
      expect(normalizeDateKeyImport('31/12/2024'), '2024-12-31');
      expect(normalizeDateKeyImport('2024-12-31T10:00:00'), '2024-12-31');
      expect(normalizeDateKeyImport(null), isNull);
      expect(normalizeDateKeyImport('null'), isNull);
      expect(normalizeDateKeyImport('  '), isNull);
    });
  });

  group('isMissingValueImport', () {
    test('trata os sentinelas de vazio do pipeline', () {
      expect(isMissingValueImport(null), isTrue);
      expect(isMissingValueImport(''), isTrue);
      expect(isMissingValueImport('   '), isTrue);
      expect(isMissingValueImport('null'), isTrue);
      expect(isMissingValueImport('undefined'), isTrue);
      expect(isMissingValueImport('0'), isFalse);
      expect(isMissingValueImport('1204'), isFalse);
    });
  });

  group('cleanCellToNullImport', () {
    test('DEFEITO CONHECIDO: "0" em coluna de texto vira null', () {
      // O animal cujo numero e literalmente "0" perde o numero na importacao.
      expect(cleanCellToNullImport('0', 'numeroAnimal', const ['pesoAtual']),
          isNull);
      // Em coluna numerica o zero e preservado.
      expect(cleanCellToNullImport('0', 'pesoAtual', const ['pesoAtual']), '0');
    });

    test('trata vazio e sentinelas', () {
      expect(cleanCellToNullImport('', 'nome', const []), isNull);
      expect(cleanCellToNullImport('null', 'nome', const []), isNull);
      expect(cleanCellToNullImport('undefined', 'nome', const []), isNull);
      expect(cleanCellToNullImport('Estrela', 'nome', const []), 'Estrela');
    });
  });
}
