import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/importacao/diagnostico_rebanho.dart';
import 'package:in_lida_web/importacao/import_diagnostico_model.dart';

/// Roda o diagnostico local sobre uma unica linha e devolve o resultado.
ImportDiagnostico _diag(
  List<Map<String, dynamic>> linhas, {
  DateTime? hoje,
}) {
  final b = ImportDiagnosticoBuilder(entidade: ImportEntidade.rebanho);
  final registros = <Map<String, dynamic>>[];
  for (var i = 0; i < linhas.length; i++) {
    registros.add({kCampoLinhaArquivo: i + 2, ...linhas[i]});
  }
  diagnosticarRebanhoLocal(
    builder: b,
    registros: registros,
    hoje: hoje ?? DateTime(2026, 9, 21),
  );
  return b.build(
      arquivo: const ImportArquivoInfo(), totalLinhas: linhas.length);
}

Set<String> _codigos(ImportDiagnostico d) =>
    d.ocorrencias.map((o) => o.codigo).toSet();

ImportOcorrencia _primeira(ImportDiagnostico d, String codigo) =>
    d.ocorrencias.firstWhere((o) => o.codigo == codigo);

/// Linha valida, usada como base para isolar uma regra por vez.
Map<String, dynamic> _animalOk() => {
      'numeroAnimal': '1204',
      'nome': 'Estrela',
      'sexo': 'Fêmea',
      'categoria': 'Novilha',
      'raca': 'Nelore',
      'status': 'Na propriedade',
      'dataNascimento': '10/03/2024',
    };

