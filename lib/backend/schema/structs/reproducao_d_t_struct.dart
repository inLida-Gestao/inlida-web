// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ReproducaoDTStruct extends BaseStruct {
  ReproducaoDTStruct({
    int? id,
    String? createdAt,
    String? updatedAt,
    String? idPropriedade,
    String? tipoReproducao,
    String? idRebanhoMatriz,
    double? scoreCorporal,
    String? idRebanhoReprodutor,
    String? dataInseminacao,
    String? dataPartidaSemen,
    int? partidaSemen,
    String? previsaoParto,
    String? idLote,
    String? dataInicial,
    String? dataFinal,
    String? statusReproducao,
    String? inseminador,
    String? anotacoes,
    String? idReproducao,
    String? deletado,
    String? categoria,
    String? numMatriz,
    String? nomeMatriz,
    String? nascimentoMatriz,
    String? numReprodutor,
    String? nomeReprodutor,
    String? nascimentoReprodutor,
    String? loteNome,
    String? dataStatus,
    String? matrizNumeroanimal,
    String? matrizChip,
    String? matrizNome,
    String? matrizDatanascimento,
    String? reprodutorNumeroanimal,
    String? reprodutorChip,
    String? reprodutorNome,
    String? reprodutorDatanascimento,
    String? ressinc,
    String? parida,
    String? dataParto,
  })  : _id = id,
        _createdAt = createdAt,
        _updatedAt = updatedAt,
        _idPropriedade = idPropriedade,
        _tipoReproducao = tipoReproducao,
        _idRebanhoMatriz = idRebanhoMatriz,
        _scoreCorporal = scoreCorporal,
        _idRebanhoReprodutor = idRebanhoReprodutor,
        _dataInseminacao = dataInseminacao,
        _dataPartidaSemen = dataPartidaSemen,
        _partidaSemen = partidaSemen,
        _previsaoParto = previsaoParto,
        _idLote = idLote,
        _dataInicial = dataInicial,
        _dataFinal = dataFinal,
        _statusReproducao = statusReproducao,
        _inseminador = inseminador,
        _anotacoes = anotacoes,
        _idReproducao = idReproducao,
        _deletado = deletado,
        _categoria = categoria,
        _numMatriz = numMatriz,
        _nomeMatriz = nomeMatriz,
        _nascimentoMatriz = nascimentoMatriz,
        _numReprodutor = numReprodutor,
        _nomeReprodutor = nomeReprodutor,
        _nascimentoReprodutor = nascimentoReprodutor,
        _loteNome = loteNome,
        _dataStatus = dataStatus,
        _matrizNumeroanimal = matrizNumeroanimal,
        _matrizChip = matrizChip,
        _matrizNome = matrizNome,
        _matrizDatanascimento = matrizDatanascimento,
        _reprodutorNumeroanimal = reprodutorNumeroanimal,
        _reprodutorChip = reprodutorChip,
        _reprodutorNome = reprodutorNome,
        _reprodutorDatanascimento = reprodutorDatanascimento,
        _ressinc = ressinc,
        _parida = parida,
        _dataParto = dataParto;

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

  // "updated_at" field.
  String? _updatedAt;
  String get updatedAt => _updatedAt ?? '';
  set updatedAt(String? val) => _updatedAt = val;

  bool hasUpdatedAt() => _updatedAt != null;

  // "id_propriedade" field.
  String? _idPropriedade;
  String get idPropriedade => _idPropriedade ?? '';
  set idPropriedade(String? val) => _idPropriedade = val;

  bool hasIdPropriedade() => _idPropriedade != null;

  // "tipo_reproducao" field.
  String? _tipoReproducao;
  String get tipoReproducao => _tipoReproducao ?? '';
  set tipoReproducao(String? val) => _tipoReproducao = val;

  bool hasTipoReproducao() => _tipoReproducao != null;

  // "id_rebanho_matriz" field.
  String? _idRebanhoMatriz;
  String get idRebanhoMatriz => _idRebanhoMatriz ?? '';
  set idRebanhoMatriz(String? val) => _idRebanhoMatriz = val;

  bool hasIdRebanhoMatriz() => _idRebanhoMatriz != null;

  // "score_corporal" field.
  double? _scoreCorporal;
  double get scoreCorporal => _scoreCorporal ?? 0.0;
  set scoreCorporal(double? val) => _scoreCorporal = val;

  void incrementScoreCorporal(double amount) =>
      scoreCorporal = scoreCorporal + amount;

  bool hasScoreCorporal() => _scoreCorporal != null;

  // "id_rebanho_reprodutor" field.
  String? _idRebanhoReprodutor;
  String get idRebanhoReprodutor => _idRebanhoReprodutor ?? '';
  set idRebanhoReprodutor(String? val) => _idRebanhoReprodutor = val;

  bool hasIdRebanhoReprodutor() => _idRebanhoReprodutor != null;

  // "data_inseminacao" field.
  String? _dataInseminacao;
  String get dataInseminacao => _dataInseminacao ?? '';
  set dataInseminacao(String? val) => _dataInseminacao = val;

  bool hasDataInseminacao() => _dataInseminacao != null;

  // "data_partida_semen" field.
  String? _dataPartidaSemen;
  String get dataPartidaSemen => _dataPartidaSemen ?? '';
  set dataPartidaSemen(String? val) => _dataPartidaSemen = val;

  bool hasDataPartidaSemen() => _dataPartidaSemen != null;

  // "partida_semen" field.
  int? _partidaSemen;
  int get partidaSemen => _partidaSemen ?? 0;
  set partidaSemen(int? val) => _partidaSemen = val;

  void incrementPartidaSemen(int amount) =>
      partidaSemen = partidaSemen + amount;

  bool hasPartidaSemen() => _partidaSemen != null;

  // "previsao_parto" field.
  String? _previsaoParto;
  String get previsaoParto => _previsaoParto ?? '';
  set previsaoParto(String? val) => _previsaoParto = val;

  bool hasPrevisaoParto() => _previsaoParto != null;

  // "id_lote" field.
  String? _idLote;
  String get idLote => _idLote ?? '';
  set idLote(String? val) => _idLote = val;

  bool hasIdLote() => _idLote != null;

  // "data_inicial" field.
  String? _dataInicial;
  String get dataInicial => _dataInicial ?? '';
  set dataInicial(String? val) => _dataInicial = val;

  bool hasDataInicial() => _dataInicial != null;

  // "data_final" field.
  String? _dataFinal;
  String get dataFinal => _dataFinal ?? '';
  set dataFinal(String? val) => _dataFinal = val;

  bool hasDataFinal() => _dataFinal != null;

  // "status_reproducao" field.
  String? _statusReproducao;
  String get statusReproducao => _statusReproducao ?? '';
  set statusReproducao(String? val) => _statusReproducao = val;

  bool hasStatusReproducao() => _statusReproducao != null;

  // "inseminador" field.
  String? _inseminador;
  String get inseminador => _inseminador ?? '';
  set inseminador(String? val) => _inseminador = val;

  bool hasInseminador() => _inseminador != null;

  // "anotacoes" field.
  String? _anotacoes;
  String get anotacoes => _anotacoes ?? '';
  set anotacoes(String? val) => _anotacoes = val;

  bool hasAnotacoes() => _anotacoes != null;

  // "id_reproducao" field.
  String? _idReproducao;
  String get idReproducao => _idReproducao ?? '';
  set idReproducao(String? val) => _idReproducao = val;

  bool hasIdReproducao() => _idReproducao != null;

  // "deletado" field.
  String? _deletado;
  String get deletado => _deletado ?? '';
  set deletado(String? val) => _deletado = val;

  bool hasDeletado() => _deletado != null;

  // "categoria" field.
  String? _categoria;
  String get categoria => _categoria ?? '';
  set categoria(String? val) => _categoria = val;

  bool hasCategoria() => _categoria != null;

  // "numMatriz" field.
  String? _numMatriz;
  String get numMatriz => _numMatriz ?? '';
  set numMatriz(String? val) => _numMatriz = val;

  bool hasNumMatriz() => _numMatriz != null;

  // "nomeMatriz" field.
  String? _nomeMatriz;
  String get nomeMatriz => _nomeMatriz ?? '';
  set nomeMatriz(String? val) => _nomeMatriz = val;

  bool hasNomeMatriz() => _nomeMatriz != null;

  // "nascimentoMatriz" field.
  String? _nascimentoMatriz;
  String get nascimentoMatriz => _nascimentoMatriz ?? '';
  set nascimentoMatriz(String? val) => _nascimentoMatriz = val;

  bool hasNascimentoMatriz() => _nascimentoMatriz != null;

  // "numReprodutor" field.
  String? _numReprodutor;
  String get numReprodutor => _numReprodutor ?? '';
  set numReprodutor(String? val) => _numReprodutor = val;

  bool hasNumReprodutor() => _numReprodutor != null;

  // "nomeReprodutor" field.
  String? _nomeReprodutor;
  String get nomeReprodutor => _nomeReprodutor ?? '';
  set nomeReprodutor(String? val) => _nomeReprodutor = val;

  bool hasNomeReprodutor() => _nomeReprodutor != null;

  // "nascimentoReprodutor" field.
  String? _nascimentoReprodutor;
  String get nascimentoReprodutor => _nascimentoReprodutor ?? '';
  set nascimentoReprodutor(String? val) => _nascimentoReprodutor = val;

  bool hasNascimentoReprodutor() => _nascimentoReprodutor != null;

  // "loteNome" field.
  String? _loteNome;
  String get loteNome => _loteNome ?? '';
  set loteNome(String? val) => _loteNome = val;

  bool hasLoteNome() => _loteNome != null;

  // "data_status" field.
  String? _dataStatus;
  String get dataStatus => _dataStatus ?? '';
  set dataStatus(String? val) => _dataStatus = val;

  bool hasDataStatus() => _dataStatus != null;

  // "matriz_numeroanimal" field.
  String? _matrizNumeroanimal;
  String get matrizNumeroanimal => _matrizNumeroanimal ?? '';
  set matrizNumeroanimal(String? val) => _matrizNumeroanimal = val;

  bool hasMatrizNumeroanimal() => _matrizNumeroanimal != null;

  // "matriz_chip" field.
  String? _matrizChip;
  String get matrizChip => _matrizChip ?? '';
  set matrizChip(String? val) => _matrizChip = val;

  bool hasMatrizChip() => _matrizChip != null;

  // "matriz_nome" field.
  String? _matrizNome;
  String get matrizNome => _matrizNome ?? '';
  set matrizNome(String? val) => _matrizNome = val;

  bool hasMatrizNome() => _matrizNome != null;

  // "matriz_datanascimento" field.
  String? _matrizDatanascimento;
  String get matrizDatanascimento => _matrizDatanascimento ?? '';
  set matrizDatanascimento(String? val) => _matrizDatanascimento = val;

  bool hasMatrizDatanascimento() => _matrizDatanascimento != null;

  // "reprodutor_numeroanimal" field.
  String? _reprodutorNumeroanimal;
  String get reprodutorNumeroanimal => _reprodutorNumeroanimal ?? '';
  set reprodutorNumeroanimal(String? val) => _reprodutorNumeroanimal = val;

  bool hasReprodutorNumeroanimal() => _reprodutorNumeroanimal != null;

  // "reprodutor_chip" field.
  String? _reprodutorChip;
  String get reprodutorChip => _reprodutorChip ?? '';
  set reprodutorChip(String? val) => _reprodutorChip = val;

  bool hasReprodutorChip() => _reprodutorChip != null;

  // "reprodutor_nome" field.
  String? _reprodutorNome;
  String get reprodutorNome => _reprodutorNome ?? '';
  set reprodutorNome(String? val) => _reprodutorNome = val;

  bool hasReprodutorNome() => _reprodutorNome != null;

  // "reprodutor_datanascimento" field.
  String? _reprodutorDatanascimento;
  String get reprodutorDatanascimento => _reprodutorDatanascimento ?? '';
  set reprodutorDatanascimento(String? val) => _reprodutorDatanascimento = val;

  bool hasReprodutorDatanascimento() => _reprodutorDatanascimento != null;

  // "ressinc" field.
  String? _ressinc;
  String get ressinc => _ressinc ?? '';
  set ressinc(String? val) => _ressinc = val;

  bool hasRessinc() => _ressinc != null;

  // "parida" field.
  String? _parida;
  String get parida => _parida ?? '';
  set parida(String? val) => _parida = val;

  bool hasParida() => _parida != null;

  // "data_parto" field.
  String? _dataParto;
  String get dataParto => _dataParto ?? '';
  set dataParto(String? val) => _dataParto = val;

  bool hasDataParto() => _dataParto != null;

  static ReproducaoDTStruct fromMap(Map<String, dynamic> data) =>
      ReproducaoDTStruct(
        id: castToType<int>(data['id']),
        createdAt: data['created_at'] as String?,
        updatedAt: data['updated_at'] as String?,
        idPropriedade: data['id_propriedade'] as String?,
        tipoReproducao: data['tipo_reproducao'] as String?,
        idRebanhoMatriz: data['id_rebanho_matriz'] as String?,
        scoreCorporal: castToType<double>(data['score_corporal']),
        idRebanhoReprodutor: data['id_rebanho_reprodutor'] as String?,
        dataInseminacao: data['data_inseminacao'] as String?,
        dataPartidaSemen: data['data_partida_semen'] as String?,
        partidaSemen: castToType<int>(data['partida_semen']),
        previsaoParto: data['previsao_parto'] as String?,
        idLote: data['id_lote'] as String?,
        dataInicial: data['data_inicial'] as String?,
        dataFinal: data['data_final'] as String?,
        statusReproducao: data['status_reproducao'] as String?,
        inseminador: data['inseminador'] as String?,
        anotacoes: data['anotacoes'] as String?,
        idReproducao: data['id_reproducao'] as String?,
        deletado: data['deletado'] as String?,
        categoria: data['categoria'] as String?,
        numMatriz: data['numMatriz'] as String?,
        nomeMatriz: data['nomeMatriz'] as String?,
        nascimentoMatriz: data['nascimentoMatriz'] as String?,
        numReprodutor: data['numReprodutor'] as String?,
        nomeReprodutor: data['nomeReprodutor'] as String?,
        nascimentoReprodutor: data['nascimentoReprodutor'] as String?,
        loteNome: data['loteNome'] as String?,
        dataStatus: data['data_status'] as String?,
        matrizNumeroanimal: data['matriz_numeroanimal'] as String?,
        matrizChip: data['matriz_chip'] as String?,
        matrizNome: data['matriz_nome'] as String?,
        matrizDatanascimento: data['matriz_datanascimento'] as String?,
        reprodutorNumeroanimal: data['reprodutor_numeroanimal'] as String?,
        reprodutorChip: data['reprodutor_chip'] as String?,
        reprodutorNome: data['reprodutor_nome'] as String?,
        reprodutorDatanascimento: data['reprodutor_datanascimento'] as String?,
        ressinc: data['ressinc'] as String?,
        parida: data['parida'] as String?,
        dataParto: data['data_parto'] as String?,
      );

  static ReproducaoDTStruct? maybeFromMap(dynamic data) => data is Map
      ? ReproducaoDTStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'created_at': _createdAt,
        'updated_at': _updatedAt,
        'id_propriedade': _idPropriedade,
        'tipo_reproducao': _tipoReproducao,
        'id_rebanho_matriz': _idRebanhoMatriz,
        'score_corporal': _scoreCorporal,
        'id_rebanho_reprodutor': _idRebanhoReprodutor,
        'data_inseminacao': _dataInseminacao,
        'data_partida_semen': _dataPartidaSemen,
        'partida_semen': _partidaSemen,
        'previsao_parto': _previsaoParto,
        'id_lote': _idLote,
        'data_inicial': _dataInicial,
        'data_final': _dataFinal,
        'status_reproducao': _statusReproducao,
        'inseminador': _inseminador,
        'anotacoes': _anotacoes,
        'id_reproducao': _idReproducao,
        'deletado': _deletado,
        'categoria': _categoria,
        'numMatriz': _numMatriz,
        'nomeMatriz': _nomeMatriz,
        'nascimentoMatriz': _nascimentoMatriz,
        'numReprodutor': _numReprodutor,
        'nomeReprodutor': _nomeReprodutor,
        'nascimentoReprodutor': _nascimentoReprodutor,
        'loteNome': _loteNome,
        'data_status': _dataStatus,
        'matriz_numeroanimal': _matrizNumeroanimal,
        'matriz_chip': _matrizChip,
        'matriz_nome': _matrizNome,
        'matriz_datanascimento': _matrizDatanascimento,
        'reprodutor_numeroanimal': _reprodutorNumeroanimal,
        'reprodutor_chip': _reprodutorChip,
        'reprodutor_nome': _reprodutorNome,
        'reprodutor_datanascimento': _reprodutorDatanascimento,
        'ressinc': _ressinc,
        'parida': _parida,
        'data_parto': _dataParto,
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
        'updated_at': serializeParam(
          _updatedAt,
          ParamType.String,
        ),
        'id_propriedade': serializeParam(
          _idPropriedade,
          ParamType.String,
        ),
        'tipo_reproducao': serializeParam(
          _tipoReproducao,
          ParamType.String,
        ),
        'id_rebanho_matriz': serializeParam(
          _idRebanhoMatriz,
          ParamType.String,
        ),
        'score_corporal': serializeParam(
          _scoreCorporal,
          ParamType.double,
        ),
        'id_rebanho_reprodutor': serializeParam(
          _idRebanhoReprodutor,
          ParamType.String,
        ),
        'data_inseminacao': serializeParam(
          _dataInseminacao,
          ParamType.String,
        ),
        'data_partida_semen': serializeParam(
          _dataPartidaSemen,
          ParamType.String,
        ),
        'partida_semen': serializeParam(
          _partidaSemen,
          ParamType.int,
        ),
        'previsao_parto': serializeParam(
          _previsaoParto,
          ParamType.String,
        ),
        'id_lote': serializeParam(
          _idLote,
          ParamType.String,
        ),
        'data_inicial': serializeParam(
          _dataInicial,
          ParamType.String,
        ),
        'data_final': serializeParam(
          _dataFinal,
          ParamType.String,
        ),
        'status_reproducao': serializeParam(
          _statusReproducao,
          ParamType.String,
        ),
        'inseminador': serializeParam(
          _inseminador,
          ParamType.String,
        ),
        'anotacoes': serializeParam(
          _anotacoes,
          ParamType.String,
        ),
        'id_reproducao': serializeParam(
          _idReproducao,
          ParamType.String,
        ),
        'deletado': serializeParam(
          _deletado,
          ParamType.String,
        ),
        'categoria': serializeParam(
          _categoria,
          ParamType.String,
        ),
        'numMatriz': serializeParam(
          _numMatriz,
          ParamType.String,
        ),
        'nomeMatriz': serializeParam(
          _nomeMatriz,
          ParamType.String,
        ),
        'nascimentoMatriz': serializeParam(
          _nascimentoMatriz,
          ParamType.String,
        ),
        'numReprodutor': serializeParam(
          _numReprodutor,
          ParamType.String,
        ),
        'nomeReprodutor': serializeParam(
          _nomeReprodutor,
          ParamType.String,
        ),
        'nascimentoReprodutor': serializeParam(
          _nascimentoReprodutor,
          ParamType.String,
        ),
        'loteNome': serializeParam(
          _loteNome,
          ParamType.String,
        ),
        'data_status': serializeParam(
          _dataStatus,
          ParamType.String,
        ),
        'matriz_numeroanimal': serializeParam(
          _matrizNumeroanimal,
          ParamType.String,
        ),
        'matriz_chip': serializeParam(
          _matrizChip,
          ParamType.String,
        ),
        'matriz_nome': serializeParam(
          _matrizNome,
          ParamType.String,
        ),
        'matriz_datanascimento': serializeParam(
          _matrizDatanascimento,
          ParamType.String,
        ),
        'reprodutor_numeroanimal': serializeParam(
          _reprodutorNumeroanimal,
          ParamType.String,
        ),
        'reprodutor_chip': serializeParam(
          _reprodutorChip,
          ParamType.String,
        ),
        'reprodutor_nome': serializeParam(
          _reprodutorNome,
          ParamType.String,
        ),
        'reprodutor_datanascimento': serializeParam(
          _reprodutorDatanascimento,
          ParamType.String,
        ),
        'ressinc': serializeParam(
          _ressinc,
          ParamType.String,
        ),
        'parida': serializeParam(
          _parida,
          ParamType.String,
        ),
        'data_parto': serializeParam(
          _dataParto,
          ParamType.String,
        ),
      }.withoutNulls;

  static ReproducaoDTStruct fromSerializableMap(Map<String, dynamic> data) =>
      ReproducaoDTStruct(
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
        updatedAt: deserializeParam(
          data['updated_at'],
          ParamType.String,
          false,
        ),
        idPropriedade: deserializeParam(
          data['id_propriedade'],
          ParamType.String,
          false,
        ),
        tipoReproducao: deserializeParam(
          data['tipo_reproducao'],
          ParamType.String,
          false,
        ),
        idRebanhoMatriz: deserializeParam(
          data['id_rebanho_matriz'],
          ParamType.String,
          false,
        ),
        scoreCorporal: deserializeParam(
          data['score_corporal'],
          ParamType.double,
          false,
        ),
        idRebanhoReprodutor: deserializeParam(
          data['id_rebanho_reprodutor'],
          ParamType.String,
          false,
        ),
        dataInseminacao: deserializeParam(
          data['data_inseminacao'],
          ParamType.String,
          false,
        ),
        dataPartidaSemen: deserializeParam(
          data['data_partida_semen'],
          ParamType.String,
          false,
        ),
        partidaSemen: deserializeParam(
          data['partida_semen'],
          ParamType.int,
          false,
        ),
        previsaoParto: deserializeParam(
          data['previsao_parto'],
          ParamType.String,
          false,
        ),
        idLote: deserializeParam(
          data['id_lote'],
          ParamType.String,
          false,
        ),
        dataInicial: deserializeParam(
          data['data_inicial'],
          ParamType.String,
          false,
        ),
        dataFinal: deserializeParam(
          data['data_final'],
          ParamType.String,
          false,
        ),
        statusReproducao: deserializeParam(
          data['status_reproducao'],
          ParamType.String,
          false,
        ),
        inseminador: deserializeParam(
          data['inseminador'],
          ParamType.String,
          false,
        ),
        anotacoes: deserializeParam(
          data['anotacoes'],
          ParamType.String,
          false,
        ),
        idReproducao: deserializeParam(
          data['id_reproducao'],
          ParamType.String,
          false,
        ),
        deletado: deserializeParam(
          data['deletado'],
          ParamType.String,
          false,
        ),
        categoria: deserializeParam(
          data['categoria'],
          ParamType.String,
          false,
        ),
        numMatriz: deserializeParam(
          data['numMatriz'],
          ParamType.String,
          false,
        ),
        nomeMatriz: deserializeParam(
          data['nomeMatriz'],
          ParamType.String,
          false,
        ),
        nascimentoMatriz: deserializeParam(
          data['nascimentoMatriz'],
          ParamType.String,
          false,
        ),
        numReprodutor: deserializeParam(
          data['numReprodutor'],
          ParamType.String,
          false,
        ),
        nomeReprodutor: deserializeParam(
          data['nomeReprodutor'],
          ParamType.String,
          false,
        ),
        nascimentoReprodutor: deserializeParam(
          data['nascimentoReprodutor'],
          ParamType.String,
          false,
        ),
        loteNome: deserializeParam(
          data['loteNome'],
          ParamType.String,
          false,
        ),
        dataStatus: deserializeParam(
          data['data_status'],
          ParamType.String,
          false,
        ),
        matrizNumeroanimal: deserializeParam(
          data['matriz_numeroanimal'],
          ParamType.String,
          false,
        ),
        matrizChip: deserializeParam(
          data['matriz_chip'],
          ParamType.String,
          false,
        ),
        matrizNome: deserializeParam(
          data['matriz_nome'],
          ParamType.String,
          false,
        ),
        matrizDatanascimento: deserializeParam(
          data['matriz_datanascimento'],
          ParamType.String,
          false,
        ),
        reprodutorNumeroanimal: deserializeParam(
          data['reprodutor_numeroanimal'],
          ParamType.String,
          false,
        ),
        reprodutorChip: deserializeParam(
          data['reprodutor_chip'],
          ParamType.String,
          false,
        ),
        reprodutorNome: deserializeParam(
          data['reprodutor_nome'],
          ParamType.String,
          false,
        ),
        reprodutorDatanascimento: deserializeParam(
          data['reprodutor_datanascimento'],
          ParamType.String,
          false,
        ),
        ressinc: deserializeParam(
          data['ressinc'],
          ParamType.String,
          false,
        ),
        parida: deserializeParam(
          data['parida'],
          ParamType.String,
          false,
        ),
        dataParto: deserializeParam(
          data['data_parto'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'ReproducaoDTStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ReproducaoDTStruct &&
        id == other.id &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        idPropriedade == other.idPropriedade &&
        tipoReproducao == other.tipoReproducao &&
        idRebanhoMatriz == other.idRebanhoMatriz &&
        scoreCorporal == other.scoreCorporal &&
        idRebanhoReprodutor == other.idRebanhoReprodutor &&
        dataInseminacao == other.dataInseminacao &&
        dataPartidaSemen == other.dataPartidaSemen &&
        partidaSemen == other.partidaSemen &&
        previsaoParto == other.previsaoParto &&
        idLote == other.idLote &&
        dataInicial == other.dataInicial &&
        dataFinal == other.dataFinal &&
        statusReproducao == other.statusReproducao &&
        inseminador == other.inseminador &&
        anotacoes == other.anotacoes &&
        idReproducao == other.idReproducao &&
        deletado == other.deletado &&
        categoria == other.categoria &&
        numMatriz == other.numMatriz &&
        nomeMatriz == other.nomeMatriz &&
        nascimentoMatriz == other.nascimentoMatriz &&
        numReprodutor == other.numReprodutor &&
        nomeReprodutor == other.nomeReprodutor &&
        nascimentoReprodutor == other.nascimentoReprodutor &&
        loteNome == other.loteNome &&
        dataStatus == other.dataStatus &&
        matrizNumeroanimal == other.matrizNumeroanimal &&
        matrizChip == other.matrizChip &&
        matrizNome == other.matrizNome &&
        matrizDatanascimento == other.matrizDatanascimento &&
        reprodutorNumeroanimal == other.reprodutorNumeroanimal &&
        reprodutorChip == other.reprodutorChip &&
        reprodutorNome == other.reprodutorNome &&
        reprodutorDatanascimento == other.reprodutorDatanascimento &&
        ressinc == other.ressinc &&
        parida == other.parida &&
        dataParto == other.dataParto;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        createdAt,
        updatedAt,
        idPropriedade,
        tipoReproducao,
        idRebanhoMatriz,
        scoreCorporal,
        idRebanhoReprodutor,
        dataInseminacao,
        dataPartidaSemen,
        partidaSemen,
        previsaoParto,
        idLote,
        dataInicial,
        dataFinal,
        statusReproducao,
        inseminador,
        anotacoes,
        idReproducao,
        deletado,
        categoria,
        numMatriz,
        nomeMatriz,
        nascimentoMatriz,
        numReprodutor,
        nomeReprodutor,
        nascimentoReprodutor,
        loteNome,
        dataStatus,
        matrizNumeroanimal,
        matrizChip,
        matrizNome,
        matrizDatanascimento,
        reprodutorNumeroanimal,
        reprodutorChip,
        reprodutorNome,
        reprodutorDatanascimento,
        ressinc,
        parida,
        dataParto
      ]);
}

