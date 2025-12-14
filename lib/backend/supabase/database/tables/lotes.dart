import '../database.dart';

class LotesTable extends SupabaseTable<LotesRow> {
  @override
  String get tableName => 'lotes';

  @override
  LotesRow createRow(Map<String, dynamic> data) => LotesRow(data);
}

class LotesRow extends SupabaseDataRow {
  LotesRow(super.data);

  @override
  SupabaseTable get table => LotesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get idPropriedade => getField<String>('id_propriedade');
  set idPropriedade(String? value) => setField<String>('id_propriedade', value);

  String? get idAnimais => getField<String>('id_animais');
  set idAnimais(String? value) => setField<String>('id_animais', value);

  String? get nome => getField<String>('nome');
  set nome(String? value) => setField<String>('nome', value);

  String? get anotacoes => getField<String>('anotacoes');
  set anotacoes(String? value) => setField<String>('anotacoes', value);

  String? get ativo => getField<String>('ativo');
  set ativo(String? value) => setField<String>('ativo', value);

  DateTime? get dataEntradaPiquete =>
      getField<DateTime>('data_entrada_piquete');
  set dataEntradaPiquete(DateTime? value) =>
      setField<DateTime>('data_entrada_piquete', value);

  DateTime? get dataSaidaPiquete => getField<DateTime>('data_saida_piquete');
  set dataSaidaPiquete(DateTime? value) =>
      setField<DateTime>('data_saida_piquete', value);

  String? get motivo => getField<String>('motivo');
  set motivo(String? value) => setField<String>('motivo', value);

  DateTime? get dataMotivo => getField<DateTime>('data_motivo');
  set dataMotivo(DateTime? value) => setField<DateTime>('data_motivo', value);

  String? get idLote => getField<String>('id_lote');
  set idLote(String? value) => setField<String>('id_lote', value);

  String? get deletado => getField<String>('deletado');
  set deletado(String? value) => setField<String>('deletado', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  double? get valorVenda => getField<double>('valorVenda');
  set valorVenda(double? value) => setField<double>('valorVenda', value);
}
