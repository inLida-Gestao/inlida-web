import '../database.dart';

class UsersTable extends SupabaseTable<UsersRow> {
  @override
  String get tableName => 'users';

  @override
  UsersRow createRow(Map<String, dynamic> data) => UsersRow(data);
}

class UsersRow extends SupabaseDataRow {
  UsersRow(super.data);

  @override
  SupabaseTable get table => UsersTable();

  String get userID => getField<String>('userID')!;
  set userID(String value) => setField<String>('userID', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get nome => getField<String>('nome');
  set nome(String? value) => setField<String>('nome', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  bool? get termos => getField<bool>('termos');
  set termos(bool? value) => setField<bool>('termos', value);

  String? get foto => getField<String>('foto');
  set foto(String? value) => setField<String>('foto', value);

  String? get telefone => getField<String>('telefone');
  set telefone(String? value) => setField<String>('telefone', value);

  bool? get excluido => getField<bool>('excluido');
  set excluido(bool? value) => setField<bool>('excluido', value);

  String? get permissao => getField<String>('permissao');
  set permissao(String? value) => setField<String>('permissao', value);

  String? get funcao => getField<String>('funcao');
  set funcao(String? value) => setField<String>('funcao', value);

  String? get acesso => getField<String>('acesso');
  set acesso(String? value) => setField<String>('acesso', value);

  String? get cpfCnpj => getField<String>('cpf_cnpj');
  set cpfCnpj(String? value) => setField<String>('cpf_cnpj', value);

  double? get valorAssinatura => getField<double>('valor_assinatura');
  set valorAssinatura(double? value) =>
      setField<double>('valor_assinatura', value);

  String? get cicloAssinatura => getField<String>('ciclo_assinatura');
  set cicloAssinatura(String? value) =>
      setField<String>('ciclo_assinatura', value);
}
