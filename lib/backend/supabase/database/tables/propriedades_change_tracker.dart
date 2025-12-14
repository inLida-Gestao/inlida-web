import '../database.dart';

class PropriedadesChangeTrackerTable
    extends SupabaseTable<PropriedadesChangeTrackerRow> {
  @override
  String get tableName => 'propriedades_change_tracker';

  @override
  PropriedadesChangeTrackerRow createRow(Map<String, dynamic> data) =>
      PropriedadesChangeTrackerRow(data);
}

class PropriedadesChangeTrackerRow extends SupabaseDataRow {
  PropriedadesChangeTrackerRow(super.data);

  @override
  SupabaseTable get table => PropriedadesChangeTrackerTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime? get lastChange => getField<DateTime>('last_change');
  set lastChange(DateTime? value) => setField<DateTime>('last_change', value);
}
