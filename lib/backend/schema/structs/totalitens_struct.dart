// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TotalitensStruct extends BaseStruct {
  TotalitensStruct({
    int? qtd,
  }) : _qtd = qtd;

  // "qtd" field.
  int? _qtd;
  int get qtd => _qtd ?? 0;
  set qtd(int? val) => _qtd = val;

  void incrementQtd(int amount) => qtd = qtd + amount;

  bool hasQtd() => _qtd != null;

  static TotalitensStruct fromMap(Map<String, dynamic> data) =>
      TotalitensStruct(
        qtd: castToType<int>(data['qtd']),
      );

  static TotalitensStruct? maybeFromMap(dynamic data) => data is Map
      ? TotalitensStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'qtd': _qtd,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'qtd': serializeParam(
          _qtd,
          ParamType.int,
        ),
      }.withoutNulls;

  static TotalitensStruct fromSerializableMap(Map<String, dynamic> data) =>
      TotalitensStruct(
        qtd: deserializeParam(
          data['qtd'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'TotalitensStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is TotalitensStruct && qtd == other.qtd;
  }

  @override
  int get hashCode => const ListEquality().hash([qtd]);
}

TotalitensStruct createTotalitensStruct({
  int? qtd,
}) =>
    TotalitensStruct(
      qtd: qtd,
    );
