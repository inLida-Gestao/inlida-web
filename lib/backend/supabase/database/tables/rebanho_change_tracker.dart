import '../database.dart';

class RebanhoChangeTrackerTable extends SupabaseTable<RebanhoChangeTrackerRow> {
  @override
  String get tableName => 'rebanho_change_tracker';

  @override
  RebanhoChangeTrackerRow createRow(Map<String, dynamic> data) =>
      RebanhoChangeTrackerRow(data);
}

class RebanhoChangeTrackerRow extends SupabaseDataRow {
  RebanhoChangeTrackerRow(super.data);

  @override
  SupabaseTable get table => RebanhoChangeTrackerTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get lastChange => getField<DateTime>('last_change')!;
  set lastChange(DateTime value) => setField<DateTime>('last_change', value);
}
