import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/reproducao/reproducao_parto_utils.dart';

/// Nascimento de referência de todos os casos. `dias(n)` devolve a data `n`
/// dias antes dele, para que os cenários possam ser lidos como "inseminação
/// em N-292".
final DateTime n = DateTime(2026, 6, 1);
DateTime dias(int quantidade) => DateTime(n.year, n.month, n.day - quantidade);

const String kPropriedade = 'prop-1';
const String kMatriz = 'matriz-1';

int _seq = 0;

ReproducaoParaVinculo insem(
  int diasAntes, {
  String? id,
  String tipo = 'Inseminação',
  String? parida,
  DateTime? dataParto,
  String? deletado,
  String? matriz = kMatriz,
  String? propriedade = kPropriedade,
  bool semData = false,
  String? idReprodutor,
}) =>
    ReproducaoParaVinculo(
      idReproducao: id ?? 'r${_seq++}',
      idPropriedade: propriedade,
      idRebanhoMatriz: matriz,
      deletado: deletado,
      tipoReproducao: tipo,
      dataInseminacao: semData ? null : dias(diasAntes),
      parida: parida,
      dataParto: dataParto,
      idRebanhoReprodutor: idReprodutor,
    );

ReproducaoParaVinculo monta(
  int? diasInicio,
  int? diasFim, {
  String? id,
  String tipo = 'Monta Natural',
  String? parida,
  DateTime? dataParto,
}) =>
    ReproducaoParaVinculo(
      idReproducao: id ?? 'r${_seq++}',
      idPropriedade: kPropriedade,
      idRebanhoMatriz: kMatriz,
      tipoReproducao: tipo,
      dataInicial: diasInicio == null ? null : dias(diasInicio),
      dataFinal: diasFim == null ? null : dias(diasFim),
      parida: parida,
      dataParto: dataParto,
    );

ResultadoBuscaReproducao buscar(
  List<ReproducaoParaVinculo> reproducoes, {
  String? propriedade = kPropriedade,
  String? matriz = kMatriz,
  DateTime? nascimento,
}) =>
    selecionarReproducaoParaNascimento(
      reproducoes: reproducoes,
      idPropriedade: propriedade,
      idRebanhoMatriz: matriz,
      dataNascimento: nascimento ?? n,
    );

