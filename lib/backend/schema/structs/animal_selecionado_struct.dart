// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AnimalSelecionadoStruct extends BaseStruct {
  AnimalSelecionadoStruct({
    String? numAnimal,
    String? nomeAnimal,
    String? dataNascAnimal,
    String? racaAnimal,
    String? categoria,
    String? idAnimal,
  })  : _numAnimal = numAnimal,
        _nomeAnimal = nomeAnimal,
        _dataNascAnimal = dataNascAnimal,
        _racaAnimal = racaAnimal,
        _categoria = categoria,
        _idAnimal = idAnimal;

  // "numAnimal" field.
  String? _numAnimal;
  String get numAnimal => _numAnimal ?? '';
  set numAnimal(String? val) => _numAnimal = val;

  bool hasNumAnimal() => _numAnimal != null;

  // "nomeAnimal" field.
  String? _nomeAnimal;
  String get nomeAnimal => _nomeAnimal ?? '';
  set nomeAnimal(String? val) => _nomeAnimal = val;

  bool hasNomeAnimal() => _nomeAnimal != null;

  // "dataNascAnimal" field.
  String? _dataNascAnimal;
  String get dataNascAnimal => _dataNascAnimal ?? '';
  set dataNascAnimal(String? val) => _dataNascAnimal = val;

  bool hasDataNascAnimal() => _dataNascAnimal != null;

  // "racaAnimal" field.
  String? _racaAnimal;
  String get racaAnimal => _racaAnimal ?? '';
  set racaAnimal(String? val) => _racaAnimal = val;

  bool hasRacaAnimal() => _racaAnimal != null;

  // "categoria" field.
  String? _categoria;
  String get categoria => _categoria ?? '';
  set categoria(String? val) => _categoria = val;

  bool hasCategoria() => _categoria != null;

  // "idAnimal" field.
  String? _idAnimal;
  String get idAnimal => _idAnimal ?? '';
  set idAnimal(String? val) => _idAnimal = val;

  bool hasIdAnimal() => _idAnimal != null;

  static AnimalSelecionadoStruct fromMap(Map<String, dynamic> data) =>
      AnimalSelecionadoStruct(
        numAnimal: data['numAnimal'] as String?,
        nomeAnimal: data['nomeAnimal'] as String?,
        dataNascAnimal: data['dataNascAnimal'] as String?,
        racaAnimal: data['racaAnimal'] as String?,
        categoria: data['categoria'] as String?,
        idAnimal: data['idAnimal'] as String?,
      );

  static AnimalSelecionadoStruct? maybeFromMap(dynamic data) => data is Map
      ? AnimalSelecionadoStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'numAnimal': _numAnimal,
        'nomeAnimal': _nomeAnimal,
        'dataNascAnimal': _dataNascAnimal,
        'racaAnimal': _racaAnimal,
        'categoria': _categoria,
        'idAnimal': _idAnimal,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'numAnimal': serializeParam(
          _numAnimal,
          ParamType.String,
        ),
        'nomeAnimal': serializeParam(
          _nomeAnimal,
          ParamType.String,
        ),
        'dataNascAnimal': serializeParam(
          _dataNascAnimal,
          ParamType.String,
        ),
        'racaAnimal': serializeParam(
          _racaAnimal,
          ParamType.String,
        ),
        'categoria': serializeParam(
          _categoria,
          ParamType.String,
        ),
        'idAnimal': serializeParam(
          _idAnimal,
          ParamType.String,
        ),
      }.withoutNulls;

  static AnimalSelecionadoStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      AnimalSelecionadoStruct(
        numAnimal: deserializeParam(
          data['numAnimal'],
          ParamType.String,
          false,
        ),
        nomeAnimal: deserializeParam(
          data['nomeAnimal'],
          ParamType.String,
          false,
        ),
        dataNascAnimal: deserializeParam(
          data['dataNascAnimal'],
          ParamType.String,
          false,
        ),
        racaAnimal: deserializeParam(
          data['racaAnimal'],
          ParamType.String,
          false,
        ),
        categoria: deserializeParam(
          data['categoria'],
          ParamType.String,
          false,
        ),
        idAnimal: deserializeParam(
          data['idAnimal'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'AnimalSelecionadoStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is AnimalSelecionadoStruct &&
        numAnimal == other.numAnimal &&
        nomeAnimal == other.nomeAnimal &&
        dataNascAnimal == other.dataNascAnimal &&
        racaAnimal == other.racaAnimal &&
        categoria == other.categoria &&
        idAnimal == other.idAnimal;
  }

  @override
  int get hashCode => const ListEquality().hash(
      [numAnimal, nomeAnimal, dataNascAnimal, racaAnimal, categoria, idAnimal]);
}

AnimalSelecionadoStruct createAnimalSelecionadoStruct({
  String? numAnimal,
  String? nomeAnimal,
  String? dataNascAnimal,
  String? racaAnimal,
  String? categoria,
  String? idAnimal,
}) =>
    AnimalSelecionadoStruct(
      numAnimal: numAnimal,
      nomeAnimal: nomeAnimal,
      dataNascAnimal: dataNascAnimal,
      racaAnimal: racaAnimal,
      categoria: categoria,
      idAnimal: idAnimal,
    );
