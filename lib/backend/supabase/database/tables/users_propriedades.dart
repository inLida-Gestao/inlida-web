import '../database.dart';

class UsersPropriedadesTable extends SupabaseTable<UsersPropriedadesRow> {
  @override
  String get tableName => 'users_propriedades';

  @override
  UsersPropriedadesRow createRow(Map<String, dynamic> data) =>
      UsersPropriedadesRow(data);
}

class UsersPropriedadesRow extends SupabaseDataRow {
  UsersPropriedadesRow(super.data);

  @override
  SupabaseTable get table => UsersPropriedadesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get nome => getField<String>('nome');
  set nome(String? value) => setField<String>('nome', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get foto => getField<String>('foto');
  set foto(String? value) => setField<String>('foto', value);

  String? get permissao => getField<String>('permissao');
  set permissao(String? value) => setField<String>('permissao', value);

  String? get idPropriedade => getField<String>('idPropriedade');
  set idPropriedade(String? value) => setField<String>('idPropriedade', value);

  String? get deletado => getField<String>('deletado');
  set deletado(String? value) => setField<String>('deletado', value);
}
