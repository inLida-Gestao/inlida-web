// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AcessoStruct extends BaseStruct {
  AcessoStruct({
    bool? acesso,
  }) : _acesso = acesso;

  // "acesso" field.
  bool? _acesso;
  bool get acesso => _acesso ?? false;
  set acesso(bool? val) => _acesso = val;

  bool hasAcesso() => _acesso != null;

  static AcessoStruct fromMap(Map<String, dynamic> data) => AcessoStruct(
        acesso: data['acesso'] as bool?,
      );

  static AcessoStruct? maybeFromMap(dynamic data) =>
      data is Map ? AcessoStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'acesso': _acesso,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'acesso': serializeParam(
          _acesso,
          ParamType.bool,
        ),
      }.withoutNulls;

  static AcessoStruct fromSerializableMap(Map<String, dynamic> data) =>
      AcessoStruct(
        acesso: deserializeParam(
          data['acesso'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'AcessoStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is AcessoStruct && acesso == other.acesso;
  }

  @override
  int get hashCode => const ListEquality().hash([acesso]);
}

AcessoStruct createAcessoStruct({
  bool? acesso,
}) =>
    AcessoStruct(
      acesso: acesso,
    );
