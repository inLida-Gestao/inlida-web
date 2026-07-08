DO $$
DECLARE
  def text;
BEGIN
  SELECT pg_get_functiondef('public.get_relatorio_resumo_estacao(text,text,text)'::regprocedure)
    INTO def;

  def := replace(def, 's.id_rebanho_matriz IS NOT NULL', 'nullif(btrim(s.id_rebanho_matriz), '''') IS NOT NULL');
  def := replace(def, 'n.id_rebanho_matriz IS NOT NULL', 'nullif(btrim(n.id_rebanho_matriz), '''') IS NOT NULL');

  def := replace(def, 'count(DISTINCT n.id_rebanho_matriz)::bigint AS n', 'count(DISTINCT nullif(btrim(n.id_rebanho_matriz), ''''))::bigint AS n');
  def := replace(def, 'count(DISTINCT s.id_rebanho_matriz)::bigint AS n', 'count(DISTINCT nullif(btrim(s.id_rebanho_matriz), ''''))::bigint AS n');
  def := replace(def, 'count(DISTINCT p.id_rebanho_matriz)::bigint AS n', 'count(DISTINCT nullif(btrim(p.id_rebanho_matriz), ''''))::bigint AS n');
  def := replace(def, 'SELECT count(DISTINCT id_rebanho_matriz)::bigint AS n', 'SELECT count(DISTINCT nullif(btrim(id_rebanho_matriz), ''''))::bigint AS n');

  EXECUTE def;
END $$;

COMMENT ON FUNCTION public.get_relatorio_resumo_estacao(text, text, text) IS
  'Resumo estação: matrizes distintas e diagnósticos nos mesmos registros com serviço no período (inseminação/início), incluindo linha Outras e considerando somente registros com matriz vinculada não vazia. Última DG: max(data_status) no período.';
