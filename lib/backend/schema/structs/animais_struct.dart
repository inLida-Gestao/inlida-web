// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AnimaisStruct extends BaseStruct {
  AnimaisStruct({
    String? idRebanho,
    String? sexo,
    String? numeroAnimal,
    String? nome,
    String? dataNascimento,
    String? categoria,
    String? raca,
    String? loteNome,
    String? rebanhoIdMatriz,
    String? rebanhoIdReprodutor,
    String? status,
    int? id,
  })  : _idRebanho = idRebanho,
        _sexo = sexo,
        _numeroAnimal = numeroAnimal,
        _nome = nome,
        _dataNascimento = dataNascimento,
        _categoria = categoria,
        _raca = raca,
        _loteNome = loteNome,
        _rebanhoIdMatriz = rebanhoIdMatriz,
        _rebanhoIdReprodutor = rebanhoIdReprodutor,
        _status = status,
        _id = id;

  // "idRebanho" field.
  String? _idRebanho;
  String get idRebanho => _idRebanho ?? '';
  set idRebanho(String? val) => _idRebanho = val;

  bool hasIdRebanho() => _idRebanho != null;

  // "sexo" field.
  String? _sexo;
  String get sexo => _sexo ?? '';
  set sexo(String? val) => _sexo = val;

  bool hasSexo() => _sexo != null;

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

  // "dataNascimento" field.
  String? _dataNascimento;
  String get dataNascimento => _dataNascimento ?? '';
  set dataNascimento(String? val) => _dataNascimento = val;

  bool hasDataNascimento() => _dataNascimento != null;

  // "categoria" field.
  String? _categoria;
  String get categoria => _categoria ?? '';
  set categoria(String? val) => _categoria = val;

  bool hasCategoria() => _categoria != null;

  // "raca" field.
  String? _raca;
  String get raca => _raca ?? '';
  set raca(String? val) => _raca = val;

  bool hasRaca() => _raca != null;

  // "loteNome" field.
  String? _loteNome;
  String get loteNome => _loteNome ?? '';
  set loteNome(String? val) => _loteNome = val;

  bool hasLoteNome() => _loteNome != null;

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

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  set status(String? val) => _status = val;

  bool hasStatus() => _status != null;

  // "id" field.
  int? _id;
  int get id => _id ?? 0;
  set id(int? val) => _id = val;

  void incrementId(int amount) => id = id + amount;

  bool hasId() => _id != null;

  static AnimaisStruct fromMap(Map<String, dynamic> data) => AnimaisStruct(
        idRebanho: data['idRebanho'] as String?,
        sexo: data['sexo'] as String?,
        numeroAnimal: data['numeroAnimal'] as String?,
        nome: data['nome'] as String?,
        dataNascimento: data['dataNascimento'] as String?,
        categoria: data['categoria'] as String?,
        raca: data['raca'] as String?,
        loteNome: data['loteNome'] as String?,
        rebanhoIdMatriz: data['rebanhoIdMatriz'] as String?,
        rebanhoIdReprodutor: data['rebanhoIdReprodutor'] as String?,
        status: data['status'] as String?,
        id: castToType<int>(data['id']),
      );

  static AnimaisStruct? maybeFromMap(dynamic data) =>
      data is Map ? AnimaisStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'idRebanho': _idRebanho,
        'sexo': _sexo,
        'numeroAnimal': _numeroAnimal,
        'nome': _nome,
        'dataNascimento': _dataNascimento,
        'categoria': _categoria,
        'raca': _raca,
        'loteNome': _loteNome,
        'rebanhoIdMatriz': _rebanhoIdMatriz,
        'rebanhoIdReprodutor': _rebanhoIdReprodutor,
        'status': _status,
        'id': _id,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'idRebanho': serializeParam(
          _idRebanho,
          ParamType.String,
        ),
        'sexo': serializeParam(
          _sexo,
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
        'dataNascimento': serializeParam(
          _dataNascimento,
          ParamType.String,
        ),
        'categoria': serializeParam(
          _categoria,
          ParamType.String,
        ),
        'raca': serializeParam(
          _raca,
          ParamType.String,
        ),
        'loteNome': serializeParam(
          _loteNome,
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
        'status': serializeParam(
          _status,
          ParamType.String,
        ),
        'id': serializeParam(
          _id,
          ParamType.int,
        ),
      }.withoutNulls;

  static AnimaisStruct fromSerializableMap(Map<String, dynamic> data) =>
      AnimaisStruct(
        idRebanho: deserializeParam(
          data['idRebanho'],
          ParamType.String,
          false,
        ),
        sexo: deserializeParam(
          data['sexo'],
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
        dataNascimento: deserializeParam(
          data['dataNascimento'],
          ParamType.String,
          false,
        ),
        categoria: deserializeParam(
          data['categoria'],
          ParamType.String,
          false,
        ),
        raca: deserializeParam(
          data['raca'],
          ParamType.String,
          false,
        ),
        loteNome: deserializeParam(
          data['loteNome'],
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
        status: deserializeParam(
          data['status'],
          ParamType.String,
          false,
        ),
        id: deserializeParam(
          data['id'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'AnimaisStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is AnimaisStruct &&
        idRebanho == other.idRebanho &&
        sexo == other.sexo &&
        numeroAnimal == other.numeroAnimal &&
        nome == other.nome &&
        dataNascimento == other.dataNascimento &&
        categoria == other.categoria &&
        raca == other.raca &&
        loteNome == other.loteNome &&
        rebanhoIdMatriz == other.rebanhoIdMatriz &&
        rebanhoIdReprodutor == other.rebanhoIdReprodutor &&
        status == other.status &&
        id == other.id;
  }

  @override
  int get hashCode => const ListEquality().hash([
        idRebanho,
        sexo,
        numeroAnimal,
        nome,
        dataNascimento,
        categoria,
        raca,
        loteNome,
        rebanhoIdMatriz,
        rebanhoIdReprodutor,
        status,
        id
      ]);
}

AnimaisStruct createAnimaisStruct({
  String? idRebanho,
  String? sexo,
  String? numeroAnimal,
  String? nome,
  String? dataNascimento,
  String? categoria,
  String? raca,
  String? loteNome,
  String? rebanhoIdMatriz,
  String? rebanhoIdReprodutor,
  String? status,
  int? id,
}) =>
    AnimaisStruct(
      idRebanho: idRebanho,
      sexo: sexo,
      numeroAnimal: numeroAnimal,
      nome: nome,
      dataNascimento: dataNascimento,
      categoria: categoria,
      raca: raca,
      loteNome: loteNome,
      rebanhoIdMatriz: rebanhoIdMatriz,
      rebanhoIdReprodutor: rebanhoIdReprodutor,
      status: status,
      id: id,
    );
