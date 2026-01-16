// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SanidadeStruct extends BaseStruct {
  SanidadeStruct({
    int? id,
    String? createdAt,
    String? idPropriedade,
    String? idRebanho,
    String? dataSanidade,
    String? idLote,
    String? porcentagemLote,
    String? idSanidade,
    String? updatedAt,
    String? deletado,
    String? vacinacao,
    String? vacinacaoOutros,
    String? vacinacaoObs,
    String? antiparasitario,
    String? antiparasitarioOutros,
    String? antiparasitarioObs,
    String? tratamento,
    String? tratamentoOutros,
    String? tratamentoObs,
    String? protocoloReprodutivo,
    String? protocoloReprodutivoOutros,
    String? protocoloReprodutivoObs,
    String? protocoloD0,
    String? protocoloRetirada,
    String? protocoloIatf,
    String? numeroAnimal,
    String? nome,
    String? chip,
    String? dataNascimento,
    String? sexo,
    String? raca,
    String? categoria,
    String? loteNome,
  })  : _id = id,
        _createdAt = createdAt,
        _idPropriedade = idPropriedade,
        _idRebanho = idRebanho,
        _dataSanidade = dataSanidade,
        _idLote = idLote,
        _porcentagemLote = porcentagemLote,
        _idSanidade = idSanidade,
        _updatedAt = updatedAt,
        _deletado = deletado,
        _vacinacao = vacinacao,
        _vacinacaoOutros = vacinacaoOutros,
        _vacinacaoObs = vacinacaoObs,
        _antiparasitario = antiparasitario,
        _antiparasitarioOutros = antiparasitarioOutros,
        _antiparasitarioObs = antiparasitarioObs,
        _tratamento = tratamento,
        _tratamentoOutros = tratamentoOutros,
        _tratamentoObs = tratamentoObs,
        _protocoloReprodutivo = protocoloReprodutivo,
        _protocoloReprodutivoOutros = protocoloReprodutivoOutros,
        _protocoloReprodutivoObs = protocoloReprodutivoObs,
        _protocoloD0 = protocoloD0,
        _protocoloRetirada = protocoloRetirada,
        _protocoloIatf = protocoloIatf,
        _numeroAnimal = numeroAnimal,
        _nome = nome,
        _chip = chip,
        _dataNascimento = dataNascimento,
        _sexo = sexo,
        _raca = raca,
        _categoria = categoria,
        _loteNome = loteNome;

  // "id" field.
  int? _id;
  int get id => _id ?? 0;
  set id(int? val) => _id = val;

  void incrementId(int amount) => id = id + amount;

  bool hasId() => _id != null;

  // "created_at" field.
  String? _createdAt;
  String get createdAt => _createdAt ?? '';
  set createdAt(String? val) => _createdAt = val;

  bool hasCreatedAt() => _createdAt != null;

  // "id_propriedade" field.
  String? _idPropriedade;
  String get idPropriedade => _idPropriedade ?? '';
  set idPropriedade(String? val) => _idPropriedade = val;

  bool hasIdPropriedade() => _idPropriedade != null;

  // "id_rebanho" field.
  String? _idRebanho;
  String get idRebanho => _idRebanho ?? '';
  set idRebanho(String? val) => _idRebanho = val;

  bool hasIdRebanho() => _idRebanho != null;

  // "data_sanidade" field.
  String? _dataSanidade;
  String get dataSanidade => _dataSanidade ?? '';
  set dataSanidade(String? val) => _dataSanidade = val;

  bool hasDataSanidade() => _dataSanidade != null;

  // "id_lote" field.
  String? _idLote;
  String get idLote => _idLote ?? '';
  set idLote(String? val) => _idLote = val;

  bool hasIdLote() => _idLote != null;

  // "porcentagem_lote" field.
  String? _porcentagemLote;
  String get porcentagemLote => _porcentagemLote ?? '';
  set porcentagemLote(String? val) => _porcentagemLote = val;

  bool hasPorcentagemLote() => _porcentagemLote != null;

  // "id_sanidade" field.
  String? _idSanidade;
  String get idSanidade => _idSanidade ?? '';
  set idSanidade(String? val) => _idSanidade = val;

  bool hasIdSanidade() => _idSanidade != null;

  // "updated_at" field.
  String? _updatedAt;
  String get updatedAt => _updatedAt ?? '';
  set updatedAt(String? val) => _updatedAt = val;

  bool hasUpdatedAt() => _updatedAt != null;

  // "deletado" field.
  String? _deletado;
  String get deletado => _deletado ?? '';
  set deletado(String? val) => _deletado = val;

  bool hasDeletado() => _deletado != null;

  // "vacinacao" field.
  String? _vacinacao;
  String get vacinacao => _vacinacao ?? '';
  set vacinacao(String? val) => _vacinacao = val;

  bool hasVacinacao() => _vacinacao != null;

  // "vacinacao_outros" field.
  String? _vacinacaoOutros;
  String get vacinacaoOutros => _vacinacaoOutros ?? '';
  set vacinacaoOutros(String? val) => _vacinacaoOutros = val;

  bool hasVacinacaoOutros() => _vacinacaoOutros != null;

  // "vacinacao_obs" field.
  String? _vacinacaoObs;
  String get vacinacaoObs => _vacinacaoObs ?? '';
  set vacinacaoObs(String? val) => _vacinacaoObs = val;

  bool hasVacinacaoObs() => _vacinacaoObs != null;

  // "antiparasitario" field.
  String? _antiparasitario;
  String get antiparasitario => _antiparasitario ?? '';
  set antiparasitario(String? val) => _antiparasitario = val;

  bool hasAntiparasitario() => _antiparasitario != null;

  // "antiparasitario_outros" field.
  String? _antiparasitarioOutros;
  String get antiparasitarioOutros => _antiparasitarioOutros ?? '';
  set antiparasitarioOutros(String? val) => _antiparasitarioOutros = val;

  bool hasAntiparasitarioOutros() => _antiparasitarioOutros != null;

  // "antiparasitario_obs" field.
  String? _antiparasitarioObs;
  String get antiparasitarioObs => _antiparasitarioObs ?? '';
  set antiparasitarioObs(String? val) => _antiparasitarioObs = val;

  bool hasAntiparasitarioObs() => _antiparasitarioObs != null;

  // "tratamento" field.
  String? _tratamento;
  String get tratamento => _tratamento ?? '';
  set tratamento(String? val) => _tratamento = val;

  bool hasTratamento() => _tratamento != null;

  // "tratamento_outros" field.
  String? _tratamentoOutros;
  String get tratamentoOutros => _tratamentoOutros ?? '';
  set tratamentoOutros(String? val) => _tratamentoOutros = val;

  bool hasTratamentoOutros() => _tratamentoOutros != null;

  // "tratamento_obs" field.
  String? _tratamentoObs;
  String get tratamentoObs => _tratamentoObs ?? '';
  set tratamentoObs(String? val) => _tratamentoObs = val;

  bool hasTratamentoObs() => _tratamentoObs != null;

  // "protocolo_reprodutivo" field.
  String? _protocoloReprodutivo;
  String get protocoloReprodutivo => _protocoloReprodutivo ?? '';
  set protocoloReprodutivo(String? val) => _protocoloReprodutivo = val;

  bool hasProtocoloReprodutivo() => _protocoloReprodutivo != null;

  // "protocolo_reprodutivo_outros" field.
  String? _protocoloReprodutivoOutros;
  String get protocoloReprodutivoOutros => _protocoloReprodutivoOutros ?? '';
  set protocoloReprodutivoOutros(String? val) =>
      _protocoloReprodutivoOutros = val;

  bool hasProtocoloReprodutivoOutros() => _protocoloReprodutivoOutros != null;

  // "protocolo_reprodutivo_obs" field.
  String? _protocoloReprodutivoObs;
  String get protocoloReprodutivoObs => _protocoloReprodutivoObs ?? '';
  set protocoloReprodutivoObs(String? val) => _protocoloReprodutivoObs = val;

  bool hasProtocoloReprodutivoObs() => _protocoloReprodutivoObs != null;

  // "protocolo_d0" field.
  String? _protocoloD0;
  String get protocoloD0 => _protocoloD0 ?? '';
  set protocoloD0(String? val) => _protocoloD0 = val;

  bool hasProtocoloD0() => _protocoloD0 != null;

  // "protocolo_retirada" field.
  String? _protocoloRetirada;
  String get protocoloRetirada => _protocoloRetirada ?? '';
  set protocoloRetirada(String? val) => _protocoloRetirada = val;

  bool hasProtocoloRetirada() => _protocoloRetirada != null;

  // "protocolo_iatf" field.
  String? _protocoloIatf;
  String get protocoloIatf => _protocoloIatf ?? '';
  set protocoloIatf(String? val) => _protocoloIatf = val;

  bool hasProtocoloIatf() => _protocoloIatf != null;

  // "numeroAnimal" field.
  String? _numeroAnimal;
  String get numeroAnimal => _numeroAnimal ?? '';
  set numeroAnimal(String? val) => _numeroAnimal = val;

  bool hasNumeroAnimal() => _numeroAnimal != null;

  // "nome" field.
  String? _nome;
  String get nome => _nome ?? '';
  set nome(String? val) => _nome = val;

  bool hasNome() => _nome != null;

  // "chip" field.
  String? _chip;
  String get chip => _chip ?? '';
  set chip(String? val) => _chip = val;

  bool hasChip() => _chip != null;

  // "dataNascimento" field.
  String? _dataNascimento;
  String get dataNascimento => _dataNascimento ?? '';
  set dataNascimento(String? val) => _dataNascimento = val;

  bool hasDataNascimento() => _dataNascimento != null;

  // "sexo" field.
  String? _sexo;
  String get sexo => _sexo ?? '';
  set sexo(String? val) => _sexo = val;

  bool hasSexo() => _sexo != null;

  // "raca" field.
  String? _raca;
  String get raca => _raca ?? '';
  set raca(String? val) => _raca = val;

  bool hasRaca() => _raca != null;

  // "categoria" field.
  String? _categoria;
  String get categoria => _categoria ?? '';
  set categoria(String? val) => _categoria = val;

  bool hasCategoria() => _categoria != null;

  // "loteNome" field.
  String? _loteNome;
  String get loteNome => _loteNome ?? '';
  set loteNome(String? val) => _loteNome = val;

  bool hasLoteNome() => _loteNome != null;

  static SanidadeStruct fromMap(Map<String, dynamic> data) => SanidadeStruct(
        id: castToType<int>(data['id']),
      createdAt: data['created_at']?.toString(),
      idPropriedade: data['id_propriedade']?.toString(),
      idRebanho: data['id_rebanho']?.toString(),
      dataSanidade: data['data_sanidade']?.toString(),
      idLote: data['id_lote']?.toString(),
      porcentagemLote: data['porcentagem_lote']?.toString(),
      idSanidade: data['id_sanidade']?.toString(),
      updatedAt: data['updated_at']?.toString(),
      deletado: data['deletado']?.toString(),
      vacinacao: data['vacinacao']?.toString(),
      vacinacaoOutros: data['vacinacao_outros']?.toString(),
      vacinacaoObs: data['vacinacao_obs']?.toString(),
      antiparasitario: data['antiparasitario']?.toString(),
      antiparasitarioOutros: data['antiparasitario_outros']?.toString(),
      antiparasitarioObs: data['antiparasitario_obs']?.toString(),
      tratamento: data['tratamento']?.toString(),
      tratamentoOutros: data['tratamento_outros']?.toString(),
      tratamentoObs: data['tratamento_obs']?.toString(),
      protocoloReprodutivo: data['protocolo_reprodutivo']?.toString(),
      protocoloReprodutivoOutros:
        data['protocolo_reprodutivo_outros']?.toString(),
      protocoloReprodutivoObs: data['protocolo_reprodutivo_obs']?.toString(),
      protocoloD0: data['protocolo_d0']?.toString(),
      protocoloRetirada: data['protocolo_retirada']?.toString(),
      protocoloIatf: data['protocolo_iatf']?.toString(),
      numeroAnimal: data['numeroAnimal']?.toString(),
      nome: data['nome']?.toString(),
      chip: data['chip']?.toString(),
      dataNascimento: data['dataNascimento']?.toString(),
      sexo: data['sexo']?.toString(),
      raca: data['raca']?.toString(),
      categoria: data['categoria']?.toString(),
      loteNome: data['loteNome']?.toString(),
      );

  static SanidadeStruct? maybeFromMap(dynamic data) =>
      data is Map ? SanidadeStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'created_at': _createdAt,
        'id_propriedade': _idPropriedade,
        'id_rebanho': _idRebanho,
        'data_sanidade': _dataSanidade,
        'id_lote': _idLote,
        'porcentagem_lote': _porcentagemLote,
        'id_sanidade': _idSanidade,
        'updated_at': _updatedAt,
        'deletado': _deletado,
        'vacinacao': _vacinacao,
        'vacinacao_outros': _vacinacaoOutros,
        'vacinacao_obs': _vacinacaoObs,
        'antiparasitario': _antiparasitario,
        'antiparasitario_outros': _antiparasitarioOutros,
        'antiparasitario_obs': _antiparasitarioObs,
        'tratamento': _tratamento,
        'tratamento_outros': _tratamentoOutros,
        'tratamento_obs': _tratamentoObs,
        'protocolo_reprodutivo': _protocoloReprodutivo,
        'protocolo_reprodutivo_outros': _protocoloReprodutivoOutros,
        'protocolo_reprodutivo_obs': _protocoloReprodutivoObs,
      'protocolo_d0': _protocoloD0,
      'protocolo_retirada': _protocoloRetirada,
      'protocolo_iatf': _protocoloIatf,
        'numeroAnimal': _numeroAnimal,
        'nome': _nome,
        'chip': _chip,
        'dataNascimento': _dataNascimento,
        'sexo': _sexo,
        'raca': _raca,
        'categoria': _categoria,
        'loteNome': _loteNome,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.int,
        ),
        'created_at': serializeParam(
          _createdAt,
          ParamType.String,
        ),
        'id_propriedade': serializeParam(
          _idPropriedade,
          ParamType.String,
        ),
        'id_rebanho': serializeParam(
          _idRebanho,
          ParamType.String,
        ),
        'data_sanidade': serializeParam(
          _dataSanidade,
          ParamType.String,
        ),
        'id_lote': serializeParam(
          _idLote,
          ParamType.String,
        ),
        'porcentagem_lote': serializeParam(
          _porcentagemLote,
          ParamType.String,
        ),
        'id_sanidade': serializeParam(
          _idSanidade,
          ParamType.String,
        ),
        'updated_at': serializeParam(
          _updatedAt,
          ParamType.String,
        ),
        'deletado': serializeParam(
          _deletado,
          ParamType.String,
        ),
        'vacinacao': serializeParam(
          _vacinacao,
          ParamType.String,
        ),
        'vacinacao_outros': serializeParam(
          _vacinacaoOutros,
          ParamType.String,
        ),
        'vacinacao_obs': serializeParam(
          _vacinacaoObs,
          ParamType.String,
        ),
        'antiparasitario': serializeParam(
          _antiparasitario,
          ParamType.String,
        ),
        'antiparasitario_outros': serializeParam(
          _antiparasitarioOutros,
          ParamType.String,
        ),
        'antiparasitario_obs': serializeParam(
          _antiparasitarioObs,
          ParamType.String,
        ),
        'tratamento': serializeParam(
          _tratamento,
          ParamType.String,
        ),
        'tratamento_outros': serializeParam(
          _tratamentoOutros,
          ParamType.String,
        ),
        'tratamento_obs': serializeParam(
          _tratamentoObs,
          ParamType.String,
        ),
        'protocolo_reprodutivo': serializeParam(
          _protocoloReprodutivo,
          ParamType.String,
        ),
        'protocolo_reprodutivo_outros': serializeParam(
          _protocoloReprodutivoOutros,
          ParamType.String,
        ),
        'protocolo_reprodutivo_obs': serializeParam(
          _protocoloReprodutivoObs,
          ParamType.String,
        ),
        'protocolo_d0': serializeParam(
          _protocoloD0,
          ParamType.String,
        ),
        'protocolo_retirada': serializeParam(
          _protocoloRetirada,
          ParamType.String,
        ),
        'protocolo_iatf': serializeParam(
          _protocoloIatf,
          ParamType.String,
        ),
        'numeroAnimal': serializeParam(
          _numeroAnimal,
          ParamType.String,
        ),
        'nome': serializeParam(
          _nome,
          ParamType.String,
        ),
        'chip': serializeParam(
          _chip,
          ParamType.String,
        ),
        'dataNascimento': serializeParam(
          _dataNascimento,
          ParamType.String,
        ),
        'sexo': serializeParam(
          _sexo,
          ParamType.String,
        ),
        'raca': serializeParam(
          _raca,
          ParamType.String,
        ),
        'categoria': serializeParam(
          _categoria,
          ParamType.String,
        ),
        'loteNome': serializeParam(
          _loteNome,
          ParamType.String,
        ),
      }.withoutNulls;

  static SanidadeStruct fromSerializableMap(Map<String, dynamic> data) =>
      SanidadeStruct(
        id: deserializeParam(
          data['id'],
          ParamType.int,
          false,
        ),
        createdAt: deserializeParam(
          data['created_at'],
          ParamType.String,
          false,
        ),
        idPropriedade: deserializeParam(
          data['id_propriedade'],
          ParamType.String,
          false,
        ),
        idRebanho: deserializeParam(
          data['id_rebanho'],
          ParamType.String,
          false,
        ),
        dataSanidade: deserializeParam(
          data['data_sanidade'],
          ParamType.String,
          false,
        ),
        idLote: deserializeParam(
          data['id_lote'],
          ParamType.String,
          false,
        ),
        porcentagemLote: deserializeParam(
          data['porcentagem_lote'],
          ParamType.String,
          false,
        ),
        idSanidade: deserializeParam(
          data['id_sanidade'],
          ParamType.String,
          false,
        ),
        updatedAt: deserializeParam(
          data['updated_at'],
          ParamType.String,
          false,
        ),
        deletado: deserializeParam(
          data['deletado'],
          ParamType.String,
          false,
        ),
        vacinacao: deserializeParam(
          data['vacinacao'],
          ParamType.String,
          false,
        ),
        vacinacaoOutros: deserializeParam(
          data['vacinacao_outros'],
          ParamType.String,
          false,
        ),
        vacinacaoObs: deserializeParam(
          data['vacinacao_obs'],
          ParamType.String,
          false,
        ),
        antiparasitario: deserializeParam(
          data['antiparasitario'],
          ParamType.String,
          false,
        ),
        antiparasitarioOutros: deserializeParam(
          data['antiparasitario_outros'],
          ParamType.String,
          false,
        ),
        antiparasitarioObs: deserializeParam(
          data['antiparasitario_obs'],
          ParamType.String,
          false,
        ),
        tratamento: deserializeParam(
          data['tratamento'],
          ParamType.String,
          false,
        ),
        tratamentoOutros: deserializeParam(
          data['tratamento_outros'],
          ParamType.String,
          false,
        ),
        tratamentoObs: deserializeParam(
          data['tratamento_obs'],
          ParamType.String,
          false,
        ),
        protocoloReprodutivo: deserializeParam(
          data['protocolo_reprodutivo'],
          ParamType.String,
          false,
        ),
        protocoloReprodutivoOutros: deserializeParam(
          data['protocolo_reprodutivo_outros'],
          ParamType.String,
          false,
        ),
        protocoloReprodutivoObs: deserializeParam(
          data['protocolo_reprodutivo_obs'],
          ParamType.String,
          false,
        ),
        protocoloD0: deserializeParam(
          data['protocolo_d0'],
          ParamType.String,
          false,
        ),
        protocoloRetirada: deserializeParam(
          data['protocolo_retirada'],
          ParamType.String,
          false,
        ),
        protocoloIatf: deserializeParam(
          data['protocolo_iatf'],
          ParamType.String,
          false,
        ),
        numeroAnimal: deserializeParam(
          data['numeroAnimal'],
          ParamType.String,
          false,
        ),
        nome: deserializeParam(
          data['nome'],
          ParamType.String,
          false,
        ),
        chip: deserializeParam(
          data['chip'],
          ParamType.String,
          false,
        ),
        dataNascimento: deserializeParam(
          data['dataNascimento'],
          ParamType.String,
          false,
        ),
        sexo: deserializeParam(
          data['sexo'],
          ParamType.String,
          false,
        ),
        raca: deserializeParam(
          data['raca'],
          ParamType.String,
          false,
        ),
        categoria: deserializeParam(
          data['categoria'],
          ParamType.String,
          false,
        ),
        loteNome: deserializeParam(
          data['loteNome'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'SanidadeStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is SanidadeStruct &&
        id == other.id &&
        createdAt == other.createdAt &&
        idPropriedade == other.idPropriedade &&
        idRebanho == other.idRebanho &&
        dataSanidade == other.dataSanidade &&
        idLote == other.idLote &&
        porcentagemLote == other.porcentagemLote &&
        idSanidade == other.idSanidade &&
        updatedAt == other.updatedAt &&
        deletado == other.deletado &&
        vacinacao == other.vacinacao &&
        vacinacaoOutros == other.vacinacaoOutros &&
        vacinacaoObs == other.vacinacaoObs &&
        antiparasitario == other.antiparasitario &&
        antiparasitarioOutros == other.antiparasitarioOutros &&
        antiparasitarioObs == other.antiparasitarioObs &&
        tratamento == other.tratamento &&
        tratamentoOutros == other.tratamentoOutros &&
        tratamentoObs == other.tratamentoObs &&
        protocoloReprodutivo == other.protocoloReprodutivo &&
        protocoloReprodutivoOutros == other.protocoloReprodutivoOutros &&
        protocoloReprodutivoObs == other.protocoloReprodutivoObs &&
          protocoloD0 == other.protocoloD0 &&
          protocoloRetirada == other.protocoloRetirada &&
          protocoloIatf == other.protocoloIatf &&
        numeroAnimal == other.numeroAnimal &&
        nome == other.nome &&
        chip == other.chip &&
        dataNascimento == other.dataNascimento &&
        sexo == other.sexo &&
        raca == other.raca &&
        categoria == other.categoria &&
        loteNome == other.loteNome;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        createdAt,
        idPropriedade,
        idRebanho,
        dataSanidade,
        idLote,
        porcentagemLote,
        idSanidade,
        updatedAt,
        deletado,
        vacinacao,
        vacinacaoOutros,
        vacinacaoObs,
        antiparasitario,
        antiparasitarioOutros,
        antiparasitarioObs,
        tratamento,
        tratamentoOutros,
        tratamentoObs,
        protocoloReprodutivo,
        protocoloReprodutivoOutros,
        protocoloReprodutivoObs,
        protocoloD0,
        protocoloRetirada,
        protocoloIatf,
        numeroAnimal,
        nome,
        chip,
        dataNascimento,
        sexo,
        raca,
        categoria,
        loteNome
      ]);
}

