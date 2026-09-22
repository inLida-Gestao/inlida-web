import '../database.dart';

/// Diff campo a campo de um registro sobrescrito por importacao.
/// Ver supabase/migrations/20260921200000_auditoria_importacao_alteracoes.sql.
class ImportAuditoriaAlteracaoTable
    extends SupabaseTable<ImportAuditoriaAlteracaoRow> {
  @override
  String get tableName => 'import_auditoria_alteracao';

  @override
  ImportAuditoriaAlteracaoRow createRow(Map<String, dynamic> data) =>
      ImportAuditoriaAlteracaoRow(data);
}

class ImportAuditoriaAlteracaoRow extends SupabaseDataRow {
  ImportAuditoriaAlteracaoRow(super.data);

  @override
  SupabaseTable get table => ImportAuditoriaAlteracaoTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get auditoriaId => getField<String>('auditoria_id')!;
  set auditoriaId(String value) => setField<String>('auditoria_id', value);

  int? get linha => getField<int>('linha');
  set linha(int? value) => setField<int>('linha', value);

  String? get chaveNegocio => getField<String>('chave_negocio');
  set chaveNegocio(String? value) => setField<String>('chave_negocio', value);

  String? get identificacao => getField<String>('identificacao');
  set identificacao(String? value) => setField<String>('identificacao', value);

  int get totalCampos => getField<int>('total_campos')!;
  set totalCampos(int value) => setField<int>('total_campos', value);

  int get totalApagados => getField<int>('total_apagados')!;
  set totalApagados(int value) => setField<int>('total_apagados', value);

  /// Mapa coluna -> {'de': valorAnterior, 'para': valorNovo}. Lido pelo mapa
  /// cru: getField nao converte jsonb aninhado.
  Map<String, dynamic> get campos {
    final bruto = data['campos'];
    return bruto is Map ? Map<String, dynamic>.from(bruto) : const {};
  }

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
