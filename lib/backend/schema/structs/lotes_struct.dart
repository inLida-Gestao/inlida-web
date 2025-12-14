// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LotesStruct extends BaseStruct {
  LotesStruct({
    int? id,
    String? createdAt,
    String? idPropriedade,
    String? idAnimais,
    String? nome,
    String? anotacoes,
    String? ativo,
    String? dataEntradaPiquete,
    String? dataSaidaPiquete,
    String? motivo,
    String? dataMotivo,
    String? idLote,
    String? deletado,
    String? updatedAt,
    int? qtdRebanhosNoLote,
  })  : _id = id,
        _createdAt = createdAt,
        _idPropriedade = idPropriedade,
        _idAnimais = idAnimais,
        _nome = nome,
        _anotacoes = anotacoes,
        _ativo = ativo,
        _dataEntradaPiquete = dataEntradaPiquete,
        _dataSaidaPiquete = dataSaidaPiquete,
        _motivo = motivo,
        _dataMotivo = dataMotivo,
        _idLote = idLote,
        _deletado = deletado,
        _updatedAt = updatedAt,
        _qtdRebanhosNoLote = qtdRebanhosNoLote;

  // "id" field.
  int? _id;
  int get id => _id ?? 0;
  set id(int? val) => _id = val;

  void incrementId(int amount) => id = id + amount;

  bool hasId() => _id != null;

  // "created_at" field.
  String? _createdAt;
  String get createdAt => _createdAt ?? '';
  set createdAt(String? val) => _createdAt = val;

  bool hasCreatedAt() => _createdAt != null;

  // "id_propriedade" field.
  String? _idPropriedade;
  String get idPropriedade => _idPropriedade ?? '';
  set idPropriedade(String? val) => _idPropriedade = val;

  bool hasIdPropriedade() => _idPropriedade != null;

  // "id_animais" field.
  String? _idAnimais;
  String get idAnimais => _idAnimais ?? '';
  set idAnimais(String? val) => _idAnimais = val;

  bool hasIdAnimais() => _idAnimais != null;

  // "nome" field.
  String? _nome;
  String get nome => _nome ?? '';
  set nome(String? val) => _nome = val;

  bool hasNome() => _nome != null;

  // "anotacoes" field.
  String? _anotacoes;
  String get anotacoes => _anotacoes ?? '';
  set anotacoes(String? val) => _anotacoes = val;

  bool hasAnotacoes() => _anotacoes != null;

  // "ativo" field.
  String? _ativo;
  String get ativo => _ativo ?? '';
  set ativo(String? val) => _ativo = val;

  bool hasAtivo() => _ativo != null;

  // "data_entrada_piquete" field.
  String? _dataEntradaPiquete;
  String get dataEntradaPiquete => _dataEntradaPiquete ?? '';
  set dataEntradaPiquete(String? val) => _dataEntradaPiquete = val;

  bool hasDataEntradaPiquete() => _dataEntradaPiquete != null;

  // "data_saida_piquete" field.
  String? _dataSaidaPiquete;
  String get dataSaidaPiquete => _dataSaidaPiquete ?? '';
  set dataSaidaPiquete(String? val) => _dataSaidaPiquete = val;

  bool hasDataSaidaPiquete() => _dataSaidaPiquete != null;

  // "motivo" field.
  String? _motivo;
  String get motivo => _motivo ?? '';
  set motivo(String? val) => _motivo = val;

  bool hasMotivo() => _motivo != null;

  // "data_motivo" field.
  String? _dataMotivo;
  String get dataMotivo => _dataMotivo ?? '';
  set dataMotivo(String? val) => _dataMotivo = val;

  bool hasDataMotivo() => _dataMotivo != null;

  // "id_lote" field.
  String? _idLote;
  String get idLote => _idLote ?? '';
  set idLote(String? val) => _idLote = val;

  bool hasIdLote() => _idLote != null;

  // "deletado" field.
  String? _deletado;
  String get deletado => _deletado ?? '';
  set deletado(String? val) => _deletado = val;

  bool hasDeletado() => _deletado != null;

  // "updated_at" field.
  String? _updatedAt;
  String get updatedAt => _updatedAt ?? '';
  set updatedAt(String? val) => _updatedAt = val;

  bool hasUpdatedAt() => _updatedAt != null;

  // "qtd_rebanhos_no_lote" field.
  int? _qtdRebanhosNoLote;
  int get qtdRebanhosNoLote => _qtdRebanhosNoLote ?? 0;
  set qtdRebanhosNoLote(int? val) => _qtdRebanhosNoLote = val;

  void incrementQtdRebanhosNoLote(int amount) =>
      qtdRebanhosNoLote = qtdRebanhosNoLote + amount;

  bool hasQtdRebanhosNoLote() => _qtdRebanhosNoLote != null;

  static LotesStruct fromMap(Map<String, dynamic> data) => LotesStruct(
        id: castToType<int>(data['id']),
        createdAt: data['created_at'] as String?,
        idPropriedade: data['id_propriedade'] as String?,
        idAnimais: data['id_animais'] as String?,
        nome: data['nome'] as String?,
        anotacoes: data['anotacoes'] as String?,
        ativo: data['ativo'] as String?,
        dataEntradaPiquete: data['data_entrada_piquete'] as String?,
        dataSaidaPiquete: data['data_saida_piquete'] as String?,
        motivo: data['motivo'] as String?,
        dataMotivo: data['data_motivo'] as String?,
        idLote: data['id_lote'] as String?,
        deletado: data['deletado'] as String?,
        updatedAt: data['updated_at'] as String?,
        qtdRebanhosNoLote: castToType<int>(data['qtd_rebanhos_no_lote']),
      );

  static LotesStruct? maybeFromMap(dynamic data) =>
      data is Map ? LotesStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'created_at': _createdAt,
        'id_propriedade': _idPropriedade,
        'id_animais': _idAnimais,
        'nome': _nome,
        'anotacoes': _anotacoes,
        'ativo': _ativo,
        'data_entrada_piquete': _dataEntradaPiquete,
        'data_saida_piquete': _dataSaidaPiquete,
        'motivo': _motivo,
        'data_motivo': _dataMotivo,
        'id_lote': _idLote,
        'deletado': _deletado,
        'updated_at': _updatedAt,
        'qtd_rebanhos_no_lote': _qtdRebanhosNoLote,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.int,
        ),
        'created_at': serializeParam(
          _createdAt,
          ParamType.String,
        ),
        'id_propriedade': serializeParam(
          _idPropriedade,
          ParamType.String,
        ),
        'id_animais': serializeParam(
          _idAnimais,
          ParamType.String,
        ),
        'nome': serializeParam(
          _nome,
          ParamType.String,
        ),
        'anotacoes': serializeParam(
          _anotacoes,
          ParamType.String,
        ),
        'ativo': serializeParam(
          _ativo,
          ParamType.String,
        ),
        'data_entrada_piquete': serializeParam(
          _dataEntradaPiquete,
          ParamType.String,
        ),
        'data_saida_piquete': serializeParam(
          _dataSaidaPiquete,
          ParamType.String,
        ),
        'motivo': serializeParam(
          _motivo,
          ParamType.String,
        ),
        'data_motivo': serializeParam(
          _dataMotivo,
          ParamType.String,
        ),
        'id_lote': serializeParam(
          _idLote,
          ParamType.String,
        ),
        'deletado': serializeParam(
          _deletado,
          ParamType.String,
        ),
        'updated_at': serializeParam(
          _updatedAt,
          ParamType.String,
        ),
        'qtd_rebanhos_no_lote': serializeParam(
          _qtdRebanhosNoLote,
          ParamType.int,
        ),
      }.withoutNulls;

  static LotesStruct fromSerializableMap(Map<String, dynamic> data) =>
      LotesStruct(
        id: deserializeParam(
          data['id'],
          ParamType.int,
          false,
        ),
        createdAt: deserializeParam(
          data['created_at'],
          ParamType.String,
          false,
        ),
        idPropriedade: deserializeParam(
          data['id_propriedade'],
          ParamType.String,
          false,
        ),
        idAnimais: deserializeParam(
          data['id_animais'],
          ParamType.String,
          false,
        ),
        nome: deserializeParam(
          data['nome'],
          ParamType.String,
          false,
        ),
        anotacoes: deserializeParam(
          data['anotacoes'],
          ParamType.String,
          false,
        ),
        ativo: deserializeParam(
          data['ativo'],
          ParamType.String,
          false,
        ),
        dataEntradaPiquete: deserializeParam(
          data['data_entrada_piquete'],
          ParamType.String,
          false,
        ),
        dataSaidaPiquete: deserializeParam(
          data['data_saida_piquete'],
          ParamType.String,
          false,
        ),
        motivo: deserializeParam(
          data['motivo'],
          ParamType.String,
          false,
        ),
        dataMotivo: deserializeParam(
          data['data_motivo'],
          ParamType.String,
          false,
        ),
        idLote: deserializeParam(
          data['id_lote'],
          ParamType.String,
          false,
        ),
        deletado: deserializeParam(
          data['deletado'],
          ParamType.String,
          false,
        ),
        updatedAt: deserializeParam(
          data['updated_at'],
          ParamType.String,
          false,
        ),
        qtdRebanhosNoLote: deserializeParam(
          data['qtd_rebanhos_no_lote'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'LotesStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is LotesStruct &&
        id == other.id &&
        createdAt == other.createdAt &&
        idPropriedade == other.idPropriedade &&
        idAnimais == other.idAnimais &&
        nome == other.nome &&
        anotacoes == other.anotacoes &&
        ativo == other.ativo &&
        dataEntradaPiquete == other.dataEntradaPiquete &&
        dataSaidaPiquete == other.dataSaidaPiquete &&
        motivo == other.motivo &&
        dataMotivo == other.dataMotivo &&
        idLote == other.idLote &&
        deletado == other.deletado &&
        updatedAt == other.updatedAt &&
        qtdRebanhosNoLote == other.qtdRebanhosNoLote;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        createdAt,
        idPropriedade,
        idAnimais,
        nome,
        anotacoes,
        ativo,
        dataEntradaPiquete,
        dataSaidaPiquete,
        motivo,
        dataMotivo,
        idLote,
        deletado,
        updatedAt,
        qtdRebanhosNoLote
      ]);
}

LotesStruct createLotesStruct({
  int? id,
  String? createdAt,
  String? idPropriedade,
  String? idAnimais,
  String? nome,
  String? anotacoes,
  String? ativo,
  String? dataEntradaPiquete,
  String? dataSaidaPiquete,
  String? motivo,
  String? dataMotivo,
  String? idLote,
  String? deletado,
  String? updatedAt,
  int? qtdRebanhosNoLote,
}) =>
    LotesStruct(
      id: id,
      createdAt: createdAt,
      idPropriedade: idPropriedade,
      idAnimais: idAnimais,
      nome: nome,
      anotacoes: anotacoes,
      ativo: ativo,
      dataEntradaPiquete: dataEntradaPiquete,
      dataSaidaPiquete: dataSaidaPiquete,
      motivo: motivo,
      dataMotivo: dataMotivo,
      idLote: idLote,
      deletado: deletado,
      updatedAt: updatedAt,
      qtdRebanhosNoLote: qtdRebanhosNoLote,
    );
