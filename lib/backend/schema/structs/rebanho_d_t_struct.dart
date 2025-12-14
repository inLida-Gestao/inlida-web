// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RebanhoDTStruct extends BaseStruct {
  RebanhoDTStruct({
    int? id,
    String? createdAt,
    String? idPropriedade,
    String? numeroAnimal,
    String? chip,
    String? codRegistro,
    String? nome,
    String? sexo,
    String? categoria,
    String? dataNascimento,
    double? pesoNascimento,
    String? porte,
    String? raca,
    String? loteID,
    String? dataEntradaLote,
    String? rebanhoIdMatriz,
    String? rebanhoIdReprodutor,
    String? dataDesmama,
    double? pesoDesmama,
    double? pesoAtual,
    String? status,
    String? origem,
    String? anotacoes,
    String? idRebanho,
    String? deletado,
    String? updatedAt,
    String? loteNome,
    String? tipo,
    String? dataAcao,
    double? valorCompra,
    String? dataUltimaPesagem,
    String? nomeConcat,
    String? dataVenda,
    double? valorVenda,
  })  : _id = id,
        _createdAt = createdAt,
        _idPropriedade = idPropriedade,
        _numeroAnimal = numeroAnimal,
        _chip = chip,
        _codRegistro = codRegistro,
        _nome = nome,
        _sexo = sexo,
        _categoria = categoria,
        _dataNascimento = dataNascimento,
        _pesoNascimento = pesoNascimento,
        _porte = porte,
        _raca = raca,
        _loteID = loteID,
        _dataEntradaLote = dataEntradaLote,
        _rebanhoIdMatriz = rebanhoIdMatriz,
        _rebanhoIdReprodutor = rebanhoIdReprodutor,
        _dataDesmama = dataDesmama,
        _pesoDesmama = pesoDesmama,
        _pesoAtual = pesoAtual,
        _status = status,
        _origem = origem,
        _anotacoes = anotacoes,
        _idRebanho = idRebanho,
        _deletado = deletado,
        _updatedAt = updatedAt,
        _loteNome = loteNome,
        _tipo = tipo,
        _dataAcao = dataAcao,
        _valorCompra = valorCompra,
        _dataUltimaPesagem = dataUltimaPesagem,
        _nomeConcat = nomeConcat,
        _dataVenda = dataVenda,
        _valorVenda = valorVenda;

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

  // "idPropriedade" field.
  String? _idPropriedade;
  String get idPropriedade => _idPropriedade ?? '';
  set idPropriedade(String? val) => _idPropriedade = val;

  bool hasIdPropriedade() => _idPropriedade != null;

  // "numeroAnimal" field.
  String? _numeroAnimal;
  String get numeroAnimal => _numeroAnimal ?? '';
  set numeroAnimal(String? val) => _numeroAnimal = val;

  bool hasNumeroAnimal() => _numeroAnimal != null;

  // "chip" field.
  String? _chip;
  String get chip => _chip ?? '';
  set chip(String? val) => _chip = val;

  bool hasChip() => _chip != null;

  // "codRegistro" field.
  String? _codRegistro;
  String get codRegistro => _codRegistro ?? '';
  set codRegistro(String? val) => _codRegistro = val;

  bool hasCodRegistro() => _codRegistro != null;

  // "nome" field.
  String? _nome;
  String get nome => _nome ?? '';
  set nome(String? val) => _nome = val;

  bool hasNome() => _nome != null;

  // "sexo" field.
  String? _sexo;
  String get sexo => _sexo ?? '';
  set sexo(String? val) => _sexo = val;

  bool hasSexo() => _sexo != null;

  // "categoria" field.
  String? _categoria;
  String get categoria => _categoria ?? '';
  set categoria(String? val) => _categoria = val;

  bool hasCategoria() => _categoria != null;

  // "dataNascimento" field.
  String? _dataNascimento;
  String get dataNascimento => _dataNascimento ?? '';
  set dataNascimento(String? val) => _dataNascimento = val;

  bool hasDataNascimento() => _dataNascimento != null;

  // "pesoNascimento" field.
  double? _pesoNascimento;
  double get pesoNascimento => _pesoNascimento ?? 0.0;
  set pesoNascimento(double? val) => _pesoNascimento = val;

  void incrementPesoNascimento(double amount) =>
      pesoNascimento = pesoNascimento + amount;

  bool hasPesoNascimento() => _pesoNascimento != null;

  // "porte" field.
  String? _porte;
  String get porte => _porte ?? '';
  set porte(String? val) => _porte = val;

  bool hasPorte() => _porte != null;

  // "raca" field.
  String? _raca;
  String get raca => _raca ?? '';
  set raca(String? val) => _raca = val;

  bool hasRaca() => _raca != null;

  // "loteID" field.
  String? _loteID;
  String get loteID => _loteID ?? '';
  set loteID(String? val) => _loteID = val;

  bool hasLoteID() => _loteID != null;

  // "dataEntradaLote" field.
  String? _dataEntradaLote;
  String get dataEntradaLote => _dataEntradaLote ?? '';
  set dataEntradaLote(String? val) => _dataEntradaLote = val;

  bool hasDataEntradaLote() => _dataEntradaLote != null;

  // "rebanhoIdMatriz" field.
  String? _rebanhoIdMatriz;
  String get rebanhoIdMatriz => _rebanhoIdMatriz ?? '';
  set rebanhoIdMatriz(String? val) => _rebanhoIdMatriz = val;

  bool hasRebanhoIdMatriz() => _rebanhoIdMatriz != null;

  // "rebanhoIdReprodutor" field.
  String? _rebanhoIdReprodutor;
  String get rebanhoIdReprodutor => _rebanhoIdReprodutor ?? '';
  set rebanhoIdReprodutor(String? val) => _rebanhoIdReprodutor = val;

  bool hasRebanhoIdReprodutor() => _rebanhoIdReprodutor != null;

  // "dataDesmama" field.
  String? _dataDesmama;
  String get dataDesmama => _dataDesmama ?? '';
  set dataDesmama(String? val) => _dataDesmama = val;

  bool hasDataDesmama() => _dataDesmama != null;

  // "pesoDesmama" field.
  double? _pesoDesmama;
  double get pesoDesmama => _pesoDesmama ?? 0.0;
  set pesoDesmama(double? val) => _pesoDesmama = val;

  void incrementPesoDesmama(double amount) =>
      pesoDesmama = pesoDesmama + amount;

  bool hasPesoDesmama() => _pesoDesmama != null;

  // "pesoAtual" field.
  double? _pesoAtual;
  double get pesoAtual => _pesoAtual ?? 0.0;
  set pesoAtual(double? val) => _pesoAtual = val;

  void incrementPesoAtual(double amount) => pesoAtual = pesoAtual + amount;

  bool hasPesoAtual() => _pesoAtual != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  set status(String? val) => _status = val;

  bool hasStatus() => _status != null;

  // "origem" field.
  String? _origem;
  String get origem => _origem ?? '';
  set origem(String? val) => _origem = val;

  bool hasOrigem() => _origem != null;

  // "anotacoes" field.
  String? _anotacoes;
  String get anotacoes => _anotacoes ?? '';
  set anotacoes(String? val) => _anotacoes = val;

  bool hasAnotacoes() => _anotacoes != null;

  // "idRebanho" field.
  String? _idRebanho;
  String get idRebanho => _idRebanho ?? '';
  set idRebanho(String? val) => _idRebanho = val;

  bool hasIdRebanho() => _idRebanho != null;

  // "deletado" field.
  String? _deletado;
  String get deletado => _deletado ?? '';
  set deletado(String? val) => _deletado = val;

  bool hasDeletado() => _deletado != null;

  // "updated_at" field.
  String? _updatedAt;
  String get updatedAt => _updatedAt ?? '';
  set updatedAt(String? val) => _updatedAt = val;

  bool hasUpdatedAt() => _updatedAt != null;

  // "loteNome" field.
  String? _loteNome;
  String get loteNome => _loteNome ?? '';
  set loteNome(String? val) => _loteNome = val;

  bool hasLoteNome() => _loteNome != null;

  // "tipo" field.
  String? _tipo;
  String get tipo => _tipo ?? '';
  set tipo(String? val) => _tipo = val;

  bool hasTipo() => _tipo != null;

  // "dataAcao" field.
  String? _dataAcao;
  String get dataAcao => _dataAcao ?? '';
  set dataAcao(String? val) => _dataAcao = val;

  bool hasDataAcao() => _dataAcao != null;

  // "valorCompra" field.
  double? _valorCompra;
  double get valorCompra => _valorCompra ?? 0.0;
  set valorCompra(double? val) => _valorCompra = val;

  void incrementValorCompra(double amount) =>
      valorCompra = valorCompra + amount;

  bool hasValorCompra() => _valorCompra != null;

  // "dataUltimaPesagem" field.
  String? _dataUltimaPesagem;
  String get dataUltimaPesagem => _dataUltimaPesagem ?? '';
  set dataUltimaPesagem(String? val) => _dataUltimaPesagem = val;

  bool hasDataUltimaPesagem() => _dataUltimaPesagem != null;

  // "nomeConcat" field.
  String? _nomeConcat;
  String get nomeConcat => _nomeConcat ?? '';
  set nomeConcat(String? val) => _nomeConcat = val;

  bool hasNomeConcat() => _nomeConcat != null;

  // "dataVenda" field.
  String? _dataVenda;
  String get dataVenda => _dataVenda ?? '';
  set dataVenda(String? val) => _dataVenda = val;

  bool hasDataVenda() => _dataVenda != null;

  // "valorVenda" field.
  double? _valorVenda;
  double get valorVenda => _valorVenda ?? 0.0;
  set valorVenda(double? val) => _valorVenda = val;

  void incrementValorVenda(double amount) => valorVenda = valorVenda + amount;

  bool hasValorVenda() => _valorVenda != null;

  static RebanhoDTStruct fromMap(Map<String, dynamic> data) => RebanhoDTStruct(
        id: castToType<int>(data['id']),
        createdAt: data['created_at'] as String?,
        idPropriedade: data['idPropriedade'] as String?,
        numeroAnimal: data['numeroAnimal'] as String?,
        chip: data['chip'] as String?,
        codRegistro: data['codRegistro'] as String?,
        nome: data['nome'] as String?,
        sexo: data['sexo'] as String?,
        categoria: data['categoria'] as String?,
        dataNascimento: data['dataNascimento'] as String?,
        pesoNascimento: castToType<double>(data['pesoNascimento']),
        porte: data['porte'] as String?,
        raca: data['raca'] as String?,
        loteID: data['loteID'] as String?,
        dataEntradaLote: data['dataEntradaLote'] as String?,
        rebanhoIdMatriz: data['rebanhoIdMatriz'] as String?,
        rebanhoIdReprodutor: data['rebanhoIdReprodutor'] as String?,
        dataDesmama: data['dataDesmama'] as String?,
        pesoDesmama: castToType<double>(data['pesoDesmama']),
        pesoAtual: castToType<double>(data['pesoAtual']),
        status: data['status'] as String?,
        origem: data['origem'] as String?,
        anotacoes: data['anotacoes'] as String?,
        idRebanho: data['idRebanho'] as String?,
        deletado: data['deletado'] as String?,
        updatedAt: data['updated_at'] as String?,
        loteNome: data['loteNome'] as String?,
        tipo: data['tipo'] as String?,
        dataAcao: data['dataAcao'] as String?,
        valorCompra: castToType<double>(data['valorCompra']),
        dataUltimaPesagem: data['dataUltimaPesagem'] as String?,
        nomeConcat: data['nomeConcat'] as String?,
        dataVenda: data['dataVenda'] as String?,
        valorVenda: castToType<double>(data['valorVenda']),
      );

  static RebanhoDTStruct? maybeFromMap(dynamic data) => data is Map
      ? RebanhoDTStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'created_at': _createdAt,
        'idPropriedade': _idPropriedade,
        'numeroAnimal': _numeroAnimal,
        'chip': _chip,
        'codRegistro': _codRegistro,
        'nome': _nome,
        'sexo': _sexo,
        'categoria': _categoria,
        'dataNascimento': _dataNascimento,
        'pesoNascimento': _pesoNascimento,
        'porte': _porte,
        'raca': _raca,
        'loteID': _loteID,
        'dataEntradaLote': _dataEntradaLote,
        'rebanhoIdMatriz': _rebanhoIdMatriz,
        'rebanhoIdReprodutor': _rebanhoIdReprodutor,
        'dataDesmama': _dataDesmama,
        'pesoDesmama': _pesoDesmama,
        'pesoAtual': _pesoAtual,
        'status': _status,
        'origem': _origem,
        'anotacoes': _anotacoes,
        'idRebanho': _idRebanho,
        'deletado': _deletado,
        'updated_at': _updatedAt,
        'loteNome': _loteNome,
        'tipo': _tipo,
        'dataAcao': _dataAcao,
        'valorCompra': _valorCompra,
        'dataUltimaPesagem': _dataUltimaPesagem,
        'nomeConcat': _nomeConcat,
        'dataVenda': _dataVenda,
        'valorVenda': _valorVenda,
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
        'idPropriedade': serializeParam(
          _idPropriedade,
          ParamType.String,
        ),
        'numeroAnimal': serializeParam(
          _numeroAnimal,
          ParamType.String,
        ),
        'chip': serializeParam(
          _chip,
          ParamType.String,
        ),
        'codRegistro': serializeParam(
          _codRegistro,
          ParamType.String,
        ),
        'nome': serializeParam(
          _nome,
          ParamType.String,
        ),
        'sexo': serializeParam(
          _sexo,
          ParamType.String,
        ),
        'categoria': serializeParam(
          _categoria,
          ParamType.String,
        ),
        'dataNascimento': serializeParam(
          _dataNascimento,
          ParamType.String,
        ),
        'pesoNascimento': serializeParam(
          _pesoNascimento,
          ParamType.double,
        ),
        'porte': serializeParam(
          _porte,
          ParamType.String,
        ),
        'raca': serializeParam(
          _raca,
          ParamType.String,
        ),
        'loteID': serializeParam(
          _loteID,
          ParamType.String,
        ),
        'dataEntradaLote': serializeParam(
          _dataEntradaLote,
          ParamType.String,
        ),
        'rebanhoIdMatriz': serializeParam(
          _rebanhoIdMatriz,
          ParamType.String,
        ),
        'rebanhoIdReprodutor': serializeParam(
          _rebanhoIdReprodutor,
          ParamType.String,
        ),
        'dataDesmama': serializeParam(
          _dataDesmama,
          ParamType.String,
        ),
        'pesoDesmama': serializeParam(
          _pesoDesmama,
          ParamType.double,
        ),
        'pesoAtual': serializeParam(
          _pesoAtual,
          ParamType.double,
        ),
        'status': serializeParam(
          _status,
          ParamType.String,
        ),
        'origem': serializeParam(
          _origem,
          ParamType.String,
        ),
        'anotacoes': serializeParam(
          _anotacoes,
          ParamType.String,
        ),
        'idRebanho': serializeParam(
          _idRebanho,
          ParamType.String,
        ),
        'deletado': serializeParam(
          _deletado,
          ParamType.String,
        ),
        'updated_at': serializeParam(
          _updatedAt,
          ParamType.String,
        ),
        'loteNome': serializeParam(
          _loteNome,
          ParamType.String,
        ),
        'tipo': serializeParam(
          _tipo,
          ParamType.String,
        ),
        'dataAcao': serializeParam(
          _dataAcao,
          ParamType.String,
        ),
        'valorCompra': serializeParam(
          _valorCompra,
          ParamType.double,
        ),
        'dataUltimaPesagem': serializeParam(
          _dataUltimaPesagem,
          ParamType.String,
        ),
        'nomeConcat': serializeParam(
          _nomeConcat,
          ParamType.String,
        ),
        'dataVenda': serializeParam(
          _dataVenda,
          ParamType.String,
        ),
        'valorVenda': serializeParam(
          _valorVenda,
          ParamType.double,
        ),
      }.withoutNulls;

  static RebanhoDTStruct fromSerializableMap(Map<String, dynamic> data) =>
      RebanhoDTStruct(
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
          data['idPropriedade'],
          ParamType.String,
          false,
        ),
        numeroAnimal: deserializeParam(
          data['numeroAnimal'],
          ParamType.String,
          false,
        ),
        chip: deserializeParam(
          data['chip'],
          ParamType.String,
          false,
        ),
        codRegistro: deserializeParam(
          data['codRegistro'],
          ParamType.String,
          false,
        ),
        nome: deserializeParam(
          data['nome'],
          ParamType.String,
          false,
        ),
        sexo: deserializeParam(
          data['sexo'],
          ParamType.String,
          false,
        ),
        categoria: deserializeParam(
          data['categoria'],
          ParamType.String,
          false,
        ),
        dataNascimento: deserializeParam(
          data['dataNascimento'],
          ParamType.String,
          false,
        ),
        pesoNascimento: deserializeParam(
          data['pesoNascimento'],
          ParamType.double,
          false,
        ),
        porte: deserializeParam(
          data['porte'],
          ParamType.String,
          false,
        ),
        raca: deserializeParam(
          data['raca'],
          ParamType.String,
          false,
        ),
        loteID: deserializeParam(
          data['loteID'],
          ParamType.String,
          false,
        ),
        dataEntradaLote: deserializeParam(
          data['dataEntradaLote'],
          ParamType.String,
          false,
        ),
        rebanhoIdMatriz: deserializeParam(
          data['rebanhoIdMatriz'],
          ParamType.String,
          false,
        ),
        rebanhoIdReprodutor: deserializeParam(
          data['rebanhoIdReprodutor'],
          ParamType.String,
          false,
        ),
        dataDesmama: deserializeParam(
          data['dataDesmama'],
          ParamType.String,
          false,
        ),
        pesoDesmama: deserializeParam(
          data['pesoDesmama'],
          ParamType.double,
          false,
        ),
        pesoAtual: deserializeParam(
          data['pesoAtual'],
          ParamType.double,
          false,
        ),
        status: deserializeParam(
          data['status'],
          ParamType.String,
          false,
        ),
        origem: deserializeParam(
          data['origem'],
          ParamType.String,
          false,
        ),
        anotacoes: deserializeParam(
          data['anotacoes'],
          ParamType.String,
          false,
        ),
        idRebanho: deserializeParam(
          data['idRebanho'],
          ParamType.String,
          false,
        ),
        deletado: deserializeParam(
          data['deletado'],
          ParamType.String,
          false,
        ),
        updatedAt: deserializeParam(
          data['updated_at'],
          ParamType.String,
          false,
        ),
        loteNome: deserializeParam(
          data['loteNome'],
          ParamType.String,
          false,
        ),
        tipo: deserializeParam(
          data['tipo'],
          ParamType.String,
          false,
        ),
        dataAcao: deserializeParam(
          data['dataAcao'],
          ParamType.String,
          false,
        ),
        valorCompra: deserializeParam(
          data['valorCompra'],
          ParamType.double,
          false,
        ),
        dataUltimaPesagem: deserializeParam(
          data['dataUltimaPesagem'],
          ParamType.String,
          false,
        ),
        nomeConcat: deserializeParam(
          data['nomeConcat'],
          ParamType.String,
          false,
        ),
        dataVenda: deserializeParam(
          data['dataVenda'],
          ParamType.String,
          false,
        ),
        valorVenda: deserializeParam(
          data['valorVenda'],
          ParamType.double,
          false,
        ),
      );

  @override
  String toString() => 'RebanhoDTStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is RebanhoDTStruct &&
        id == other.id &&
        createdAt == other.createdAt &&
        idPropriedade == other.idPropriedade &&
        numeroAnimal == other.numeroAnimal &&
        chip == other.chip &&
        codRegistro == other.codRegistro &&
        nome == other.nome &&
        sexo == other.sexo &&
        categoria == other.categoria &&
        dataNascimento == other.dataNascimento &&
        pesoNascimento == other.pesoNascimento &&
        porte == other.porte &&
        raca == other.raca &&
        loteID == other.loteID &&
        dataEntradaLote == other.dataEntradaLote &&
        rebanhoIdMatriz == other.rebanhoIdMatriz &&
        rebanhoIdReprodutor == other.rebanhoIdReprodutor &&
        dataDesmama == other.dataDesmama &&
        pesoDesmama == other.pesoDesmama &&
        pesoAtual == other.pesoAtual &&
        status == other.status &&
        origem == other.origem &&
        anotacoes == other.anotacoes &&
        idRebanho == other.idRebanho &&
        deletado == other.deletado &&
        updatedAt == other.updatedAt &&
        loteNome == other.loteNome &&
        tipo == other.tipo &&
        dataAcao == other.dataAcao &&
        valorCompra == other.valorCompra &&
        dataUltimaPesagem == other.dataUltimaPesagem &&
        nomeConcat == other.nomeConcat &&
        dataVenda == other.dataVenda &&
        valorVenda == other.valorVenda;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        createdAt,
        idPropriedade,
        numeroAnimal,
        chip,
        codRegistro,
        nome,
        sexo,
        categoria,
        dataNascimento,
        pesoNascimento,
        porte,
        raca,
        loteID,
        dataEntradaLote,
        rebanhoIdMatriz,
        rebanhoIdReprodutor,
        dataDesmama,
        pesoDesmama,
        pesoAtual,
        status,
        origem,
        anotacoes,
        idRebanho,
        deletado,
        updatedAt,
        loteNome,
        tipo,
        dataAcao,
        valorCompra,
        dataUltimaPesagem,
        nomeConcat,
        dataVenda,
        valorVenda
      ]);
}