void main() {
  test('linha correta nao gera nenhuma ocorrencia', () {
    final d = _diag([_animalOk()]);
    expect(d.ocorrencias, isEmpty, reason: d.ocorrencias.map((o) => o.mensagem).join(' | '));
    expect(d.temBloqueio, isFalse);
  });

  group('identidade', () {
    test('sem nenhum identificador bloqueia a linha', () {
      final d = _diag([
        {'sexo': 'Fêmea'}
      ]);
      expect(_codigos(d), contains(ImportCodigo.rebSemIdentidade));
      expect(d.acaoPorLinha[2], ImportAcaoLinha.bloquear);
    });

    test('so o nome ja identifica', () {
      final d = _diag([
        {'nome': 'Estrela', 'sexo': 'Fêmea'}
      ]);
      expect(_codigos(d), isNot(contains(ImportCodigo.rebSemIdentidade)));
    });
  });

  group('datas', () {
    test('formato nao reconhecido bloqueia em vez de perder o campo', () {
      final d = _diag([
        {..._animalOk(), 'dataNascimento': '1/5/2024'}
      ]);
      expect(_codigos(d),
          contains(ImportCodigo.rebDataFormatoNaoReconhecido));
      expect(d.temBloqueio, isTrue);
    });

    test('formato americano e identificado como tal', () {
      final d = _diag([
        {..._animalOk(), 'dataNascimento': '05/13/2024'}
      ]);
      expect(_codigos(d), contains(ImportCodigo.rebDataMesDiaInvertido));
      expect(_primeira(d, ImportCodigo.rebDataMesDiaInvertido).mensagem,
          contains('americano'));
    });

    test('data inexistente no calendario e bloqueada', () {
      final d = _diag([
        {..._animalOk(), 'dataNascimento': '31/02/2024'}
      ]);
      expect(_codigos(d), contains(ImportCodigo.rebDataImpossivel));
    });

    test('ano antigo e data futura viram aviso, nao bloqueio', () {
      final antigo = _diag([
        {..._animalOk(), 'dataNascimento': '10/03/1970'}
      ]);
      expect(_codigos(antigo), contains(ImportCodigo.rebAnoImplausivel));
      expect(antigo.temBloqueio, isFalse);

      final futuro = _diag([
        {..._animalOk(), 'dataNascimento': '10/03/2030'}
      ]);
      expect(_codigos(futuro), contains(ImportCodigo.rebAnoImplausivel));
      expect(futuro.temBloqueio, isFalse);
    });
  });

  group('cronologia', () {
    test('desmama antes do nascimento bloqueia', () {
      final d = _diag([
        {
          ..._animalOk(),
          'dataNascimento': '05/06/2023',
          'dataDesmama': '10/01/2023',
        }
      ]);
      expect(_codigos(d), contains(ImportCodigo.rebCronologiaInvertida));
      expect(_primeira(d, ImportCodigo.rebCronologiaInvertida).escopo,
          ImportEscopo.semantica);
    });

    test('venda e morte antes do nascimento bloqueiam', () {
      final d = _diag([
        {
          ..._animalOk(),
          'dataNascimento': '05/06/2023',
          'dataVenda': '10/01/2022',
          'status': 'Vendido',
        }
      ]);
      expect(_codigos(d), contains(ImportCodigo.rebCronologiaInvertida));
    });

    test('desmama fora da janela de 150-310 dias avisa', () {
      final d = _diag([
        {
          ..._animalOk(),
          'dataNascimento': '01/01/2024',
          'dataDesmama': '22/01/2024', // 21 dias
        }
      ]);
      expect(_codigos(d), contains(ImportCodigo.rebDesmamaForaDaJanela));
      expect(d.temBloqueio, isFalse);
    });

    test('desmama dentro da janela nao avisa', () {
      final d = _diag([
        {
          ..._animalOk(),
          'dataNascimento': '01/01/2024',
          'dataDesmama': '01/08/2024', // ~213 dias
        }
      ]);
      expect(_codigos(d), isNot(contains(ImportCodigo.rebDesmamaForaDaJanela)));
    });

    test('saida antes da entrada bloqueia', () {
      final d = _diag([
        {
          ..._animalOk(),
          'movimentacao_entrada': '15/03/2026',
          'movimentacao_saida': '01/02/2026',
        }
      ]);
      expect(_codigos(d), contains(ImportCodigo.rebCronologiaInvertida));
    });
  });

  group('dominios', () {
    test('sexo invalido bloqueia, mas F e M sao aceitos', () {
      expect(
        _codigos(_diag([
          {..._animalOk(), 'sexo': 'Femia'}
        ])),
        contains(ImportCodigo.rebSexoForaDoDominio),
      );
      expect(
        _codigos(_diag([
          {..._animalOk(), 'sexo': 'F'}
        ])),
        isNot(contains(ImportCodigo.rebSexoForaDoDominio)),
      );
    });

    test('sexo com mojibake e aceito', () {
      final d = _diag([
        {..._animalOk(), 'sexo': 'FÃªmea'}
      ]);
      expect(_codigos(d), isNot(contains(ImportCodigo.rebSexoForaDoDominio)));
    });

    test('categoria inexistente bloqueia e sugere as validas', () {
      final d = _diag([
        {..._animalOk(), 'categoria': 'Vaca'}
      ]);
      expect(_codigos(d), contains(ImportCodigo.rebCategoriaForaDoDominio));
      expect(_primeira(d, ImportCodigo.rebCategoriaForaDoDominio).sugestao,
          contains('Vaca Primipara'));
    });

    test('categoria incompativel com o sexo bloqueia', () {
      final d = _diag([
        {..._animalOk(), 'sexo': 'Fêmea', 'categoria': 'Touro'}
      ]);
      expect(_codigos(d),
          contains(ImportCodigo.rebCategoriaIncompativelComSexo));
    });

    test('status fora do dominio bloqueia porque quebra relatorio', () {
      final d = _diag([
        {..._animalOk(), 'status': 'Ativo'}
      ]);
      expect(_codigos(d), contains(ImportCodigo.rebStatusForaDoDominio));
      expect(_primeira(d, ImportCodigo.rebStatusForaDoDominio).sugestao,
          contains('Na propriedade'));
    });

    test('origem, porte e raca desconhecidos apenas avisam', () {
      final d = _diag([
        {
          ..._animalOk(),
          'origem': 'comprado',
          'porte': 'Pequeno',
          'raca': 'Nelore Puro',
        }
      ]);
      expect(
          _codigos(d),
          containsAll([
            ImportCodigo.rebOrigemForaDoDominio,
            ImportCodigo.rebPorteForaDoDominio,
            ImportCodigo.rebRacaDesconhecida,
          ]));
      expect(d.temBloqueio, isFalse);
    });
  });

  group('status x datas', () {
    test('data de morte com status divergente avisa', () {
      final d = _diag([
        {
          ..._animalOk(),
          'data_morte': '10/05/2025',
          'status': 'Na propriedade',
        }
      ]);
      expect(_codigos(d), contains(ImportCodigo.rebMorteSemStatus));
      expect(_primeira(d, ImportCodigo.rebMorteSemStatus).sugestao,
          contains('mortalidade'));
    });

    test('valor de venda com status divergente avisa', () {
      final d = _diag([
        {..._animalOk(), 'valorVenda': 4500.0, 'status': 'Na propriedade'}
      ]);
      expect(_codigos(d), contains(ImportCodigo.rebVendaSemStatus));
    });
  });

  group('pesos', () {
    test('peso de nascimento absurdo avisa', () {
      final d = _diag([
        {..._animalOk(), 'pesoNascimento': 480.0}
      ]);
      expect(_codigos(d), contains(ImportCodigo.rebPesoForaDeFaixa));
    });

    test('peso atual usa a faixa da categoria', () {
      // 4800 kg para uma Novilha: fora de 120-550.
      final d = _diag([
        {..._animalOk(), 'categoria': 'Novilha', 'pesoAtual': 4800.0}
      ]);
      final oc = _primeira(d, ImportCodigo.rebPesoForaDeFaixa);
      expect(oc.mensagem, contains('Novilha'));

      // 300 kg para Novilha esta dentro da faixa.
      final ok = _diag([
        {..._animalOk(), 'categoria': 'Novilha', 'pesoAtual': 300.0}
      ]);
      expect(_codigos(ok), isNot(contains(ImportCodigo.rebPesoForaDeFaixa)));
    });

    test('desmama menor que nascimento sugere colunas trocadas', () {
      final d = _diag([
        {..._animalOk(), 'pesoNascimento': 38.0, 'pesoDesmama': 32.0}
      ]);
      expect(_codigos(d),
          contains(ImportCodigo.rebPesoDesmamaMenorQueNascimento));
      expect(
          _primeira(d, ImportCodigo.rebPesoDesmamaMenorQueNascimento).sugestao,
          contains('trocadas'));
    });

    test('peso atual sem data avisa que sera datado hoje', () {
      final d = _diag([
        {..._animalOk(), 'pesoAtual': 300.0}
      ], hoje: DateTime(2026, 9, 21));
      final oc = _primeira(d, ImportCodigo.rebPesagemAtualComDataDeHoje);
      expect(oc.mensagem, contains('21/09/2026'));
    });
  });

  group('vinculos de pais', () {
    test('matriz "SN" avisa sobre vinculo generico', () {
      final d = _diag([
        {..._animalOk(), 'numeroMatriz': 'SN'}
      ]);
      expect(_codigos(d), contains(ImportCodigo.rebMatrizSnGenerica));
    });

    test('animal como pai de si mesmo bloqueia', () {
      final d = _diag([
        {..._animalOk(), 'numeroAnimal': '1204', 'numeroMatriz': '1204'}
      ]);
      expect(_codigos(d), contains(ImportCodigo.rebPaiIgualAoFilho));
      expect(d.temBloqueio, isTrue);
    });
  });

  group('duplicidade no arquivo', () {
    test('mesma identidade em duas linhas bloqueia a segunda', () {
      final d = _diag([_animalOk(), _animalOk()]);
      final oc = _primeira(d, ImportCodigo.rebDuplicidadeNoArquivo);
      expect(oc.linha, 3);
      expect(oc.mensagem, contains('linha 2'));
      expect(d.acaoPorLinha[3], ImportAcaoLinha.bloquear);
      expect(d.acaoPorLinha[2], isNull, reason: 'a primeira linha segue valida');
    });

    test('mesmo numero com identidade diferente nao e duplicata', () {
      final d = _diag([
        _animalOk(),
        {..._animalOk(), 'nome': 'Outra', 'dataNascimento': '11/03/2024'},
      ]);
      expect(_codigos(d), isNot(contains(ImportCodigo.rebDuplicidadeNoArquivo)));
    });
  });
}
