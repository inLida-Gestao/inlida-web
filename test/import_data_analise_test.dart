import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/importacao/import_data_analise.dart';

void main() {
  test('data valida e reconhecida e convertida', () {
    final a = analisarDataImport('31/12/2024');
    expect(a.status, StatusData.valida);
    expect(a.iso, '2024-12-31');
    expect(a.data, DateTime(2024, 12, 31));
    expect(a.problema, isFalse);
  });

  test('celula vazia nao e problema', () {
    for (final v in [null, '', '   ', 'null', 'undefined']) {
      expect(analisarDataImport(v).status, StatusData.ausente, reason: '$v');
    }
  });

  test('formato nao reconhecido e sinalizado em vez de sumir', () {
    // Hoje o pipeline devolve null e o campo desaparece sem aviso nenhum.
    expect(analisarDataImport('1/5/2024').status,
        StatusData.formatoNaoReconhecido);
    expect(analisarDataImport('44562').status,
        StatusData.formatoNaoReconhecido);
    expect(analisarDataImport('24-mai-2024').status,
        StatusData.formatoNaoReconhecido);
  });

  test('pega as datas impossiveis que o DateTime.tryParse deixa passar', () {
    final fev31 = analisarDataImport('31/02/2024');
    expect(fev31.status, StatusData.impossivel);
    expect(fev31.iso, '2024-02-31', reason: 'e o que o pipeline gera hoje');
    expect(fev31.pareceMesDiaInvertido, isFalse);

    final mes13 = analisarDataImport('05/13/2024');
    expect(mes13.status, StatusData.impossivel);
    expect(mes13.pareceMesDiaInvertido, isTrue,
        reason: 'dia 13 nao existe como mes, entao o arquivo e MM/DD/AAAA');

    final dez31Americano = analisarDataImport('12/31/2024');
    expect(dez31Americano.status, StatusData.impossivel);
    expect(dez31Americano.pareceMesDiaInvertido, isTrue);
  });

  test('ano bissexto e respeitado', () {
    expect(analisarDataImport('29/02/2024').status, StatusData.valida);
    expect(analisarDataImport('29/02/2023').status, StatusData.impossivel);
  });

  test('aceita ISO com horario', () {
    final a = analisarDataImport('2024-12-31 10:30');
    expect(a.status, StatusData.valida);
    expect(a.iso, '2024-12-31');
  });

  test('corrige mojibake antes de analisar', () {
    expect(analisarDataImport(' 31/12/2024 ').status, StatusData.valida);
  });

  test('formatarDataBr formata com dois digitos', () {
    expect(formatarDataBr(DateTime(2024, 1, 5)), '05/01/2024');
  });
}