RebanhoDTStruct createRebanhoDTStruct({
  int? id,
  String? createdAt,
  String? idPropriedade,
  String? numeroAnimal,
  String? chip,
  String? codRegistro,
  String? nome,
  String? sexo,
  String? categoria,
  String? dataNascimento,
  double? pesoNascimento,
  String? porte,
  String? raca,
  String? loteID,
  String? dataEntradaLote,
  String? rebanhoIdMatriz,
  String? rebanhoIdReprodutor,
  String? dataDesmama,
  double? pesoDesmama,
  double? pesoAtual,
  String? status,
  String? origem,
  String? anotacoes,
  String? idRebanho,
  String? deletado,
  String? updatedAt,
  String? loteNome,
  String? tipo,
  String? dataAcao,
  double? valorCompra,
  String? dataUltimaPesagem,
  String? nomeConcat,
  String? dataVenda,
  double? valorVenda,
}) =>
    RebanhoDTStruct(
      id: id,
      createdAt: createdAt,
      idPropriedade: idPropriedade,
      numeroAnimal: numeroAnimal,
      chip: chip,
      codRegistro: codRegistro,
      nome: nome,
      sexo: sexo,
      categoria: categoria,
      dataNascimento: dataNascimento,
      pesoNascimento: pesoNascimento,
      porte: porte,
      raca: raca,
      loteID: loteID,
      dataEntradaLote: dataEntradaLote,
      rebanhoIdMatriz: rebanhoIdMatriz,
      rebanhoIdReprodutor: rebanhoIdReprodutor,
      dataDesmama: dataDesmama,
      pesoDesmama: pesoDesmama,
      pesoAtual: pesoAtual,
      status: status,
      origem: origem,
      anotacoes: anotacoes,
      idRebanho: idRebanho,
      deletado: deletado,
      updatedAt: updatedAt,
      loteNome: loteNome,
      tipo: tipo,
      dataAcao: dataAcao,
      valorCompra: valorCompra,
      dataUltimaPesagem: dataUltimaPesagem,
      nomeConcat: nomeConcat,
      dataVenda: dataVenda,
      valorVenda: valorVenda,
    );