SanidadeStruct createSanidadeStruct({
  int? id,
  String? createdAt,
  String? idPropriedade,
  String? idRebanho,
  String? dataSanidade,
  String? idLote,
  String? porcentagemLote,
  String? idSanidade,
  String? updatedAt,
  String? deletado,
  String? vacinacao,
  String? vacinacaoOutros,
  String? vacinacaoObs,
  String? antiparasitario,
  String? antiparasitarioOutros,
  String? antiparasitarioObs,
  String? tratamento,
  String? tratamentoOutros,
  String? tratamentoObs,
  String? protocoloReprodutivo,
  String? protocoloReprodutivoOutros,
  String? protocoloReprodutivoObs,
  String? protocoloD0,
  String? protocoloRetirada,
  String? protocoloIatf,
  String? numeroAnimal,
  String? nome,
  String? chip,
  String? dataNascimento,
  String? sexo,
  String? raca,
  String? categoria,
  String? loteNome,
}) =>
    SanidadeStruct(
      id: id,
      createdAt: createdAt,
      idPropriedade: idPropriedade,
      idRebanho: idRebanho,
      dataSanidade: dataSanidade,
      idLote: idLote,
      porcentagemLote: porcentagemLote,
      idSanidade: idSanidade,
      updatedAt: updatedAt,
      deletado: deletado,
      vacinacao: vacinacao,
      vacinacaoOutros: vacinacaoOutros,
      vacinacaoObs: vacinacaoObs,
      antiparasitario: antiparasitario,
      antiparasitarioOutros: antiparasitarioOutros,
      antiparasitarioObs: antiparasitarioObs,
      tratamento: tratamento,
      tratamentoOutros: tratamentoOutros,
      tratamentoObs: tratamentoObs,
      protocoloReprodutivo: protocoloReprodutivo,
      protocoloReprodutivoOutros: protocoloReprodutivoOutros,
      protocoloReprodutivoObs: protocoloReprodutivoObs,
      protocoloD0: protocoloD0,
      protocoloRetirada: protocoloRetirada,
      protocoloIatf: protocoloIatf,
      numeroAnimal: numeroAnimal,
      nome: nome,
      chip: chip,
      dataNascimento: dataNascimento,
      sexo: sexo,
      raca: raca,
      categoria: categoria,
      loteNome: loteNome,
    );
