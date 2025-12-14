// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PropriedadeStruct extends BaseStruct {
  PropriedadeStruct({
    int? id,
    String? createdAt,
    String? userID,
    String? usersID,
    String? rebanhosID,
    String? anotacoes,
    int? areaAgricultura,
    int? areaBenfeitoria,
    int? areaPastagem,
    int? areaReserva,
    int? areaTotal,
    String? cidade,
    String? estado,
    String? icone,
    String? idPropriedade,
    String? atividades,
    String? nome,
    String? updatedAt,
    int? importadosupa,
    String? deletado,
    int? countRebanhos,
  })  : _id = id,
        _createdAt = createdAt,
        _userID = userID,
        _usersID = usersID,
        _rebanhosID = rebanhosID,
        _anotacoes = anotacoes,
        _areaAgricultura = areaAgricultura,
        _areaBenfeitoria = areaBenfeitoria,
        _areaPastagem = areaPastagem,
        _areaReserva = areaReserva,
        _areaTotal = areaTotal,
        _cidade = cidade,
        _estado = estado,
        _icone = icone,
        _idPropriedade = idPropriedade,
        _atividades = atividades,
        _nome = nome,
        _updatedAt = updatedAt,
        _importadosupa = importadosupa,
        _deletado = deletado,
        _countRebanhos = countRebanhos;

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

  // "userID" field.
  String? _userID;
  String get userID => _userID ?? '';
  set userID(String? val) => _userID = val;

  bool hasUserID() => _userID != null;

  // "usersID" field.
  String? _usersID;
  String get usersID => _usersID ?? '';
  set usersID(String? val) => _usersID = val;

  bool hasUsersID() => _usersID != null;

  // "rebanhosID" field.
  String? _rebanhosID;
  String get rebanhosID => _rebanhosID ?? '';
  set rebanhosID(String? val) => _rebanhosID = val;

  bool hasRebanhosID() => _rebanhosID != null;

  // "anotacoes" field.
  String? _anotacoes;
  String get anotacoes => _anotacoes ?? '';
  set anotacoes(String? val) => _anotacoes = val;

  bool hasAnotacoes() => _anotacoes != null;

  // "areaAgricultura" field.
  int? _areaAgricultura;
  int get areaAgricultura => _areaAgricultura ?? 0;
  set areaAgricultura(int? val) => _areaAgricultura = val;

  void incrementAreaAgricultura(int amount) =>
      areaAgricultura = areaAgricultura + amount;

  bool hasAreaAgricultura() => _areaAgricultura != null;

  // "areaBenfeitoria" field.
  int? _areaBenfeitoria;
  int get areaBenfeitoria => _areaBenfeitoria ?? 0;
  set areaBenfeitoria(int? val) => _areaBenfeitoria = val;

  void incrementAreaBenfeitoria(int amount) =>
      areaBenfeitoria = areaBenfeitoria + amount;

  bool hasAreaBenfeitoria() => _areaBenfeitoria != null;

  // "areaPastagem" field.
  int? _areaPastagem;
  int get areaPastagem => _areaPastagem ?? 0;
  set areaPastagem(int? val) => _areaPastagem = val;

  void incrementAreaPastagem(int amount) =>
      areaPastagem = areaPastagem + amount;

  bool hasAreaPastagem() => _areaPastagem != null;

  // "areaReserva" field.
  int? _areaReserva;
  int get areaReserva => _areaReserva ?? 0;
  set areaReserva(int? val) => _areaReserva = val;

  void incrementAreaReserva(int amount) => areaReserva = areaReserva + amount;

  bool hasAreaReserva() => _areaReserva != null;

  // "areaTotal" field.
  int? _areaTotal;
  int get areaTotal => _areaTotal ?? 0;
  set areaTotal(int? val) => _areaTotal = val;

  void incrementAreaTotal(int amount) => areaTotal = areaTotal + amount;

  bool hasAreaTotal() => _areaTotal != null;

  // "cidade" field.
  String? _cidade;
  String get cidade => _cidade ?? '';
  set cidade(String? val) => _cidade = val;

  bool hasCidade() => _cidade != null;

  // "estado" field.
  String? _estado;
  String get estado => _estado ?? '';
  set estado(String? val) => _estado = val;

  bool hasEstado() => _estado != null;

  // "icone" field.
  String? _icone;
  String get icone => _icone ?? '';
  set icone(String? val) => _icone = val;

  bool hasIcone() => _icone != null;

  // "idPropriedade" field.
  String? _idPropriedade;
  String get idPropriedade => _idPropriedade ?? '';
  set idPropriedade(String? val) => _idPropriedade = val;

  bool hasIdPropriedade() => _idPropriedade != null;

  // "atividades" field.
  String? _atividades;
  String get atividades => _atividades ?? '';
  set atividades(String? val) => _atividades = val;

  bool hasAtividades() => _atividades != null;

  // "nome" field.
  String? _nome;
  String get nome => _nome ?? '';
  set nome(String? val) => _nome = val;

  bool hasNome() => _nome != null;

  // "updated_at" field.
  String? _updatedAt;
  String get updatedAt => _updatedAt ?? '';
  set updatedAt(String? val) => _updatedAt = val;

  bool hasUpdatedAt() => _updatedAt != null;

  // "importadosupa" field.
  int? _importadosupa;
  int get importadosupa => _importadosupa ?? 0;
  set importadosupa(int? val) => _importadosupa = val;

  void incrementImportadosupa(int amount) =>
      importadosupa = importadosupa + amount;

  bool hasImportadosupa() => _importadosupa != null;

  // "deletado" field.
  String? _deletado;
  String get deletado => _deletado ?? '';
  set deletado(String? val) => _deletado = val;

  bool hasDeletado() => _deletado != null;

  // "countRebanhos" field.
  int? _countRebanhos;
  int get countRebanhos => _countRebanhos ?? 0;
  set countRebanhos(int? val) => _countRebanhos = val;

  void incrementCountRebanhos(int amount) =>
      countRebanhos = countRebanhos + amount;

  bool hasCountRebanhos() => _countRebanhos != null;

  static PropriedadeStruct fromMap(Map<String, dynamic> data) =>
      PropriedadeStruct(
        id: castToType<int>(data['id']),
        createdAt: data['created_at'] as String?,
        userID: data['userID'] as String?,
        usersID: data['usersID'] as String?,
        rebanhosID: data['rebanhosID'] as String?,
        anotacoes: data['anotacoes'] as String?,
        areaAgricultura: castToType<int>(data['areaAgricultura']),
        areaBenfeitoria: castToType<int>(data['areaBenfeitoria']),
        areaPastagem: castToType<int>(data['areaPastagem']),
        areaReserva: castToType<int>(data['areaReserva']),
        areaTotal: castToType<int>(data['areaTotal']),
        cidade: data['cidade'] as String?,
        estado: data['estado'] as String?,
        icone: data['icone'] as String?,
        idPropriedade: data['idPropriedade'] as String?,
        atividades: data['atividades'] as String?,
        nome: data['nome'] as String?,
        updatedAt: data['updated_at'] as String?,
        importadosupa: castToType<int>(data['importadosupa']),
        deletado: data['deletado'] as String?,
        countRebanhos: castToType<int>(data['countRebanhos']),
      );

  static PropriedadeStruct? maybeFromMap(dynamic data) => data is Map
      ? PropriedadeStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'created_at': _createdAt,
        'userID': _userID,
        'usersID': _usersID,
        'rebanhosID': _rebanhosID,
        'anotacoes': _anotacoes,
        'areaAgricultura': _areaAgricultura,
        'areaBenfeitoria': _areaBenfeitoria,
        'areaPastagem': _areaPastagem,
        'areaReserva': _areaReserva,
        'areaTotal': _areaTotal,
        'cidade': _cidade,
        'estado': _estado,
        'icone': _icone,
        'idPropriedade': _idPropriedade,
        'atividades': _atividades,
        'nome': _nome,
        'updated_at': _updatedAt,
        'importadosupa': _importadosupa,
        'deletado': _deletado,
        'countRebanhos': _countRebanhos,
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
        'userID': serializeParam(
          _userID,
          ParamType.String,
        ),
        'usersID': serializeParam(
          _usersID,
          ParamType.String,
        ),
        'rebanhosID': serializeParam(
          _rebanhosID,
          ParamType.String,
        ),
        'anotacoes': serializeParam(
          _anotacoes,
          ParamType.String,
        ),
        'areaAgricultura': serializeParam(
          _areaAgricultura,
          ParamType.int,
        ),
        'areaBenfeitoria': serializeParam(
          _areaBenfeitoria,
          ParamType.int,
        ),
        'areaPastagem': serializeParam(
          _areaPastagem,
          ParamType.int,
        ),
        'areaReserva': serializeParam(
          _areaReserva,
          ParamType.int,
        ),
        'areaTotal': serializeParam(
          _areaTotal,
          ParamType.int,
        ),
        'cidade': serializeParam(
          _cidade,
          ParamType.String,
        ),
        'estado': serializeParam(
          _estado,
          ParamType.String,
        ),
        'icone': serializeParam(
          _icone,
          ParamType.String,
        ),
        'idPropriedade': serializeParam(
          _idPropriedade,
          ParamType.String,
        ),
        'atividades': serializeParam(
          _atividades,
          ParamType.String,
        ),
        'nome': serializeParam(
          _nome,
          ParamType.String,
        ),
        'updated_at': serializeParam(
          _updatedAt,
          ParamType.String,
        ),
        'importadosupa': serializeParam(
          _importadosupa,
          ParamType.int,
        ),
        'deletado': serializeParam(
          _deletado,
          ParamType.String,
        ),
        'countRebanhos': serializeParam(
          _countRebanhos,
          ParamType.int,
        ),
      }.withoutNulls;

  static PropriedadeStruct fromSerializableMap(Map<String, dynamic> data) =>
      PropriedadeStruct(
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
        userID: deserializeParam(
          data['userID'],
          ParamType.String,
          false,
        ),
        usersID: deserializeParam(
          data['usersID'],
          ParamType.String,
          false,
        ),
        rebanhosID: deserializeParam(
          data['rebanhosID'],
          ParamType.String,
          false,
        ),
        anotacoes: deserializeParam(
          data['anotacoes'],
          ParamType.String,
          false,
        ),
        areaAgricultura: deserializeParam(
          data['areaAgricultura'],
          ParamType.int,
          false,
        ),
        areaBenfeitoria: deserializeParam(
          data['areaBenfeitoria'],
          ParamType.int,
          false,
        ),
        areaPastagem: deserializeParam(
          data['areaPastagem'],
          ParamType.int,
          false,
        ),
        areaReserva: deserializeParam(
          data['areaReserva'],
          ParamType.int,
          false,
        ),
        areaTotal: deserializeParam(
          data['areaTotal'],
          ParamType.int,
          false,
        ),
        cidade: deserializeParam(
          data['cidade'],
          ParamType.String,
          false,
        ),
        estado: deserializeParam(
          data['estado'],
          ParamType.String,
          false,
        ),
        icone: deserializeParam(
          data['icone'],
          ParamType.String,
          false,
        ),
        idPropriedade: deserializeParam(
          data['idPropriedade'],
          ParamType.String,
          false,
        ),
        atividades: deserializeParam(
          data['atividades'],
          ParamType.String,
          false,
        ),
        nome: deserializeParam(
          data['nome'],
          ParamType.String,
          false,
        ),
        updatedAt: deserializeParam(
          data['updated_at'],
          ParamType.String,
          false,
        ),
        importadosupa: deserializeParam(
          data['importadosupa'],
          ParamType.int,
          false,
        ),
        deletado: deserializeParam(
          data['deletado'],
          ParamType.String,
          false,
        ),
        countRebanhos: deserializeParam(
          data['countRebanhos'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'PropriedadeStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is PropriedadeStruct &&
        id == other.id &&
        createdAt == other.createdAt &&
        userID == other.userID &&
        usersID == other.usersID &&
        rebanhosID == other.rebanhosID &&
        anotacoes == other.anotacoes &&
        areaAgricultura == other.areaAgricultura &&
        areaBenfeitoria == other.areaBenfeitoria &&
        areaPastagem == other.areaPastagem &&
        areaReserva == other.areaReserva &&
        areaTotal == other.areaTotal &&
        cidade == other.cidade &&
        estado == other.estado &&
        icone == other.icone &&
        idPropriedade == other.idPropriedade &&
        atividades == other.atividades &&
        nome == other.nome &&
        updatedAt == other.updatedAt &&
        importadosupa == other.importadosupa &&
        deletado == other.deletado &&
        countRebanhos == other.countRebanhos;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        createdAt,
        userID,
        usersID,
        rebanhosID,
        anotacoes,
        areaAgricultura,
        areaBenfeitoria,
        areaPastagem,
        areaReserva,
        areaTotal,
        cidade,
        estado,
        icone,
        idPropriedade,
        atividades,
        nome,
        updatedAt,
        importadosupa,
        deletado,
        countRebanhos
      ]);
}

PropriedadeStruct createPropriedadeStruct({
  int? id,
  String? createdAt,
  String? userID,
  String? usersID,
  String? rebanhosID,
  String? anotacoes,
  int? areaAgricultura,
  int? areaBenfeitoria,
  int? areaPastagem,
  int? areaReserva,
  int? areaTotal,
  String? cidade,
  String? estado,
  String? icone,
  String? idPropriedade,
  String? atividades,
  String? nome,
  String? updatedAt,
  int? importadosupa,
  String? deletado,
  int? countRebanhos,
}) =>
    PropriedadeStruct(
      id: id,
      createdAt: createdAt,
      userID: userID,
      usersID: usersID,
      rebanhosID: rebanhosID,
      anotacoes: anotacoes,
      areaAgricultura: areaAgricultura,
      areaBenfeitoria: areaBenfeitoria,
      areaPastagem: areaPastagem,
      areaReserva: areaReserva,
      areaTotal: areaTotal,
      cidade: cidade,
      estado: estado,
      icone: icone,
      idPropriedade: idPropriedade,
      atividades: atividades,
      nome: nome,
      updatedAt: updatedAt,
      importadosupa: importadosupa,
      deletado: deletado,
      countRebanhos: countRebanhos,
    );
