import '../database.dart';

class AnunciosTable extends SupabaseTable<AnunciosRow> {
  @override
  String get tableName => 'anuncios';

  @override
  AnunciosRow createRow(Map<String, dynamic> data) => AnunciosRow(data);
}

class AnunciosRow extends SupabaseDataRow {
  AnunciosRow(super.data);

  @override
  SupabaseTable get table => AnunciosTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get imagem => getField<String>('imagem');
  set imagem(String? value) => setField<String>('imagem', value);

  String? get link => getField<String>('link');
  set link(String? value) => setField<String>('link', value);
}
