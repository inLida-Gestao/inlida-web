import '../database.dart';

class HistoricoPesagensTable extends SupabaseTable<HistoricoPesagensRow> {
  @override
  String get tableName => 'historico_pesagens';

  @override
  HistoricoPesagensRow createRow(Map<String, dynamic> data) =>
      HistoricoPesagensRow(data);
}

class HistoricoPesagensRow extends SupabaseDataRow {
  HistoricoPesagensRow(super.data);

  @override
  SupabaseTable get table => HistoricoPesagensTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get idRebanho => getField<String>('idRebanho');
  set idRebanho(String? value) => setField<String>('idRebanho', value);

  DateTime? get dataPesagem => getField<DateTime>('dataPesagem');
  set dataPesagem(DateTime? value) => setField<DateTime>('dataPesagem', value);

  String? get tipo => getField<String>('tipo');
  set tipo(String? value) => setField<String>('tipo', value);

  double? get peso => getField<double>('peso');
  set peso(double? value) => setField<double>('peso', value);

  String? get deletado => getField<String>('deletado');
  set deletado(String? value) => setField<String>('deletado', value);

  String? get idPropriedade => getField<String>('id_propriedade');
  set idPropriedade(String? value) => setField<String>('id_propriedade', value);
}
