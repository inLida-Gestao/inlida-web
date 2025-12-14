import '../database.dart';

class PatrociniosTable extends SupabaseTable<PatrociniosRow> {
  @override
  String get tableName => 'patrocinios';

  @override
  PatrociniosRow createRow(Map<String, dynamic> data) => PatrociniosRow(data);
}

class PatrociniosRow extends SupabaseDataRow {
  PatrociniosRow(super.data);

  @override
  SupabaseTable get table => PatrociniosTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get imagem => getField<String>('imagem');
  set imagem(String? value) => setField<String>('imagem', value);

  String? get link => getField<String>('link');
  set link(String? value) => setField<String>('link', value);
}
