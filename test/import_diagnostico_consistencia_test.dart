// Consistencia com o banco, com o lookup montado a mao: nenhum teste toca
// Supabase. E por isso que o ImportContexto recebe o lookup pronto.
import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/importacao/diagnostico_pesagem.dart';
import 'package:in_lida_web/importacao/diagnostico_rebanho.dart';
import 'package:in_lida_web/importacao/import_diagnostico_model.dart';
import 'package:in_lida_web/importacao/import_lookups.dart';

const _idProp = 'PROP-A';

/// Monta um lookup como se o banco tivesse estes animais.
RebanhoDbLookup _lookupCom(
  List<AnimalExistente> animais, {
  Map<String, String> lotes = const {},
  Set<String> lotesAmbiguos = const {},
}) {
  final byNumero = <String, String>{};
  final byAnimalIdentity = <String, String>{};
  final porIdRebanho = <String, AnimalExistente>{};
  final vistos = <String, int>{};
  final ambiguos = <String>{};

  for (final a in animais) {
    porIdRebanho[a.idRebanho] = a;
    final numero = (a.numeroAnimal ?? '').trim();
    if (numero.isEmpty) continue;
    byNumero.putIfAbsent(numero, () => a.idRebanho);
    final n = (vistos[numero] ?? 0) + 1;
    vistos[numero] = n;
    if (n > 1) ambiguos.add(numero);

    // Usa a MESMA funcao do codigo de producao: montar a chave a mao no teste
    // esconderia justamente o tipo de divergencia de normalizacao que se quer
    // evitar.
    byAnimalIdentity.putIfAbsent(
      composeIdentidadeAnimalImport(
        numero: numero,
        nome: a.nome,
        dataNascimento: a.dataNascimento,
        sexo: a.sexo,
        raca: a.raca,
      ),
      () => a.idRebanho,
    );
  }

  return RebanhoDbLookup(
    byNumero: byNumero,
    byAnimalIdentity: byAnimalIdentity,
    porIdRebanho: porIdRebanho,
    numerosAmbiguos: ambiguos,
    loteNomeParaId: lotes,
    lotesAmbiguos: lotesAmbiguos,
  );
}

ImportDiagnostico _diagRebanho(
  List<Map<String, dynamic>> linhas,
  RebanhoDbLookup lookup, {
  String idPropriedade = _idProp,
}) {
  final b = ImportDiagnosticoBuilder(entidade: ImportEntidade.rebanho);
  final registros = <Map<String, dynamic>>[];
  for (var i = 0; i < linhas.length; i++) {
    registros.add({kCampoLinhaArquivo: i + 2, ...linhas[i]});
  }
  diagnosticarRebanhoConsistencia(
    builder: b,
    registros: registros,
    idPropriedade: idPropriedade,
    lookup: lookup,
  );
  return b.build(
      arquivo: const ImportArquivoInfo(), totalLinhas: linhas.length);
}

ImportDiagnostico _diagPesagem(
  List<Map<String, dynamic>> linhas,
  RebanhoDbLookup lookup, {
  Set<String> existentes = const {},
}) {
  final b = ImportDiagnosticoBuilder(entidade: ImportEntidade.pesagem);
  final registros = <Map<String, dynamic>>[];
  for (var i = 0; i < linhas.length; i++) {
    registros.add({kCampoLinhaArquivo: i + 2, ...linhas[i]});
  }
  diagnosticarPesagemConsistencia(
    builder: b,
    registros: registros,
    lookup: lookup,
    chavesPesagemExistentes: existentes,
  );
  return b.build(
      arquivo: const ImportArquivoInfo(), totalLinhas: linhas.length);
}

Set<String> _codigos(ImportDiagnostico d) =>
    d.ocorrencias.map((o) => o.codigo).toSet();

ImportOcorrencia _primeira(ImportDiagnostico d, String codigo) =>
    d.ocorrencias.firstWhere((o) => o.codigo == codigo);

