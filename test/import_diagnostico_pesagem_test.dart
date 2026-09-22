import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/importacao/diagnostico_pesagem.dart';
import 'package:in_lida_web/importacao/import_diagnostico_model.dart';

ImportDiagnostico _diag(List<Map<String, dynamic>> linhas, {DateTime? hoje}) {
  final b = ImportDiagnosticoBuilder(entidade: ImportEntidade.pesagem);
  final registros = <Map<String, dynamic>>[];
  for (var i = 0; i < linhas.length; i++) {
    registros.add({kCampoLinhaArquivo: i + 2, ...linhas[i]});
  }
  diagnosticarPesagemLocal(
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

Map<String, dynamic> _pesagemOk() => {
      'numeroAnimal': '1204',
      'dataPesagem': '20/08/2026',
      'peso': 480.0,
      'tipo': 'Atual',
    };

void main() {
  test('pesagem correta nao gera ocorrencia', () {
    final d = _diag([_pesagemOk()]);
    expect(d.ocorrencias, isEmpty,
        reason: d.ocorrencias.map((o) => o.mensagem).join(' | '));
  });

  test('tipo em branco equivale a Atual e nao reclama', () {
    final d = _diag([
      {..._pesagemOk(), 'tipo': null}
    ]);
    expect(_codigos(d), isNot(contains(ImportCodigo.pesTipoInvalido)));
  });

  group('identificacao e peso', () {
    test('sem identificacao bloqueia', () {
      final d = _diag([
        {'dataPesagem': '20/08/2026', 'peso': 480.0}
      ]);
      expect(_codigos(d), contains(ImportCodigo.pesSemIdentificacao));
    });

    test('linha sem peso bloqueia — hoje entraria com peso nulo', () {
      final d = _diag([
        {'numeroAnimal': '1204', 'dataPesagem': '20/08/2026'}
      ]);
      expect(_codigos(d), contains(ImportCodigo.pesSemPeso));
      expect(d.acaoPorLinha[2], ImportAcaoLinha.bloquear);
    });

    test('peso zero e negativo bloqueiam', () {
      for (final p in [0.0, -5.0]) {
        final d = _diag([
          {..._pesagemOk(), 'peso': p}
        ]);
        expect(_codigos(d), contains(ImportCodigo.pesPesoZeroOuNegativo),
            reason: 'peso $p');
      }
    });

    test('peso com unidade bloqueia em vez de virar nulo', () {
      final d = _diag([
        {..._pesagemOk(), 'peso': '480 kg'}
      ]);
      expect(_codigos(d), contains(ImportCodigo.pesPesoZeroOuNegativo));
      expect(_primeira(d, ImportCodigo.pesPesoZeroOuNegativo).sugestao,
          contains('sem unidade'));
    });

    test('peso fora da faixa do tipo avisa', () {
      final d = _diag([
        {..._pesagemOk(), 'tipo': 'Nascimento', 'peso': 480.0}
      ]);
      expect(_codigos(d), contains(ImportCodigo.pesVariacaoImplausivel));
      expect(d.temBloqueio, isFalse);
    });
  });

  group('tipo', () {
    test('tipo livre bloqueia e explica a consequencia', () {
      final d = _diag([
        {..._pesagemOk(), 'tipo': 'Pesagem mensal'}
      ]);
      final oc = _primeira(d, ImportCodigo.pesTipoInvalido);
      expect(oc.mensagem, contains('relatórios'));
      expect(oc.sugestao, contains('Atual'));
    });

    test('desmama avisa sobre reclassificacao de categoria', () {
      final d = _diag([
        {..._pesagemOk(), 'tipo': 'Desmama', 'peso': 200.0},
        {
          ..._pesagemOk(),
          'numeroAnimal': '1205',
          'tipo': 'Desmama',
          'peso': 210.0
        },
      ]);
      final oc = _primeira(d, ImportCodigo.pesDesmamaAlteraFicha);
      expect(oc.mensagem, contains('2 pesagem'));
      expect(oc.mensagem, contains('Novilha'));
      expect(d.contagemPorCodigo[ImportCodigo.pesDesmamaAlteraFicha], 1,
          reason: 'e um aviso agregado, uma vez por arquivo');
    });
  });

  group('datas', () {
    test('data ausente ou invalida bloqueia', () {
      expect(
        _codigos(_diag([
          {..._pesagemOk(), 'dataPesagem': null}
        ])),
        contains(ImportCodigo.pesDataInvalida),
      );
      expect(
        _codigos(_diag([
          {..._pesagemOk(), 'dataPesagem': '1/9/26'}
        ])),
        contains(ImportCodigo.pesDataInvalida),
      );
      expect(
        _codigos(_diag([
          {..._pesagemOk(), 'dataPesagem': '31/02/2026'}
        ])),
        contains(ImportCodigo.pesDataInvalida),
      );
    });

    test('data futura avisa', () {
      final d = _diag([
        {..._pesagemOk(), 'dataPesagem': '15/11/2026'}
      ], hoje: DateTime(2026, 9, 21));
      expect(_codigos(d), contains(ImportCodigo.pesDataFutura));
      expect(d.temBloqueio, isFalse);
    });

    test('pesagem antes do nascimento bloqueia', () {
      final d = _diag([
        {
          ..._pesagemOk(),
          'dataNascimento': '05/06/2024',
          'dataPesagem': '10/01/2024',
        }
      ]);
      final oc = _primeira(d, ImportCodigo.pesDataAntesDoNascimento);
      expect(oc.escopo, ImportEscopo.semantica);
      expect(oc.mensagem, contains('nasceu'));
    });
  });

  group('duplicidade', () {
    test('linha identica bloqueia porque o banco recusaria', () {
      final d = _diag([_pesagemOk(), _pesagemOk()]);
      final oc = _primeira(d, ImportCodigo.pesDuplicadaNoArquivo);
      expect(oc.linha, 3);
      expect(oc.mensagem, contains('linha 2'));
      expect(d.acaoPorLinha[3], ImportAcaoLinha.bloquear);
    });

    test('mesmo animal e dia com peso diferente nao e duplicata', () {
      // O unique parcial inclui o peso, entao as duas passam pelo banco.
      final d = _diag([
        _pesagemOk(),
        {..._pesagemOk(), 'peso': 502.0},
      ]);
      expect(_codigos(d), isNot(contains(ImportCodigo.pesDuplicadaNoArquivo)));
    });
  });
}
