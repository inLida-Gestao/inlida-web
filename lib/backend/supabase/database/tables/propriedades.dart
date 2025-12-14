import '../database.dart';

class PropriedadesTable extends SupabaseTable<PropriedadesRow> {
  @override
  String get tableName => 'propriedades';

  @override
  PropriedadesRow createRow(Map<String, dynamic> data) => PropriedadesRow(data);
}

class PropriedadesRow extends SupabaseDataRow {
  PropriedadesRow(super.data);

  @override
  SupabaseTable get table => PropriedadesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get userID => getField<String>('userID');
  set userID(String? value) => setField<String>('userID', value);

  String? get usersID => getField<String>('usersID');
  set usersID(String? value) => setField<String>('usersID', value);

  String? get rebanhosID => getField<String>('rebanhosID');
  set rebanhosID(String? value) => setField<String>('rebanhosID', value);

  String? get anotacoes => getField<String>('anotacoes');
  set anotacoes(String? value) => setField<String>('anotacoes', value);

  int? get areaAgricultura => getField<int>('areaAgricultura');
  set areaAgricultura(int? value) => setField<int>('areaAgricultura', value);

  int? get areaBenfeitoria => getField<int>('areaBenfeitoria');
  set areaBenfeitoria(int? value) => setField<int>('areaBenfeitoria', value);

  int? get areaPastagem => getField<int>('areaPastagem');
  set areaPastagem(int? value) => setField<int>('areaPastagem', value);

  int? get areaReserva => getField<int>('areaReserva');
  set areaReserva(int? value) => setField<int>('areaReserva', value);

  int? get areaTotal => getField<int>('areaTotal');
  set areaTotal(int? value) => setField<int>('areaTotal', value);

  String? get cidade => getField<String>('cidade');
  set cidade(String? value) => setField<String>('cidade', value);

  String? get estado => getField<String>('estado');
  set estado(String? value) => setField<String>('estado', value);

  String? get icone => getField<String>('icone');
  set icone(String? value) => setField<String>('icone', value);

  String? get idPropriedade => getField<String>('idPropriedade');
  set idPropriedade(String? value) => setField<String>('idPropriedade', value);

  String? get atividades => getField<String>('atividades');
  set atividades(String? value) => setField<String>('atividades', value);

  String? get nome => getField<String>('nome');
  set nome(String? value) => setField<String>('nome', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  int? get importadosupa => getField<int>('importadosupa');
  set importadosupa(int? value) => setField<int>('importadosupa', value);

  String? get deletado => getField<String>('deletado');
  set deletado(String? value) => setField<String>('deletado', value);

  double? get countRebanhos => getField<double>('countRebanhos');
  set countRebanhos(double? value) => setField<double>('countRebanhos', value);
}