void main() {
  group('rebanho: criar x sobrescrever', () {
    final estrela = AnimalExistente(
      idRebanho: 'abc123',
      id: 7,
      numeroAnimal: '1204',
      nome: 'Estrela',
      dataNascimento: '2024-03-10',
      sexo: 'Fêmea',
      raca: 'Nelore',
      status: 'Na propriedade',
      loteNome: 'Pasto 1',
    );

    test('identidade completa marca ATUALIZAR e avisa da sobrescrita', () {
      final d = _diagRebanho([
        {
          'numeroAnimal': '1204',
          'nome': 'Estrela',
          'dataNascimento': '10/03/2024',
          'sexo': 'Fêmea',
          'raca': 'Nelore',
        }
      ], _lookupCom([estrela]));

      expect(d.acaoPorLinha[2], ImportAcaoLinha.atualizar);
      expect(d.totalAtualizar, 1);
      final oc = _primeira(d, ImportCodigo.rebSobrescritaDeAnimalExistente);
      expect(oc.severidade, ImportSeveridade.aviso);
      expect(oc.mensagem, contains('apagam'),
          reason: 'o usuario precisa saber que campo em branco apaga dado');
      expect(d.registrosAtualizados.single['numeroAnimal'], '1204');
      expect(d.registrosAtualizados.single['detalhe'], contains('Pasto 1'));
    });

    test('divergencia minima avisa que vai DUPLICAR em vez de atualizar', () {
      // Mesma numeracao, raca diferente: a chave de 5 campos nao casa.
      final d = _diagRebanho([
        {
          'numeroAnimal': '1204',
          'nome': 'Estrela',
          'dataNascimento': '10/03/2024',
          'sexo': 'Fêmea',
          'raca': 'Nelore PO',
        }
      ], _lookupCom([estrela]));

      expect(d.acaoPorLinha[2], ImportAcaoLinha.criar);
      final oc = _primeira(d, ImportCodigo.rebDuplicataPorDivergenciaMinima);
      expect(oc.mensagem, contains('DUPLICADO'));
      expect(oc.mensagem, contains('Raça'));
    });

    test('animal novo apenas marca criar', () {
      final d = _diagRebanho([
        {'numeroAnimal': '9999', 'sexo': 'Fêmea'}
      ], _lookupCom([estrela]));
      expect(d.acaoPorLinha[2], ImportAcaoLinha.criar);
      expect(d.ocorrencias, isEmpty);
    });
  });

  group('rebanho: propriedade', () {
    test('linha de outra propriedade e bloqueada', () {
      final d = _diagRebanho([
        {'numeroAnimal': '1204', 'idPropriedade': 'PROP-B'}
      ], _lookupCom([]));
      final oc = _primeira(d, ImportCodigo.rebExportDeOutraPropriedade);
      expect(oc.severidade, ImportSeveridade.bloqueante);
      expect(oc.mensagem, contains('transferiria'));
      expect(d.acaoPorLinha[2], ImportAcaoLinha.bloquear);
    });

    test('mesma propriedade nao reclama', () {
      final d = _diagRebanho([
        {'numeroAnimal': '1204', 'idPropriedade': _idProp}
      ], _lookupCom([]));
      expect(_codigos(d),
          isNot(contains(ImportCodigo.rebExportDeOutraPropriedade)));
    });
  });

  group('rebanho: lote', () {
    test('lote inexistente avisa que o animal entra sem lote', () {
      final d = _diagRebanho([
        {'numeroAnimal': '1204', 'loteNome': 'Retiro Novo'}
      ], _lookupCom([], lotes: {'pasto 1': 'lote-1'}));
      expect(_codigos(d), contains(ImportCodigo.rebLoteInexistente));
    });

    test('lote existente, mesmo com acento e caixa diferentes, passa', () {
      final d = _diagRebanho([
        {'numeroAnimal': '1204', 'loteNome': 'PASTO 1'}
      ], _lookupCom([], lotes: {'pasto 1': 'lote-1'}));
      expect(_codigos(d), isNot(contains(ImportCodigo.rebLoteInexistente)));
    });

    test('dois lotes com o mesmo nome avisam sobre ambiguidade', () {
      final d = _diagRebanho(
          [
            {'numeroAnimal': '1204', 'loteNome': 'Pasto 1'}
          ],
          _lookupCom([],
              lotes: {'pasto 1': 'lote-1'}, lotesAmbiguos: {'pasto 1'}));
      expect(_codigos(d), contains(ImportCodigo.rebLoteAmbiguo));
    });
  });

  group('rebanho: matriz e reprodutor', () {
    final touro = AnimalExistente(
      idRebanho: 't1',
      numeroAnimal: '77',
      sexo: 'Macho',
      status: 'Na propriedade',
    );

    test('matriz inexistente avisa que o vinculo nao sera criado', () {
      final d = _diagRebanho([
        {'numeroAnimal': '1204', 'numeroMatriz': '555'}
      ], _lookupCom([]));
      expect(_codigos(d), contains(ImportCodigo.rebMatrizNaoEncontrada));
    });

    test('matriz cadastrada como macho avisa', () {
      final d = _diagRebanho([
        {'numeroAnimal': '1204', 'numeroMatriz': '77'}
      ], _lookupCom([touro]));
      final oc = _primeira(d, ImportCodigo.rebMatrizSexoIncompativel);
      expect(oc.mensagem, contains('Macho'));
    });

    test('numero de pai repetido avisa risco de vinculo errado', () {
      final d = _diagRebanho(
          [
            {'numeroAnimal': '1204', 'numeroReprodutor': '77'}
          ],
          _lookupCom([
            touro,
            AnimalExistente(idRebanho: 't2', numeroAnimal: '77', sexo: 'Macho'),
          ]));
      expect(_codigos(d), contains(ImportCodigo.rebPaiResolvidoSoPorNumero));
    });

    test('marcador generico "SN" nao vira "matriz nao encontrada"', () {
      // Ja e tratado pela regra local; nao deve gerar ruido aqui tambem.
      final d = _diagRebanho([
        {'numeroAnimal': '1204', 'numeroMatriz': 'SN'}
      ], _lookupCom([]));
      expect(_codigos(d), isNot(contains(ImportCodigo.rebMatrizNaoEncontrada)));
    });
  });

  group('pesagem', () {
    final boi = AnimalExistente(
      idRebanho: 'r1',
      numeroAnimal: '1204',
      dataNascimento: '2024-06-05',
      status: 'Na propriedade',
    );

    test('animal inexistente explica como a busca foi feita', () {
      final d = _diagPesagem([
        {'numeroAnimal': '9999', 'dataPesagem': '20/08/2026', 'peso': 480.0}
      ], _lookupCom([boi]));
      final oc = _primeira(d, ImportCodigo.pesAnimalNaoEncontrado);
      expect(oc.severidade, ImportSeveridade.bloqueante);
      expect(oc.mensagem, contains('restrita à propriedade'));
    });

    test('numero repetido bloqueia para o peso nao ir ao animal errado', () {
      final d = _diagPesagem(
          [
            {'numeroAnimal': '1204', 'dataPesagem': '20/08/2026', 'peso': 480.0}
          ],
          _lookupCom([
            boi,
            AnimalExistente(idRebanho: 'r2', numeroAnimal: '1204'),
          ]));
      expect(_codigos(d), contains(ImportCodigo.pesAnimalAmbiguo));
    });

    test('pesagem ja existente no banco e bloqueada', () {
      final chave = composePesagemChaveImport(
        idRebanho: 'r1',
        tipo: 'Atual',
        dataIso: '2026-08-20',
        peso: 480.0,
      );
      final d = _diagPesagem(
          [
            {
              'numeroAnimal': '1204',
              'dataPesagem': '20/08/2026',
              'peso': 480.0,
              'tipo': 'Atual'
            }
          ],
          _lookupCom([boi]),
          existentes: {chave});
      expect(_codigos(d), contains(ImportCodigo.pesDuplicadaNoBanco));
      expect(d.acaoPorLinha[2], ImportAcaoLinha.bloquear);
    });

    test('mesmo dia com peso diferente apenas avisa: o unique nao barra', () {
      final d = _diagPesagem([
        {
          'numeroAnimal': '1204',
          'dataPesagem': '20/08/2026',
          'peso': 480.0,
          'tipo': 'Atual'
        },
        {
          'numeroAnimal': '1204',
          'dataPesagem': '20/08/2026',
          'peso': 502.0,
          'tipo': 'Atual'
        },
      ], _lookupCom([boi]));
      final oc = _primeira(d, ImportCodigo.pesMesmoDiaPesoDiferente);
      expect(oc.severidade, ImportSeveridade.aviso);
      expect(oc.mensagem, contains('480'));
      expect(oc.mensagem, contains('502'));
    });

    test('pesagem antes do nascimento registrado no sistema bloqueia', () {
      final d = _diagPesagem([
        {'numeroAnimal': '1204', 'dataPesagem': '10/01/2024', 'peso': 40.0}
      ], _lookupCom([boi]));
      final oc = _primeira(d, ImportCodigo.pesDataAntesDoNascimento);
      expect(oc.mensagem, contains('no sistema'));
    });

    test('animal vendido antes da pesagem avisa', () {
      final vendido = AnimalExistente(
        idRebanho: 'r9',
        numeroAnimal: '300',
        status: 'Vendido',
        dataVenda: '2026-03-10',
      );
      final d = _diagPesagem([
        {'numeroAnimal': '300', 'dataPesagem': '20/08/2026', 'peso': 480.0}
      ], _lookupCom([vendido]));
      final oc = _primeira(d, ImportCodigo.pesAnimalVendidoOuMorto);
      expect(oc.mensagem, contains('Vendido'));
      expect(oc.mensagem, contains('10/03/2026'));
    });
  });
}
