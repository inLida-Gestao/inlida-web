// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RebanhosPorPeriodoStruct extends BaseStruct {
  RebanhosPorPeriodoStruct({
    List<int>? ano,
    List<int>? mes,
    List<String>? mesNome,
    List<String>? sexo,
    List<int>? quantidade,
  })  : _ano = ano,
        _mes = mes,
        _mesNome = mesNome,
        _sexo = sexo,
        _quantidade = quantidade;

  // "ano" field.
  List<int>? _ano;
  List<int> get ano => _ano ?? const [];
  set ano(List<int>? val) => _ano = val;

  void updateAno(Function(List<int>) updateFn) {
    updateFn(_ano ??= []);
  }

  bool hasAno() => _ano != null;

  // "mes" field.
  List<int>? _mes;
  List<int> get mes => _mes ?? const [];
  set mes(List<int>? val) => _mes = val;

  void updateMes(Function(List<int>) updateFn) {
    updateFn(_mes ??= []);
  }

  bool hasMes() => _mes != null;

  // "mes_nome" field.
  List<String>? _mesNome;
  List<String> get mesNome => _mesNome ?? const [];
  set mesNome(List<String>? val) => _mesNome = val;

  void updateMesNome(Function(List<String>) updateFn) {
    updateFn(_mesNome ??= []);
  }

  bool hasMesNome() => _mesNome != null;

  // "sexo" field.
  List<String>? _sexo;
  List<String> get sexo => _sexo ?? const [];
  set sexo(List<String>? val) => _sexo = val;

  void updateSexo(Function(List<String>) updateFn) {
    updateFn(_sexo ??= []);
  }

  bool hasSexo() => _sexo != null;

  // "quantidade" field.
  List<int>? _quantidade;
  List<int> get quantidade => _quantidade ?? const [];
  set quantidade(List<int>? val) => _quantidade = val;

  void updateQuantidade(Function(List<int>) updateFn) {
    updateFn(_quantidade ??= []);
  }

  bool hasQuantidade() => _quantidade != null;

  static RebanhosPorPeriodoStruct fromMap(Map<String, dynamic> data) =>
      RebanhosPorPeriodoStruct(
        ano: getDataList(data['ano']),
        mes: getDataList(data['mes']),
        mesNome: getDataList(data['mes_nome']),
        sexo: getDataList(data['sexo']),
        quantidade: getDataList(data['quantidade']),
      );

  static RebanhosPorPeriodoStruct? maybeFromMap(dynamic data) => data is Map
      ? RebanhosPorPeriodoStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'ano': _ano,
        'mes': _mes,
        'mes_nome': _mesNome,
        'sexo': _sexo,
        'quantidade': _quantidade,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'ano': serializeParam(
          _ano,
          ParamType.int,
          isList: true,
        ),
        'mes': serializeParam(
          _mes,
          ParamType.int,
          isList: true,
        ),
        'mes_nome': serializeParam(
          _mesNome,
          ParamType.String,
          isList: true,
        ),
        'sexo': serializeParam(
          _sexo,
          ParamType.String,
          isList: true,
        ),
        'quantidade': serializeParam(
          _quantidade,
          ParamType.int,
          isList: true,
        ),
      }.withoutNulls;

  static RebanhosPorPeriodoStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      RebanhosPorPeriodoStruct(
        ano: deserializeParam<int>(
          data['ano'],
          ParamType.int,
          true,
        ),
        mes: deserializeParam<int>(
          data['mes'],
          ParamType.int,
          true,
        ),
        mesNome: deserializeParam<String>(
          data['mes_nome'],
          ParamType.String,
          true,
        ),
        sexo: deserializeParam<String>(
          data['sexo'],
          ParamType.String,
          true,
        ),
        quantidade: deserializeParam<int>(
          data['quantidade'],
          ParamType.int,
          true,
        ),
      );

  @override
  String toString() => 'RebanhosPorPeriodoStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is RebanhosPorPeriodoStruct &&
        listEquality.equals(ano, other.ano) &&
        listEquality.equals(mes, other.mes) &&
        listEquality.equals(mesNome, other.mesNome) &&
        listEquality.equals(sexo, other.sexo) &&
        listEquality.equals(quantidade, other.quantidade);
  }

  @override
  int get hashCode =>
      const ListEquality().hash([ano, mes, mesNome, sexo, quantidade]);
}

RebanhosPorPeriodoStruct createRebanhosPorPeriodoStruct() =>
    RebanhosPorPeriodoStruct();
