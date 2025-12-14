import '../database.dart';

class PiqueteTable extends SupabaseTable<PiqueteRow> {
  @override
  String get tableName => 'piquete';

  @override
  PiqueteRow createRow(Map<String, dynamic> data) => PiqueteRow(data);
}

class PiqueteRow extends SupabaseDataRow {
  PiqueteRow(super.data);

  @override
  SupabaseTable get table => PiqueteTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get nome => getField<String>('nome');
  set nome(String? value) => setField<String>('nome', value);

  double? get area => getField<double>('area');
  set area(double? value) => setField<double>('area', value);

  List<String> get forrageria => getListField<String>('forrageria');
  set forrageria(List<String>? value) =>
      setListField<String>('forrageria', value);

  String? get anotacoes => getField<String>('anotacoes');
  set anotacoes(String? value) => setField<String>('anotacoes', value);

  String? get incluirPiquete => getField<String>('incluir_piquete');
  set incluirPiquete(String? value) =>
      setField<String>('incluir_piquete', value);

  List<String> get idRebanhos => getListField<String>('id_rebanhos');
  set idRebanhos(List<String>? value) =>
      setListField<String>('id_rebanhos', value);

  List<String> get idLotes => getListField<String>('id_lotes');
  set idLotes(List<String>? value) => setListField<String>('id_lotes', value);

  String? get idPiquete => getField<String>('id_piquete');
  set idPiquete(String? value) => setField<String>('id_piquete', value);

  String? get idPropriedade => getField<String>('id_propriedade');
  set idPropriedade(String? value) => setField<String>('id_propriedade', value);
}
