import '../database.dart';

class PastagemTable extends SupabaseTable<PastagemRow> {
  @override
  String get tableName => 'pastagem';

  @override
  PastagemRow createRow(Map<String, dynamic> data) => PastagemRow(data);
}

class PastagemRow extends SupabaseDataRow {
  PastagemRow(super.data);

  @override
  SupabaseTable get table => PastagemTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get idPropriedade => getField<String>('id_propriedade');
  set idPropriedade(String? value) => setField<String>('id_propriedade', value);

  String? get idPiquete => getField<String>('id_piquete');
  set idPiquete(String? value) => setField<String>('id_piquete', value);

  String? get dataManejo => getField<String>('data_manejo');
  set dataManejo(String? value) => setField<String>('data_manejo', value);

  String? get qualidade => getField<String>('qualidade');
  set qualidade(String? value) => setField<String>('qualidade', value);

  String? get observacao => getField<String>('observacao');
  set observacao(String? value) => setField<String>('observacao', value);

  List<String> get manejos => getListField<String>('manejos');
  set manejos(List<String>? value) => setListField<String>('manejos', value);

  String? get idPastagem => getField<String>('id_pastagem');
  set idPastagem(String? value) => setField<String>('id_pastagem', value);
}
