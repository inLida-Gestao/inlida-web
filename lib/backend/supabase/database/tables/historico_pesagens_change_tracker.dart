import '../database.dart';

class HistoricoPesagensChangeTrackerTable
    extends SupabaseTable<HistoricoPesagensChangeTrackerRow> {
  @override
  String get tableName => 'historico_pesagens_change_tracker';

  @override
  HistoricoPesagensChangeTrackerRow createRow(Map<String, dynamic> data) =>
      HistoricoPesagensChangeTrackerRow(data);
}

class HistoricoPesagensChangeTrackerRow extends SupabaseDataRow {
  HistoricoPesagensChangeTrackerRow(super.data);

  @override
  SupabaseTable get table => HistoricoPesagensChangeTrackerTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get lastChange => getField<DateTime>('last_change')!;
  set lastChange(DateTime value) => setField<DateTime>('last_change', value);
}
