// O diff precisa acusar mudanca real e calar sobre diferenca que nao existe.
// Se encher o relatorio de ruido, o usuario para de ler -- e ai a auditoria
// deixa de servir.
import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/importacao/import_diff.dart';
import 'package:in_lida_web/importacao/import_lookups.dart';

List<String> _colunasDe(List campos) =>
    campos.map((c) => (c as dynamic).coluna as String).toList();

void main() {
  group('nao acusa diferenca que nao existe', () {
    test('mesma data em formatos diferentes', () {
      final d = compararRegistro(
        gravado: {'dataNascimento': '2024-08-10'},
        daPlanilha: {'dataNascimento': '10/08/2024'},
        colunas: const ['dataNascimento'],
      );
      expect(d, isEmpty);
    });

    test('mesmo numero como texto e como double', () {
      final d = compararRegistro(
        gravado: {'pesoAtual': 480.0},
        daPlanilha: {'pesoAtual': '480'},
        colunas: const ['pesoAtual'],
      );
      expect(d, isEmpty);
    });

    test('mojibake corrigido nao conta como mudanca', () {
      final d = compararRegistro(
        gravado: {'raca': 'Mestiço'},
        daPlanilha: {'raca': 'MestiÃ§o'},
        colunas: const ['raca'],
      );
      expect(d, isEmpty);
    });

    test('espacos em volta nao contam', () {
      final d = compararRegistro(
        gravado: {'nome': 'Estrela'},
        daPlanilha: {'nome': '  Estrela  '},
        colunas: const ['nome'],
      );
      expect(d, isEmpty);
    });

    test('vazio dos dois lados nao e mudanca', () {
      final d = compararRegistro(
        gravado: {'chip': null},
        daPlanilha: {'chip': ''},
        colunas: const ['chip'],
      );
      expect(d, isEmpty);
    });
  });

  group('acusa mudanca real', () {
    test('peso trocado mostra de e para', () {
      final d = compararRegistro(
        gravado: {'pesoAtual': 480.0},
        daPlanilha: {'pesoAtual': '48'},
        colunas: const ['pesoAtual'],
      );
      expect(d, hasLength(1));
      expect(d.single.coluna, 'pesoAtual');
      expect(d.single.de, '480');
      expect(d.single.para, '48');
      expect(d.single.apaga, isFalse);
    });

    test('data trocada e exibida em DD/MM/AAAA', () {
      final d = compararRegistro(
        gravado: {'dataDesmama': '2024-08-10'},
        daPlanilha: {'dataDesmama': '15/09/2024'},
        colunas: const ['dataDesmama'],
      );
      expect(d.single.de, '10/08/2024');
      expect(d.single.para, '15/09/2024');
    });

    test('caixa diferente e mudanca real, nao ruido', () {
      final d = compararRegistro(
        gravado: {'nome': 'Estrela'},
        daPlanilha: {'nome': 'ESTRELA'},
        colunas: const ['nome'],
      );
      expect(d, hasLength(1));
    });
  });

  group('apagamento — o caso mais perigoso', () {
    test('coluna presente e vazia APAGA o valor gravado', () {
      final d = compararRegistro(
        gravado: {'dataDesmama': '2024-08-10', 'pesoDesmama': 210.0},
        daPlanilha: {'dataDesmama': '', 'pesoDesmama': null},
        colunas: const ['dataDesmama', 'pesoDesmama'],
      );
      expect(d, hasLength(2));
      expect(d.every((c) => c.apaga), isTrue);
      expect(d.first.de, '10/08/2024');
      expect(d.first.para, isNull);
    });

    test('coluna AUSENTE na planilha nao entra no diff', () {
      // Sem a chave, o campo nem e enviado ao banco: o valor e preservado.
      // Acusar isso como apagamento seria alarme falso.
      final d = compararRegistro(
        gravado: {'dataDesmama': '2024-08-10', 'pesoAtual': 480.0},
        daPlanilha: {'pesoAtual': 480.0},
        colunas: const ['dataDesmama', 'pesoAtual'],
      );
      expect(d, isEmpty);
    });
  });

  test('so compara as colunas pedidas', () {
    final d = compararRegistro(
      gravado: {'nome': 'A', 'anotacoes': 'x'},
      daPlanilha: {'nome': 'B', 'anotacoes': 'y'},
      colunas: const ['nome'],
    );
    expect(_colunasDe(d), ['nome']);
  });

  test('o catalogo de colunas cobre os campos criticos da planilha', () {
    // Se uma coluna sair desta lista, a sobrescrita dela passa despercebida.
    expect(
      colunasComparaveisRebanho,
      containsAll(<String>[
        'numeroAnimal', 'nome', 'sexo', 'dataNascimento', 'raca', 'categoria',
        'status', 'pesoNascimento', 'pesoDesmama', 'pesoAtual', 'dataDesmama',
        'loteNome', 'dataVenda', 'data_morte', 'numeroMatriz',
        'numeroReprodutor',
      ]),
    );
  });
}
