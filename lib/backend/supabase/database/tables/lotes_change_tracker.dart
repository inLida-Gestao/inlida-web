import '../database.dart';

class LotesChangeTrackerTable extends SupabaseTable<LotesChangeTrackerRow> {
  @override
  String get tableName => 'lotes_change_tracker';

  @override
  LotesChangeTrackerRow createRow(Map<String, dynamic> data) =>
      LotesChangeTrackerRow(data);
}

class LotesChangeTrackerRow extends SupabaseDataRow {
  LotesChangeTrackerRow(super.data);

  @override
  SupabaseTable get table => LotesChangeTrackerTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get lastChange => getField<DateTime>('last_change')!;
  set lastChange(DateTime value) => setField<DateTime>('last_change', value);
}
