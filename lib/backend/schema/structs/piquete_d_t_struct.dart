// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PiqueteDTStruct extends BaseStruct {
  PiqueteDTStruct({
    int? id,
    String? createdAt,
    String? nome,
    double? area,
    List<String>? forrageria,
    String? anotacoes,
    String? incluirPiquete,
    List<String>? idRebanhos,
    List<String>? idLotes,
    String? idPiquete,
    String? idPropriedade,
  })  : _id = id,
        _createdAt = createdAt,
        _nome = nome,
        _area = area,
        _forrageria = forrageria ?? [],
        _anotacoes = anotacoes,
        _incluirPiquete = incluirPiquete,
        _idRebanhos = idRebanhos ?? [],
        _idLotes = idLotes ?? [],
        _idPiquete = idPiquete,
        _idPropriedade = idPropriedade;

  int? _id;
  int get id => _id ?? 0;
  set id(int? val) => _id = val;
  bool hasId() => _id != null;

  String? _createdAt;
  String get createdAt => _createdAt ?? '';
  set createdAt(String? val) => _createdAt = val;
  bool hasCreatedAt() => _createdAt != null;

  String? _nome;
  String get nome => _nome ?? '';
  set nome(String? val) => _nome = val;
  bool hasNome() => _nome != null;

  double? _area;
  double get area => _area ?? 0.0;
  set area(double? val) => _area = val;
  bool hasArea() => _area != null;

  List<String> _forrageria;
  List<String> get forrageria => _forrageria;
  set forrageria(List<String> val) => _forrageria = val;
  bool hasForrageria() => _forrageria.isNotEmpty;

  String? _anotacoes;
  String get anotacoes => _anotacoes ?? '';
  set anotacoes(String? val) => _anotacoes = val;
  bool hasAnotacoes() => _anotacoes != null;

  String? _incluirPiquete;
  String get incluirPiquete => _incluirPiquete ?? '';
  set incluirPiquete(String? val) => _incluirPiquete = val;
  bool hasIncluirPiquete() => _incluirPiquete != null;

  List<String> _idRebanhos;
  List<String> get idRebanhos => _idRebanhos;
  set idRebanhos(List<String> val) => _idRebanhos = val;
  bool hasIdRebanhos() => _idRebanhos.isNotEmpty;

  List<String> _idLotes;
  List<String> get idLotes => _idLotes;
  set idLotes(List<String> val) => _idLotes = val;
  bool hasIdLotes() => _idLotes.isNotEmpty;

  String? _idPiquete;
  String get idPiquete => _idPiquete ?? '';
  set idPiquete(String? val) => _idPiquete = val;
  bool hasIdPiquete() => _idPiquete != null;

  String? _idPropriedade;
  String get idPropriedade => _idPropriedade ?? '';
  set idPropriedade(String? val) => _idPropriedade = val;
  bool hasIdPropriedade() => _idPropriedade != null;

  static PiqueteDTStruct fromMap(Map<String, dynamic> data) => PiqueteDTStruct(
        id: castToType<int>(data['id']),
        createdAt: data['created_at'] as String?,
        nome: data['nome'] as String?,
        area: castToType<double>(data['area']),
        forrageria: (data['forrageria'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        anotacoes: data['anotacoes'] as String?,
        incluirPiquete: data['incluir_piquete'] as String?,
        idRebanhos: (data['id_rebanhos'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        idLotes: (data['id_lotes'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        idPiquete: data['id_piquete'] as String?,
        idPropriedade: data['id_propriedade'] as String?,
      );

  static PiqueteDTStruct? maybeFromMap(dynamic data) =>
      data is Map ? PiqueteDTStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'created_at': _createdAt,
        'nome': _nome,
        'area': _area,
        'forrageria': _forrageria,
        'anotacoes': _anotacoes,
        'incluir_piquete': _incluirPiquete,
        'id_rebanhos': _idRebanhos,
        'id_lotes': _idLotes,
        'id_piquete': _idPiquete,
        'id_propriedade': _idPropriedade,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(_id, ParamType.int),
        'created_at': serializeParam(_createdAt, ParamType.String),
        'nome': serializeParam(_nome, ParamType.String),
        'area': serializeParam(_area, ParamType.double),
        'forrageria': serializeParam(_forrageria, ParamType.String, isList: true),
        'anotacoes': serializeParam(_anotacoes, ParamType.String),
        'incluir_piquete': serializeParam(_incluirPiquete, ParamType.String),
        'id_rebanhos': serializeParam(_idRebanhos, ParamType.String, isList: true),
        'id_lotes': serializeParam(_idLotes, ParamType.String, isList: true),
        'id_piquete': serializeParam(_idPiquete, ParamType.String),
        'id_propriedade': serializeParam(_idPropriedade, ParamType.String),
      }.withoutNulls;

  static PiqueteDTStruct fromSerializableMap(Map<String, dynamic> data) =>
      PiqueteDTStruct(
        id: deserializeParam(data['id'], ParamType.int, false),
        createdAt: deserializeParam(data['created_at'], ParamType.String, false),
        nome: deserializeParam(data['nome'], ParamType.String, false),
        area: deserializeParam(data['area'], ParamType.double, false),
        forrageria: deserializeParam<String>(data['forrageria'], ParamType.String, true),
        anotacoes: deserializeParam(data['anotacoes'], ParamType.String, false),
        incluirPiquete:
            deserializeParam(data['incluir_piquete'], ParamType.String, false),
        idRebanhos: deserializeParam<String>(data['id_rebanhos'], ParamType.String, true),
        idLotes: deserializeParam<String>(data['id_lotes'], ParamType.String, true),
        idPiquete: deserializeParam(data['id_piquete'], ParamType.String, false),
        idPropriedade:
            deserializeParam(data['id_propriedade'], ParamType.String, false),
      );

  @override
  String toString() => 'PiqueteDTStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is PiqueteDTStruct &&
        id == other.id &&
        createdAt == other.createdAt &&
        nome == other.nome &&
        area == other.area &&
        listEquality.equals(forrageria, other.forrageria) &&
        anotacoes == other.anotacoes &&
        incluirPiquete == other.incluirPiquete &&
        listEquality.equals(idRebanhos, other.idRebanhos) &&
        listEquality.equals(idLotes, other.idLotes) &&
        idPiquete == other.idPiquete &&
        idPropriedade == other.idPropriedade;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        createdAt,
        nome,
        area,
        forrageria,
        anotacoes,
        incluirPiquete,
        idRebanhos,
        idLotes,
        idPiquete,
        idPropriedade,
      ]);
}

PiqueteDTStruct createPiqueteDTStruct({
  int? id,
  String? createdAt,
  String? nome,
  double? area,
  List<String>? forrageria,
  String? anotacoes,
  String? incluirPiquete,
  List<String>? idRebanhos,
  List<String>? idLotes,
  String? idPiquete,
  String? idPropriedade,
}) =>
    PiqueteDTStruct(
      id: id,
      createdAt: createdAt,
      nome: nome,
      area: area,
      forrageria: forrageria,
      anotacoes: anotacoes,
      incluirPiquete: incluirPiquete,
      idRebanhos: idRebanhos,
      idLotes: idLotes,
      idPiquete: idPiquete,
      idPropriedade: idPropriedade,
    );
