// O diff precisa chegar ao diagnostico e sobreviver a ida e volta ao banco.
import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/importacao/diagnostico_rebanho.dart';
import 'package:in_lida_web/importacao/import_auditoria_repository.dart';
import 'package:in_lida_web/importacao/import_diagnostico_model.dart';
import 'package:in_lida_web/importacao/import_lookups.dart';

const _idProp = 'PROP-A';

final _estrela = AnimalExistente(
  idRebanho: 'abc123',
  id: 7,
  numeroAnimal: '1204',
  nome: 'Estrela',
  dataNascimento: '2024-03-10',
  sexo: 'Fêmea',
  raca: 'Nelore',
  status: 'Na propriedade',
);

RebanhoDbLookup _lookup() => RebanhoDbLookup(
      byNumero: {'1204': 'abc123'},
      byAnimalIdentity: {
        composeIdentidadeAnimalImport(
          numero: '1204',
          nome: 'Estrela',
          dataNascimento: '2024-03-10',
          sexo: 'Fêmea',
          raca: 'Nelore',
        ): 'abc123',
      },
      porIdRebanho: {'abc123': _estrela},
    );

ImportDiagnostico _diag(Map<String, dynamic> planilha,
    {Map<String, dynamic>? gravado}) {
  final b = ImportDiagnosticoBuilder(entidade: ImportEntidade.rebanho);
  diagnosticarRebanhoConsistencia(
    builder: b,
    registros: [
      {kCampoLinhaArquivo: 2, ...planilha}
    ],
    idPropriedade: _idProp,
    lookup: _lookup(),
    animaisCompletos: {
      'abc123': gravado ??
          {
            'idRebanho': 'abc123',
            'numeroAnimal': '1204',
            'nome': 'Estrela',
            'dataNascimento': '2024-03-10',
            'sexo': 'Fêmea',
            'raca': 'Nelore',
            'pesoAtual': 480.0,
            'dataDesmama': '2024-10-05',
            'pesoDesmama': 210.0,
          },
    },
  );
  return b.build(arquivo: const ImportArquivoInfo(), totalLinhas: 1);
}

Map<String, dynamic> _identidade() => {
      'numeroAnimal': '1204',
      'nome': 'Estrela',
      'dataNascimento': '10/03/2024',
      'sexo': 'Fêmea',
      'raca': 'Nelore',
    };

void main() {
  test('peso trocado aparece com o valor anterior', () {
    final d = _diag({..._identidade(), 'pesoAtual': 48.0});

    final a = d.alteracoes.single;
    expect(a.chaveNegocio, 'abc123');
    expect(a.identificacao, contains('1204'));

    final campo = a.campos.singleWhere((c) => c.coluna == 'pesoAtual');
    expect(campo.de, '480');
    expect(campo.para, '48');
    expect(d.totalCamposAlterados, 1);
    expect(d.totalCamposApagados, 0);
  });

  test('coluna em branco e contada como apagamento', () {
    final d = _diag({
      ..._identidade(),
      'dataDesmama': '',
      'pesoDesmama': null,
    });
    expect(d.totalCamposApagados, 2);
    expect(d.alteracoes.single.campos.every((c) => c.apaga), isTrue);
  });

  test('planilha identica ao gravado nao gera alteracao', () {
    final d = _diag({..._identidade(), 'pesoAtual': '480'});
    expect(d.alteracoes, isEmpty,
        reason: 'listar quem nao mudou tiraria a atencao do que importa');
    expect(d.totalAtualizar, 1, reason: 'ainda assim e uma sobrescrita');
  });

  test('a mensagem de sobrescrita diz quantos campos e quantos apagam', () {
    final d = _diag({..._identidade(), 'pesoAtual': 48.0, 'dataDesmama': ''});
    final oc = d.ocorrencias
        .firstWhere((o) => o.codigo == ImportCodigo.rebSobrescritaDeAnimalExistente);
    expect(oc.mensagem, contains('2 campo(s)'));
    expect(oc.mensagem, contains('1 que será(ão) APAGADO(S)'));
  });

  test('o diff sobrevive a ida e volta ao banco', () {
    // Simula o que foi gravado em import_auditoria_alteracao e relido.
    final remontado = remontarDiagnosticoDaAuditoria(
      auditoria: const {
        'entidade': 'rebanho',
        'total_linhas': 1,
        'previstos_atualizar': 1,
      },
      resumos: const [],
      itens: const [],
      alteracoes: const [
        {
          'linha': 2,
          'chave_negocio': 'abc123',
          'identificacao': 'nº 1204 - Estrela',
          'total_campos': 2,
          'total_apagados': 1,
          'campos': {
            'pesoAtual': {'de': '480', 'para': '48'},
            'dataDesmama': {'de': '05/10/2024', 'para': null},
          },
        }
      ],
    );

    expect(remontado.alteracoes, hasLength(1));
    expect(remontado.totalCamposAlterados, 2);
    expect(remontado.totalCamposApagados, 1);
    expect(remontado.registrosAtualizados.single['detalhe'],
        contains('1 apagado(s)'));

    final peso = remontado.alteracoes.single.campos
        .singleWhere((c) => c.coluna == 'pesoAtual');
    expect(peso.de, '480');
    expect(peso.para, '48');
  });
}