ReproducaoDTStruct createReproducaoDTStruct({
  int? id,
  String? createdAt,
  String? updatedAt,
  String? idPropriedade,
  String? tipoReproducao,
  String? idRebanhoMatriz,
  double? scoreCorporal,
  String? idRebanhoReprodutor,
  String? dataInseminacao,
  String? dataPartidaSemen,
  int? partidaSemen,
  String? previsaoParto,
  String? idLote,
  String? dataInicial,
  String? dataFinal,
  String? statusReproducao,
  String? inseminador,
  String? anotacoes,
  String? idReproducao,
  String? deletado,
  String? categoria,
  String? numMatriz,
  String? nomeMatriz,
  String? nascimentoMatriz,
  String? numReprodutor,
  String? nomeReprodutor,
  String? nascimentoReprodutor,
  String? loteNome,
  String? dataStatus,
  String? matrizNumeroanimal,
  String? matrizChip,
  String? matrizNome,
  String? matrizDatanascimento,
  String? reprodutorNumeroanimal,
  String? reprodutorChip,
  String? reprodutorNome,
  String? reprodutorDatanascimento,
  String? ressinc,
  String? parida,
  String? dataParto,
}) =>
    ReproducaoDTStruct(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      idPropriedade: idPropriedade,
      tipoReproducao: tipoReproducao,
      idRebanhoMatriz: idRebanhoMatriz,
      scoreCorporal: scoreCorporal,
      idRebanhoReprodutor: idRebanhoReprodutor,
      dataInseminacao: dataInseminacao,
      dataPartidaSemen: dataPartidaSemen,
      partidaSemen: partidaSemen,
      previsaoParto: previsaoParto,
      idLote: idLote,
      dataInicial: dataInicial,
      dataFinal: dataFinal,
      statusReproducao: statusReproducao,
      inseminador: inseminador,
      anotacoes: anotacoes,
      idReproducao: idReproducao,
      deletado: deletado,
      categoria: categoria,
      numMatriz: numMatriz,
      nomeMatriz: nomeMatriz,
      nascimentoMatriz: nascimentoMatriz,
      numReprodutor: numReprodutor,
      nomeReprodutor: nomeReprodutor,
      nascimentoReprodutor: nascimentoReprodutor,
      loteNome: loteNome,
      dataStatus: dataStatus,
      matrizNumeroanimal: matrizNumeroanimal,
      matrizChip: matrizChip,
      matrizNome: matrizNome,
      matrizDatanascimento: matrizDatanascimento,
      reprodutorNumeroanimal: reprodutorNumeroanimal,
      reprodutorChip: reprodutorChip,
      reprodutorNome: reprodutorNome,
      reprodutorDatanascimento: reprodutorDatanascimento,
      ressinc: ressinc,
      parida: parida,
      dataParto: dataParto,
    );
