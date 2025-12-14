import '../database.dart';

class CidadesTable extends SupabaseTable<CidadesRow> {
  @override
  String get tableName => 'cidades';

  @override
  CidadesRow createRow(Map<String, dynamic> data) => CidadesRow(data);
}

class CidadesRow extends SupabaseDataRow {
  CidadesRow(super.data);

  @override
  SupabaseTable get table => CidadesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get uf => getField<String>('UF');
  set uf(String? value) => setField<String>('UF', value);

  String? get cidade => getField<String>('cidade');
  set cidade(String? value) => setField<String>('cidade', value);

  double? get latitude => getField<double>('latitude');
  set latitude(double? value) => setField<double>('latitude', value);

  double? get longitude => getField<double>('longitude');
  set longitude(double? value) => setField<double>('longitude', value);

  String? get nomeEstado => getField<String>('nome_estado');
  set nomeEstado(String? value) => setField<String>('nome_estado', value);
}
