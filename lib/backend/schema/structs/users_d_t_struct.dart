// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersDTStruct extends BaseStruct {
  UsersDTStruct({
    String? nome,
    String? email,
    String? foto,
    String? telefone,
    bool? excluido,
    String? permissao,
    String? funcao,
    String? userID,
  })  : _nome = nome,
        _email = email,
        _foto = foto,
        _telefone = telefone,
        _excluido = excluido,
        _permissao = permissao,
        _funcao = funcao,
        _userID = userID;

  // "nome" field.
  String? _nome;
  String get nome => _nome ?? '';
  set nome(String? val) => _nome = val;

  bool hasNome() => _nome != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  set email(String? val) => _email = val;

  bool hasEmail() => _email != null;

  // "foto" field.
  String? _foto;
  String get foto => _foto ?? '';
  set foto(String? val) => _foto = val;

  bool hasFoto() => _foto != null;

  // "telefone" field.
  String? _telefone;
  String get telefone => _telefone ?? '';
  set telefone(String? val) => _telefone = val;

  bool hasTelefone() => _telefone != null;

  // "excluido" field.
  bool? _excluido;
  bool get excluido => _excluido ?? false;
  set excluido(bool? val) => _excluido = val;

  bool hasExcluido() => _excluido != null;

  // "permissao" field.
  String? _permissao;
  String get permissao => _permissao ?? '';
  set permissao(String? val) => _permissao = val;

  bool hasPermissao() => _permissao != null;

  // "funcao" field.
  String? _funcao;
  String get funcao => _funcao ?? '';
  set funcao(String? val) => _funcao = val;

  bool hasFuncao() => _funcao != null;

  // "userID" field.
  String? _userID;
  String get userID => _userID ?? '';
  set userID(String? val) => _userID = val;

  bool hasUserID() => _userID != null;

  static UsersDTStruct fromMap(Map<String, dynamic> data) => UsersDTStruct(
        nome: data['nome'] as String?,
        email: data['email'] as String?,
        foto: data['foto'] as String?,
        telefone: data['telefone'] as String?,
        excluido: data['excluido'] as bool?,
        permissao: data['permissao'] as String?,
        funcao: data['funcao'] as String?,
        userID: data['userID'] as String?,
      );

  static UsersDTStruct? maybeFromMap(dynamic data) =>
      data is Map ? UsersDTStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'nome': _nome,
        'email': _email,
        'foto': _foto,
        'telefone': _telefone,
        'excluido': _excluido,
        'permissao': _permissao,
        'funcao': _funcao,
        'userID': _userID,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'nome': serializeParam(
          _nome,
          ParamType.String,
        ),
        'email': serializeParam(
          _email,
          ParamType.String,
        ),
        'foto': serializeParam(
          _foto,
          ParamType.String,
        ),
        'telefone': serializeParam(
          _telefone,
          ParamType.String,
        ),
        'excluido': serializeParam(
          _excluido,
          ParamType.bool,
        ),
        'permissao': serializeParam(
          _permissao,
          ParamType.String,
        ),
        'funcao': serializeParam(
          _funcao,
          ParamType.String,
        ),
        'userID': serializeParam(
          _userID,
          ParamType.String,
        ),
      }.withoutNulls;

  static UsersDTStruct fromSerializableMap(Map<String, dynamic> data) =>
      UsersDTStruct(
        nome: deserializeParam(
          data['nome'],
          ParamType.String,
          false,
        ),
        email: deserializeParam(
          data['email'],
          ParamType.String,
          false,
        ),
        foto: deserializeParam(
          data['foto'],
          ParamType.String,
          false,
        ),
        telefone: deserializeParam(
          data['telefone'],
          ParamType.String,
          false,
        ),
        excluido: deserializeParam(
          data['excluido'],
          ParamType.bool,
          false,
        ),
        permissao: deserializeParam(
          data['permissao'],
          ParamType.String,
          false,
        ),
        funcao: deserializeParam(
          data['funcao'],
          ParamType.String,
          false,
        ),
        userID: deserializeParam(
          data['userID'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'UsersDTStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UsersDTStruct &&
        nome == other.nome &&
        email == other.email &&
        foto == other.foto &&
        telefone == other.telefone &&
        excluido == other.excluido &&
        permissao == other.permissao &&
        funcao == other.funcao &&
        userID == other.userID;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([nome, email, foto, telefone, excluido, permissao, funcao, userID]);
}

UsersDTStruct createUsersDTStruct({
  String? nome,
  String? email,
  String? foto,
  String? telefone,
  bool? excluido,
  String? permissao,
  String? funcao,
  String? userID,
}) =>
    UsersDTStruct(
      nome: nome,
      email: email,
      foto: foto,
      telefone: telefone,
      excluido: excluido,
      permissao: permissao,
      funcao: funcao,
      userID: userID,
    );
