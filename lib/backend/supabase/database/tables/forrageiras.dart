import '../database.dart';

class ForrageirasTable extends SupabaseTable<ForrageirasRow> {
  @override
  String get tableName => 'forrageiras';

  @override
  ForrageirasRow createRow(Map<String, dynamic> data) => ForrageirasRow(data);
}

class ForrageirasRow extends SupabaseDataRow {
  ForrageirasRow(super.data);

  @override
  SupabaseTable get table => ForrageirasTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get nome => getField<String>('nome')!;
  set nome(String value) => setField<String>('nome', value);
}
