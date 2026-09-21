import '../database.dart';

/// Contagem por codigo de problema de uma importacao. Nunca truncado.
class ImportAuditoriaResumoTable
    extends SupabaseTable<ImportAuditoriaResumoRow> {
  @override
  String get tableName => 'import_auditoria_resumo';

  @override
  ImportAuditoriaResumoRow createRow(Map<String, dynamic> data) =>
      ImportAuditoriaResumoRow(data);
}

class ImportAuditoriaResumoRow extends SupabaseDataRow {
  ImportAuditoriaResumoRow(super.data);

  @override
  SupabaseTable get table => ImportAuditoriaResumoTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get auditoriaId => getField<String>('auditoria_id')!;
  set auditoriaId(String value) => setField<String>('auditoria_id', value);

  String get codigo => getField<String>('codigo')!;
  set codigo(String value) => setField<String>('codigo', value);

  String get severidade => getField<String>('severidade')!;
  set severidade(String value) => setField<String>('severidade', value);

  String get escopo => getField<String>('escopo')!;
  set escopo(String value) => setField<String>('escopo', value);

  String? get coluna => getField<String>('coluna');
  set coluna(String? value) => setField<String>('coluna', value);

  int get quantidade => getField<int>('quantidade')!;
  set quantidade(int value) => setField<int>('quantidade', value);

  String? get mensagem => getField<String>('mensagem');
  set mensagem(String? value) => setField<String>('mensagem', value);

  /// jsonb, e nao integer[], porque getField nao lida com arrays do Postgres.
  /// Ler pelo mapa cru evita a conversao tipada, que aqui nao ajuda.
  List<int> get linhasAmostra {
    final bruto = data['linhas_amostra'];
    if (bruto is List) {
      return bruto
          .map((e) => e is int ? e : int.tryParse(e.toString()))
          .whereType<int>()
          .toList();
    }
    return const [];
  }
}
