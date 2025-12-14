import '../database.dart';

class AdministradoresTable extends SupabaseTable<AdministradoresRow> {
  @override
  String get tableName => 'administradores';

  @override
  AdministradoresRow createRow(Map<String, dynamic> data) =>
      AdministradoresRow(data);
}

class AdministradoresRow extends SupabaseDataRow {
  AdministradoresRow(super.data);

  @override
  SupabaseTable get table => AdministradoresTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);
}
