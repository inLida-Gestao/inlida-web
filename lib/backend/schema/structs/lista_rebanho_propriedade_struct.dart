// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ListaRebanhoPropriedadeStruct extends BaseStruct {
  ListaRebanhoPropriedadeStruct({
    String? categoria,
    int? quantidade,
    double? porcentagem,
  })  : _categoria = categoria,
        _quantidade = quantidade,
        _porcentagem = porcentagem;

  // "categoria" field.
  String? _categoria;
  String get categoria => _categoria ?? '';
  set categoria(String? val) => _categoria = val;

  bool hasCategoria() => _categoria != null;

  // "quantidade" field.
  int? _quantidade;
  int get quantidade => _quantidade ?? 0;
  set quantidade(int? val) => _quantidade = val;

  void incrementQuantidade(int amount) => quantidade = quantidade + amount;

  bool hasQuantidade() => _quantidade != null;

  // "porcentagem" field.
  double? _porcentagem;
  double get porcentagem => _porcentagem ?? 0.0;
  set porcentagem(double? val) => _porcentagem = val;

  void incrementPorcentagem(double amount) =>
      porcentagem = porcentagem + amount;

  bool hasPorcentagem() => _porcentagem != null;

  static ListaRebanhoPropriedadeStruct fromMap(Map<String, dynamic> data) =>
      ListaRebanhoPropriedadeStruct(
        categoria: data['categoria'] as String?,
        quantidade: castToType<int>(data['quantidade']),
        porcentagem: castToType<double>(data['porcentagem']),
      );

  static ListaRebanhoPropriedadeStruct? maybeFromMap(dynamic data) =>
      data is Map
          ? ListaRebanhoPropriedadeStruct.fromMap(data.cast<String, dynamic>())
          : null;

  Map<String, dynamic> toMap() => {
        'categoria': _categoria,
        'quantidade': _quantidade,
        'porcentagem': _porcentagem,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'categoria': serializeParam(
          _categoria,
          ParamType.String,
        ),
        'quantidade': serializeParam(
          _quantidade,
          ParamType.int,
        ),
        'porcentagem': serializeParam(
          _porcentagem,
          ParamType.double,
        ),
      }.withoutNulls;

  static ListaRebanhoPropriedadeStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ListaRebanhoPropriedadeStruct(
        categoria: deserializeParam(
          data['categoria'],
          ParamType.String,
          false,
        ),
        quantidade: deserializeParam(
          data['quantidade'],
          ParamType.int,
          false,
        ),
        porcentagem: deserializeParam(
          data['porcentagem'],
          ParamType.double,
          false,
        ),
      );

  @override
  String toString() => 'ListaRebanhoPropriedadeStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ListaRebanhoPropriedadeStruct &&
        categoria == other.categoria &&
        quantidade == other.quantidade &&
        porcentagem == other.porcentagem;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([categoria, quantidade, porcentagem]);
}

ListaRebanhoPropriedadeStruct createListaRebanhoPropriedadeStruct({
  String? categoria,
  int? quantidade,
  double? porcentagem,
}) =>
    ListaRebanhoPropriedadeStruct(
      categoria: categoria,
      quantidade: quantidade,
      porcentagem: porcentagem,
    );
