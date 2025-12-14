import '../database.dart';

class ReproducaoChangeTrackerTable
    extends SupabaseTable<ReproducaoChangeTrackerRow> {
  @override
  String get tableName => 'reproducao_change_tracker';

  @override
  ReproducaoChangeTrackerRow createRow(Map<String, dynamic> data) =>
      ReproducaoChangeTrackerRow(data);
}

class ReproducaoChangeTrackerRow extends SupabaseDataRow {
  ReproducaoChangeTrackerRow(super.data);

  @override
  SupabaseTable get table => ReproducaoChangeTrackerTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get lastChange => getField<DateTime>('last_change')!;
  set lastChange(DateTime value) => setField<DateTime>('last_change', value);
}
