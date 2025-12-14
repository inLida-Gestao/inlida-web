// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LotesDTStruct extends BaseStruct {
  LotesDTStruct({
    String? idLote,
    String? nome,
  })  : _idLote = idLote,
        _nome = nome;

  // "idLote" field.
  String? _idLote;
  String get idLote => _idLote ?? '';
  set idLote(String? val) => _idLote = val;

  bool hasIdLote() => _idLote != null;

  // "nome" field.
  String? _nome;
  String get nome => _nome ?? '';
  set nome(String? val) => _nome = val;

  bool hasNome() => _nome != null;

  static LotesDTStruct fromMap(Map<String, dynamic> data) => LotesDTStruct(
        idLote: data['idLote'] as String?,
        nome: data['nome'] as String?,
      );

  static LotesDTStruct? maybeFromMap(dynamic data) =>
      data is Map ? LotesDTStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'idLote': _idLote,
        'nome': _nome,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'idLote': serializeParam(
          _idLote,
          ParamType.String,
        ),
        'nome': serializeParam(
          _nome,
          ParamType.String,
        ),
      }.withoutNulls;

  static LotesDTStruct fromSerializableMap(Map<String, dynamic> data) =>
      LotesDTStruct(
        idLote: deserializeParam(
          data['idLote'],
          ParamType.String,
          false,
        ),
        nome: deserializeParam(
          data['nome'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'LotesDTStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is LotesDTStruct &&
        idLote == other.idLote &&
        nome == other.nome;
  }

  @override
  int get hashCode => const ListEquality().hash([idLote, nome]);
}

LotesDTStruct createLotesDTStruct({
  String? idLote,
  String? nome,
}) =>
    LotesDTStruct(
      idLote: idLote,
      nome: nome,
    );
