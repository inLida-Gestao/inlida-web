import '../database.dart';

/// Uma tentativa de importacao de planilha, inclusive as canceladas.
/// Ver supabase/migrations/20260921180000_auditoria_importacao_planilhas.sql.
class ImportAuditoriaTable extends SupabaseTable<ImportAuditoriaRow> {
  @override
  String get tableName => 'import_auditoria';

  @override
  ImportAuditoriaRow createRow(Map<String, dynamic> data) =>
      ImportAuditoriaRow(data);
}

class ImportAuditoriaRow extends SupabaseDataRow {
  ImportAuditoriaRow(super.data);

  @override
  SupabaseTable get table => ImportAuditoriaTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get idPropriedade => getField<String>('id_propriedade')!;
  set idPropriedade(String value) => setField<String>('id_propriedade', value);

  String? get usuarioId => getField<String>('usuario_id');
  set usuarioId(String? value) => setField<String>('usuario_id', value);

  /// Snapshot do nome de quem importou. Ver a migration
  /// 20260921190000_auditoria_importacao_autor_snapshot.sql: um join com
  /// public.users nao serviria, porque a RLS de la e por usuario.
  String? get usuarioNome => getField<String>('usuario_nome');
  set usuarioNome(String? value) => setField<String>('usuario_nome', value);

  String? get usuarioEmail => getField<String>('usuario_email');
  set usuarioEmail(String? value) => setField<String>('usuario_email', value);

  String get entidade => getField<String>('entidade')!;
  set entidade(String value) => setField<String>('entidade', value);

  String? get entidadeDetectada => getField<String>('entidade_detectada');
  set entidadeDetectada(String? value) =>
      setField<String>('entidade_detectada', value);

  String? get nomeArquivo => getField<String>('nome_arquivo');
  set nomeArquivo(String? value) => setField<String>('nome_arquivo', value);

  int? get arquivoTamanhoBytes => getField<int>('arquivo_tamanho_bytes');
  set arquivoTamanhoBytes(int? value) =>
      setField<int>('arquivo_tamanho_bytes', value);

  String? get arquivoSha1 => getField<String>('arquivo_sha1');
  set arquivoSha1(String? value) => setField<String>('arquivo_sha1', value);

  String? get formato => getField<String>('formato');
  set formato(String? value) => setField<String>('formato', value);

  String? get delimitador => getField<String>('delimitador');
  set delimitador(String? value) => setField<String>('delimitador', value);

  String? get encodingUsado => getField<String>('encoding_usado');
  set encodingUsado(String? value) => setField<String>('encoding_usado', value);

  String? get abaUsada => getField<String>('aba_usada');
  set abaUsada(String? value) => setField<String>('aba_usada', value);

  bool get usouFallbackPosicional =>
      getField<bool>('usou_fallback_posicional')!;
  set usouFallbackPosicional(bool value) =>
      setField<bool>('usou_fallback_posicional', value);

  int get totalLinhas => getField<int>('total_linhas')!;
  set totalLinhas(int value) => setField<int>('total_linhas', value);

  int get totalBloqueantes => getField<int>('total_bloqueantes')!;
  set totalBloqueantes(int value) => setField<int>('total_bloqueantes', value);

  int get totalAvisos => getField<int>('total_avisos')!;
  set totalAvisos(int value) => setField<int>('total_avisos', value);

  int get previstosCriar => getField<int>('previstos_criar')!;
  set previstosCriar(int value) => setField<int>('previstos_criar', value);

  int get previstosAtualizar => getField<int>('previstos_atualizar')!;
  set previstosAtualizar(int value) =>
      setField<int>('previstos_atualizar', value);

  int get previstosBloquear => getField<int>('previstos_bloquear')!;
  set previstosBloquear(int value) =>
      setField<int>('previstos_bloquear', value);

  int get criados => getField<int>('criados')!;
  set criados(int value) => setField<int>('criados', value);

  int get atualizados => getField<int>('atualizados')!;
  set atualizados(int value) => setField<int>('atualizados', value);

  int get falhados => getField<int>('falhados')!;
  set falhados(int value) => setField<int>('falhados', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get decisao => getField<String>('decisao');
  set decisao(String? value) => setField<String>('decisao', value);

  String? get erro => getField<String>('erro');
  set erro(String? value) => setField<String>('erro', value);

  bool get itensTruncados => getField<bool>('itens_truncados')!;
  set itensTruncados(bool value) => setField<bool>('itens_truncados', value);

  int? get duracaoParseMs => getField<int>('duracao_parse_ms');
  set duracaoParseMs(int? value) => setField<int>('duracao_parse_ms', value);

  int? get duracaoDiagnosticoMs => getField<int>('duracao_diagnostico_ms');
  set duracaoDiagnosticoMs(int? value) =>
      setField<int>('duracao_diagnostico_ms', value);

  int? get duracaoEscritaMs => getField<int>('duracao_escrita_ms');
  set duracaoEscritaMs(int? value) =>
      setField<int>('duracao_escrita_ms', value);

  String? get appVersion => getField<String>('app_version');
  set appVersion(String? value) => setField<String>('app_version', value);

  DateTime get startedAt => getField<DateTime>('started_at')!;
  set startedAt(DateTime value) => setField<DateTime>('started_at', value);

  DateTime? get finishedAt => getField<DateTime>('finished_at');
  set finishedAt(DateTime? value) => setField<DateTime>('finished_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
