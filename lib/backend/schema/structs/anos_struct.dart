// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AnosStruct extends BaseStruct {
  AnosStruct({
    int? anoInt,
    String? anostring,
  })  : _anoInt = anoInt,
        _anostring = anostring;

  // "anoInt" field.
  int? _anoInt;
  int get anoInt => _anoInt ?? 0;
  set anoInt(int? val) => _anoInt = val;

  void incrementAnoInt(int amount) => anoInt = anoInt + amount;

  bool hasAnoInt() => _anoInt != null;

  // "anostring" field.
  String? _anostring;
  String get anostring => _anostring ?? '';
  set anostring(String? val) => _anostring = val;

  bool hasAnostring() => _anostring != null;

  static AnosStruct fromMap(Map<String, dynamic> data) => AnosStruct(
        anoInt: castToType<int>(data['anoInt']),
        anostring: data['anostring'] as String?,
      );

  static AnosStruct? maybeFromMap(dynamic data) =>
      data is Map ? AnosStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'anoInt': _anoInt,
        'anostring': _anostring,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'anoInt': serializeParam(
          _anoInt,
          ParamType.int,
        ),
        'anostring': serializeParam(
          _anostring,
          ParamType.String,
        ),
      }.withoutNulls;

  static AnosStruct fromSerializableMap(Map<String, dynamic> data) =>
      AnosStruct(
        anoInt: deserializeParam(
          data['anoInt'],
          ParamType.int,
          false,
        ),
        anostring: deserializeParam(
          data['anostring'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'AnosStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is AnosStruct &&
        anoInt == other.anoInt &&
        anostring == other.anostring;
  }

  @override
  int get hashCode => const ListEquality().hash([anoInt, anostring]);
}

AnosStruct createAnosStruct({
  int? anoInt,
  String? anostring,
}) =>
    AnosStruct(
      anoInt: anoInt,
      anostring: anostring,
    );