void main() {
  group('janelas de concepção', () {
    test('a automática vai de N-305 a N-275', () {
      final janela = janelaConcepcao(n);
      expect(janela.inicio, dias(305));
      expect(janela.fim, dias(275));
    });

    test('a estendida vai de N-350 a N-306', () {
      final janela = janelaConcepcaoEstendida(n);
      expect(janela.inicio, dias(350));
      expect(janela.fim, dias(306));
    });

    test('as duas janelas não se sobrepõem', () {
      final automatica = janelaConcepcao(n);
      final estendida = janelaConcepcaoEstendida(n);
      expect(estendida.fim.isBefore(automatica.inicio), isTrue);
      expect(estendida.fim, dias(306));
      expect(automatica.inicio, dias(305));
    });

    test('contem inclui as duas bordas', () {
      final janela = janelaConcepcao(n);
      expect(janela.contem(dias(305)), isTrue);
      expect(janela.contem(dias(275)), isTrue);
      expect(janela.contem(dias(306)), isFalse);
      expect(janela.contem(dias(274)), isFalse);
    });

    test('cruza aceita períodos que apenas encostam na janela', () {
      final janela = janelaConcepcaoEstendida(n);
      expect(janela.cruza(dias(400), dias(350)), isTrue);
      expect(janela.cruza(dias(306), dias(200)), isTrue);
      expect(janela.cruza(dias(400), dias(351)), isFalse);
      expect(janela.cruza(dias(305), dias(200)), isFalse);
    });
  });

  group('vínculo automático', () {
    test('inseminação em N-292 não parida vincula automaticamente', () {
      final resultado = buscar([insem(292, id: 'alvo')]);
      expect(resultado.automatica?.idReproducao, 'alvo');
      expect(resultado.candidatosManuais, isEmpty);
    });

    test('entre N-275 e N-305 vence a mais recente', () {
      final resultado = buscar([insem(305, id: 'antiga'), insem(275, id: 'recente')]);
      expect(resultado.automatica?.idReproducao, 'recente');
    });

    test('as bordas 275 e 305 entram na janela automática', () {
      expect(buscar([insem(275)]).automatica, isNotNull);
      expect(buscar([insem(305)]).automatica, isNotNull);
    });

    test('N-274 fica fora das duas janelas', () {
      expect(buscar([insem(274)]).vazio, isTrue);
    });

    test('N-306 cai na janela estendida e vai para escolha manual', () {
      final resultado = buscar([insem(306, id: 'estendida')]);
      expect(resultado.automatica, isNull);
      expect(
        resultado.candidatosManuais.map((c) => c.idReproducao),
        ['estendida'],
      );
    });

    test('N-350 ainda é candidata manual e N-351 já não é', () {
      expect(buscar([insem(350)]).candidatosManuais, hasLength(1));
      expect(buscar([insem(351)]).vazio, isTrue);
    });

    test('a janela automática tem prioridade sobre a estendida', () {
      final resultado = buscar([insem(320, id: 'estendida'), insem(290, id: 'auto')]);
      expect(resultado.automatica?.idReproducao, 'auto');
      expect(resultado.candidatosManuais, isEmpty);
    });
  });

  group('tipo de reprodução', () {
    test('monta natural nunca entra na janela automática', () {
      final resultado = buscar([monta(300, 280)]);
      expect(resultado.automatica, isNull);
    });

    test('monta natural cruzando a janela estendida vira candidata manual', () {
      final resultado = buscar([monta(340, 300, id: 'monta')]);
      expect(
        resultado.candidatosManuais.map((c) => c.idReproducao),
        ['monta'],
      );
    });

    test('monta natural sem data final usa a data inicial nas duas bordas', () {
      expect(buscar([monta(320, null)]).candidatosManuais, hasLength(1));
      expect(buscar([monta(290, null)]).vazio, isTrue);
    });

    test('monta natural só com data final usa ela como referência', () {
      final resultado = buscar([monta(null, 320)]);
      expect(resultado.candidatosManuais.single.dataReferencia, dias(320));
    });

    test('a caixa do tipo é ignorada', () {
      for (final tipo in ['INSEMINAÇÃO', 'inseminacao', ' Inseminação ']) {
        expect(
          buscar([insem(290, tipo: tipo)]).automatica,
          isNotNull,
          reason: 'tipo rejeitado: $tipo',
        );
      }
      expect(buscar([monta(320, 310, tipo: ' MONTA NATURAL ')]).candidatosManuais,
          hasLength(1));
    });

    test('tipo desconhecido nunca é candidato', () {
      expect(buscar([insem(290, tipo: 'Transferência de embrião')]).vazio, isTrue);
      expect(buscar([insem(320, tipo: 'Transferência de embrião')]).vazio, isTrue);
      expect(dataReferenciaConcepcao(insem(290, tipo: 'Outro')), isNull);
    });

    test('inseminação sem data de inseminação é ignorada sem erro', () {
      expect(buscar([insem(290, semData: true)]).vazio, isTrue);
    });
  });

  group('parto já confirmado', () {
    test('parida SIM é descartada em favor de uma livre', () {
      final resultado = buscar([
        insem(286, id: 'parida', parida: 'SIM'),
        insem(300, id: 'livre'),
      ]);
      expect(resultado.automatica?.idReproducao, 'livre');
    });

    test('data de parto preenchida conta como parida mesmo com parida NAO', () {
      final resultado = buscar([
        insem(290, parida: 'NAO', dataParto: DateTime(2026, 5, 30)),
      ]);
      expect(resultado.vazio, isTrue);
    });

    test('a caixa de parida é ignorada', () {
      for (final parida in ['sim', ' Sim ', 'SIM']) {
        expect(
          buscar([insem(290, parida: parida)]).vazio,
          isTrue,
          reason: 'parida aceita indevidamente: $parida',
        );
      }
    });

    test('todas paridas não vinculam nada, nem na janela estendida', () {
      final resultado = buscar([
        insem(290, parida: 'SIM'),
        insem(320, parida: 'SIM'),
      ]);
      expect(resultado.vazio, isTrue);
    });

    test('partoConfirmado aceita apenas sim ou data', () {
      expect(partoConfirmado('SIM', null), isTrue);
      expect(partoConfirmado('NAO', DateTime(2026, 1, 1)), isTrue);
      expect(partoConfirmado('NAO', null), isFalse);
      expect(partoConfirmado(null, null), isFalse);
    });
  });

  group('escopo', () {
    test('reprodução de outra matriz é ignorada', () {
      expect(buscar([insem(290, matriz: 'outra')]).vazio, isTrue);
    });

    test('reprodução de outra propriedade é ignorada', () {
      expect(buscar([insem(290, propriedade: 'outra')]).vazio, isTrue);
    });

    test('reprodução deletada é ignorada', () {
      expect(buscar([insem(290, deletado: 'SIM')]).vazio, isTrue);
      expect(buscar([insem(290, deletado: ' sim ')]).vazio, isTrue);
    });

    test('deletado nulo ou NAO continua candidata', () {
      expect(buscar([insem(290, deletado: null)]).automatica, isNotNull);
      expect(buscar([insem(290, deletado: 'NAO')]).automatica, isNotNull);
    });
  });

  group('pré-condições', () {
    test('sem propriedade, sem matriz ou sem data não busca nada', () {
      final reproducoes = [insem(290)];
      expect(buscar(reproducoes, propriedade: null).vazio, isTrue);
      expect(buscar(reproducoes, propriedade: '  ').vazio, isTrue);
      expect(buscar(reproducoes, matriz: null).vazio, isTrue);
      for (final matriz in ['', 'null', '-']) {
        expect(
          buscar(reproducoes, matriz: matriz).vazio,
          isTrue,
          reason: 'matriz aceita indevidamente: "$matriz"',
        );
      }
      expect(
        selecionarReproducaoParaNascimento(
          reproducoes: reproducoes,
          idPropriedade: kPropriedade,
          idRebanhoMatriz: kMatriz,
          dataNascimento: null,
        ).vazio,
        isTrue,
      );
    });

    test('idAnimalValido rejeita os sentinelas', () {
      expect(idAnimalValido('abc'), isTrue);
      for (final id in <String?>[null, '', '   ', 'null', '-']) {
        expect(idAnimalValido(id), isFalse, reason: 'id aceito: "$id"');
      }
    });
  });

  test('candidatas manuais vêm da mais recente para a mais antiga', () {
    final resultado = buscar([
      insem(350, id: 'antiga'),
      insem(310, id: 'recente'),
      insem(330, id: 'meio'),
    ]);
    expect(
      resultado.candidatosManuais.map((c) => c.idReproducao),
      ['recente', 'meio', 'antiga'],
    );
  });

  test('o candidato carrega os dados do reprodutor da reprodução', () {
    final resultado = buscar([insem(290, idReprodutor: 'touro-1')]);
    expect(resultado.automatica?.idRebanhoReprodutor, 'touro-1');
    expect(resultado.automatica?.dataReferencia, dias(290));
  });

  group('chaveVinculoReproducao', () {
    test('é estável para a mesma matriz e data', () {
      expect(
        chaveVinculoReproducao(kMatriz, n),
        chaveVinculoReproducao(kMatriz, DateTime(2026, 6, 1, 23, 59)),
      );
      expect(chaveVinculoReproducao(kMatriz, n), 'matriz-1|2026-06-01');
    });

    test('muda quando a matriz ou a data mudam', () {
      final base = chaveVinculoReproducao(kMatriz, n);
      expect(chaveVinculoReproducao('outra', n), isNot(base));
      expect(chaveVinculoReproducao(kMatriz, dias(1)), isNot(base));
    });

    test('tolera matriz e data nulas', () {
      expect(chaveVinculoReproducao(null, null), '|');
    });
  });
}
