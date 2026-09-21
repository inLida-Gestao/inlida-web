import '../database.dart';

/// Amostra do detalhe de uma importacao: ate 50 por codigo e 1000 por
/// auditoria, truncada no cliente.
class ImportAuditoriaItemTable extends SupabaseTable<ImportAuditoriaItemRow> {
  @override
  String get tableName => 'import_auditoria_item';

  @override
  ImportAuditoriaItemRow createRow(Map<String, dynamic> data) =>
      ImportAuditoriaItemRow(data);
}

class ImportAuditoriaItemRow extends SupabaseDataRow {
  ImportAuditoriaItemRow(super.data);

  @override
  SupabaseTable get table => ImportAuditoriaItemTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get auditoriaId => getField<String>('auditoria_id')!;
  set auditoriaId(String value) => setField<String>('auditoria_id', value);

  int? get linha => getField<int>('linha');
  set linha(int? value) => setField<int>('linha', value);

  String get severidade => getField<String>('severidade')!;
  set severidade(String value) => setField<String>('severidade', value);

  String get escopo => getField<String>('escopo')!;
  set escopo(String value) => setField<String>('escopo', value);

  String get codigo => getField<String>('codigo')!;
  set codigo(String value) => setField<String>('codigo', value);

  String? get coluna => getField<String>('coluna');
  set coluna(String? value) => setField<String>('coluna', value);

  String? get valor => getField<String>('valor');
  set valor(String? value) => setField<String>('valor', value);

  String? get mensagem => getField<String>('mensagem');
  set mensagem(String? value) => setField<String>('mensagem', value);

  String? get acaoResultante => getField<String>('acao_resultante');
  set acaoResultante(String? value) =>
      setField<String>('acao_resultante', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
