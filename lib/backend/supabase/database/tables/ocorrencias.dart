import '../database.dart';

class OcorrenciasTable extends SupabaseTable<OcorrenciasRow> {
  @override
  String get tableName => 'ocorrencias';

  @override
  OcorrenciasRow createRow(Map<String, dynamic> data) => OcorrenciasRow(data);
}

class OcorrenciasRow extends SupabaseDataRow {
  OcorrenciasRow(super.data);

  @override
  SupabaseTable get table => OcorrenciasTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get idPastagem => getField<String>('id_pastagem');
  set idPastagem(String? value) => setField<String>('id_pastagem', value);

  String? get idUser => getField<String>('id_user');
  set idUser(String? value) => setField<String>('id_user', value);

  String? get idPropriedade => getField<String>('id_propriedade');
  set idPropriedade(String? value) => setField<String>('id_propriedade', value);

  List<String> get ocorrencias => getListField<String>('ocorrencias');
  set ocorrencias(List<String>? value) =>
      setListField<String>('ocorrencias', value);

  double? get porcetagem => getField<double>('porcetagem');
  set porcetagem(double? value) => setField<double>('porcetagem', value);

  String? get anotacoes => getField<String>('anotacoes');
  set anotacoes(String? value) => setField<String>('anotacoes', value);

  String? get idOcorrencias => getField<String>('id_ocorrencias');
  set idOcorrencias(String? value) => setField<String>('id_ocorrencias', value);
}
