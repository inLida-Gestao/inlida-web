// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class HistoricoPesagensStruct extends BaseStruct {
  HistoricoPesagensStruct({
    int? id,
    String? idRebanho,
    DateTime? dataPesagem,
    String? tipo,
    double? peso,
    String? deletado,
    String? createdAt,
  })  : _id = id,
        _idRebanho = idRebanho,
        _dataPesagem = dataPesagem,
        _tipo = tipo,
        _peso = peso,
        _deletado = deletado,
        _createdAt = createdAt;

  // "id" field.
  int? _id;
  int get id => _id ?? 0;
  set id(int? val) => _id = val;

  void incrementId(int amount) => id = id + amount;

  bool hasId() => _id != null;

  // "idRebanho" field.
  String? _idRebanho;
  String get idRebanho => _idRebanho ?? '';
  set idRebanho(String? val) => _idRebanho = val;

  bool hasIdRebanho() => _idRebanho != null;

  // "dataPesagem" field.
  DateTime? _dataPesagem;
  DateTime? get dataPesagem => _dataPesagem;
  set dataPesagem(DateTime? val) => _dataPesagem = val;

  bool hasDataPesagem() => _dataPesagem != null;

  // "tipo" field.
  String? _tipo;
  String get tipo => _tipo ?? '';
  set tipo(String? val) => _tipo = val;

  bool hasTipo() => _tipo != null;

  // "peso" field.
  double? _peso;
  double get peso => _peso ?? 0.0;
  set peso(double? val) => _peso = val;

  void incrementPeso(double amount) => peso = peso + amount;

  bool hasPeso() => _peso != null;

  // "deletado" field.
  String? _deletado;
  String get deletado => _deletado ?? '';
  set deletado(String? val) => _deletado = val;

  bool hasDeletado() => _deletado != null;

  // "created_at" field.
  String? _createdAt;
  String get createdAt => _createdAt ?? '';
  set createdAt(String? val) => _createdAt = val;

  bool hasCreatedAt() => _createdAt != null;

  static HistoricoPesagensStruct fromMap(Map<String, dynamic> data) =>
      HistoricoPesagensStruct(
        id: castToType<int>(data['id']),
        idRebanho: data['idRebanho'] as String?,
        dataPesagem: data['dataPesagem'] as DateTime?,
        tipo: data['tipo'] as String?,
        peso: castToType<double>(data['peso']),
        deletado: data['deletado'] as String?,
        createdAt: data['created_at'] as String?,
      );

  static HistoricoPesagensStruct? maybeFromMap(dynamic data) => data is Map
      ? HistoricoPesagensStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'idRebanho': _idRebanho,
        'dataPesagem': _dataPesagem,
        'tipo': _tipo,
        'peso': _peso,
        'deletado': _deletado,
        'created_at': _createdAt,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.int,
        ),
        'idRebanho': serializeParam(
          _idRebanho,
          ParamType.String,
        ),
        'dataPesagem': serializeParam(
          _dataPesagem,
          ParamType.DateTime,
        ),
        'tipo': serializeParam(
          _tipo,
          ParamType.String,
        ),
        'peso': serializeParam(
          _peso,
          ParamType.double,
        ),
        'deletado': serializeParam(
          _deletado,
          ParamType.String,
        ),
        'created_at': serializeParam(
          _createdAt,
          ParamType.String,
        ),
      }.withoutNulls;

  static HistoricoPesagensStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      HistoricoPesagensStruct(
        id: deserializeParam(
          data['id'],
          ParamType.int,
          false,
        ),
        idRebanho: deserializeParam(
          data['idRebanho'],
          ParamType.String,
          false,
        ),
        dataPesagem: deserializeParam(
          data['dataPesagem'],
          ParamType.DateTime,
          false,
        ),
        tipo: deserializeParam(
          data['tipo'],
          ParamType.String,
          false,
        ),
        peso: deserializeParam(
          data['peso'],
          ParamType.double,
          false,
        ),
        deletado: deserializeParam(
          data['deletado'],
          ParamType.String,
          false,
        ),
        createdAt: deserializeParam(
          data['created_at'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'HistoricoPesagensStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is HistoricoPesagensStruct &&
        id == other.id &&
        idRebanho == other.idRebanho &&
        dataPesagem == other.dataPesagem &&
        tipo == other.tipo &&
        peso == other.peso &&
        deletado == other.deletado &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([id, idRebanho, dataPesagem, tipo, peso, deletado, createdAt]);
}

HistoricoPesagensStruct createHistoricoPesagensStruct({
  int? id,
  String? idRebanho,
  DateTime? dataPesagem,
  String? tipo,
  double? peso,
  String? deletado,
  String? createdAt,
}) =>
    HistoricoPesagensStruct(
      id: id,
      idRebanho: idRebanho,
      dataPesagem: dataPesagem,
      tipo: tipo,
      peso: peso,
      deletado: deletado,
      createdAt: createdAt,
    );
