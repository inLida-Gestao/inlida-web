import '../database.dart';

class SanidadeChangeTrackerTable
    extends SupabaseTable<SanidadeChangeTrackerRow> {
  @override
  String get tableName => 'sanidade_change_tracker';

  @override
  SanidadeChangeTrackerRow createRow(Map<String, dynamic> data) =>
      SanidadeChangeTrackerRow(data);
}

class SanidadeChangeTrackerRow extends SupabaseDataRow {
  SanidadeChangeTrackerRow(super.data);

  @override
  SupabaseTable get table => SanidadeChangeTrackerTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get lastChange => getField<DateTime>('last_change')!;
  set lastChange(DateTime value) => setField<DateTime>('last_change', value);
}
